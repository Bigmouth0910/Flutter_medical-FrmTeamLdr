import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:dio/dio.dart' as diopack;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
// import 'package:rxphoto/features/patient/ui/widgets/cupertino_date_textbox.dart';
import 'package:cupertino_date_textbox/cupertino_date_textbox.dart';
import 'package:rxphoto/features/patient/ui/widgets/commonPhrase.dart';
import 'package:rxphoto/features/patient/ui/widgets/treatmentTreeWidget.dart';
import 'package:rxphoto/features/patient/ui/widgets/treeWidget.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MedicalHistoryDialog extends StatefulWidget {
  const MedicalHistoryDialog({Key? key}) : super(key: key);

  @override
  _MedicalHistoryDialogState createState() => _MedicalHistoryDialogState();
}

class _MedicalHistoryDialogState extends State<MedicalHistoryDialog> {
  int? selectedDoctorId;
  String? _path;
  diopack.MultipartFile? imageData;
  TextEditingController _birthTextController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController attendingController = TextEditingController();

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    PatientBloc patientBloc = context.read<PatientBloc>();
    noteController.text = patientBloc.state.selectedMedicalHistory?.notes ?? "";
    attendingController.text =
        patientBloc.state.selectedMedicalHistory?.attendingPhysician ?? "";

