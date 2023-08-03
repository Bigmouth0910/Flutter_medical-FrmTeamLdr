import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxphoto/features/patientDetail/bloc/patientdetail_bloc.dart';
import 'package:rxphoto/features/patientDetail/ui/widget/MedicalHistoryDialog.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rxphoto/models/medicalhistory.model.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:rxphoto/models/treatment.model.dart';
import 'package:rxphoto/models/diagnosis.model.dart';

class MedicalHistoryItem extends StatefulWidget {
  MedicalHistory? medicalHistory;
  MedicalHistoryItem({this.medicalHistory});

  @override
  _MedicalHistoryItemState createState() => _MedicalHistoryItemState();
}

class _MedicalHistoryItemState extends State<MedicalHistoryItem> {
  @override
  Widget build(BuildContext context) {
    final patientBloc = context.watch<PatientBloc>();
    // get diagnosis str from list of diagnosis ID
    final diagnosisList = patientBloc.state.diagnosisNormalList;
    var attend = patientBloc.state.doctors.firstWhere((element) =>
        element.id.toString() == widget.medicalHistory!.attendingPhysician);
    var attendingStr = (attend.firstName ?? "") + " " + (attend.lastName ?? "");
    var diagnosisStr = widget.medicalHistory!.diagnosis.toString() == ""
        ? ""
        : widget.medicalHistory!.diagnosis
            .toString()
            .split(" ")
            .map((e) {
              var foundDiagnosis = diagnosisList.firstWhere(
                  (element) => element.id.toString() == e.toString(),
                  orElse: () {
                return Diagnosis(
                    id: 0,
                    tagName: '',
                    createDate: '',
                    lastUpdateDate: '',
                    children: []);
              });
              return foundDiagnosis.tagName.toString();
            })
            .toList()
            .join(" ");
    // get treatment str from list of treatment ID
    final treatmentList = patientBloc.state.treatmentNormalList;
    var treatmentStr = widget.medicalHistory!.treatment.toString() == ""
        ? ""
        : widget.medicalHistory!.treatment
            .toString()
            .split(" ")
            .map((e) {
              var foundTreatment = treatmentList.firstWhere(
                  (element) => element.id.toString() == e.toString(),
                  orElse: () {
                return Treatment(
                    id: 0,
                    tagName: '',
                    createDate: '',
                    lastUpdateDate: '',
                    children: []);
              });
              return foundTreatment.tagName.toString();
            })
            .toList()
            .join(" ");

    return InkWell(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 255, 145, 166),
                blurRadius: 3.0,
                spreadRadius: 0.0,
                offset: Offset(
                  0.0,
                  0.0,
                ),
              ),
            ],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text("$attendingStr",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 18, color: Color(0xffBFBFBF))),
                ),
                Text(widget.medicalHistory!.dateOfVisit ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, color: Color(0xffF45666)))
              ]),
              // SizedBox(height: 5),
              // Row(children: [
              //   Text("Diagnosis: ",
              //       overflow: TextOverflow.ellipsis,
              //       style: TextStyle(fontSize: 18)),
              //   Expanded(
              //     child: Text(diagnosisStr,
              //         overflow: TextOverflow.ellipsis,
              //         style: TextStyle(fontSize: 18)),
              //   ),
              // ]),
              SizedBox(height: 5),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(S.of(context).tx + '    ',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff686868),
                        fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(treatmentStr,
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 18, color: Color(0xff686868))),
                ),
              ]),
              SizedBox(height: 5),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(S.of(context).dx + '    ',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff686868),
                        fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(diagnosisStr,
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 18, color: Color(0xff686868))),
                ),
              ]),
              SizedBox(height: 5),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(S.of(context).notes + '    ',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff686868),
                        fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(widget.medicalHistory!.notes ?? "",
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 18, color: Color(0xff686868))),
                ),
              ]),
              SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                    onPressed: () async {
                      patientBloc.add(
                          MedicalHistoryDataUpdated(widget.medicalHistory!));
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return BlocProvider<PatientBloc>.value(
                                value: patientBloc,
                                child: MedicalHistoryDialog());
                          });
                    },
                    icon: Icon(Icons.edit, color: Color(0xffC888A8)),
                    iconSize: 30.0),
                Visibility(
                    visible:
                        patientBloc.getUser().role_type == 1 ? true : false,
                    child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Color(0xffF45666),
                        ),
                        onPressed: () async {
                          final value = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content:
                                      Text(S.of(context).sureToDeleteHistory),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        S.of(context).cancel,
                                        style: TextStyle(
                                            color: Color(0xffF45666),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: Text(S.of(context).delete,
                                          style: TextStyle(
                                              color: Color(0xffF45666),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              });
                          if (value! == true) {
                            patientBloc.add(
                                MedicalDataRemoved(widget.medicalHistory!.id));
                          }
                        })),
              ])
            ],
          ),
        ));
  }
}
