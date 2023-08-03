import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/editCameraImage/ui/injectionInputDialog.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/features/patient/ui/patient_page.dart';
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
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';

enum CanvasState { pan, draw }

enum WindowType { edit, preview }

class EditHomeCameraPage extends StatefulWidget {
  EditHomeCameraPage();
  @override
  _EditHomeCameraPageState createState() => _EditHomeCameraPageState();
  static _EditHomeCameraPageState of(BuildContext context) =>
      context.findAncestorStateOfType<_EditHomeCameraPageState>()!;
}

class _EditHomeCameraPageState extends State<EditHomeCameraPage> {
  CanvasState canvasState = CanvasState.draw;
  WindowType windowState = WindowType.edit;
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
    final takenPhoto = patientBloc.state.takenPhoto!;
    var decodedImage = await decodeImageFromList(takenPhoto.readAsBytesSync());

    print(decodedImage.width);
    print(decodedImage.height);
    var pixelRatio = window.devicePixelRatio;
    //Size in physical pixels
    var physicalScreenSize = window.physicalSize;
    var physicalWidth = physicalScreenSize.width;
    var physicalHeight = physicalScreenSize.height;

//Size in logical pixels
    var logicalScreenSize = window.physicalSize / pixelRatio;
    var logicalWidth = logicalScreenSize.width;
    var logicalHeight = logicalScreenSize.height;

//Padding in physical pixels
    var padding = window.padding;

//Safe area paddings in logical pixels
    var paddingLeft = window.padding.left / window.devicePixelRatio;
    var paddingRight = window.padding.right / window.devicePixelRatio;
    var paddingTop = window.padding.top / window.devicePixelRatio;
    var paddingBottom = window.padding.bottom / window.devicePixelRatio;

//Safe area in logical pixels
    var safeWidth = logicalWidth - paddingLeft - paddingRight;
    var safeHeight = logicalHeight - paddingTop - paddingBottom;

    setState(() {
      calculatedCanvasHeight =
          decodedImage.height * (safeWidth / decodedImage.width);
    });
  }

  bool checkIfChanged() {
    bool isChanged = false;

    drawPoints.forEach((key, value) {
      if (key == 'undo') return;

      if (value.length != 0) {
        isChanged = true;
      }
    });

    return isChanged;
  }

  void savePhoto() async {
    final patientBloc = context.read<PatientBloc>();
    final takenPhoto = patientBloc.state.takenPhoto!;

    final captureFilePath = await CaptureScreen();

    if (checkIfChanged() == true) {
      await GallerySaver.saveImage(captureFilePath);
    }

    if (patientBloc.state.takenPhoto != null) {
      GallerySaver.saveImage(takenPhoto.path).then((path) async {});
    }

    AlertController.show(
        S.current.saveSuccess, S.current.saveSuccessDesc, TypeAlert.success);
  }

  @override
  Widget build(BuildContext context) {
    final patientBloc = context.watch<PatientBloc>();
    final takenPhoto = patientBloc.state.takenPhoto!;

    developer.log(drawPoints.toString());

    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.1),
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
            Center(
                child: SingleChildScrollView(
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
                              child: Image(
                                fit: BoxFit.fitWidth,
                                image: FileImage(takenPhoto),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    buildCurrentPath(),
                  ],
                ),
              ),
            )),
            ...[buildPaintToolbar(), buildNextTemplate()],
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
              onTap: (index) async {
                switch (index) {
                  case 0: //Switching window Type
                    Navigator.of(context).pop();
                    break;
                  case 1: //Retake
                    final captureFilePath = await CaptureScreen();
                    var mFile = await MultipartFile.fromFile(captureFilePath,
                        filename: path.basename(captureFilePath),
                        contentType: MediaType("image", "jpeg"));

                    var sendData = {
                      "photographer": patientBloc.state.currentUser!.id,
                      "photo": mFile,
                    };

                    final globalRepository = context.read<GlobalRepository>();

                    await globalRepository.addPatientImage(sendData,
                        flag: true);

                    if (checkIfChanged() == true) {
                      mFile = await MultipartFile.fromFile(
                          patientBloc.state.takenPhoto!.path,
                          filename:
                              path.basename(patientBloc.state.takenPhoto!.path),
                          contentType: MediaType("image", "jpeg"));

                      sendData = {
                        "photographer": patientBloc.state.currentUser!.id,
                        "photo": mFile,
                      };

                      await globalRepository.addPatientImage(sendData,
                          flag: true);
                    }

                    Alert(
                      context: context,
                      type: AlertType.success,
                      title: S.of(context).uploadSuccess,
                      desc: S.of(context).uploadSuccessDesc1,
                      buttons: [
                        DialogButton(
                          child: Text(
                            "OK",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          width: 120,
                        )
                      ],
                    ).show();
                    break;
                  case 2: //Save
                    savePhoto();

                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.PATIENT_PAGE, (route) => false);

                    break;
                }
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.camera_alt_outlined, color: Colors.white),
                    label: S.of(context).retake),
                BottomNavigationBarItem(
                    icon:
                        Icon(Icons.cloud_upload_outlined, color: Colors.white),
                    label: S.of(context).upload),
                BottomNavigationBarItem(
                    icon: Icon(Icons.save_outlined, color: Colors.white),
                    label: S.of(context).complete),
              ],
              backgroundColor: Color(0xff263136),
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.white,
              type: BottomNavigationBarType.fixed,
            )));
  }

  Widget buildNextTemplate() {
    return Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () async {
            savePhoto();
            Navigator.of(context).pop();
          },
          child: Image.asset(
            "assets/images/retake.png",
            width: 50,
          ),
        ));
  }

  Future<String> CaptureScreen() async {
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

  GestureDetector buildCurrentPath() {
    double distance(Offset a, Offset b) {
      return sqrt(pow((a.dx - b.dx), 2) + pow((a.dy - b.dy), 2));
    }

    return GestureDetector(
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
          drawPoints.entries.forEach((element) {
            for (CPoint value in element.value) {
              value.isSelected = false;
            }
          });
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
            margin: EdgeInsets.only(left: 10, bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                color: toolType == 'hand' ? Colors.white : Color(0xaa000000),
                borderRadius: BorderRadius.circular(50.0)),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    toolType = 'hand';
                  });
                },
                icon: Icon(Icons.pan_tool,
                    color: toolType == 'hand' ? Colors.black : Colors.white),
                iconSize: 30.0),
          ),
          Container(
            margin: EdgeInsets.only(left: 10, bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                color: toolType == 'pencil' ? Colors.white : Color(0xaa000000),
                borderRadius: BorderRadius.circular(50.0)),
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
            margin: EdgeInsets.only(left: 10, bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                color:
                    toolType == 'injection' ? Colors.white : Color(0xaa000000),
                borderRadius: BorderRadius.circular(50.0)),
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
            margin: EdgeInsets.only(left: 10, bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                color: toolType == 'text' ? Colors.white : Color(0xaa000000),
                borderRadius: BorderRadius.circular(50.0)),
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
            margin: EdgeInsets.only(left: 10, bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                color: toolType == 'more' ? Colors.white : Color(0xaa000000),
                borderRadius: BorderRadius.circular(50.0)),
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
            margin: EdgeInsets.only(left: 10, bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                color: toolType == 'oval' ? Colors.white : Color(0xaa000000),
                borderRadius: BorderRadius.circular(50.0)),
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
            margin: EdgeInsets.only(left: 10, bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                color: toolType == 'undo' ? Colors.white : Color(0xaa000000),
                borderRadius: BorderRadius.circular(50.0)),
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
