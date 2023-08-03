import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:rxphoto/models/patientImage.model.dart';

class UploadMultiPhotos extends StatefulWidget {
  final List<dynamic> data;
  const UploadMultiPhotos(this.data);

  @override
  _UploadMultiPhotosState createState() => _UploadMultiPhotosState();
}

class _UploadMultiPhotosState extends State<UploadMultiPhotos> {
  List<int> selectedBodyCategoryValue = [];
  List<int> selectedBodyPartValue = [];
  List<List<DropdownMenuItem<int>>> subdropdownItems = [];
  diopack.MultipartFile? imageData;
  List<TextEditingController> noteController = [];
  DateTime shootingTime = DateTime.now();
  int? currentMedicalNo = 0;
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    PatientBloc patientBloc = context.read<PatientBloc>();

    setState(() {
      currentMedicalNo = patientBloc.state.curMedicalNo;
      data = widget.data;

      for (int i = 0; i < widget.data.length; i++) {
        selectedBodyCategoryValue.add(-1);
        selectedBodyPartValue.add(-1);
        noteController.add(TextEditingController());
        subdropdownItems.add([]);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    noteController.map((e) => e.dispose());
  }

  void uploadPhoto() async {
    final globalRepository = context.read<GlobalRepository>();
    final patientBloc = context.read<PatientBloc>();

    var sendData = {
      "IMAGE_CONTENT": data,
      "BODY_PART_ID": selectedBodyPartValue,
      "NOTES": noteController.map((e) => e.text).toList(),
      "PHOTOGRAPHER": patientBloc.state.currentUser!.id,
      "PATIENT_ID": patientBloc.state.selectedPatient!.id,
      "MEDICAL_RECORD_NO": currentMedicalNo,
    };

    context.loaderOverlay.show(widget: UploadingOverlay());
    try {
      await globalRepository.createAlbumPatientImages(sendData).then((value) {
        context.loaderOverlay.hide();
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
                // Navigator.pop(context);
                patientBloc.add(PatientImageUpdateRequested());
              },
              width: 120,
            )
          ],
        ).show();
      });
      patientBloc.add(PatientGalleryDataRequested("Date"));
    } catch (e) {
      context.loaderOverlay.hide();
    }
  }

  Widget showOneGroup(e, i) {
    Uint8List? imageBytes;

    if (e is String) {
      imageBytes = base64Decode(e);
    }

    PatientBloc patientBloc = context.watch<PatientBloc>();
    List<DropdownMenuItem<int>> dropdownItems = patientBloc.state.bodypartList
        .map((e) => DropdownMenuItem(child: Text(e.name!), value: e.id))
        .toList();

    if (selectedBodyCategoryValue.length == 0 ||
        selectedBodyPartValue.length == 0 ||
        noteController.length == 0) return Container();

    return Column(
      children: [
        SizedBox(height: 15),
        Stack(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color: Color(0xffD9D9D9),
                child: e is String
                    ? Image.memory(imageBytes!, fit: BoxFit.contain)
                    : CachedNetworkImage(
                        httpHeaders: {"Authorization": authString},
                        fit: BoxFit.contain,
                        imageUrl: '$baseUrl/photos/${e.photoUrl}',
                        placeholder: (context, url) =>
                            new CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                      )),
            Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        selectedBodyCategoryValue.removeAt(i);
                        selectedBodyPartValue.removeAt(i);
                        noteController.removeAt(i);
                        subdropdownItems.removeAt(i);
                        data.removeAt(i);
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                      color: Color(0xffF45666),
                    )))
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, top: 0, bottom: 5),
                child: Text('⬤  ' + S.of(context).SelectBodyPart,
                    style: TextStyle(color: Color(0xffC888A8), fontSize: 16)),
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
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                        onChanged: (int? newValue) {
                          final filteredList = patientBloc.state.bodyparts
                              .where((element) => element.partsFor == newValue);
                          log(filteredList.toString());
                          setState(() {
                            selectedBodyCategoryValue[i] = newValue!;
                            subdropdownItems[i] = filteredList
                                .map((e) => DropdownMenuItem(
                                    child: Text(e.title!), value: e.id))
                                .toList();
                            selectedBodyPartValue[i] =
                                filteredList.toList().length == 0
                                    ? -1
                                    : filteredList.toList()[0].id;
                          });
                        },
                        value: selectedBodyCategoryValue[i] == -1
                            ? null
                            : selectedBodyCategoryValue[i],
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
                margin: EdgeInsets.only(left: 20, top: 0, bottom: 5),
                child: Text('⬤  ' + S.of(context).SelectAngle,
                    style: TextStyle(color: Color(0xffC888A8), fontSize: 16)),
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
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedBodyPartValue[i] = newValue!;
                          });
                        },
                        value: selectedBodyPartValue[i] == -1
                            ? null
                            : selectedBodyPartValue[i],
                        items: subdropdownItems[i]),
                  ))
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(bottom: 5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                  child: Text('⬤  ' + S.of(context).notes,
                      style:
                          TextStyle(color: Color(0xffC888A8), fontSize: 16))),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black26),
                  ),
                ),
                child: TextField(
                  controller: noteController[i],
                  maxLines: 3,
                  decoration: InputDecoration(
                      hintText: S.of(context).noteForThisPhoto,
                      hintStyle: TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(13, 8, 5, 8)),
                ),
              ),
            ]))
      ],
    );
  }

  List<Widget> showGroups(List<dynamic> data) {
    int i = 0;

    return data.map((e) {
      return showOneGroup(e, i++);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    PatientBloc patientBloc = context.watch<PatientBloc>();
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
                          uploadPhoto();
                        },
                        child: Text(S.of(context).upload,
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 20, top: 0, bottom: 5),
                    child: Text(
                        '⬤  ' + S.of(context).PatientPage_medicalHistory,
                        style:
                            TextStyle(color: Color(0xffC888A8), fontSize: 16))),
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
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                          onChanged: (int? newValue) {
                            setState(() {
                              currentMedicalNo = newValue;
                            });
                          },
                          value:
                              currentMedicalNo == 0 ? null : currentMedicalNo,
                          alignment: Alignment.centerLeft,
                          items: getMedicalSuggestions()),
                    )),
                Column(children: showGroups(data)),
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
