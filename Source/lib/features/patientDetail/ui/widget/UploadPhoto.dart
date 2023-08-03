import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:dio/dio.dart' as diopack;
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxphoto/generated/l10n.dart';

class UploadPhotoDialog extends StatefulWidget {
  final String? shootingTime;
  final String? uploadingFilePath;
  final int? selectedBodyPartValue;
  final int? selectedBodyCategoryValue;
  const UploadPhotoDialog(
      {this.shootingTime,
      this.uploadingFilePath,
      this.selectedBodyPartValue = 0,
      this.selectedBodyCategoryValue = 0});

  @override
  _UploadPhotoDialogState createState() => _UploadPhotoDialogState();
}

class _UploadPhotoDialogState extends State<UploadPhotoDialog> {
  int? selectedBodyCategoryValue;
  bool? selectedUncategorized;
  int? selectedBodyPartValue;
  List<DropdownMenuItem<int>> subdropdownItems = [];
  diopack.MultipartFile? imageData;
  TextEditingController noteController = TextEditingController();
  TextEditingController authorTextController = TextEditingController();
  DateTime shootingTime = DateTime.now();
  int? currentMedicalNo = 0;
  final ImagePicker _picker = ImagePicker();
  String? photoPath = "";

  @override
  void initState() {
    super.initState();
    PatientBloc patientBloc = context.read<PatientBloc>();

    setState(() {
      shootingTime = DateTime.now();
      authorTextController.text = userName;
      selectedBodyCategoryValue = widget.selectedBodyCategoryValue == 0
          ? patientBloc.state.bodypartList[0].id
          : widget.selectedBodyCategoryValue;
      selectedBodyPartValue = widget.selectedBodyPartValue;
      selectedUncategorized =
          patientBloc.state.bodypartList[0].name!.toLowerCase() ==
                  "uncategorized"
              ? true
              : false;
      subdropdownItems = patientBloc.state.bodyparts
          .where((element) => element.partsFor == selectedBodyCategoryValue!)
          .map((e) => DropdownMenuItem(child: Text(e.title!), value: e.id))
          .toList();
      currentMedicalNo = patientBloc.state.curMedicalNo;
      photoPath = widget.uploadingFilePath;
    });
  }

  @override
  void dispose() {
    super.dispose();
    noteController.dispose();
  }

