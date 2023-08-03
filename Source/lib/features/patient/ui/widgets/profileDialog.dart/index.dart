import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:dio/dio.dart' as diopack;
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rxphoto/generated/l10n.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({Key? key}) : super(key: key);

  @override
  _ProfileDialogState createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  String? _path;
  diopack.MultipartFile? imageData;
  TextEditingController _birthTextController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController medicalHistoryNoController = TextEditingController();

  // Image Picker
  List<XFile>? _imageFileList;

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  bool isVideo = false;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  DateTime? selectedDate;

  void showDatePicker() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (value) {
                if (value != null && value != selectedDate)
                  setState(() {
                    selectedDate = value;
                  });
              },
              initialDateTime: selectedDate,
            ),
          );
        });
  }

  void onDateChange(DateTime? currentTime) {
    setState(() {
      selectedDate = currentTime;
    });
  }

  @override
  void initState() {
    setState(() {
      selectedDate = DateTime.now();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PatientBloc patientBloc = context.watch<PatientBloc>();
    var selectedDiagnosis = patientBloc.state.selectedDiagnosis;
    var selectedTreatment = patientBloc.state.selectedTreatment;
    var doctorId = context.read<GlobalRepository>().getUser().id;

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
            height: 600,
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
                        S.of(context).PatientPage_addPatient,
                        style:
                            TextStyle(fontSize: 20.0, color: Color(0xffC2404C)),
                      ),
                      InkWell(
                        onTap: () async {
                          var errorText = "";
                          if (firstNameController.text == "")
                            errorText = S.of(context).pleaseInputFirstName;
                          else if (lastNameController.text == "")
                            errorText = S.of(context).pleaseInputLastName;
                          else if (medicalHistoryNoController.text == "")
                            errorText =
                                S.of(context).pleaseInputMedicalHistoryNo;
                          else if (_path == null)
                            _path = "";
                          // errorText = S.of(context).pleaseSelectProfileImage;
                          else if (selectedDate == null ||
                              selectedDate.toString().isEmpty)
                            errorText = S.of(context).pleaseChooseBirth;

                          if (errorText == "") {
                            var data = {
                              "DOCTOR_ID": doctorId,
                              "FIRST_NAME": firstNameController.text,
                              "LAST_NAME": lastNameController.text,
                              "MEDICAL_HISTORY_NO":
                                  medicalHistoryNoController.text,
                              "PICTURE": imageData,
                              "PICTURE_PATH": _path,
                              "BIRTH_DATE": selectedDate.toString(),
                            };
                            patientBloc.add(PatientDataCreated(data));
                            Navigator.pop(context);
                          } else {
                            AlertController.show(
                                "Input Error", errorText, TypeAlert.error);
                          }
                        },
                        child: Text(S.of(context).create,
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(
                        onTap: () async {
                          Dialog selectdialog = Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Container(
                              height: 120,
                              width: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                        child: Text(
                                            S.of(context).setProfilePicture,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xffF45666),
                                                fontSize: 16))),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final XFile? image =
                                            await _picker.pickImage(
                                                source: ImageSource.gallery);
                                        if (image != null) {
                                          var _image = image.path;
                                          File file = File(_image);
                                          String fileName =
                                              file.path.split('/').last;
                                          // print(image.thumbPath);
                                          var temp = await diopack.MultipartFile
                                              .fromFile(file.path,
                                                  filename:
                                                      path.basename(file.path),
                                                  contentType: MediaType(
                                                      "image", "jpeg"));
                                          setState(() {
                                            _path = image.path;
                                            imageData = temp;
                                          });
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      child: Center(
                                          child: Text(
                                              S.of(context).chooseFromLibrary,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))),
                                    ),
                                  ),
                                  Expanded(
                                      child: InkWell(
                                          onTap: () async {
                                            final XFile? photo =
                                                await _picker.pickImage(
                                                    source: ImageSource.camera);
                                            if (photo != null) {
                                              var _image = photo.path;
                                              File file = File(_image);

                                              String fileName =
                                                  file.path.split('/').last;

                                              // var crypt =
                                              //     AesCrypt('my cool password');
                                              // crypt.setOverwriteMode(
                                              //     AesCryptOwMode.on);

                                              // var encFilepath =
                                              //     crypt.encryptFileSync(file.path);
                                              // print('Encrypted file: $encFilepath');
                                              // var decFilepath = crypt
                                              //     .decryptFileSync(encFilepath);
                                              // print(
                                              //     'Decrypted file 1: $decFilepath');

                                              // print('File content: ' +
                                              //     File(decFilepath)
                                              //         .readAsStringSync() +
                                              //     '\n');

                                              print(photo.path);
                                              // var temp = await diopack.MultipartFile
                                              //     .fromFile(encFilepath,
                                              //         filename:
                                              //             basename(encFilepath));

                                              var temp = await diopack
                                                      .MultipartFile
                                                  .fromFile(file.path,
                                                      filename: path
                                                          .basename(file.path),
                                                      contentType: MediaType(
                                                          "image", "jpeg"));
                                              setState(() {
                                                _path = photo.path;
                                                imageData = temp;
                                              });
                                            }
                                            Navigator.of(context).pop();
                                          },
                                          child: Center(
                                              child: Text(
                                            S.of(context).takeNewPhoto,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                          )))),
                                ],
                              ),
                            ),
                          );
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => selectdialog);
                        },
                        child: _path != null
                            ? Container(
                                height: 100,
                                width: 100,
                                child:
                                    Image.file(File(_path!), fit: BoxFit.cover))
                            : Image(
                                image:
                                    AssetImage('assets/images/no_people.png'),
                                width: 50,
                                height: 50),
                      ),
                      Container(
                          margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                          child: Text.rich(
                            TextSpan(children: <TextSpan>[
                              TextSpan(
                                text:
                                    S.of(context).PatientPage_addProfilePicture,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black54),
                              )
                            ]),
                            textAlign: TextAlign.center,
                          )),
                    ])),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Padding(
                                padding: EdgeInsets.only(left: 18),
                                child: Text(
                                    '⬤  ' + S.of(context).PatientPage_name,
                                    style: TextStyle(
                                        color: Color(0xffC888A8),
                                        fontSize: 16)))),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.black26),
                              bottom: BorderSide(color: Colors.black26),
                            ),
                          ),
                          child: TextField(
                            controller: firstNameController,
                            autofocus: true,
                            decoration: InputDecoration(
                                fillColor: Colors.white,
                                hintText: S.of(context).PatientPage_firstName,
                                hintStyle: TextStyle(color: Colors.black26),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(13, 8, 5, 8)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.black26),
                            ),
                          ),
                          child: TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                                hintText: S.of(context).PatientPage_lastName,
                                hintStyle: TextStyle(color: Colors.black26),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(13, 8, 5, 8)),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(18, 0, 0, 5),
                                child: Text(
                                    '⬤  ' +
                                        S
                                            .of(context)
                                            .PatientPage_medicalHistoryNo,
                                    style: TextStyle(
                                        color: Color(0xffC888A8),
                                        fontSize: 16)))),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.black26),
                              bottom: BorderSide(color: Colors.black26),
                            ),
                          ),
                          child: TextField(
                            controller: medicalHistoryNoController,
                            decoration: InputDecoration(
                                hintText:
                                    S.of(context).PatientPage_medicalHistoryNo,
                                hintStyle: TextStyle(color: Colors.black26),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(13, 8, 5, 8)),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(18, 0, 0, 5),
                                child: Text(
                                    '⬤  ' +
                                        S.of(context).PatientPage_DateOfBirth,
                                    style: TextStyle(
                                        color: Color(0xffC888A8),
                                        fontSize: 16)))),
                        InkWell(
                          onTap: () {
                            showDatePicker();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(color: Colors.black26),
                                bottom: BorderSide(color: Colors.black26),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                              child: Text(
                                  DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!),
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16)),
                            ),
                          ),
                        ),
                        // CupertinoDateTextBox(
                        //     initialValue: DateTime.now(),
                        //     onDateChange: onDateChange,
                        //     color: Colors.black,
                        //     fontSize: 16,
                        //     hintText: S.of(context).PatientPage_BirthDate),

                        // Container(
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       border: Border(
                        //         top: BorderSide(color: Colors.black26),
                        //         bottom: BorderSide(color: Colors.black26),
                        //       ),
                        //     ),
                        //     child: GestureDetector(
                        //       onTap: () {
                        //         print('clicked Textfield');
                        //       },
                        //       child: AbsorbPointer(
                        //           child: Stack(
                        //         children: [
                        //           TextField(
                        //             onTap: () {
                        //               setState(() {
                        //                 _isShowDatePicker = true;
                        //               });
                        //             },
                        //             controller: _birthTextController,
                        //             decoration: InputDecoration(
                        //                 // prefixIcon: Icon(Icons.dialpad),
                        //                 hintText: 'Birth Date',
                        //                 hintStyle: TextStyle(color: Colors.black26),
                        //                 border: InputBorder.none,
                        //                 isDense: true,
                        //                 contentPadding:
                        //                     EdgeInsets.fromLTRB(15, 8, 5, 8)),
                        //           ),
                        //           // CupertinoDatePicker(
                        //           //   mode: CupertinoDatePickerMode.date,
                        //           //   initialDateTime: DateTime(1969, 1, 1),
                        //           //   maximumDate: DateTime.now(),
                        //           //   onDateTimeChanged: (DateTime newDateTime) {
                        //           //     print('date changed');
                        //           //     print(newDateTime);
                        //           //     _birthTextController.value =
                        //           //         _birthTextController.value.copyWith(
                        //           //             text: DateFormat('MM-dd-yyyy')
                        //           //                 .format(newDateTime));
                        //           //   },
                        //           // )
                        //         ],
                        //       )),
                        //     )),

                        // Container(
                        //   margin: EdgeInsets.fromLTRB(0, 25, 0, 10),
                        //   width: MediaQuery.of(context).size.width,
                        //   child: Stack(children: [
                        //     Padding(
                        //         padding: EdgeInsets.fromLTRB(18, 0, 0, 5),
                        //         child: Text(S.of(context).PatientPage_Diagnosis,
                        //             style: TextStyle(
                        //                 color: Colors.black54, fontSize: 16))),
                        //     Positioned(
                        //         child: InkWell(
                        //           child: Icon(Icons.add, size: 30),
                        //           onTap: () {
                        //             showMaterialModalBottomSheet(
                        //               context: context,
                        //               builder: (context) =>
                        //                   SingleChildScrollView(
                        //                 controller:
                        //                     ModalScrollController.of(context),
                        //                 child: Container(
                        //                   height: 300,
                        //                   child:
                        //                       BlocProvider<PatientBloc>.value(
                        //                           value: patientBloc,
                        //                           child: TreeWidget()),
                        //                 ),
                        //               ),
                        //             );
                        //           },
                        //         ),
                        //         right: 5,
                        //         top: 0)
                        //   ]),
                        // ),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     border: Border(
                        //       top: BorderSide(color: Colors.black26),
                        //       bottom: BorderSide(color: Colors.black26),
                        //     ),
                        //   ),
                        //   padding:
                        //       EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        //   height: 50,
                        //   width: MediaQuery.of(context).size.width,
                        //   child: SingleChildScrollView(
                        //       child: Wrap(
                        //           spacing: 4.0, // gap between adjacent chips
                        //           runSpacing: 4.0, // gap between lines
                        //           alignment: WrapAlignment.start,
                        //           crossAxisAlignment: WrapCrossAlignment.center,
                        //           children: selectedDiagnosis
                        //               .map((e) => Chip(
                        //                     label: Text(
                        //                       e['label'] ?? "No TagName",
                        //                       style: TextStyle(fontSize: 18),
                        //                     ),
                        //                     visualDensity: VisualDensity(
                        //                         vertical: -4, horizontal: 0),
                        //                     labelStyle:
                        //                         TextStyle(color: Colors.white),
                        //                     labelPadding: EdgeInsets.all(2),
                        //                     backgroundColor: Color(0xffF45666),
                        //                     onDeleted: () {
                        //                       patientBloc.add(
                        //                           PatientDeleteDiagnosis(
                        //                               e['key']!.toString()));
                        //                     },
                        //                     deleteIcon:
                        //                         Icon(Icons.close, size: 25),
                        //                     deleteIconColor: Colors.white,
                        //                     elevation: 5,
                        //                   ))
                        //               .toList())),
                        // ),
                        // Container(
                        //   margin: EdgeInsets.fromLTRB(0, 25, 0, 10),
                        //   width: MediaQuery.of(context).size.width,
                        //   child: Stack(children: [
                        //     Padding(
                        //         padding: EdgeInsets.fromLTRB(18, 0, 0, 5),
                        //         child: Text(S.of(context).PatientPage_Treatment,
                        //             style: TextStyle(
                        //                 color: Colors.black54, fontSize: 16))),
                        //     Positioned(
                        //         child: InkWell(
                        //           child: Icon(Icons.add, size: 30),
                        //           onTap: () {
                        //             showMaterialModalBottomSheet(
                        //                 context: context,
                        //                 builder: (context) =>
                        //                     SingleChildScrollView(
                        //                       controller:
                        //                           ModalScrollController.of(
                        //                               context),
                        //                       child: Container(
                        //                         height: 300,
                        //                         child: BlocProvider<
                        //                             PatientBloc>.value(
                        //                           value: patientBloc,
                        //                           child: TreatmentTreeWidget(),
                        //                         ),
                        //                       ),
                        //                     ));
                        //           },
                        //         ),
                        //         right: 5,
                        //         top: 0)
                        //   ]),
                        // ),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     border: Border(
                        //       top: BorderSide(color: Colors.black26),
                        //       bottom: BorderSide(color: Colors.black26),
                        //     ),
                        //   ),
                        //   padding:
                        //       EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        //   height: 50,
                        //   width: MediaQuery.of(context).size.width,
                        //   child: SingleChildScrollView(
                        //       child: Wrap(
                        //           spacing: 4.0, // gap between adjacent chips
                        //           runSpacing: 4.0, // gap between lines
                        //           alignment: WrapAlignment.start,
                        //           crossAxisAlignment: WrapCrossAlignment.center,
                        //           children: selectedTreatment
                        //               .map((e) => Chip(
                        //                     label: Text(
                        //                       e['label'] ?? "No TagName",
                        //                       style: TextStyle(fontSize: 18),
                        //                     ),
                        //                     visualDensity: VisualDensity(
                        //                         vertical: -4, horizontal: 0),
                        //                     labelStyle:
                        //                         TextStyle(color: Colors.white),
                        //                     labelPadding: EdgeInsets.all(2),
                        //                     backgroundColor: Color(0xffF45666),
                        //                     onDeleted: () => patientBloc.add(
                        //                         PatientDeleteTreatment(
                        //                             e['key']!)),
                        //                     deleteIcon:
                        //                         Icon(Icons.close, size: 18),
                        //                     deleteIconColor: Colors.white,
                        //                     elevation: 5,
                        //                   ))
                        //               .toList())),
                        // ),
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
