import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:provider/provider.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/gallery/ui/widget/patient_gallery_block.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/features/patientDetail/ui/widget/UploadMultiPhotos.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:rxphoto/models/patientImage.model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:rxphoto/features/patientDetail/ui/widget/UploadPhoto.dart';
import 'package:intl/intl.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String currentSortValue = "Date";
  bool orderBy = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    final patientBloc = context.read<PatientBloc>();
    patientBloc.add(PatientGalleryDataRequested("Date"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final patientBloc = context.watch<PatientBloc>();
    final galleryData = patientBloc.state.galleryData;

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Color(0xffFF91A6),
              title: patientBloc.state.isNormalGallery == true
                  ? Text(
                      "${patientBloc.state.selectedPatient!.firstName}, ${patientBloc.state.selectedPatient!.lastName}  ")
                  : Text(S.current.temporaryStorage),
              actions: [
                if (patientBloc.state.isNormalGallery == true)
                  IconButton(
                      onPressed: () async {
                        final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (image != null) {
                          var _image = image.path;
                          File file = File(_image);
                          var lastModDate = await file.lastModified();
                          var tt = file.lastModifiedSync();

                          String fileName = file.path.split('/').last;
                          await showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return BlocProvider<PatientBloc>.value(
                                    value: patientBloc,
                                    child: UploadPhotoDialog(
                                        shootingTime:
                                            DateFormat('yyyy-MM-dd hh:mm:ss a')
                                                .format(lastModDate),
                                        uploadingFilePath: _image));
                              });

                          patientBloc.add(PatientGalleryDataRequested("Date"));
                        }
                      },
                      icon: Icon(Icons.add)),
                if (patientBloc.state.isNormalGallery == true)
                  IconButton(
                      onPressed: () {
                        var galleryData = patientBloc.state.galleryData;
                        var selectedItemLength = 0;

                        List<PatientImage> selectedPatientImages = [];
                        galleryData!.entries.forEach((element) {
                          selectedPatientImages = [
                            ...selectedPatientImages,
                            ...element.value
                                .where((e1) => e1.isSelected == true)
                                .toList()
                          ];
                        });
                        selectedItemLength = selectedPatientImages.length;
                        // galleryData!.entries.forEach((element) {
                        //   selectedItemLength += element.value
                        //       .where((e1) => e1.isSelected == true)
                        //       .toList()
                        //       .length;
                        // });
                        if (selectedItemLength != 2) {
                          AlertController.show(S.current.error,
                              S.current.twoPhotoForCompare, TypeAlert.error);
                        } else {
                          patientBloc.add(ComparePatientImageSelected(
                              selectedPatientImages));
                          patientBloc
                              .add(BeforeWindowTypeChanged("twogallery"));
                          Navigator.of(context).pushNamed(Routes.COMPARE_PAGE);
                        }
                      },
                      icon: Icon(Icons.compare)),
                if (patientBloc.state.isNormalGallery == true)
                  IconButton(
                      onPressed: () {
                        var galleryData = patientBloc.state.galleryData;
                        var selectedItemLength = 0;
                        galleryData!.entries.forEach((element) {
                          selectedItemLength += element.value
                              .where((e1) => e1.isSelected == true)
                              .toList()
                              .length;
                        });
                        if (selectedItemLength != 2) {
                          AlertController.show(S.current.error,
                              S.current.twoPhotoForReport, TypeAlert.error);
                        } else {
                          Navigator.of(context).pushNamed(Routes.REPORT_PAGE);
                        }
                      },
                      icon: Icon(Icons.download)),
                if (patientBloc.state.isNormalGallery == false)
                  InkWell(
                    onTap: () {
                      List<PatientImage> selectedPatientImages = [];
                      galleryData!.entries.forEach((element) {
                        selectedPatientImages = [
                          ...selectedPatientImages,
                          ...element.value
                              .where((e1) => e1.isSelected == true)
                              .toList()
                        ];
                      });

                      Navigator.of(context).pop();

                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return BlocProvider<PatientBloc>.value(
                                value: patientBloc,
                                child:
                                    UploadMultiPhotos(selectedPatientImages));
                          });
                    },
                    child: Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        child: Text(
                          S.current.ok,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        )),
                  )
              ],
            ),
            body: galleryData != null && galleryData.entries.length != 0
                ? (Column(
                    children: [
                      filterToolbar(patientBloc),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: galleryData.entries
                              .map((e) => PatientGalleryBloc(
                                  header: e.key,
                                  images: e.value,
                                  type: currentSortValue))
                              .toList(),
                        ),
                      ))
                    ],
                  ))
                : Center(
                    child: Text(S.of(context).NoPhoto,
                        style: TextStyle(fontSize: 20)))));
  }

  Widget filterToolbar(PatientBloc patientBloc) {
    if (patientBloc.state.isNormalGallery == false) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          child: InkWell(
              onTap: () {
                setState(() {
                  orderBy = !orderBy;
                });

                patientBloc.add(PatientGalleryDataRequested(currentSortValue,
                    orderBy: orderBy));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    S.current.date,
                    style: TextStyle(color: Color(0xff686868), fontSize: 18),
                  ),
                  orderBy == true
                      ? Icon(Icons.arrow_downward_outlined,
                          color: Color(0xff686868))
                      : Icon(Icons.arrow_upward_outlined,
                          color: Color(0xff686868))
                ],
              )));
    }

    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.white54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(S.of(context).sortBy + ' ', style: TextStyle(fontSize: 15)),
              DropdownButton<String>(
                // dropdownColor: Colors.black87,
                // underline: Container(),
                value: currentSortValue,
                items: <String>['Date', 'Area', 'Medical Records']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == "Date"
                        ? S.current.date
                        : (value == 'Area'
                            ? S.current.bodyPart
                            : S.current.PatientPage_medicalHistory)),
                  );
                }).toList(),
                onChanged: (value) {
                  context
                      .read<PatientBloc>()
                      .add(PatientGalleryDataRequested(value!));
                  setState(() {
                    currentSortValue = value;
                  });
                },
                hint: Text("Sort by"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
