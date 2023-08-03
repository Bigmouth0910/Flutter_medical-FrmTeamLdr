import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/EditPreviewPhoto/ui/injectionInputDialog.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:rxphoto/screens/CPoint.dart';
import 'package:rxphoto/screens/MyCustomPainter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';

enum CanvasState { pan, draw }

enum WindowType { edit, preview }

class EditPreviewPhotoPage extends StatefulWidget {
  EditPreviewPhotoPage();
  @override
  _EditPreviewPhotoPageState createState() => _EditPreviewPhotoPageState();
  static _EditPreviewPhotoPageState of(BuildContext context) =>
      context.findAncestorStateOfType<_EditPreviewPhotoPageState>()!;
}

class _EditPreviewPhotoPageState extends State<EditPreviewPhotoPage> {
  CanvasState canvasState = CanvasState.draw;
  WindowType windowState = WindowType.preview;
  Map<String, List<CPoint>> drawPoints = Map<String, List<CPoint>>();
  ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController noteTextController = TextEditingController();

  String toolType = "hand";
  String noteContent = "";
  int currentDrawOrder = 1;
  double injectionRadius = 20.0;
  double calculatedCanvasHeight = 0;

  @override
  void dispose() {
    // AlertController().dispose();
    super.dispose();
  }

  @override
  void initState() {
    getDimensionsOfFile();
    super.initState();
  }

