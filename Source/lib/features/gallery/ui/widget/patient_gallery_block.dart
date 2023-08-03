import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:flutter/material.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/models/medicalhistory.model.dart';
import 'package:rxphoto/models/patientImage.model.dart';
import 'package:provider/provider.dart';

class PatientGalleryBloc extends StatefulWidget {
  String? header;
  String? type;
  List<PatientImage>? images;
  PatientGalleryBloc({this.header, this.images, this.type});

  @override
  _PatientGalleryBlocState createState() => _PatientGalleryBlocState();
}

class _PatientGalleryBlocState extends State<PatientGalleryBloc> {
  @override
  Widget build(BuildContext context) {
    final PatientBloc patientBloc = context.read<PatientBloc>();

    if (widget.type == 'Medical Records') {
      final List<MedicalHistory> medicalHis = patientBloc.state.medicalHistory
          .where((element) => element.id.toString() == widget.header)
          .toList();

      if (medicalHis.length != 0) {
        String treatmentStr = medicalHis[0].treatment.toString() == ""
            ? ""
            : medicalHis[0]
                .treatment
                .toString()
                .split(" ")
                .map((e) {
                  var foundTreatment = patientBloc.state.treatmentNormalList
                      .firstWhere(
                          (element) => element.id.toString() == e.toString());
                  if (foundTreatment != null)
                    return foundTreatment.tagName.toString();
                  else
                    return "";
                })
                .toList()
                .join(" ");

        setState(() {
          widget.header = '${medicalHis[0].dateOfVisit} (${treatmentStr})';
        });
      }
    }

    Widget galleryImage(PatientImage photo) {
      return GestureDetector(
        onDoubleTap: () {
          patientBloc.add(GalleryPatientImageDblSelected(photo));
          patientBloc.add(BeforeWindowTypeChanged("singlegallery"));
          Navigator.of(context).pushNamed(Routes.EDIT_PREVIEW_PHOTO);
        },
        onTap: () {
          patientBloc.add(PatientGalleryPatientSelected(photo));
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffF45666), width: 2),
              boxShadow: [
                photo.isSelected! == false
                    ? BoxShadow(
                        color: Colors.white,
                        blurRadius: 2,
                        offset: Offset(0, 0),
                      )
                    : BoxShadow(
                        color: Color(0xffF45666),
                        blurRadius: 8,
                        offset: Offset(0, 0),
                      ),
              ],
            ),
            width: 110,
            height: 150,
            margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
            child: Stack(
              children: [
                Opacity(
                  opacity: photo.isSelected! == true ? 0.4 : 1,
                  child: CachedNetworkImage(
                    httpHeaders: {"Authorization": authString},
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    imageUrl: "$patientImgUrl/${photo.photoUrl}",
                    placeholder: (context, url) =>
                        new CircularProgressIndicator(),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                ),
                if (patientBloc.state.isNormalGallery == true)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: 0.4,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          color: Colors.white,
                          child: Center(
                              child: widget.type == "Area"
                                  ? Text(
                                      "${photo.medicalHistoryNo}\n${photo.createDate}",
                                      textAlign: TextAlign.center,
                                    )
                                  : (widget.type == 'Date'
                                      ? Text(
                                          "${photo.medicalHistoryNo}\n${photo.bodyPartTitle}",
                                          textAlign: TextAlign.center)
                                      : Text(
                                          "${photo.bodyPartTitle}\n${photo.createDate}",
                                          textAlign: TextAlign.center)))),
                    ),
                  )
              ],
            )),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.all(10),
              height: 40,
              child: Text("${widget.header}",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffFFC5CB), Color(0xffF45666)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              width: MediaQuery.of(context).size.width),
          Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
              child: Wrap(
                  children: widget.images!
                      .asMap()
                      .entries
                      .map((e) => galleryImage(e.value))
                      .toList()))
        ],
      ),
    );
  }
}
