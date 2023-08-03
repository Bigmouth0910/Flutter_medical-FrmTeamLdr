import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxphoto/features/patientDetail/ui/widget/UploadPhoto.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class DetailListElement extends StatefulWidget {
  bool? isUncategorized;
  int? order;
  int? partFor;
  int? sectionLength;
  String? patientBodyPartImage;
  int? partId = 0;

  DetailListElement({
    this.isUncategorized,
    this.order,
    this.partFor,
    this.sectionLength,
    this.patientBodyPartImage,
    this.partId,
  });

  @override
  _DetailListElementState createState() => _DetailListElementState();
}

class _DetailListElementState extends State<DetailListElement> {
  @override
  final ImagePicker _picker = ImagePicker();

  Widget build(BuildContext context) {
    final patientBloc = context.watch<PatientBloc>();
    final bodyparts = patientBloc.state.bodyparts;
    final currentBodyPart = widget.partFor == null || widget.order == null
        ? null
        : bodyparts
            .where((element) => element.partsFor == widget.partFor!)
            .toList()[widget.order!];
    return InkWell(
        onTap: () {
          if (!widget.isUncategorized!) {
            final SimpleDialog dialog = new SimpleDialog(
              title: Text(
                S.of(context).PatientDetailPage_SelectPhotoTakingMethod,
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xffF45666)),
              ),
              children: <Widget>[
                new SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    patientBloc.add(PatientBodyPartOrderSelected(
                        widget.order!, widget.sectionLength!, widget.partFor!));
                    patientBloc
                        .add(PatientPhotoTakingMethodSelected("template"));
                    // Navigator.pushNamed(context, Routes.EDITCAMERA_PAGE);
                    Navigator.pushNamed(context, Routes.CAMERA_PAGE);
                  },
                  child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Text(S.of(context).PatientDetailPage_ByTemplate,
                          style: TextStyle(fontSize: 18))),
                ),
                widget.patientBodyPartImage != null
                    ? new SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context);
                          patientBloc.add(PatientBodyPartOrderSelected(
                              widget.order!,
                              widget.sectionLength!,
                              widget.partFor!));
                          patientBloc
                              .add(PatientPhotoTakingMethodSelected("ghost"));
                          Navigator.pushNamed(context, Routes.CAMERA_PAGE);
                        },
                        child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Text(S.of(context).PatientDetailPage_ByGhost,
                                style: TextStyle(fontSize: 18))),
                      )
                    : Container(),
                new SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(context);
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      var _image = image.path;
                      File file = File(_image);
                      var lastModDate = await file.lastModified();
                      var tt = file.lastModifiedSync();

                      String fileName = file.path.split('/').last;
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return BlocProvider<PatientBloc>.value(
                                value: patientBloc,
                                child: UploadPhotoDialog(
                                    shootingTime:
                                        DateFormat('yyyy-MM-dd hh:mm:ss a')
                                            .format(lastModDate),
                                    selectedBodyPartValue: widget.partId,
                                    selectedBodyCategoryValue: widget.partFor,
                                    uploadingFilePath: _image));
                          });
                    }
                  },
                  child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Text(S.of(context).PatientDetailPage_ByUpload,
                          style: TextStyle(fontSize: 18))),
                ),
              ],
            );
            showDialog(
                context: context, builder: (BuildContext context) => dialog);
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Color(0xffFF91A6), width: 1)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              //The image
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: widget.isUncategorized!
                          ? CachedNetworkImage(
                              httpHeaders: {"Authorization": authString},
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              imageUrl:
                                  "$patientImgUrl/${widget.patientBodyPartImage}",
                              placeholder: (context, url) =>
                                  new CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  new Icon(Icons.error),
                            )
                          : CachedNetworkImage(
                              httpHeaders: {"Authorization": authString},
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              imageUrl: (widget.patientBodyPartImage != null &&
                                      widget.patientBodyPartImage != '')
                                  ? "$patientImgUrl/${widget.patientBodyPartImage}"
                                  : "$bodyPartUrl/${currentBodyPart!.photoImagePath}",
                              placeholder: (context, url) =>
                                  new CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  new Icon(Icons.error),
                            ))),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 20),
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          //The title
                          widget.isUncategorized!
                              ? Container()
                              : Text(
                                  currentBodyPart!.title ?? "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff686868)),
                                ),
                          Container(
                            height: 10,
                          ),
                          //The content
                          Text(
                            (widget.patientBodyPartImage != null &&
                                    widget.patientBodyPartImage != '')
                                ? S.of(context).updated
                                : S.of(context).notUpdated,
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                color: (widget.patientBodyPartImage != null &&
                                        widget.patientBodyPartImage != '')
                                    ? Color(0xffFF91A6)
                                    : Color(0xffBFBFBF)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Icon(Icons.keyboard_arrow_right,
                          size: 35, color: Color(0xff686868)),
                    )
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