  void getDimensionsOfFile() async {
    final patientBloc = context.read<PatientBloc>();
    final selectedGalleryPhoto =
        patientBloc.state.galleryPatientImageDblSelected!;
    final selectedPhotoUrl = "$patientImgUrl/${selectedGalleryPhoto.photoUrl}";
    setState(() {
      noteController.text = selectedGalleryPhoto.notes ?? "";
    });

    var photoWidth = 0;
    var photoHeight = 0;
    Image image = new Image.network(selectedPhotoUrl,
        headers: {"Authorization": authString});
    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
      photoWidth = info.image.width;
      photoHeight = info.image.height;
      var pixelRatio = ui.window.devicePixelRatio;
      //Size in physical pixels
      var physicalScreenSize = ui.window.physicalSize;
      var physicalWidth = physicalScreenSize.width;
      var physicalHeight = physicalScreenSize.height;

//Size in logical pixels
      var logicalScreenSize = ui.window.physicalSize / pixelRatio;
      var logicalWidth = logicalScreenSize.width;
      var logicalHeight = logicalScreenSize.height;

//Padding in physical pixels
      var padding = ui.window.padding;

//Safe area paddings in logical pixels
      var paddingLeft = ui.window.padding.left / ui.window.devicePixelRatio;
      var paddingRight = ui.window.padding.right / ui.window.devicePixelRatio;
      var paddingTop = ui.window.padding.top / ui.window.devicePixelRatio;
      var paddingBottom = ui.window.padding.bottom / ui.window.devicePixelRatio;

//Safe area in logical pixels
      var safeWidth = logicalWidth - paddingLeft - paddingRight;
      var safeHeight = logicalHeight - paddingTop - paddingBottom;

      setState(() {
        calculatedCanvasHeight = photoHeight * 1.0 * (safeWidth / photoWidth);
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    final patientBloc = context.watch<PatientBloc>();
    final selectedPhoto = patientBloc.state.galleryPatientImageDblSelected!;
    final selectedPhotoUrl = "$patientImgUrl/${selectedPhoto.photoUrl}";

    String retakeStr = S.of(context).retake;
    String saveStr = S.of(context).save;
    String addMoreStr = S.of(context).addMore;
    String addNoteStr = S.of(context).addNote;

    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: patientBloc.state.beforeWindowType == "twogallery"
            ? FloatingActionButton(
                child: Text(canvasState == CanvasState.draw ? "Pan" : "Draw"),
                backgroundColor:
                    canvasState == CanvasState.draw ? Colors.red : Colors.blue,
                onPressed: () {
                  this.setState(() {
                    canvasState = canvasState == CanvasState.draw
                        ? CanvasState.pan
                        : CanvasState.draw;
                  });
                },
              )
            : null,
        body: Stack(
          children: [
            // Tricky for taking screenshot of whole image scrolled
            windowState == WindowType.edit
                ? SingleChildScrollView(
                    physics: canvasState == CanvasState.draw
                        ? NeverScrollableScrollPhysics()
                        : null,
                    scrollDirection: Axis.vertical,
                    child: Screenshot(
                      controller: screenshotController,
                      child: Stack(
                        children: [
                          BlocBuilder<PatientBloc, PatientState>(
                            builder: (context, state) {
                              return Container(
                                child: LayoutBuilder(
                                  builder: (context, constraints) => SizedBox(
                                    width: constraints.biggest.width,
                                    // height: calculatedCanvasHeight,
                                    // width: 200,
                                    child: CachedNetworkImage(
                                      httpHeaders: {
                                        "Authorization": authString
                                      },
                                      // width: MediaQuery.of(context).size.width,
                                      // height: MediaQuery.of(context).size.width,
                                      fit: BoxFit.fitWidth,
                                      imageUrl: selectedPhotoUrl,
                                      placeholder: (context, url) =>
                                          new CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          new Icon(Icons.error),
                                    ),
                                    // child: Image(
                                    //   fit: BoxFit.fitWidth,
                                    //   image: FileImage(takenPhoto),
                                    // ),
                                  ),
                                ),
                              );
                            },
                          ),
                          buildCurrentPath(),
                        ],
                      ),
                    ),
                  )
                : PhotoView(
                    imageProvider: NetworkImage(selectedPhotoUrl,
                        headers: {"Authorization": authString})),
            if (windowState == WindowType.edit) ...[
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  color: Colors.black.withOpacity(0.6),
                  child: Text(
                    S.of(context).notes + ':' + noteController.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              buildPaintToolbar(),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.only(top: 30, right: 20),
                  child: InkWell(
                      onTap: () {
                        int cnt = 0;
                        drawPoints.entries.forEach((element) {
                          element.value.removeWhere((d) {
                            if (d.isSelected) cnt++;
                            return d.isSelected;
                          });
                        });

                        currentDrawOrder -= cnt;

                        setState(() {});
                      },
                      child: Icon(Icons.delete,
                          size: 30, color: Colors.redAccent)),
                ),
              ),
              patientBloc.state.selectedPatientImageBodypartType
                              .toLowerCase() ==
                          "uncategorized" ||
                      patientBloc.state.photoTakingMethod == "ghost" ||
                      patientBloc.state.beforeWindowType == "singlegallery"
                  ? Container()
                  : buildNextTemplate()
            ],
          ],
        ),
        bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
              primaryColor: Colors.transparent,
              textTheme: Theme.of(context)
                  .textTheme
                  .copyWith(caption: TextStyle(color: Colors.black)),
            ),
            child: BottomNavigationBar(
              // fixedColor: Colors.white,
              onTap: (index) {
                switch (index) {
                  case 0: //Switching window Type
                    setState(() {
                      windowState = windowState == WindowType.edit
                          ? WindowType.preview
                          : WindowType.edit;
                    });
                    break;
                  // case 1: //Retake
                  //   onHandlerReTake();
                  //   break;
                  case 1: //Save
                    onHandlerToSave();
                    break;
                  // case 3: //Add more
                  //   onHandlerAddMore();
                  //   break;
                  case 2: //Add Note
                    onHandlerAddNote();
                    break;
                }
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: windowState == WindowType.edit
                        ? Icon(Icons.preview_outlined, color: Colors.white)
                        : Icon(Icons.edit, color: Colors.white),
                    label: windowState == WindowType.edit
                        ? S.of(context).preview
                        : S.of(context).edit),
                // BottomNavigationBarItem(
                //     icon: Icon(Icons.camera_alt_rounded, color: Colors.white),
                //     label: retakeStr),
                BottomNavigationBarItem(
                    icon: Icon(Icons.save_outlined, color: Colors.white),
                    label: saveStr),
                // BottomNavigationBarItem(
                //     icon: Icon(Icons.add_comment_rounded, color: Colors.white),
                //     label: addMoreStr),
                BottomNavigationBarItem(
                    icon: Icon(Icons.note_add, color: Colors.white),
                    label: addNoteStr),
              ],
              backgroundColor: Color(0xff263136),
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.white,
              type: BottomNavigationBarType.fixed,
            )));
  }

  void onHandlerToSave() async {
    final globalRepository = context.read<GlobalRepository>();
    final patientBloc = context.read<PatientBloc>();
    final selectedGalleryPhoto =
        patientBloc.state.galleryPatientImageDblSelected!;

    final captureFilePath = await CaptureScreen();
    GallerySaver.saveImage(captureFilePath).then((path) async {
      // await File(captureFilePath).delete();
    });
    var mFile = await MultipartFile.fromFile(captureFilePath,
        filename: path.basename(captureFilePath),
        contentType: MediaType("image", "jpeg"));

    var sendData = {
      "patient_id": patientBloc.state.selectedPatient!.id,
      "body_part_id": selectedGalleryPhoto.bodyPartId,
      "photo": mFile,
      "notes": noteController.text,
      "is_active": 0,
      "is_uncategorized": selectedGalleryPhoto.isUncategorized,
      'medical_history_id': patientBloc.state.curMedicalNo
    };
    context.loaderOverlay.show(widget: SavingOverlay());
    await globalRepository.addPatientImage(sendData).then((value) {
      context.loaderOverlay.hide();
      Alert(
        context: context,
        type: AlertType.success,
        title: S.of(context).uploadAlertTitle,
        desc: S.of(context).uploadAlertContent,
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              // patientBloc.add(PatientImageUpdateRequested());
              patientBloc.add(PatientGalleryDataRequested(""));
              Navigator.pop(context);
              Navigator.pop(context);
            },
            width: 120,
          )
        ],
      ).show();
    });
  }

  Future<void> takePicture() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Images';
  }

  void onHandlerReTake() {
    Navigator.pushReplacementNamed(context, Routes.CAMERA_PAGE);
  }

  void onHandlerAddMore() async {
    final globalRepository = context.read<GlobalRepository>();
    final patientBloc = context.read<PatientBloc>();

    final captureFilePath = await CaptureScreen();
    GallerySaver.saveImage(captureFilePath).then((path) async {
      // await File(captureFilePath).delete();
    });
    var mFile = await MultipartFile.fromFile(captureFilePath,
        filename: path.basename(captureFilePath),
        contentType: MediaType("image", "jpeg"));
    var sendData = {
      "patient_id": patientBloc.state.selectedPatient!.id,
      "body_part_id": patientBloc
          .state.bodyparts[patientBloc.state.selectedBodyPartOrder!].id,
      "photo": mFile,
      "notes": noteController.text,
      "is_active": 0,
      'medical_history_id': patientBloc.state.curMedicalNo
    };
    context.loaderOverlay.show(widget: SavingOverlay());
    await globalRepository.addPatientImage(sendData).then((value) {
      context.loaderOverlay.hide();
      Alert(
        context: context,
        type: AlertType.success,
        title: S.of(context).uploadSuccess,
        desc: S.of(context).uploadSuccessDesc,
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              patientBloc.add(PatientImageUpdateRequested());
              Navigator.pushReplacementNamed(context, Routes.CAMERA_PAGE);
            },
            width: 120,
          )
        ],
      ).show();
    });
  }

  Widget buildNextTemplate() {
    return Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () async {
            final globalRepository = context.read<GlobalRepository>();
            final patientBloc = context.read<PatientBloc>();

            final captureFilePath = await CaptureScreen();
            var mFile = await MultipartFile.fromFile(captureFilePath,
                filename: path.basename(captureFilePath),
                contentType: MediaType("image", "jpeg"));

            var currentBodypart = patientBloc.state.bodyparts
                .where((element) =>
                    element.partsFor ==
                    patientBloc.state.selectedBodyPartGroup!)
                .toList();
            var bodyPartId =
                currentBodypart[patientBloc.state.selectedBodyPartOrder!].id;
            var sendData = {
              "patient_id": patientBloc.state.selectedPatient!.id,
              "body_part_id": bodyPartId,
              "photo": mFile,
              "notes": noteController.text,
              "is_active": 0,
              'medical_history_id': patientBloc.state.curMedicalNo
            };
            context.loaderOverlay.show(widget: SavingOverlay());
            await globalRepository.addPatientImage(sendData).then((value) {
              context.loaderOverlay.hide();
              Alert(
                context: context,
                type: AlertType.success,
                title: S.of(context).uploadSuccess,
                desc: S.of(context).uploadSuccessDesc,
                buttons: [
                  DialogButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (patientBloc.state.selectedBodyPartOrder! + 2 <=
                          patientBloc.state.selectedBodyPartLength!) {
                        patientBloc.add(PatientSelectNextOrder());
                        patientBloc.add(PatientImageUpdateRequested());
                        Navigator.pushReplacementNamed(
                            context, Routes.CAMERA_PAGE);
                      } else {
                        patientBloc.add(PatientImageUpdateRequested());
                        Navigator.pushReplacementNamed(
                            context, Routes.PATIENT_DETAIL_PAGE);
                      }
                    },
                    width: 120,
                  )
                ],
              ).show();
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
            child:
                Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 40),
            alignment: Alignment.center,
          ),
        ));
  }

  void onHandlerAddNote() {
    Alert(
        context: context,
        title: S.of(context).notes,
        content: Column(
          children: <Widget>[
            TextField(
              controller: noteController,
              maxLines: 5,
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: S.of(context).addNote,
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: Color(0xffF4568C),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              S.of(context).add,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void saveButton() {
    // var crypt = AesCrypt('my cool password');
    // crypt.setOverwriteMode(AesCryptOwMode.on);
    // var encFilepath = crypt.encryptFileSync(file.path);
    // print('Encrypted file: $encFilepath');
  }

  Future<String> CaptureScreen() async {
    // var container = Container(
    //     padding: const EdgeInsets.all(30.0),
    //     decoration: BoxDecoration(
    //       border: Border.all(color: Colors.blueAccent, width: 5.0),
    //       color: Colors.redAccent,
    //     ),
    //     child: Text(
    //       "This is an invisible widget",
    //       style: Theme.of(context).textTheme.headline6,
    //     ));
    // screenshotController
    //     .captureFromWidget(
    //         InheritedTheme.captureAll(context, Material(child: container)),
    //         delay: Duration(seconds: 1))
    //     .then((capturedImage) {

    // });

    final path = await screenshotController
        .capture(pixelRatio: 1.0)
        .then((Uint8List? image) async {
      if (image != null) {
        // final directory = await getApplicationDocumentsDirectory();
        final directory = await getExternalStorageDirectory();
        final imagePath = await File('${directory!.path}/rxphoto_' +
                DateTime.now().millisecondsSinceEpoch.toString() +
                '.png')
            .create();
        try {
          final path = await imagePath.writeAsBytes(image).then((result) {
            print("Capture Image Path: ${result.path}");
            return result.path;
          });
          return path;
        } catch (e) {
          return "";
        }
      }
    }).catchError((onError) {
      print(onError);
    });
    return path ?? "";
  }

  Future<String> SaveImage(Uint8List? image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = await File('${directory.path}/image.png').create();
    try {
      await imagePath.writeAsBytes(image!).then((result) {
        print("Capture Image Path: ${result.path}");

        return result;
      });
    } catch (e) {
      return "";
    }
    return "";
  }

  GestureDetector buildCurrentPath() {
    double distance(Offset a, Offset b) {
      return sqrt(pow((a.dx - b.dx), 2) + pow((a.dy - b.dy), 2));
    }

    return GestureDetector(
      // onTapDown: (TapDownDetails details) {
      //   final box = context.findRenderObject() as RenderBox;
      //   // final point = box.globalToLocal(details.globalPosition);
      //   final point = box.globalToLocal(details.localPosition);
      //   if (toolType == "text") {
      //     noteTextController.text = "";
      //     Alert(
      //         context: context,
      //         title: "Add Text",
      //         content: Column(
      //           children: <Widget>[
      //             TextField(
      //               controller: noteTextController,
      //               decoration: InputDecoration(
      //                 icon: Icon(Icons.account_circle),
      //                 labelText: 'Text',
      //               ),
      //             ),
      //           ],
      //         ),
      //         buttons: [
      //           DialogButton(
      //             onPressed: () {
      //               if (drawPoints[toolType] == null)
      //                 drawPoints[toolType] = [
      //                   CPoint(
      //                       start: point,
      //                       end: Offset(0, 0),
      //                       content: noteTextController.text,
      //                       order: currentDrawOrder++)
      //                 ];
      //               else
      //                 drawPoints[toolType]!.add(CPoint(
      //                     start: point,
      //                     end: Offset(0, 0),
      //                     content: noteTextController.text,
      //                     order: currentDrawOrder++));
      //               Navigator.pop(context);
      //             },
      //             child: Text(
      //               "Add Text",
      //               style: TextStyle(color: Colors.white, fontSize: 20),
      //             ),
      //           ),
      //           DialogButton(
      //             onPressed: () {
      //               Navigator.pop(context);
      //             },
      //             child: Text(
      //               "Cancel",
      //               style: TextStyle(color: Colors.white, fontSize: 20),
      //             ),
      //           )
      //         ]).show();
      //   } else if (toolType == "injection") {
      //     var foundIndex = -1;
      //     var foundInjectionValue = "";
      //     drawPoints.entries.forEach((element) {
      //       for (CPoint value in element.value) {
      //         if (element.key == "injection") {
      //           if (sqrt(pow((point.dx - value.start.dx), 2) +
      //                   pow((point.dy - value.start.dy), 2)) <=
      //               injectionRadius + 10) {
      //             foundIndex = element.value.indexOf(value);
      //             foundInjectionValue = value.content;
      //           }
      //         }
      //       }
      //     });
      //     var oldInjectionType = "";
      //     if (drawPoints[toolType] != null && foundIndex != -1)
      //       oldInjectionType =
      //           drawPoints[toolType]![foundIndex].injectionType!;
      //     showDialog(
      //         context: context,
      //         builder: (BuildContext context) => InjectionInputDialog(
      //               foundInjectionValue: foundInjectionValue,
      //               oldInjectionType: oldInjectionType,
      //               callback: (val, injectionType) {
      //                 if (drawPoints[toolType] == null)
      //                   setState(() {
      //                     drawPoints[toolType] = [
      //                       CPoint(
      //                           start: point,
      //                           end: Offset(0, 0),
      //                           content: val,
      //                           injectionType: injectionType,
      //                           order: currentDrawOrder++)
      //                     ];
      //                   });
      //                 else
      //                   setState(() {
      //                     if (foundIndex == -1)
      //                       drawPoints[toolType]!.add(CPoint(
      //                           start: point,
      //                           end: Offset(0, 0),
      //                           content: val,
      //                           injectionType: injectionType,
      //                           order: currentDrawOrder++));
      //                     else
      //                       drawPoints[toolType]![foundIndex] = CPoint(
      //                           start: drawPoints[toolType]![foundIndex]
      //                               .start,
      //                           end: Offset(0, 0),
      //                           content: val,
      //                           injectionType: injectionType,
      //                           order: drawPoints[toolType]![foundIndex]
      //                               .order);
      //                   });
      //               },
      //             ));
      //   }
      // },
      onPanStart: (DragStartDetails details) {
        final box = context.findRenderObject() as RenderBox;
        // final point = box.globalToLocal(details.globalPosition);
        final point = box.globalToLocal(details.localPosition);
        // Offset offset = Offset(dx, dy);

        double cx, cy, tx, ty, xR, yR = 0.0;

        setState(() {
          if (toolType == "hand") {
            drawPoints.entries.forEach((element) {
              for (CPoint value in element.value) {
                if (element.key == "oval") {
                  cx = (value.start.dx + value.end.dx) / 2;
                  cy = (value.start.dy + value.end.dy) / 2;
                  xR = (value.start.dx - value.end.dx).abs() / 2;
                  yR = (value.start.dy - value.end.dy).abs() / 2;
                  tx = point.dx - cx;
                  ty = point.dy - cy;
                  value.isSelected =
                      ((tx * tx) / (xR * xR) + (ty * ty) / (yR * yR)) <= 1.0;
                }
                // else if (element.key == "pencil") {
                //   value.isSelected = (distance(point, value.start) +
                //               distance(point, value.end) -
                //               distance(value.start, value.end))
                //           .abs() <
                //       3;
                // }
                else if (element.key == "text") {
                  value.isSelected = point.dx >= value.start.dx - 30 &&
                      point.dx <= value.start.dx + 100 &&
                      point.dy >= value.start.dy - 30 &&
                      point.dy <= value.start.dy + 30;
                } else if (element.key == "more" || element.key == "pencil") {
                  if (value.pathPoints!.length != 0) {
                    final maxXValue = value.pathPoints!
                        .reduce((curr, next) => curr.dx > next.dx ? curr : next)
                        .dx;
                    final minXValue = value.pathPoints!
                        .reduce((curr, next) => curr.dx < next.dx ? curr : next)
                        .dx;
                    final maxYValue = value.pathPoints!
                        .reduce((curr, next) => curr.dy > next.dy ? curr : next)
                        .dy;
                    final minYValue = value.pathPoints!
                        .reduce((curr, next) => curr.dy < next.dy ? curr : next)
                        .dy;
                    value.isSelected = point.dx >= minXValue - 30 &&
                        point.dx <= maxXValue + 30 &&
                        point.dy >= minYValue - 30 &&
                        point.dy <= maxYValue + 30;
                  }
                } else if (element.key == "injection") {
                  value.isSelected = sqrt(pow((point.dx - value.start.dx), 2) +
                          pow((point.dy - value.start.dy), 2)) <=
                      injectionRadius + 10;
                }
              }
            });
          } else if (toolType == "text") {
            noteTextController.text = "";
            Alert(
                style:
                    AlertStyle(titleStyle: TextStyle(color: Color(0xffF4568C))),
                context: context,
                title: "Add Text",
                content: Column(
                  children: <Widget>[
                    TextField(
                      controller: noteTextController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.account_circle),
                        labelText: 'Text',
                      ),
                    ),
                  ],
                ),
                buttons: [
                  DialogButton(
                    color: Color(0xffF4568C),
                    onPressed: () {
                      if (drawPoints[toolType] == null)
                        drawPoints[toolType] = [
                          CPoint(
                              start: point,
                              end: Offset(0, 0),
                              content: noteTextController.text,
                              order: currentDrawOrder++)
                        ];
                      else
                        drawPoints[toolType]!.add(CPoint(
                            start: point,
                            end: Offset(0, 0),
                            content: noteTextController.text,
                            order: currentDrawOrder++));
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Add Text",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  DialogButton(
                    color: Color(0xffF4568C),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]).show();
          } else if (toolType == "injection") {
            var foundIndex = -1;
            var foundInjectionValue = "";
            drawPoints.entries.forEach((element) {
              for (CPoint value in element.value) {
                if (element.key == "injection") {
                  if (sqrt(pow((point.dx - value.start.dx), 2) +
                          pow((point.dy - value.start.dy), 2)) <=
                      injectionRadius + 10) {
                    foundIndex = element.value.indexOf(value);
                    foundInjectionValue = value.content;
                  }
                }
              }
            });
            var oldInjectionType = "";
            if (drawPoints[toolType] != null && foundIndex != -1)
              oldInjectionType =
                  drawPoints[toolType]![foundIndex].injectionType!;
            showDialog(
                context: context,
                builder: (BuildContext context) => InjectionInputDialog(
                      foundInjectionValue: foundInjectionValue,
                      oldInjectionType: oldInjectionType,
                      callback: (val, injectionType) {
                        if (drawPoints[toolType] == null)
                          setState(() {
                            drawPoints[toolType] = [
                              CPoint(
                                  start: point,
                                  end: Offset(0, 0),
                                  content: val,
                                  injectionType: injectionType,
                                  order: currentDrawOrder++)
                            ];
                          });
                        else
                          setState(() {
                            if (foundIndex == -1)
                              drawPoints[toolType]!.add(CPoint(
                                  start: point,
                                  end: Offset(0, 0),
                                  content: val,
                                  injectionType: injectionType,
                                  order: currentDrawOrder++));
                            else
                              drawPoints[toolType]![foundIndex] = CPoint(
                                  start:
                                      drawPoints[toolType]![foundIndex].start,
                                  end: Offset(0, 0),
                                  content: val,
                                  injectionType: injectionType,
                                  order:
                                      drawPoints[toolType]![foundIndex].order);
                          });
                      },
                    ));
          } else {
            if (drawPoints[toolType] == null)
              drawPoints[toolType] = [
                CPoint(
                    start: point,
                    end: point,
                    content: "",
                    order: currentDrawOrder++)
              ];
            else
              drawPoints[toolType]!.add(CPoint(
                  start: point,
                  end: point,
                  content: "",
                  order: currentDrawOrder++));
          }
        });
      },
      onPanUpdate: (DragUpdateDetails details) {
        final box = context.findRenderObject() as RenderBox;
        final point = box.globalToLocal(details.localPosition);
        // final point = box.globalToLocal(details.globalPosition);
        setState(() {
          if (toolType == "hand") {
            drawPoints.entries.forEach((element) {
              for (CPoint value in element.value) {
                if (value.isSelected == true) {
                  final deltaPoint = box.globalToLocal(details.delta);
                  value.start += deltaPoint;
                  value.end += deltaPoint;
                  if (element.key == "more" || element.key == "pencil") {
                    for (var i = 0; i < value.pathPoints!.length; i++) {
                      value.pathPoints![i] += deltaPoint;
                    }
                  }
                }
              }
            });
          } else {
            if (drawPoints[toolType] != null) {
              if (toolType == 'more' || toolType == "pencil") {
                drawPoints[toolType]![drawPoints[toolType]!.length - 1]
                    .pathPoints!
                    .add(point);
              } else if (toolType != "injection") {
                drawPoints[toolType]![drawPoints[toolType]!.length - 1].end =
                    point;
              }
            }
          }
        });
      },
      onPanEnd: (DragEndDetails details) {
        setState(() {
          if (toolType != 'hand') {
            drawPoints.entries.forEach((element) {
              for (CPoint value in element.value) {
                value.isSelected = false;
              }
            });
          }
        });
      },
      child: RepaintBoundary(
        child: Container(
            // padding: EdgeInsets.fromLTRB(
            //     padding.left, padding.top, padding.right, padding.bottom),
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: calculatedCanvasHeight,
            child: CustomPaint(
                painter: MyCustomPainter(
                    drawPoints: drawPoints,
                    toolType: toolType,
                    injectionRadius: injectionRadius),
                size: Size.infinite)),
      ),
    );
  }

  Widget buildPaintToolbar() {
    return Positioned(
      left: 0,
      top: 70,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 10),
            decoration: BoxDecoration(
                color: toolType == 'hand'
                    ? Colors.white
                    : ui.Color.fromARGB(200, 0, 0, 0),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 2)),
            child: IconButton(
              onPressed: () {
                setState(() {
                  toolType = 'hand';
                });
              },
              icon: Icon(
                Icons.pan_tool,
                color: toolType == 'hand' ? Colors.black : Colors.white,
              ),
              iconSize: 30,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 10),
            decoration: BoxDecoration(
                color: toolType == 'pencil'
                    ? Colors.white
                    : ui.Color.fromARGB(200, 0, 0, 0),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 2)),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    toolType = 'pencil';
                  });
                },
                icon: Icon(Icons.edit,
                    color: toolType == 'pencil' ? Colors.black : Colors.white),
                iconSize: 30.0),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 10),
            decoration: BoxDecoration(
                color: toolType == 'injection'
                    ? Colors.white
                    : ui.Color.fromARGB(200, 0, 0, 0),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 2)),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    toolType = 'injection';
                  });
                },
                icon: Icon(Icons.chat_bubble_rounded,
                    color:
                        toolType == 'injection' ? Colors.black : Colors.white),
                iconSize: 30.0),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 10),
            decoration: BoxDecoration(
                color: toolType == 'text'
                    ? Colors.white
                    : ui.Color.fromARGB(200, 0, 0, 0),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 2)),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    toolType = 'text';
                  });
                },
                icon: Icon(Icons.text_fields_outlined,
                    color: toolType == 'text' ? Colors.black : Colors.white),
                iconSize: 30.0),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 10),
            decoration: BoxDecoration(
                color: toolType == 'more'
                    ? Colors.white
                    : ui.Color.fromARGB(200, 0, 0, 0),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 2)),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    toolType = 'more';
                  });
                },
                icon: Icon(Icons.more_horiz,
                    color: toolType == 'more' ? Colors.black : Colors.white),
                iconSize: 30.0),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 10),
            decoration: BoxDecoration(
                color: toolType == 'oval'
                    ? Colors.white
                    : ui.Color.fromARGB(200, 0, 0, 0),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 2)),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    toolType = 'oval';
                  });
                },
                icon: Icon(Icons.circle_outlined,
                    color: toolType == 'oval' ? Colors.black : Colors.white),
                iconSize: 30.0),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 0, left: 10),
            decoration: BoxDecoration(
                color: toolType == 'undo'
                    ? Colors.white
                    : ui.Color.fromARGB(200, 0, 0, 0),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white, width: 2)),
            child: IconButton(
                onPressed: () {
                  currentDrawOrder -= 1;
                  drawPoints.entries.forEach((element) {
                    element.value
                        .removeWhere((d) => d.order == currentDrawOrder);
                  });
                  setState(() {
                    toolType = 'undo';
                  });
                },
                icon: Icon(Icons.undo,
                    color: toolType == 'undo' ? Colors.black : Colors.white),
                iconSize: 30.0),
          ),
        ],
      ),
    );
  }
}

class SavingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 12),
            Text(
              'Saving...',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}
