import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:rxphoto/common/routes/routes.dart';
import 'package:rxphoto/features/patient/bloc/patient_bloc.dart';
import 'package:rxphoto/features/patientDetail/ui/widget/DetailListElement.dart';
import 'package:rxphoto/features/patientDetail/ui/widget/MedicalHistoryItem.dart';
import 'package:rxphoto/features/patientDetail/ui/widget/MedicalHistoryDialog.dart';
import 'package:rxphoto/features/patientDetail/ui/widget/FilterDialog.dart';
import 'package:rxphoto/features/patientDetail/ui/widget/UploadMultiPhotos.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:rxphoto/models/diagnosis.model.dart';
import 'package:rxphoto/models/patientImage.model.dart';
import 'package:rxphoto/models/treatment.model.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:images_picker/images_picker.dart';

class PatientDetailPage extends StatefulWidget {
  PatientDetailPage();
  final SlidableBarController controller =
      SlidableBarController(initialStatus: false);

  @override
  _PatientDetailPageState createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController suggestionController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String noteContent = "";
  TabController? _controller;
  String currentTabName = "";
  List<Widget> photosList = [];

  @override
  void initState() {
    super.initState();
    final patientBloc = context.read<PatientBloc>();
    _controller = TabController(
        length: patientBloc.state.bodypartList.length, vsync: this);

    _controller!.addListener(() {
      var selectedTabName =
          patientBloc.state.bodypartList[_controller!.index].name ?? "";
      setState(() {
        currentTabName = selectedTabName;
      });
      patientBloc.add(PatientImageBodyPartTypeSelected(selectedTabName));
      print("Selected Index: " + _controller!.index.toString());
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientBloc = context.watch<PatientBloc>();
    final selectedPatient = patientBloc.state.selectedPatient;
    var bodyparts = patientBloc.state.bodyparts;
    var patientImages = patientBloc.state.patientImages;
    var medicalHistory = patientBloc.state.medicalHistory;
    var bodypartList = patientBloc.state.bodypartList;

    var firstName = selectedPatient != null ? selectedPatient.firstName : "";
    var lastName = selectedPatient != null ? selectedPatient.lastName : "";
    var patientName = (lastName ?? "") + (firstName ?? "");
    var treatmentList = patientBloc.state.treatmentNormalList;

    List<DropdownMenuItem<int>> getMedicalSuggestions() {
      List<DropdownMenuItem<int>> widgets = [];

      if (patientBloc.state.medicalHistory.length != 0) {
        for (var item in patientBloc.state.medicalHistory) {
          var treatmentStr = item.treatment.toString() == ""
              ? ""
              : item.treatment
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

          widgets.add(DropdownMenuItem(
              child: Container(
                  child: Text(
                      '${item.dateOfVisit.toString()} (${treatmentStr})',
                      textAlign: TextAlign.left)),
              value: item.id));
        }
      }

      return widgets;
    }

    List<DropdownMenuItem<String>> medicalSuggestions = medicalHistory
        .map((e) => DropdownMenuItem(
            child: Container(
                width: 200,
                child: Text(
                    '${e.medicalHistoryNo} (${e.dateOfVisit.toString()} - ${e.treatment})',
                    textAlign: TextAlign.left)),
            value: e.medicalHistoryNo))
        .toList();

    List<Widget> getListElements(
        bool isUncategorized, int sectionLength, int section) {
      List<Widget> widgets = [];
      if (isUncategorized) {
        var filteredList = patientImages
            .where((element) =>
                element.patientId! == selectedPatient!.id &&
                element.isUncategorized == 1 &&
                element.medicalHistoryId == patientBloc.state.curMedicalNo)
            .toList();
        List<PatientImage> cresult = filteredList.toList();
        cresult.sort((a, b) {
          return a.lastUpdateDate!.compareTo(b.lastUpdateDate!);
        });
        for (int i = 0; i < cresult.length; i++) {
          widgets.add(DetailListElement(
              isUncategorized: isUncategorized,
              sectionLength: sectionLength,
              partFor: section,
              patientBodyPartImage: cresult[i].photoUrl));
        }
      } else {
        bodyparts
            .where((element) => element.partsFor == section)
            .toList()
            .asMap()
            .forEach((key, value) {
          var filteredList = patientImages.where((element) =>
              element.patientId! == selectedPatient!.id &&
              element.bodyPartId == value.id &&
              element.medicalHistoryId == patientBloc.state.curMedicalNo);

          var filteredHistoryList = patientImages.where((element) =>
              element.patientId! == selectedPatient!.id &&
              element.bodyPartId == value.id);

          if (filteredList.isNotEmpty) {
            List<PatientImage> cresult = filteredList.toList();
            cresult.sort((a, b) {
              return a.lastUpdateDate!.compareTo(b.lastUpdateDate!);
            });
            widgets.add(DetailListElement(
                isUncategorized: isUncategorized,
                sectionLength: sectionLength,
                partFor: section,
                order: key,
                partId: value.id,
                patientBodyPartImage: cresult[cresult.length - 1].photoUrl));
          } else {
            widgets.add(DetailListElement(
                isUncategorized: isUncategorized,
                sectionLength: sectionLength,
                order: key,
                partFor: section,
                partId: value.id,
                patientBodyPartImage:
                    filteredHistoryList.isNotEmpty ? '' : null));
          }
        });
      }
      return widgets;
    }

    List<Widget> getMedicalHistoryList() {
      List<Widget> widgets = [];
      if (medicalHistory.length != 0) {
        if (patientBloc.state.filterDoctor != 0) {
          medicalHistory = medicalHistory.where((e) {
            return e.attendingPhysician.toString() ==
                patientBloc.state.filterDoctor.toString();
          }).toList();
        }

        if (patientBloc.state.filterBody != 0) {
          medicalHistory = medicalHistory.where((history) {
            return patientBloc.state.patientImages
                    .where((image) {
                      return patientBloc.state.bodyparts
                              .where((part) {
                                return image.bodyPartId == part.id &&
                                    part.partsFor ==
                                        patientBloc.state.filterBody;
                              })
                              .toList()
                              .length !=
                          0;
                    })
                    .toList()
                    .length !=
                0;
          }).toList();
        }

        if (patientBloc.state.filterHasPhoto != 0) {
          medicalHistory = medicalHistory.where((history) {
            bool flag = patientBloc.state.patientImages
                    .where((image) {
                      return image.medicalHistoryId == history.id;
                    })
                    .toList()
                    .length !=
                0;

            if (flag == true && patientBloc.state.filterHasPhoto == 1)
              return true;
            if (flag == false && patientBloc.state.filterHasPhoto == 2)
              return true;

            return false;
          }).toList();
        }

        if (patientBloc.state.filterInterval != 0) {
          medicalHistory = medicalHistory.where((e) {
            if (e.dateOfVisit == null) return false;

            DateTime dateOfVisit = DateTime.parse(e.dateOfVisit!);
            DateTime from = DateTime.now().subtract(const Duration(days: 7));
            DateTime to = DateTime.now();

            if (patientBloc.state.filterInterval == 2) {
              from = DateTime.now().subtract(const Duration(days: 30));
            } else if (patientBloc.state.filterInterval == 3) {
              from = DateTime.now().subtract(const Duration(days: 92));
            } else if (patientBloc.state.filterInterval == 4) {
              from = DateTime.now().subtract(const Duration(days: 365));
            } else if (patientBloc.state.filterInterval == 5) {
              from = DateTime.now().subtract(const Duration(days: 365 * 10));
              to = DateTime.now().subtract(const Duration(days: 365));
            }

            return dateOfVisit.compareTo(from) >= 0 &&
                dateOfVisit.compareTo(to) <= 0;
          }).toList();
        }

        if (patientBloc.state.filterKeywords != '') {
          medicalHistory = medicalHistory.where((history) {
            var treatmentStr = history.treatment.toString() == ""
                ? ""
                : history.treatment
                    .toString()
                    .split(" ")
                    .map((e) {
                      var foundTreatment = patientBloc.state.treatmentNormalList
                          .firstWhere(
                              (element) =>
                                  element.id.toString() == e.toString(),
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

            var diagnosisStr = history.diagnosis.toString() == ""
                ? ""
                : history.diagnosis
                    .toString()
                    .split(" ")
                    .map((e) {
                      var foundDiagnosis = patientBloc.state.diagnosisNormalList
                          .firstWhere(
                              (element) =>
                                  element.id.toString() == e.toString(),
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

            if (history.notes
                        .toString()
                        .indexOf(patientBloc.state.filterKeywords.toString()) >=
                    0 ||
                treatmentStr
                        .indexOf(patientBloc.state.filterKeywords.toString()) >=
                    0 ||
                diagnosisStr
                        .indexOf(patientBloc.state.filterKeywords.toString()) >=
                    0) {
              return true;
            }

            return false;
          }).toList();
        }

        medicalHistory.sort((a, b) {
          if (a.lastUpdateDate != null && b.lastUpdateDate != null)
            return -a.lastUpdateDate!.compareTo(b.lastUpdateDate!);
          return 0;
        });
        for (var item in medicalHistory) {
          widgets.add(MedicalHistoryItem(medicalHistory: item));
        }
      }
      return widgets;
    }

    List<Tab> getTabs() {
      List<Tab> _tabs = [];
      for (int i = 0; i < bodypartList.length; i++) {
        _tabs.add(Tab(text: bodypartList[i].name));
      }
      return _tabs;
    }

    List<Widget> getTabContent() {
      List<Widget> _widget = [];
      for (int i = 0; i < bodypartList.length; i++) {
        var sectionLength = bodyparts
            .where((element) => element.partsFor == bodypartList[i].id)
            .toList()
            .length;
        bool isUncategorized =
            bodypartList[i].name!.toLowerCase() == "uncategorized"
                ? true
                : false;
        _widget.add(ListView(
          children: getListElements(
              isUncategorized, sectionLength, bodypartList[i].id),
        ));
      }
      return _widget;
    }

    Widget sourceDialogBuilder(BuildContext context) {
      return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 240,
              height: 30,
              margin: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                  color: Color(0xffCBCBCB),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15))),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              width: 300,
              child: Column(children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  S.current.photoSource,
                  style: TextStyle(color: Color(0xffF45666), fontSize: 22),
                ),
                SizedBox(
                  height: 40,
                ),
                InkWell(
                    onTap: () async {
                      List<Media>? images = await ImagesPicker.pick(
                        count: 100,
                        language: Language.System,
                      );

                      if (images == null) return;

                      var data = [];

                      for (int i = 0; i < images.length; i++) {
                        XFile _file = XFile(images[i].path);
                        List<int> imageBase64 = await _file.readAsBytes();
                        String imageAsString = base64Encode(imageBase64);

                        data.add(imageAsString);
                      }

                      Navigator.of(context).pop();

                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return BlocProvider<PatientBloc>.value(
                                value: patientBloc,
                                child: UploadMultiPhotos(data));
                          });
                    },
                    child: Text(
                      S.current.localDevice,
                      style: TextStyle(color: Color(0xff686868), fontSize: 22),
                    )),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      patientBloc.add(SetGalleryType(false));
                      Navigator.of(context).pushNamed(Routes.GALLERY_PAGE);
                    },
                    child: Text(
                      S.current.temporaryAlbum,
                      style: TextStyle(color: Color(0xff686868), fontSize: 22),
                    )),
                SizedBox(
                  height: 40,
                ),
              ]),
            ),
            SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Text(
                  S.current.cancel,
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            )
          ]));
    }

    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      // endDrawerEnableOpenDragGesture: false,
      appBar: AppBar(
        backgroundColor: Color(0xffFF91A6),
        leading: Builder(
          builder: (context) => // Ensure Scaffold is in context
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop()),
        ),
        centerTitle: true,
        title: patientBloc.state.selectedPatient != null
            ? InkWell(
                onTap: () {
                  // Navigator.of(context).pop();
                },
                child: Text(
                    "${patientBloc.state.selectedPatient!.lastName ?? ''}${patientBloc.state.selectedPatient!.firstName ?? ''}"))
            : Text(""),
        actions: [
          IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            onPressed: () {
              patientBloc.add(PatientDataRequested());
              patientBloc
                  .add(PatientSelected(patientBloc.state.selectedPatient!));
            },
            icon: const Icon(
              Icons.sync,
              color: Colors.white,
              size: 30,
            ),
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: 300,
        child: patientBloc.state.selectedPatient != null
            ? Column(
                children: [
                  Container(
                      width: 300,
                      child: Container(
                        padding: EdgeInsets.only(top: 20),
                        height: 190,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                              Color(0xffFF879E),
                              Color(0xffFFC5CB)
                            ])),
                        child: Stack(
                          children: [
                            SizedBox(
                                width: 300,
                                height: 190,
                                child: Image(
                                  image: AssetImage('assets/images/bg.png'),
                                  width: 300,
                                  fit: BoxFit.fitWidth,
                                )),
                            Center(
                              child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 40,
                                          child: patientBloc
                                                          .state
                                                          .selectedPatient!
                                                          .filePath !=
                                                      null &&
                                                  patientBloc
                                                          .state
                                                          .selectedPatient!
                                                          .filePath !=
                                                      ""
                                              ? CachedNetworkImage(
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                      "$patientUrl/${patientBloc.state.selectedPatient!.filePath}",
                                                  placeholder: (context, url) =>
                                                      new CircularProgressIndicator(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          new Icon(Icons.error),
                                                )
                                              : CircleAvatar(
                                                  radius: 35,
                                                  backgroundImage: AssetImage(
                                                      'assets/images/no_people.png'),
                                                ))),
                                  Container(
                                    height: 10,
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                          "${patientBloc.state.selectedPatient!.lastName}${patientBloc.state.selectedPatient!.firstName}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18)),
                                      Text(
                                          "${patientBloc.state.selectedPatient!.birthDate}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14)),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                transform:
                                    Matrix4.translationValues(-80, -30, 0),
                                child: ElevatedButton(
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.all(0),
                                        fixedSize: new Size(40, 40),
                                        minimumSize: new Size(40, 40),
                                        backgroundColor: Color(0xffF45666)),
                                    onPressed: () async {
                                      patientBloc.add(
                                          MedicalHistoryDialogInputStarted());
                                      showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (BuildContext context) {
                                            return BlocProvider<
                                                    PatientBloc>.value(
                                                value: patientBloc,
                                                child: MedicalHistoryDialog());
                                          });
                                    },
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 30,
                                    ))),
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext context) {
                                        return BlocProvider<PatientBloc>.value(
                                            value: patientBloc,
                                            child: FilterDialog());
                                      });
                                },
                                icon: Icon(
                                  Icons.filter_alt,
                                  color: Color(0xff686868),
                                  size: 25,
                                ))
                          ])),
                  Container(
                      width: 300,
                      height: MediaQuery.of(context).size.height - 330,
                      child: SingleChildScrollView(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Column(
                              children: getMedicalHistoryList(),
                            )),
                      )),
                  Container(
                      width: 300,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Container(
                          width: 500,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.all(10),
                                side: BorderSide(
                                    color: Color(0xffF4568C), width: 1),
                                backgroundColor: Colors.white,
                                primary: Color(0xffF4568C)),
                            child: Text(
                              S.of(context).gallery,
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              patientBloc.add(SetGalleryType(true));
                              Navigator.of(context)
                                  .pushNamed(Routes.GALLERY_PAGE);
                            },
                          ))),
                ],
              )
            : Container(),
      ),
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          if (state.status == PatientStatus.success) {
            return Container(
              child: DefaultTabController(
                length: state.bodypartList.length,
                child: Column(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 10, bottom: 5),
                        child: Padding(
                            padding: EdgeInsets.only(left: 18),
                            child: Text(
                                '⬤  ' +
                                    S.of(context).PatientPage_medicalHistory,
                                style: TextStyle(
                                    color: Color(0xffC888A8), fontSize: 16)))),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        margin:
                            EdgeInsets.only(bottom: 10, left: 20, right: 20),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                top: BorderSide(color: Color(0xffBFBFBF)),
                                bottom: BorderSide(color: Color(0xffBFBFBF)),
                                left: BorderSide(color: Color(0xffBFBFBF)),
                                right: BorderSide(color: Color(0xffBFBFBF)))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              isExpanded: true,
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16),
                              onChanged: (int? newValue) {
                                patientBloc.add(PatientCurMedicalNo(newValue!));
                              },
                              value: patientBloc.state.curMedicalNo == 0
                                  ? null
                                  : patientBloc.state.curMedicalNo,
                              alignment: Alignment.centerLeft,
                              items: getMedicalSuggestions()),
                        )),
                    TabBar(
                      unselectedLabelColor: Color(0xff686868),
                      indicatorColor: Color(0xffF45666),
                      controller: _controller,
                      isScrollable: true,
                      labelColor: Colors.black,
                      labelStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      tabs: getTabs(),
                    ),
                    Container(
                      child: null,
                      height: 10,
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _controller,
                        children: getTabContent(),
                      ),
                    ),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            widthFactor: 100,
                            child: ElevatedButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color(0xffF4568C), // background
                                primary: Colors.white, // foreground
                              ),
                              child: InkWell(
                                  onTap: () async {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: sourceDialogBuilder);
                                  },
                                  child: Container(
                                      height: 40,
                                      width: 250,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.upload,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                            Text(
                                              S.of(context).UploadPhotos,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            )
                                          ]))),
                              onPressed: () {},
                            ),
                          ),
                          currentTabName.toLowerCase() == "uncategorized"
                              ? Positioned(
                                  right: 10,
                                  top: 3,
                                  child: IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context,
                                            Routes.NORMAL_COMPARE_PAGE);
                                      },
                                      icon: Icon(Icons.camera_alt,
                                          color: Color(0xffF4568C)),
                                      iconSize: 40.0))
                              : Container()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    ));
  }
}