    setState(() {
      var selectedMedicalHistory = patientBloc.state.selectedMedicalHistory;
      if (selectedMedicalHistory?.attendingPhysician != null)
        selectedDoctorId = int.parse(
            patientBloc.state.selectedMedicalHistory!.attendingPhysician!);
      else
        selectedDoctorId = patientBloc.state.currentUser!.id;
      selectedDate =
          patientBloc.state.selectedMedicalHistory?.dateOfVisit != null
              ? DateTime.parse(
                  patientBloc.state.selectedMedicalHistory?.dateOfVisit ?? "")
              : DateTime.now();
    });
    // PatientBloc patientBloc = context.read<PatientBloc>();
  }

  @override
  void dispose() {
    super.dispose();
    noteController.dispose();
    attendingController.dispose();
  }

  void callBackSetNotes(String label) {
    noteController.text = noteController.text + " " + label;
  }

  @override
  Widget build(BuildContext context) {
    PatientBloc patientBloc = context.watch<PatientBloc>();
    List<DropdownMenuItem<int>> dropdownItems = patientBloc.state.doctors
        .map((e) => DropdownMenuItem(
            child: Container(
                child: Text((e.firstName ?? "") + " " + (e.lastName ?? ""),
                    textAlign: TextAlign.left)),
            value: e.id))
        .toList();
    var selectedDiagnosis = patientBloc.state.selectedDiagnosis;
    var selectedTreatment = patientBloc.state.selectedTreatment;
    var selectedMedicalHistory = patientBloc.state.selectedMedicalHistory;
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
                        S.of(context).PatientPage_addHistory,
                        style:
                            TextStyle(fontSize: 20.0, color: Color(0xffC2404C)),
                      ),
                      InkWell(
                        onTap: () async {
                          var errorText = "";
                          if (selectedDate == null ||
                              selectedDate.toString().isEmpty)
                            errorText = "please input date of visit";

                          if (errorText == "") {
                            var data = {
                              "ATTENDING_PHYSICIAN":
                                  selectedDoctorId.toString(),
                              // "ATTENDING_PHYSICIAN": (patientBloc.state.doctors
                              //             .firstWhere((element) =>
                              //                 element.id == selectedDoctorId)
                              //             .firstName ??
                              //         "") +
                              //     " " +
                              //     (patientBloc.state.doctors
                              //             .firstWhere((element) =>
                              //                 element.id == selectedDoctorId)
                              //             .lastName ??
                              //         ""),
                              "NOTES": noteController.text,
                              "DATEOFVISIT": selectedDate.toString(),
                            };

                            if (selectedMedicalHistory!.id == -1)
                              patientBloc.add(MedicalDataCreated(null, data));
                            else
                              patientBloc.add(MedicalDataUpdateRequested(data));
                            Navigator.pop(context);
                          } else {
                            AlertController.show(
                                "Input Error", errorText, TypeAlert.error);
                          }
                        },
                        child: Text(
                            selectedMedicalHistory!.id == -1
                                ? S.of(context).create
                                : S.of(context).save,
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(18, 0, 0, 5),
                                child: Text(
                                    '⬤  ' +
                                        S.of(context).PatientPage_DateOfVisit,
                                    style: TextStyle(
                                        color: Color(0xffC888A8),
                                        fontSize: 16)))),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(1900, 8),
                                lastDate: DateTime.now(),
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                helpText: S.of(context).selectDate,
                                cancelText: S.of(context).cancel,
                                confirmText: S.of(context).ok,
                                builder: (BuildContext context, Widget? child) {
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
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(color: Colors.black26),
                                  bottom: BorderSide(color: Colors.black26),
                                ),
                              ),
                              child: Text(
                                  DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16)),
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                            child: Padding(
                                padding: EdgeInsets.only(left: 18),
                                child: Text(
                                    '⬤  ' +
                                        S
                                            .of(context)
                                            .PatientPage_AttendingPhysician,
                                    style: TextStyle(
                                        color: Color(0xffC888A8),
                                        fontSize: 16)))),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     border: Border(
                        //       top: BorderSide(color: Colors.black26),
                        //       bottom: BorderSide(color: Colors.black26),
                        //     ),
                        //   ),
                        //   child: TextField(
                        //     controller: attendingController,
                        //     autofocus: true,
                        //     decoration: InputDecoration(
                        //         fillColor: Colors.white,
                        //         hintText: "please input Attending Physician",
                        //         hintStyle: TextStyle(color: Colors.black26),
                        //         border: InputBorder.none,
                        //         isDense: true,
                        //         contentPadding:
                        //             EdgeInsets.fromLTRB(13, 8, 5, 8)),
                        //   ),
                        // ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                    top: BorderSide(
                                        color: Colors.black26, width: 1),
                                    bottom: BorderSide(
                                        color: Colors.black26, width: 1))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  isExpanded: true,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                  onChanged: (int? newValue) {
                                    // setState(() {
                                    //   selectedDoctorId = newValue!;
                                    // });
                                  },
                                  value: selectedDoctorId,
                                  items: dropdownItems),
                            )),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                          width: MediaQuery.of(context).size.width,
                          height: 30,
                          child: Stack(children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(18, 0, 0, 5),
                                child: Text(
                                    '⬤  ' + S.of(context).PatientPage_Diagnosis,
                                    style: TextStyle(
                                        color: Color(0xffC888A8),
                                        fontSize: 16))),
                            Positioned(
                                child: InkWell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.add,
                                        size: 30,
                                        color: Color(0xffF45666),
                                      )),
                                  onTap: () {
                                    showMaterialModalBottomSheet(
                                      context: context,
                                      builder: (context) =>
                                          SingleChildScrollView(
                                        controller:
                                            ModalScrollController.of(context),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child:
                                              BlocProvider<PatientBloc>.value(
                                                  value: patientBloc,
                                                  child: TreeWidget()),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                right: 5,
                                top: -10)
                          ]),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.black26),
                              bottom: BorderSide(color: Colors.black26),
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                              child: Wrap(
                                  spacing: 4.0, // gap between adjacent chips
                                  runSpacing: 4.0, // gap between lines
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: selectedDiagnosis
                                      .map((e) => Chip(
                                            label: Text(
                                              e['label'] ?? "No TagName",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            visualDensity: VisualDensity(
                                                vertical: -4, horizontal: 0),
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            labelPadding: EdgeInsets.all(2),
                                            backgroundColor: Color(0xffF45666),
                                            onDeleted: () {
                                              patientBloc.add(
                                                  PatientDeleteDiagnosis(
                                                      e['key']!.toString()));
                                            },
                                            deleteIcon:
                                                Icon(Icons.close, size: 25),
                                            deleteIconColor: Colors.white,
                                            elevation: 5,
                                          ))
                                      .toList())),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                          width: MediaQuery.of(context).size.width,
                          height: 30,
                          child: Stack(children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(18, 0, 0, 5),
                                child: Text(
                                    '⬤  ' + S.of(context).PatientPage_Treatment,
                                    style: TextStyle(
                                        color: Color(0xffC888A8),
                                        fontSize: 16))),
                            Positioned(
                                child: InkWell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.add,
                                        size: 30,
                                        color: Color(0xffF45666),
                                      )),
                                  onTap: () {
                                    showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) =>
                                            SingleChildScrollView(
                                              controller:
                                                  ModalScrollController.of(
                                                      context),
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                child: BlocProvider<
                                                    PatientBloc>.value(
                                                  value: patientBloc,
                                                  child: TreatmentTreeWidget(),
                                                ),
                                              ),
                                            ));
                                  },
                                ),
                                right: 5,
                                top: -10)
                          ]),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.black26),
                              bottom: BorderSide(color: Colors.black26),
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                              child: Wrap(
                                  spacing: 4.0, // gap between adjacent chips
                                  runSpacing: 4.0, // gap between lines
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: selectedTreatment
                                      .map((e) => Chip(
                                            label: Text(
                                              e['label'] ?? "No TagName",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            visualDensity: VisualDensity(
                                                vertical: -4, horizontal: 0),
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            labelPadding: EdgeInsets.all(2),
                                            backgroundColor: Color(0xffF45666),
                                            onDeleted: () => patientBloc.add(
                                                PatientDeleteTreatment(
                                                    e['key']!)),
                                            deleteIcon:
                                                Icon(Icons.close, size: 18),
                                            deleteIconColor: Colors.white,
                                            elevation: 5,
                                          ))
                                      .toList())),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                            width: MediaQuery.of(context).size.width,
                            height: 30,
                            child: Stack(children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 18),
                                  child: Text('⬤  ' + S.of(context).notes,
                                      style: TextStyle(
                                          color: Color(0xffC888A8),
                                          fontSize: 16))),
                              Positioned(
                                  child: InkWell(
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.add,
                                          size: 30,
                                          color: Color(0xffF45666),
                                        )),
                                    onTap: () {
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) =>
                                            SingleChildScrollView(
                                          controller:
                                              ModalScrollController.of(context),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child:
                                                BlocProvider<PatientBloc>.value(
                                                    value: patientBloc,
                                                    child: commonPhrase(
                                                        (label) =>
                                                            callBackSetNotes(
                                                                label))),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  right: 5,
                                  top: -10)
                            ])),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.black26),
                              bottom: BorderSide(color: Colors.black26),
                            ),
                          ),
                          child: TextField(
                            controller: noteController,
                            maxLines: 5,
                            autofocus: true,
                            decoration: InputDecoration(
                                fillColor: Colors.white,
                                hintText: S.of(context).PatientPage_EnterNotes,
                                hintStyle: TextStyle(color: Colors.black26),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(13, 8, 5, 8)),
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
