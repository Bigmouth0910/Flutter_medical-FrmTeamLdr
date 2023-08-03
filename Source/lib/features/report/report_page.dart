import 'dart:typed_data';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/models/patientImage.model.dart';
import 'package:rxphoto/screens/CPoint.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController noteTextController = TextEditingController();
  String toolType = "hand";
  Map<String, List<CPoint>> drawPoints = Map<String, List<CPoint>>();
  int currentDrawOrder = 1;
  double injectionRadius = 20.0;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
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
        final imagePath = await File('/storage/emulated/0/Download/rxphoto_' +
                DateTime.now().millisecondsSinceEpoch.toString() +
                '.png')
            .create();
        try {
          final path = await imagePath.writeAsBytes(image).then((result) {
            print("Capture Image Path: ${result.path}");
            return result.path;
          });

          AlertController.show(S.current.downloadSuccess,
              "${S.current.downloadSuccessDesc}: (${path})", TypeAlert.success);
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final patientBloc = context.watch<PatientBloc>();
    final currentUser = patientBloc.state.currentUser;
    var clinicTitle = currentUser?.clinic?.title ?? "";
    if (currentUser?.clinic?.city != null)
      clinicTitle = clinicTitle + " " + currentUser!.clinic!.city!;
    if (currentUser?.clinic?.zip != null)
      clinicTitle = clinicTitle + "/" + currentUser!.clinic!.zip!;
    if (currentUser?.clinic?.url != null)
      clinicTitle = clinicTitle + "/" + currentUser!.clinic!.url!;
    if (currentUser?.clinic?.state != null)
      clinicTitle = clinicTitle + "/" + currentUser!.clinic!.state!;
    if (currentUser?.clinic?.email != null)
      clinicTitle = clinicTitle + "/" + currentUser!.clinic!.email!;
    if (currentUser?.clinic?.phone != null)
      clinicTitle = clinicTitle + "/" + currentUser!.clinic!.phone!;
    if (currentUser?.clinic?.address != null)
      clinicTitle = clinicTitle + "/" + currentUser!.clinic!.address!;
    final clinicPhotoUrl = currentUser?.clinic?.logo;

    final galleryData = patientBloc.state.galleryData;
    final selectedPatient = patientBloc.state.selectedPatient;
    final patientName =
        selectedPatient!.firstName! + " " + selectedPatient.lastName!;
    final patientDateOfBirth = selectedPatient.birthDate!;
    final DateFormat yearFormat = DateFormat('yyyy-MM-dd');
    final patientDateOfCreated =
        yearFormat.format(yearFormat.parse(selectedPatient.createDate!));
    List<PatientImage> selectedPatientImages = [];
    galleryData!.entries.forEach((element) {
      selectedPatientImages = [
        ...selectedPatientImages,
        ...element.value.where((e1) => e1.isSelected == true).toList()
      ];
    });

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xffFF91A6),
            centerTitle: true,
            title: Text(S.of(context).report),
            actions: [
              IconButton(
                  onPressed: () async {
                    await CaptureScreen();
                  },
                  icon: Icon(
                    Icons.download,
                    color: Colors.white,
                  ))
            ],
          ),
          body: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: Color(0xffFF91A6))),
            child: SingleChildScrollView(
                child: Screenshot(
              controller: screenshotController,
              child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                              width: 240,
                              child: Row(
                                children: [
                                  Text(S.of(context).reportDate,
                                      style: TextStyle(
                                          color: Color(0xff686868),
                                          fontSize: 20)),
                                  Container(width: 30),
                                  Text(
                                      "${new DateFormat('yyyy-MM-dd').format(new DateTime.now())}",
                                      style: TextStyle(
                                          color: Color(0xff222222),
                                          fontSize: 20)),
                                ],
                              ))),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 200,
                                child: CachedNetworkImage(
                                  fit: BoxFit.contain,
                                  imageUrl:
                                      "$uploadFolderUrl/logos/$clinicPhotoUrl",
                                  placeholder: (context, url) =>
                                      new CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                      "${currentUser?.clinic?.title ?? ""}",
                                      style: TextStyle(
                                          color: Color(0xff222222),
                                          fontSize: 20)))
                            ],
                          ),
                          Container(
                            width: 20,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Text(
                                      "• ${S.of(context).clinicInformation}",
                                      style: TextStyle(
                                          color: Color(0xffC888A8),
                                          fontSize: 20),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xffF45666),
                                          Color(0xffFFE2E0)
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                    // width: MediaQuery.of(context).size.width
                                  ))
                                ],
                              ),
                              Container(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 200,
                                      child: Text(
                                          "${S.of(context).contactNumber}",
                                          style: TextStyle(
                                              color: Color(0xff686868),
                                              fontSize: 20))),
                                  Container(
                                      child: Text(
                                          "${currentUser!.clinic!.phone!}",
                                          style: TextStyle(
                                              color: Color(0xff222222),
                                              fontSize: 20)))
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 200,
                                      child: Text("Email",
                                          style: TextStyle(
                                              color: Color(0xff686868),
                                              fontSize: 20))),
                                  Container(
                                      child: Text(
                                          "${currentUser!.clinic!.email!}",
                                          style: TextStyle(
                                              color: Color(0xff222222),
                                              fontSize: 20)))
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 200,
                                      child: Text("${S.of(context).address}",
                                          style: TextStyle(
                                              color: Color(0xff686868),
                                              fontSize: 20))),
                                  Container(
                                      child: Text(
                                          "${currentUser!.clinic!.address!}",
                                          style: TextStyle(
                                              color: Color(0xff222222),
                                              fontSize: 20)))
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 200,
                                      child: Text("${S.of(context).website}",
                                          style: TextStyle(
                                              color: Color(0xff686868),
                                              fontSize: 20))),
                                  Container(
                                      child: Text(
                                          "${currentUser!.clinic!.url!}",
                                          style: TextStyle(
                                              color: Color(0xff222222),
                                              fontSize: 20)))
                                ],
                              ),
                            ],
                          )),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffF45666), Color(0xffFFE2E0)],
                                end: Alignment.centerLeft,
                                begin: Alignment.centerRight,
                              ),
                            ),
                            // width: MediaQuery.of(context).size.width
                          )),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              S.of(context).patientInformation,
                              style: TextStyle(
                                  color: Color(0xffC888A8), fontSize: 20),
                            ),
                          ),
                          Expanded(
                              child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffF45666), Color(0xffFFE2E0)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            // width: MediaQuery.of(context).size.width
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(
                            S.of(context).patientName,
                            style: TextStyle(
                                color: Color(0xff686868), fontSize: 20),
                          )),
                          Expanded(
                              child: Text(
                            patientName,
                            style: TextStyle(
                                color: Color(0xff222222), fontSize: 20),
                          )),
                          Container(
                            width: 10,
                            color: Colors.white,
                          ),
                          Expanded(
                              child: Text(
                            S.of(context).PatientPage_medicalHistoryNo,
                            style: TextStyle(
                                color: Color(0xff686868), fontSize: 20),
                          )),
                          Expanded(
                              child: Text(
                            selectedPatient.medicalHistoryNo.toString(),
                            style: TextStyle(
                                color: Color(0xff222222), fontSize: 20),
                          )),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xffFFE2E0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                            child: Text(
                                          "Before",
                                          style: TextStyle(
                                              color: Color(0xff686868),
                                              fontSize: 25),
                                        )),
                                        Container(height: 20),
                                        CachedNetworkImage(
                                          fit: BoxFit.fitWidth,
                                          imageUrl:
                                              "$patientImgUrl/${selectedPatientImages[0].photoUrl}",
                                          placeholder: (context, url) =>
                                              new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              new Icon(Icons.error),
                                        ),
                                        Container(
                                          height: 20,
                                        ),
                                        Text(
                                            "${selectedPatientImages[0].notes}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16))
                                      ]))),
                          Container(
                            width: 10,
                            color: Colors.white,
                          ),
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xffFFE2E0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                            child: Text(
                                          "After",
                                          style: TextStyle(
                                              color: Color(0xff686868),
                                              fontSize: 25),
                                        )),
                                        Container(height: 20),
                                        CachedNetworkImage(
                                          fit: BoxFit.fitWidth,
                                          imageUrl:
                                              "$patientImgUrl/${selectedPatientImages[1].photoUrl}",
                                          placeholder: (context, url) =>
                                              new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              new Icon(Icons.error),
                                        ),
                                        Container(
                                          height: 20,
                                        ),
                                        Text(
                                            "${selectedPatientImages[1].notes}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16))
                                      ]))),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffF45666), Color(0xffFFE2E0)],
                                end: Alignment.centerLeft,
                                begin: Alignment.centerRight,
                              ),
                            ),
                            // width: MediaQuery.of(context).size.width
                          )),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              S.of(context).moreInfo,
                              style: TextStyle(
                                  color: Color(0xffC888A8), fontSize: 20),
                            ),
                          ),
                          Expanded(
                              child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffF45666), Color(0xffFFE2E0)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            // width: MediaQuery.of(context).size.width
                          ))
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.black26),
                          ),
                        ),
                        child: TextField(
                          showCursor: false,
                          minLines: 5,
                          maxLines: 100,
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              hintText: S.of(context).moreInfoDesc,
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.fromLTRB(13, 8, 5, 8)),
                        ),
                      ),
                    ],
                  )),
            )),
          )),
    );
  }
}
