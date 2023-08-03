import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:rxphoto/features/ComparePhoto/ComparePhotoComponent.dart';
import 'package:rxphoto/features/EditPreviewPhoto/editPreviewPhotoPage.dart';
import 'package:rxphoto/features/editCameraImage/ui/injectionInputDialog.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/models/patientImage.model.dart';
import 'package:rxphoto/screens/CPoint.dart';
import 'package:rxphoto/screens/MyCustomPainter.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({Key? key}) : super(key: key);

  @override
  _ComparePageState createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController noteTextController = TextEditingController();
  String toolType = "hand";
  Map<String, List<CPoint>> drawPoints = Map<String, List<CPoint>>();
  int currentDrawOrder = 1;
  double injectionRadius = 20.0;

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
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final patientBloc = context.watch<PatientBloc>();
    // final galleryData = patientBloc.state.galleryData;
    // List<PatientImage> selectedPatientImages = [];
    // galleryData!.entries.forEach((element) {
    //   selectedPatientImages = [
    //     ...selectedPatientImages,
    //     ...element.value.where((e1) => e1.isSelected == true).toList()
    //   ];
    // });
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text("Compare"),
      // ),
      body: Row(
        children: [
          Expanded(
              child: ComparePhotoComponent(
                  patientBloc.state.selectedCompareImages[0], "left")),
          // Container(
          //   width: 10,
          //   color: Colors.black,
          // ),
          Expanded(
              child: ComparePhotoComponent(
                  patientBloc.state.selectedCompareImages[1], "right")),
        ],
      ),
    );
  }
}
