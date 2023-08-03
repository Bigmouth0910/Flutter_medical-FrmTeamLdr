import 'dart:developer';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/models/patient.model.dart';
import 'package:rxphoto/models/route_models/common_route_model.dart';
import 'package:provider/provider.dart';

class ListElement extends StatefulWidget {
  final Patient? patient;
  ListElement({this.patient});

  @override
  _ListElementState createState() => _ListElementState();
}

class _ListElementState extends State<ListElement> {
  Uint8List decryptedData = Uint8List.fromList([]);
  @override
  void initState() {
    super.initState();
    // getDecryptedImage();
  }

  // void getDecryptedImage() async {
  //   try {
  //     var dir = await getApplicationDocumentsDirectory();
  //     var testdir = await getApplicationSupportDirectory();

  //     print("path ${dir.path}");
  //     var originalPath = "http://10.97.5.38:8100/uploads/patients/" +
  //         widget.patient!.filePath!;
  //     print("original Path : ${originalPath}");
  //     var downloadPath = dir.path + "/" + basename(widget.patient!.filePath!);
  //     await patientController.dioclient.dio.download(originalPath, downloadPath,
  //         onReceiveProgress: (rec, total) {
  //       print("Rec: $rec , Total: $total");

  //       // setState(() {
  //       //   downloading = true;
  //       //   progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
  //       // });
  //     });
  //     var crypt = AesCrypt('my cool password');
  //     var test = crypt.decryptDataFromFileSync(downloadPath);
  //     var ddd = "!11";
  //     setState(() {
  //       decryptedData = crypt.decryptDataFromFileSync(downloadPath);
  //     });
  //     print("Download path: $downloadPath");
  //     // crypt.decryptFile(downloadPath).then((value) {
  //     //   print(value);
  //     // });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    PatientBloc patientBlock = context.read<PatientBloc>();
    return InkWell(
        onTap: () {
          patientBlock.add(PatientSelected(widget.patient!));
          Navigator.of(context).pushNamed(Routes.PATIENT_DETAIL_PAGE);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
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
              color: Color(0xFFFFFFFF)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              //The image
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: widget.patient?.filePath != null &&
                              widget.patient?.filePath != ""
                          ? CachedNetworkImage(
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              imageUrl:
                                  "$patientUrl/${widget.patient?.filePath}",
                              placeholder: (context, url) =>
                                  new CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  new Icon(Icons.error),
                            )
                          : CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/no_people.png'),
                              radius: 30,
                            ))
                  // child: decryptedData.isEmpty
                  //     ? Text("Loading...")
                  //     : CircleAvatar(
                  //         radius: 35.0,
                  //         // backgroundImage: Image.memory(decryptedData).image,
                  //         // backgroundImage:
                  //         //     Image.file(File(imgPath), fit: BoxFit.cover).image,
                  //         backgroundImage: widget.patient?.filePath == null
                  //             ? NetworkImage("$patientUrl/no_people.png")
                  //             : NetworkImage(
                  //                 "$patientUrl/${widget.patient?.filePath}"),
                  //         backgroundColor: Colors.transparent,
                  //       ),
                  ),

              Expanded(
                  child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          //The title
                          Text(
                            widget.patient!.firstName == null
                                ? widget.patient!.lastName ?? ""
                                : (widget.patient!.lastName ?? "") +
                                    widget.patient!.firstName!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(height: 5),
                          //The content
                          Text(
                            widget.patient?.birthDate ?? "",
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFFBFBFBF)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Icon(Icons.keyboard_arrow_right,
                          size: 35, color: Color(0xFF686868)),
                    )
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
