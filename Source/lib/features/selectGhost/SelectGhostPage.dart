import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:provider/provider.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/selectGhost/ui/widget/patient_gallery_block.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/generated/l10n.dart';

class SelectGhostPage extends StatefulWidget {
  const SelectGhostPage({Key? key}) : super(key: key);

  @override
  _SelectGhostPageState createState() => _SelectGhostPageState();
}

class _SelectGhostPageState extends State<SelectGhostPage> {
  String currentSortValue = "Date";

  @override
  void initState() {
    final patientBloc = context.read<PatientBloc>();
    patientBloc.add(PatientGalleryDataRequested("GhostDate"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final patientBloc = context.watch<PatientBloc>();
    final galleryGhostData = patientBloc.state.galleryGhostData;

    return SafeArea(
        child: Scaffold(
            backgroundColor: Color(0xff474649),
            appBar: AppBar(
              title: Text("Back"),
            ),
            body: galleryGhostData != null && galleryGhostData.length != 0
                ? (Column(
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              child: PatientGalleryBloc()))
                    ],
                  ))
                : Center(
                    child: Text(S.of(context).noPatientImage,
                        style: TextStyle(fontSize: 20)))));
  }
}
