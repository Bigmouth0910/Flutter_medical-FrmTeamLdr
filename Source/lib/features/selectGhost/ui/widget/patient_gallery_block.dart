import 'package:cached_network_image/cached_network_image.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:flutter/material.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/models/patientImage.model.dart';
import 'package:provider/provider.dart';

class PatientGalleryBloc extends StatefulWidget {
  PatientGalleryBloc();

  @override
  _PatientGalleryBlocState createState() => _PatientGalleryBlocState();
}

class _PatientGalleryBlocState extends State<PatientGalleryBloc> {
  @override
  Widget build(BuildContext context) {
    final PatientBloc patientBloc = context.read<PatientBloc>();
    final galleryGhostData = patientBloc.state.galleryGhostData;

    Widget galleryImage(PatientImage photo) {
      return InkWell(
        onTap: () {
          var index = galleryGhostData!.indexOf(photo);
          patientBloc.add(PatientGhostOrderSelected(index));
          Navigator.of(context).pop();
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              boxShadow: [
                photo.isSelected! == false
                    ? BoxShadow(
                        color: Colors.white,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      )
                    : BoxShadow(
                        color: Colors.blue,
                        blurRadius: 8,
                        offset: Offset(0, 1),
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: 0.4,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        color: Colors.white,
                        child: Center(child: Text("${photo.bodyPartTitle}"))),
                  ),
                )
              ],
            )),
      );
    }

    return Container(
      color: Color(0xff474649),
      child: Column(
        children: [
          // Container(
          //     padding: EdgeInsets.all(10),
          //     height: 40,
          //     child: Text("${widget.header}",
          //         style: TextStyle(fontSize: 18, color: Colors.white)),
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [
          //           Colors.red,
          //           Colors.transparent,
          //           Colors.transparent,
          //           Colors.blue
          //         ],
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter,
          //         stops: [0, 0, 0, 1],
          //       ),
          //     ),
          //     width: MediaQuery.of(context).size.width),
          Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
              child: galleryGhostData != null
                  ? Wrap(
                      children:
                          galleryGhostData.map((e) => galleryImage(e)).toList())
                  : null)
        ],
      ),
    );
  }
}
