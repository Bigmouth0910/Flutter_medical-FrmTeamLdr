import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/homeCamera/camera_page.dart';
import 'package:rxphoto/features/normalCamera/camera_page.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/features/patient/ui/widgets/custom_search_delegate.dart';
import 'package:rxphoto/features/patient/ui/widgets/list_element.dart';
import 'package:rxphoto/features/patient/ui/widgets/historyDialog.dart/index.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:rxphoto/models/patient.model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class PatientPage extends StatefulWidget {
  PatientPage();
  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  int? orderBy = 0;
  File? imageFile;
  final _pageController = PageController(initialPage: 1);
  List<Widget> _getListElements(List<Patient> allPatients) {
    List<Widget> widgets = [];
    for (var patient in allPatients) {
      widgets.add(ListElement(patient: patient));
    }
    return widgets;
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
  }

  Future<File?> takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      return null;
    }

    File file = File(image.path);

    return file;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final patientBloc = context.watch<PatientBloc>();
    final patientsOrder = <PatientOrder>[
      PatientOrder(0, S.of(context).PatientPage_NewToOld),
      PatientOrder(1, S.of(context).PatientPage_OldToNew)
    ];
    List<DropdownMenuItem<int>> orderByItems = patientsOrder
        .map((e) => DropdownMenuItem(
            child: Container(
                width: 200,
                child: Text((e.value), textAlign: TextAlign.center)),
            value: e.id))
        .toList();

    return SafeArea(
      child: PageView(
        controller: _pageController,
        onPageChanged: (value) async {},
        children: [
          HomeCameraPage(),
          Scaffold(
            appBar: AppBar(
              toolbarHeight: 70,
              backgroundColor: Color.fromARGB(255, 255, 145, 166),
              automaticallyImplyLeading: false,
              title: Text(S.of(context).PatientPage_patients,
                  style: TextStyle(fontSize: 25)),
              actions: [
                IconButton(
                  onPressed: () async {
                    patientBloc.add(MedicalHistoryDataRequested());
                    await showSearch<List<Patient>>(
                        context: context,
                        delegate: CustomSearchDelegate(
                            "text",
                            patientBloc.state.diagnosis,
                            patientBloc.state.treatments));
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                // IconButton(
                //   padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                //   onPressed: () {
                //     showDialog<String>(
                //         context: context,
                //         builder: (BuildContext context) {
                //           int selectedRadio = Intl.getCurrentLocale() == "en" ? 1 : 2;

                //           return AlertDialog(
                //             content: StatefulBuilder(
                //               builder: (BuildContext context, StateSetter setState) {
                //                 return Column(
                //                     mainAxisSize: MainAxisSize.min,
                //                     children: [
                //                       Text(S.of(context).PatientPage_languageChoose,
                //                           style: TextStyle(fontSize: 18)),
                //                       InkWell(
                //                         onTap: () async {
                //                           setState(() {
                //                             selectedRadio = 1;
                //                           });
                //                           Navigator.pop(context, "en");
                //                         },
                //                         child: Row(
                //                           children: [
                //                             Radio<int>(
                //                                 value: 1,
                //                                 groupValue: selectedRadio,
                //                                 onChanged: (int? value) {
                //                                   setState(
                //                                       () => selectedRadio = value!);
                //                                 }),
                //                             Text("English",
                //                                 style: TextStyle(fontSize: 16)),
                //                           ],
                //                         ),
                //                       ),
                //                       InkWell(
                //                         onTap: () async {
                //                           setState(() {
                //                             selectedRadio = 2;
                //                           });
                //                           Navigator.pop(context, "zh");
                //                         },
                //                         child: Row(
                //                           children: [
                //                             Radio<int>(
                //                                 value: 2,
                //                                 groupValue: selectedRadio,
                //                                 onChanged: (int? value) {
                //                                   setState(
                //                                       () => selectedRadio = value!);
                //                                 }),
                //                             Text("中国语",
                //                                 style: TextStyle(fontSize: 16)),
                //                           ],
                //                         ),
                //                       ),
                //                     ]);
                //               },
                //             ),
                //           );
                //         }).then((language) {
                //       if (language != "") {
                //         setState(() {
                //           S.load(Locale(language!));
                //         });
                //       }
                //     });
                //   },
                //   icon: const Icon(
                //     Icons.settings,
                //     color: Colors.white,
                //     size: 30,
                //   ),
                // ),
                IconButton(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  onPressed: () {
                    patientBloc.add(PatientDataRequested(
                        orderBy: orderBy == 0 ? 'new' : 'old'));
                  },
                  icon: const Icon(
                    Icons.sync,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(S.of(context).logOut),
                            content: Text(S.of(context).logOutContent),
                            actions: <Widget>[
                              ElevatedButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Color(0xffF4568C)),
                                child: Text(S.of(context).logOut),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      Routes.LOGIN_PAGE, (route) => false);
                                },
                              ),
                              ElevatedButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Color(0xffF4568C)),
                                child: Text(S.of(context).cancel),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                  icon: const Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            body: BlocListener<PatientBloc, PatientState>(
              listener: (context, state) {
                if (state.status == PatientStatus.patientCreated) {
                  AlertController.show(S.of(context).success,
                      S.of(context).newPatientCreateSuccess, TypeAlert.success);
                } else if (state.status == PatientStatus.patientCreateFailure) {
                  AlertController.show(S.of(context).failed,
                      S.of(context).newPatientCreateFailed, TypeAlert.success);
                }
              },
              child: BlocBuilder<PatientBloc, PatientState>(
                builder: (context, state) {
                  if (state.status == PatientStatus.initial) {
                    patientBloc.add(PatientDataRequested());
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state.status == PatientStatus.loading) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Stack(children: [
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 28),
                            child: DropdownButton(
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 16),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    orderBy = newValue;

                                    patientBloc.add(PatientDataRequested(
                                        orderBy: orderBy == 0 ? 'new' : 'old'));
                                  });
                                },
                                alignment: Alignment.center,
                                value: orderBy,
                                items: orderByItems),
                          ),
                          Expanded(
                              child: Container(
                            child: ListView(
                              children: _getListElements(state.patients),
                            ),
                          ))
                        ],
                      ),
                      Positioned(
                        left: -30,
                        bottom: MediaQuery.of(context).size.height / 2 - 60,
                        child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                _pageController.jumpToPage(0);
                              },
                              child: Image.asset(
                                'assets/images/camera.png',
                                width: 60,
                              ),
                            )),
                      ),
                    ]);
                  }
                },
              ),
            ),
            floatingActionButton: !(patientBloc.state.status ==
                        PatientStatus.initial ||
                    patientBloc.state.status == PatientStatus.loading)
                ? FloatingActionButton(
                    onPressed: () async {
                      patientBloc.add(PatientDialogInputStarted(
                          isFormatSelectedPatient: true));
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return BlocProvider<PatientBloc>.value(
                                value: patientBloc, child: HistoryDialog());
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xffF45666),
                          borderRadius: BorderRadius.circular(5),
                          border:
                              Border.all(width: 2, color: Color(0xffF45666))),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    backgroundColor: Color(0xffF45666),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        ],
      ),
    );
  }
}
