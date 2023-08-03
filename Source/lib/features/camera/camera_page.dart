import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/features/patientDetail/bloc/patientdetail_bloc.dart';
import 'package:rxphoto/screens/preview_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';

import 'package:loader_overlay/loader_overlay.dart';
import '../../main.dart';

class CameraPage extends StatefulWidget {
  CameraPage();
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? controller;
  double scale = 1.0;

  File? _imageFile;
  File? _videoFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableOpacityOffset = 0.0;
  double _maxAvailableOpacityOffset = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  //ghost functionality variables
  int currentBodypartImageIndex = 0;
  bool isGhost = false;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  double _currentOpacityOffset = 0.8;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.medium;

  late PatientdetailBloc _patientDetailBloc;

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
        // _startVideoPlayer();
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
        _videoFile = null;
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    // final deviceRatio = size.width / size.height;

    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
        cameraDescription, currentResolutionPreset,
        imageFormatGroup: ImageFormatGroup.jpeg, enableAudio: false);

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted)
        setState(() {
          final size = MediaQuery.of(context).size;
          scale = size.aspectRatio * controller!.value.aspectRatio;
          if (scale < 1) scale = 1 / scale;
        });
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
      controller?.dispose();
      Navigator.pop(context);
    }

    if (mounted) {
      // updated by me ----
      _currentFlashMode = FlashMode.off;
      await controller!.setFlashMode(
        FlashMode.off,
      );
      // updated by me ----
      setState(() {
        // _isCameraInitialized = controller!.value.isInitialized;
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void initState() {
    // Hide the status bar in Android
    // SystemChrome.setEnabledSystemUIOverlays([]);
    // Set and initialize the new camera

    WidgetsBinding.instance.addObserver(this);

    onNewCameraSelected(cameras[0]);
    // uncomment later
    refreshAlreadyCapturedImages();
    final patientBloc = context.read<PatientBloc>();
    setState(() {
      isGhost = patientBloc.state.photoTakingMethod == "ghost" ? true : false;
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientBloc = context.watch<PatientBloc>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isCameraInitialized
            ? Stack(children: [
                Transform.scale(
                  scale: scale,
                  child: Center(child: CameraPreview(controller!)),
                ),
                BlocBuilder<PatientBloc, PatientState>(
                  builder: (context, state) {
                    return Align(
                      alignment: Alignment.center,
                      child: patientBloc.state.photoTakingMethod == "template"
                          ? Opacity(
                              opacity: 0.3,
                              child: state.bodyparts
                                          .where((element) =>
                                              element.partsFor ==
                                              state.selectedBodyPartGroup)
                                          .toList()[
                                              state.selectedBodyPartOrder!]
                                          .templateImagePath !=
                                      null
                                  ? Image.network("$templateUrl/${state.bodyparts.where((element) => element.partsFor == state.selectedBodyPartGroup).toList()[state.selectedBodyPartOrder!].templateImagePath}",
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover)
                                  : Container()
                              // child: Image.asset(
                              //   'assets/images/template.png',
                              //   width: 340.0,
                              //   height: 350.0,
                              // ),
                              )
                          : Opacity(
                              opacity: _currentOpacityOffset,
                              child: state.selectedPatientBodypartImages.length != 0 &&
                                      state
                                              .selectedPatientBodypartImages[
                                                  patientBloc.state.selectedGhostOrder!]
                                              .photoUrl !=
                                          null
                                  ? Image.network("$patientImgUrl/${state.selectedPatientBodypartImages[patientBloc.state.selectedGhostOrder!].photoUrl}",
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      headers: {
                                        "Authorization": authString,
                                        "Access-Control-Allow-Headers":
                                            "Access-Control-Allow-Origin, Accept"
                                      },
                                      fit: BoxFit.cover)
                                  : Container()),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    8.0,
                    16.0,
                    8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Container(
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(10.0),
                            //   ),
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: Text(
                            //       'Ghost',
                            //       style: TextStyle(color: Colors.black),
                            //     ),
                            //   ),
                            // ),
                            Switch(
                              onChanged: (val) {
                                setState(() {
                                  isGhost = val;
                                });
                                patientBloc.add(
                                    PatientPhotoTakingMethodSelected(
                                        val == true ? "ghost" : "template"));
                              },
                              value: isGhost,
                              activeColor: Colors.blue,
                              activeTrackColor: Colors.yellow,
                              inactiveThumbColor: Colors.blue,
                              inactiveTrackColor: Colors.yellow,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                ),
                                child: DropdownButton<ResolutionPreset>(
                                  dropdownColor: Colors.black87,
                                  underline: Container(),
                                  value: currentResolutionPreset,
                                  items: [
                                    for (ResolutionPreset preset
                                        in resolutionPresets)
                                      DropdownMenuItem(
                                        child: Text(
                                          preset
                                              .toString()
                                              .split('.')[1]
                                              .toUpperCase(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        value: preset,
                                      )
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      currentResolutionPreset = value!;
                                      _isCameraInitialized = false;
                                    });
                                    onNewCameraSelected(
                                        controller!.description);
                                  },
                                  hint: Text("Select item"),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      // Spacer(),
                      Row(
                          mainAxisAlignment:
                              patientBloc.state.photoTakingMethod == "template"
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.spaceBetween,
                          children: [
                            if (patientBloc.state.photoTakingMethod == "ghost")
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, top: 16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          _currentOpacityOffset
                                                  .toStringAsFixed(1) +
                                              'x',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 300,
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: Container(
                                        height: 30,
                                        child: Slider(
                                          value: _currentOpacityOffset,
                                          min: _minAvailableOpacityOffset,
                                          max: _maxAvailableOpacityOffset,
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.white30,
                                          onChanged: (value) async {
                                            setState(() {
                                              _currentOpacityOffset = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0, top: 16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _currentExposureOffset
                                                .toStringAsFixed(1) +
                                            'x',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 300,
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Container(
                                      height: 30,
                                      child: Slider(
                                        value: _currentExposureOffset,
                                        min: _minAvailableExposureOffset,
                                        max: _maxAvailableExposureOffset,
                                        activeColor: Colors.white,
                                        inactiveColor: Colors.white30,
                                        onChanged: (value) async {
                                          setState(() {
                                            _currentExposureOffset = value;
                                          });
                                          await controller!
                                              .setExposureOffset(value);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    ],
                  ),
                ),
                if (patientBloc.state.photoTakingMethod == "ghost" &&
                    patientBloc.state.selectedGhostOrder! > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          patientBloc.add(PatientGhostOrderBackward());
                          // currentBodypartImageIndex--;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 5),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(Icons.keyboard_arrow_left,
                            color: Colors.black, size: 40),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                if (patientBloc.state.photoTakingMethod == "ghost" &&
                    patientBloc.state.selectedPatientBodypartImages.length - 1 >
                        patientBloc.state.selectedGhostOrder!)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          patientBloc.add(PatientGhostOrderForward());
                          // currentBodypartImageIndex++;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 5),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(Icons.keyboard_arrow_right,
                            color: Colors.black, size: 40),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      color: Colors.white.withOpacity(0.1),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _currentZoomLevel,
                                  min: _minAvailableZoom,
                                  max: _maxAvailableZoom,
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white30,
                                  onChanged: (value) async {
                                    setState(() {
                                      _currentZoomLevel = value;
                                    });
                                    await controller!.setZoomLevel(value);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _currentZoomLevel.toStringAsFixed(1) +
                                          'x',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  patientBloc.add(PatientDataRequested());
                                  Navigator.of(context).pop();
                                },
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 40),
                              ),
                              InkWell(
                                onTap: _isRecordingInProgress
                                    ? () async {
                                        if (controller!
                                            .value.isRecordingPaused) {
                                          await resumeVideoRecording();
                                        } else {
                                          await pauseVideoRecording();
                                        }
                                      }
                                    : () {
                                        setState(() {
                                          _isCameraInitialized = false;
                                        });
                                        onNewCameraSelected(cameras[
                                            _isRearCameraSelected ? 1 : 0]);
                                        setState(() {
                                          _isRearCameraSelected =
                                              !_isRearCameraSelected;
                                        });
                                      },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.black38,
                                      size: 60,
                                    ),
                                    _isRecordingInProgress
                                        ? controller!.value.isRecordingPaused
                                            ? Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                            : Icon(
                                                Icons.pause,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                        : Icon(
                                            _isRearCameraSelected
                                                ? Icons.camera_front
                                                : Icons.camera_rear,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: _isVideoCameraSelected
                                    ? () async {
                                        if (_isRecordingInProgress) {
                                          XFile? rawVideo =
                                              await stopVideoRecording();
                                          File videoFile = File(rawVideo!.path);

                                          int currentUnix = DateTime.now()
                                              .millisecondsSinceEpoch;

                                          final directory =
                                              await getApplicationDocumentsDirectory();

                                          String fileFormat =
                                              videoFile.path.split('.').last;

                                          _videoFile = await videoFile.copy(
                                            '${directory.path}/$currentUnix.$fileFormat',
                                          );

                                          // _startVideoPlayer();
                                        } else {
                                          await startVideoRecording();
                                        }
                                      }
                                    : () async {
                                        context.loaderOverlay.show();
                                        try {
                                          XFile? rawImage = await takePicture();
                                          File imageFile = File(rawImage!.path);
                                          int currentUnix = DateTime.now()
                                              .millisecondsSinceEpoch;
                                          final directory =
                                              await getApplicationDocumentsDirectory();
                                          String fileFormat =
                                              imageFile.path.split('.').last;
                                          print(fileFormat);
                                          // await imageFile.copy(
                                          //   '${directory.path}/$currentUnix.$fileFormat',
                                          // );
                                          // await uploadFileToServer(
                                          //     '${directory.path}/$currentUnix.$fileFormat');
                                          // GallerySaver.saveImage(imageFile.path)
                                          //     .then((path1) async {
                                          //   // await File(captureFilePath).delete();
                                          // });
                                          refreshAlreadyCapturedImages();
                                          patientBloc.add(
                                              PatientPhotoTaken(imageFile));
                                          patientBloc.add(
                                              BeforeWindowTypeChanged(
                                                  "camera"));
                                          context.loaderOverlay.hide();
                                        } catch (e) {
                                          context.loaderOverlay.hide();
                                        }
                                        Navigator.pushReplacementNamed(
                                            context, Routes.EDITCAMERA_PAGE);
                                      },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: _isVideoCameraSelected
                                          ? Colors.white
                                          : Colors.white38,
                                      size: 80,
                                    ),
                                    Icon(
                                      Icons.circle,
                                      color: _isVideoCameraSelected
                                          ? Colors.red
                                          : Colors.white,
                                      size: 65,
                                    ),
                                    _isVideoCameraSelected &&
                                            _isRecordingInProgress
                                        ? Icon(
                                            Icons.stop_rounded,
                                            color: Colors.white,
                                            size: 32,
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: _imageFile != null || _videoFile != null
                                    ? () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => PreviewScreen(
                                              imageFile: _imageFile!,
                                              fileList: allFileList,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: BlocBuilder<PatientBloc, PatientState>(
                                    builder: (context, state) {
                                  return InkWell(
                                    onTap: () {
                                      if (state.photoTakingMethod == "ghost") {
                                        Navigator.of(context).pushNamed(
                                            Routes.SELECT_GHOST_PAGE);
                                      }
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        image: patientBloc
                                                    .state.photoTakingMethod ==
                                                "template"
                                            ? (state.bodyparts
                                                        .where((element) =>
                                                            element.partsFor ==
                                                            state
                                                                .selectedBodyPartGroup)
                                                        .toList()[state
                                                            .selectedBodyPartOrder!]
                                                        .photoImagePath !=
                                                    null
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                        "$bodyPartUrl/${state.bodyparts.where((element) => element.partsFor == state.selectedBodyPartGroup).toList()[state.selectedBodyPartOrder!].photoImagePath}"),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null)
                                            : (state.selectedPatientBodypartImages
                                                            .length !=
                                                        0 &&
                                                    state
                                                            .selectedPatientBodypartImages[
                                                                patientBloc
                                                                    .state
                                                                    .selectedGhostOrder!]
                                                            .photoUrl !=
                                                        null
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                        "$patientImgUrl/${state.selectedPatientBodypartImages[patientBloc.state.selectedGhostOrder!].photoUrl}",
                                                        headers: {
                                                          "Authorization":
                                                              authString,
                                                          "Access-Control-Allow-Headers":
                                                              "Access-Control-Allow-Origin, Accept"
                                                        }),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null),
                                      ),
                                      //   child:
                                      //       // videoController != null &&
                                      //       //         videoController!
                                      //       //             .value.isInitialized
                                      //       //     ? ClipRRect(
                                      //       //         borderRadius:
                                      //       //             BorderRadius.circular(8.0),
                                      //       //         child: AspectRatio(
                                      //       //           aspectRatio: videoController!
                                      //       //               .value.aspectRatio,
                                      //       //           child: VideoPlayer(
                                      //       //               videoController!),
                                      //       //         ),
                                      //       //       )
                                      //       //     :
                                      //       Container(),
                                      // );
                                    ),
                                  );
                                }),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    _currentFlashMode = FlashMode.off;
                                  });
                                  await controller!.setFlashMode(
                                    FlashMode.off,
                                  );
                                },
                                child: Icon(
                                  Icons.flash_off,
                                  color: _currentFlashMode == FlashMode.off
                                      ? Colors.amber
                                      : Colors.white,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    _currentFlashMode = FlashMode.auto;
                                  });
                                  await controller!.setFlashMode(
                                    FlashMode.auto,
                                  );
                                },
                                child: Icon(
                                  Icons.flash_auto,
                                  color: _currentFlashMode == FlashMode.auto
                                      ? Colors.amber
                                      : Colors.white,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    _currentFlashMode = FlashMode.always;
                                  });
                                  await controller!.setFlashMode(
                                    FlashMode.always,
                                  );
                                },
                                child: Icon(
                                  Icons.flash_on,
                                  color: _currentFlashMode == FlashMode.always
                                      ? Colors.amber
                                      : Colors.white,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    _currentFlashMode = FlashMode.torch;
                                  });
                                  await controller!.setFlashMode(
                                    FlashMode.torch,
                                  );
                                },
                                child: Icon(
                                  Icons.highlight,
                                  color: _currentFlashMode == FlashMode.torch
                                      ? Colors.amber
                                      : Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                )
              ])
            : Center(
                child: Text(
                  'LOADING...',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
