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

class FilterDialog extends StatefulWidget {
  const FilterDialog();

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  TextEditingController keywordsController = TextEditingController();
  int? selectedDoctorId;
  int? selectedBodyCategoryValue;
  int? selectedInterval;
  int? hasPhoto;

  @override
  void initState() {
    super.initState();
    PatientBloc patientBloc = context.read<PatientBloc>();

    setState(() {
      keywordsController.text = patientBloc.state.filterKeywords ?? "";
      selectedBodyCategoryValue = patientBloc.state.filterBody;
      selectedDoctorId = patientBloc.state.filterDoctor;
      selectedInterval = patientBloc.state.filterInterval;
      hasPhoto = patientBloc.state.filterHasPhoto;
    });
  }

  @override
  Widget build(BuildContext context) {
    PatientBloc patientBloc = context.watch<PatientBloc>();
    List<DropdownMenuItem<int>> doctorItems = [
      ...[
        DropdownMenuItem(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child:
                    Text(S.of(context).selectDr, textAlign: TextAlign.center)),
            value: 0)
      ],
      ...patientBloc.state.doctors
          .map((e) => DropdownMenuItem(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text((e.firstName ?? "") + " " + (e.lastName ?? ""),
                      textAlign: TextAlign.center)),
              value: e.id))
          .toList()
    ];
    List<DropdownMenuItem<int>> bodyPartItems = [
      ...[
        DropdownMenuItem(child: Text(S.of(context).selectBodyPart), value: 0)
      ],
      ...patientBloc.state.bodypartList
          .map((e) => DropdownMenuItem(child: Text(e.name!), value: e.id))
          .toList()
    ];

    Map<int, String> intervals = <int, String>{
      0: S.of(context).all,
      1: S.of(context).withinWeek,
      2: S.of(context).withinMonth,
      3: S.of(context).within3Month,
      4: S.of(context).withinYear,
      5: S.of(context).overYear
    };
    List<DropdownMenuItem<int>> intervalItems = intervals.entries
        .map((e) =>
            DropdownMenuItem(child: Text(e.value.toString()), value: e.key))
        .toList();

    Map<int, String> hasPhotos = <int, String>{
      0: S.of(context).all,
      1: S.of(context).yes,
      2: S.of(context).no
    };
    List<DropdownMenuItem<int>> hasPhotoItems = hasPhotos.entries
        .map((e) =>
            DropdownMenuItem(child: Text(e.value.toString()), value: e.key))
        .toList();

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        S.of(context).filters,
                        style:
                            TextStyle(fontSize: 20.0, color: Color(0xffC2404C)),
                      ),
                      InkWell(
                        onTap: () {
                          patientBloc.add(PatientFilterDone(
                              keywordsController.text.toString(),
                              selectedDoctorId,
                              selectedBodyCategoryValue,
                              selectedInterval,
                              hasPhoto));

                          Navigator.of(context).pop();
                        },
                        child: Text(S.of(context).filterOk,
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                  child: Text('⬤  ' + S.of(context).EnterKeywords,
                      style: TextStyle(color: Color(0xffC888A8), fontSize: 16)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.black26),
                      bottom: BorderSide(color: Colors.black26),
                    ),
                  ),
                  child: TextField(
                    controller: keywordsController,
                    maxLines: 1,
                    decoration: InputDecoration(
                        hintText: S.of(context).enterKeywordDesc,
                        hintStyle: TextStyle(color: Colors.black26),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(13, 8, 5, 8)),
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                            '⬤  ' +
                                S.of(context).PatientPage_AttendingPhysician,
                            style: TextStyle(
                                color: Color(0xffC888A8), fontSize: 16)))),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.black26),
                          bottom: BorderSide(color: Colors.black26),
                        )),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                            isExpanded: true,
                            style: TextStyle(
                                color: Color(0xff000000), fontSize: 16),
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedDoctorId = newValue!;
                              });
                            },
                            value: selectedDoctorId,
                            items: doctorItems))),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 5, bottom: 5),
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
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedBodyCategoryValue = newValue!;
                              });
                            },
                            value: selectedBodyCategoryValue,
                            items: bodyPartItems))),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                  child: Text('⬤  ' + S.of(context).visitTime,
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
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedInterval = newValue!;
                            });
                          },
                          value: selectedInterval,
                          items: intervalItems),
                    )),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                  child: Text('⬤  ' + S.of(context).NoPhoto,
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
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          onChanged: (int? newValue) {
                            setState(() {
                              hasPhoto = newValue;
                            });
                          },
                          value: hasPhoto,
                          items: hasPhotoItems),
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