  void uploadPhoto(String uploadFilePath, int? bodypartId,
      bool selectedUncategorized, String note) async {
    final globalRepository = context.read<GlobalRepository>();
    final patientBloc = context.read<PatientBloc>();

    var mFile = await MultipartFile.fromFile(uploadFilePath,
        filename: path.basename(uploadFilePath),
        contentType: MediaType("image", "jpeg"));
    var sendData = {
      "patient_id": patientBloc.state.selectedPatient!.id,
      "body_part_id": selectedUncategorized ? null : bodypartId,
      "photo": mFile,
      "notes": note,
      "is_active": 0,
      "medical_history_id": currentMedicalNo,
      "is_uncategorized": selectedUncategorized ? 1 : 0,
      "shooting_time": DateFormat('yyyy-MM-dd').format(shootingTime),
    };
    context.loaderOverlay.show(widget: UploadingOverlay());
    try {
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
                Navigator.pop(context);
                patientBloc.add(PatientImageUpdateRequested());
              },
              width: 120,
            )
          ],
        ).show();
      });
    } catch (e) {
      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    PatientBloc patientBloc = context.watch<PatientBloc>();
    List<DropdownMenuItem<int>> dropdownItems = patientBloc.state.bodypartList
        .map((e) => DropdownMenuItem(child: Text(e.name!), value: e.id))
        .toList();
    var doctorId = context.read<GlobalRepository>().getUser().id;
    var medicalHistory = patientBloc.state.medicalHistory;
    var treatmentList = patientBloc.state.treatmentNormalList;

    List<DropdownMenuItem<int>> getMedicalSuggestions() {
      List<DropdownMenuItem<int>> widgets = [];

      if (medicalHistory.length != 0) {
        medicalHistory.sort((a, b) {
          if (a.lastUpdateDate != null && b.lastUpdateDate != null)
            return -a.lastUpdateDate!.compareTo(b.lastUpdateDate!);
          return 0;
        });

        for (var item in medicalHistory) {
          var treatmentStr = item.treatment.toString() == ""
              ? ""
              : item.treatment
                  .toString()
                  .split(" ")
                  .map((e) {
                    var foundTreatment = treatmentList.firstWhere(
                        (element) => element.id.toString() == e.toString());
                    if (foundTreatment != null)
                      return foundTreatment.tagName.toString();
                    else
                      return "";
                  })
                  .toList()
                  .join(" ");

          widgets.add(DropdownMenuItem(
              child: Container(
                  child: Text(
                      '${item.dateOfVisit.toString()} (${treatmentStr})',
                      textAlign: TextAlign.left)),
              value: item.id));
        }
      }

      return widgets;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xffF4F4F4),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  // height: 100,#0B6DC9
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      color: Color(0xffFF91A6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(S.of(context).cancel,
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                      ),
                      Text(
                        S.of(context).UploadPhotos,
                        style:
                            TextStyle(fontSize: 20.0, color: Color(0xffC2404C)),
                      ),
                      InkWell(
                        onTap: () async {
                          uploadPhoto(photoPath!, selectedBodyPartValue,
                              selectedUncategorized!, noteController.text);
                        },
                        child: Text(S.of(context).upload,
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                      ),
                    ],
                  ),
                ),
                Container(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.file(File(photoPath!)))),
                    Container(
                      transform: Matrix4.translationValues(
                          MediaQuery.of(context).size.width - 150, -20, 0),
                      child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Color(0xffF45666),
                              fixedSize: new Size(40, 40),
                              padding: EdgeInsets.all(0),
                              minimumSize: new Size(40, 40)),
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery);

                            if (image != null) {
                              var _image = image.path;

                              setState(() {
                                photoPath = _image;
                              });
                            }
                          },
                          child: Icon(
                            Icons.change_circle,
                            color: Colors.white,
                            size: 30,
                          )),
                    ),
                    Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(left: 20, top: 0, bottom: 5),
                              child: Text('⬤  ' + S.of(context).shootingTime,
                                  style: TextStyle(
                                      color: Color(0xffC888A8), fontSize: 16)),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900, 8),
                                    lastDate: DateTime.now(),
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    helpText: S.of(context).selectDate,
                                    cancelText: S.of(context).cancel,
                                    confirmText: S.of(context).ok,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.fromSwatch(
                                            primarySwatch: MaterialColor(
                                              0xffF4568C,
                                              <int, Color>{
                                                50: Color(0xffF4568C),
                                                100: Color(0xffF4568C),
                                                200: Color(0xffF4568C),
                                                300: Color(0xffF4568C),
                                                400: Color(0xffF4568C),
                                                500: Color(0xffF4568C),
                                                600: Color(0xffF4568C),
                                                700: Color(0xffF4568C),
                                                800: Color(0xffF4568C),
                                                900: Color(0xffF4568C),
                                              },
                                            ),
                                            primaryColorDark: Color(0xffF4568C),
                                            accentColor: Color(0xffF4568C),
                                          ),
                                          dialogBackgroundColor: Colors.white,
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (picked != null) {
                                    setState(() {
                                      shootingTime = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      top: BorderSide(color: Colors.black26),
                                      bottom: BorderSide(color: Colors.black26),
                                    ),
                                  ),
                                  child: Text(
                                      DateFormat('yyyy-MM-dd')
                                          .format(shootingTime),
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 16)),
                                ),
                              ),
                            )

                            // Flexible(
                            //   child: CupertinoDateTextBox(
                            //       initialValue: DateTime.now(),
                            //       onDateChange: onDateChange,
                            //       color: Colors.black,
                            //       fontSize: 16,
                            //       hintText: DateFormat('yyyy-MM-dd')
                            //           .format(DateTime.now())),
                            // )
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(left: 20, top: 0, bottom: 5),
                              child: Text('⬤  ' + S.of(context).PhotoAuthor,
                                  style: TextStyle(
                                      color: Color(0xffC888A8), fontSize: 16)),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(color: Colors.black26),
                                    bottom: BorderSide(color: Colors.black26),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                width: MediaQuery.of(context).size.width,
                                child: Text("$userName",
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 16)))
                          ],
                        )),
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, top: 0, bottom: 5),
                            child: Text('⬤  ' + S.of(context).SelectBodyPart,
                                style: TextStyle(
                                    color: Color(0xffC888A8), fontSize: 16)),
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(color: Colors.black26),
                                  bottom: BorderSide(color: Colors.black26),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                    isExpanded: true,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 16),
                                    onChanged: (int? newValue) {
                                      final filteredList = patientBloc
                                          .state.bodyparts
                                          .where((element) =>
                                              element.partsFor == newValue);
                                      setState(() {
                                        selectedUncategorized = patientBloc
                                                    .state.bodypartList
                                                    .firstWhere((element) =>
                                                        element.id == newValue!)
                                                    .name!
                                                    .toLowerCase() ==
                                                "uncategorized"
                                            ? true
                                            : false;
                                        selectedBodyCategoryValue = newValue!;
                                        subdropdownItems = filteredList
                                            .map((e) => DropdownMenuItem(
                                                child: Text(e.title!),
                                                value: e.id))
                                            .toList();
                                        selectedBodyPartValue =
                                            filteredList.toList().length == 0
                                                ? null
                                                : filteredList.toList()[0].id;
                                      });
                                    },
                                    value: selectedBodyCategoryValue == 0
                                        ? null
                                        : selectedBodyCategoryValue,
                                    items: dropdownItems),
                              ))
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, top: 0, bottom: 5),
                            child: Text('⬤  ' + S.of(context).SelectAngle,
                                style: TextStyle(
                                    color: Color(0xffC888A8), fontSize: 16)),
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(color: Colors.black26),
                                  bottom: BorderSide(color: Colors.black26),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                    isExpanded: true,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 16),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedBodyPartValue = newValue!;
                                      });
                                    },
                                    value: selectedBodyPartValue == 0
                                        ? null
                                        : selectedBodyPartValue,
                                    items: subdropdownItems),
                              ))
                        ],
                      ),
                    ),
                    // Container(
                    //     margin: EdgeInsets.only(bottom: 5),
                    //     child: Padding(
                    //         padding: EdgeInsets.only(left: 18),
                    //         child: Text("Shooting Time ",
                    //             style: TextStyle(
                    //                 color: Colors.black54, fontSize: 16)))),
                    Container(
                        margin: EdgeInsets.only(left: 20, top: 0, bottom: 5),
                        child: Text(
                            '⬤  ' + S.of(context).PatientPage_medicalHistory,
                            style: TextStyle(
                                color: Color(0xffC888A8), fontSize: 16))),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.black26),
                            bottom: BorderSide(color: Colors.black26),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              isExpanded: true,
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16),
                              onChanged: (int? newValue) {
                                setState(() {
                                  currentMedicalNo = newValue;
                                });
                              },
                              value: currentMedicalNo == 0
                                  ? null
                                  : currentMedicalNo,
                              alignment: Alignment.centerLeft,
                              items: getMedicalSuggestions()),
                        )),
                    Container(
                        margin: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                        child: Text('⬤  ' + S.of(context).notes,
                            style: TextStyle(
                                color: Color(0xffC888A8), fontSize: 16))),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.black26),
                        ),
                      ),
                      child: TextField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                            hintText: S.of(context).noteForThisPhoto,
                            hintStyle: TextStyle(color: Colors.black26),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(13, 8, 5, 8)),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UploadingOverlay extends StatelessWidget {
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
              'Uploading...',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}
