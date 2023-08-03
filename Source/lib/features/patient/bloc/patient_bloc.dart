import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/features/patient/ui/widgets/commonPhrase.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:rxphoto/models/bodypart.model.dart';
import 'package:rxphoto/models/user.model.dart';
import 'package:rxphoto/models/bodypartlist.model.dart';
import 'package:rxphoto/models/commonphrase.model.dart';
import 'package:rxphoto/models/diagnosis.model.dart';
import 'package:rxphoto/models/patient.model.dart';
import 'package:rxphoto/models/medicalhistory.model.dart';
import 'package:rxphoto/models/patientImage.model.dart';
import 'package:rxphoto/models/treatment.model.dart';
import 'package:rxphoto/models/treatmentInfo.model.dart';

part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientBloc({required GlobalRepository globalRepository})
      : _globalRepository = globalRepository,
        super(PatientState()) {
    on<PatientDataRequested>(_onDataRequested);
    on<PatientImageUpdateRequested>(_onPatientImageUpdateRequested);
    on<PatientDataCreated>(_onDataCreated);
    on<PatientDialogDiagnosisSelected>(_onDiagnosisSelected);
    on<PatientDialogCommonPhraseSelected>(_onCommonPhraseSelected);
    on<PatientNoteUpdated>(_onNoteUpdated);
    on<PatientDialogTreatmentSelected>(_onTreatmentSelected);
    on<PatientSelected>(_onPatientSelected);
    on<PatientBodyPartOrderSelected>(_onBodyPartOrderSelected);
    //PatientDetailPage
    on<PatientPhotoTakingMethodSelected>(_onPhotoTakingMethodSelected);
    on<PatientPhotoTaken>(_onPhotoTaken);
    on<PatientImageBodyPartTypeSelected>(_onPatientImageBodyPartTypeSelected);
    // EditPhotoImage
    on<PatientSelectNextOrder>(_onSelectNextOrder);
    on<PatientDeleteDiagnosis>(_onDeleteDiagnosis);
    on<PatientDeleteTreatment>(_onDeleteTreatment);
    on<PatientDialogInputStarted>(_onDialogInputStarted);
    // Medical History
    on<MedicalHistoryDataRequested>(_onMedicalHistoryDataRequested);
    on<MedicalHistoryDialogInputStarted>(_onMedicalDialogInputStarted);
    on<MedicalHistoryDataUpdated>(_onMedicalHistoryDataUpdated);
    on<MedicalDataCreated>(_onMedicalDataCreated);
    on<MedicalDataUpdateRequested>(_onMedicalDataUpdateRequested);
    on<MedicalDataRemoved>(_onMedicalDataRemoved);

    // Gallery
    on<PatientGalleryDataRequested>(_onGalleryDataRequested);
    on<PatientGalleryPatientSelected>(_onGalleryPatientSelected);
    on<GalleryPatientImageDblSelected>(_onGalleryPatientImageDblSelected);
    //Ghost
    on<PatientGhostOrderSelected>(_onGhostOrderSelected);
    on<PatientGhostOrderForward>(_onGhostOrderForward);
    on<PatientGhostOrderBackward>(_onGhostOrderBackward);
    on<UserDataSaved>(_onUserDataSaved);
    on<ComparePatientImageSelected>(_onComparePatientImageSelected);
    on<BeforeWindowTypeChanged>(_onBeforeWindowTypeChanged);
    on<PatientFilterDone>(_onPatientFilterDone);
    on<PatientCurMedicalNo>(_onPatientCurMedicalNo);
    on<PatientAndMedicalHistoryDataCreated>(
        _onPatientAndMedicalHistoryDataCreated);
    on<SetGalleryType>(_onSetGalleryType);
  }

  final GlobalRepository _globalRepository;

  String getBodyPartName(int? bodyPartId) {
    var foundElement = state.bodyparts
        .singleWhereOrNull((element) => element.id == bodyPartId);
    return foundElement == null ? "Uncategory" : foundElement.title!;
  }

  void _onPatientCurMedicalNo(
      PatientCurMedicalNo event, Emitter<PatientState> emit) async {
    emit(state.copyWith(curMedicalNo: event.curMedicalNo));
  }

  void _onGalleryDataRequested(
      PatientGalleryDataRequested event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      final sortBy =
          event.sortBy != "" ? event.sortBy : state.selectedGallerySortType;

      List<PatientImage> patientImages;

      if (state.isNormalGallery == true)
        patientImages =
            await _globalRepository.getPatientImage(state.selectedPatient!.id);
      else
        patientImages = await _globalRepository.getPatientImage(
            state.currentUser!.id!,
            isNormalGallery: false,
            orderBy: event.orderBy!);

      var groupResult;

      patientImages = patientImages.map((e) {
        e.isSelected = false;
        return e;
      }).toList();

      if (state.isNormalGallery == true) {
        final DateFormat yearFormat = DateFormat('yyyy-MM-dd');
        for (var item in patientImages) {
          var foundBodyPart = state.bodyparts
              .singleWhereOrNull((element) => element.id == item.bodyPartId);
          if (foundBodyPart != null) {
            item.bodyPartTitle = foundBodyPart.title;
            if (item.createDate != null)
              item.createDate =
                  yearFormat.format(yearFormat.parse(item.createDate!));
          } else {
            item.bodyPartTitle = "Uncategory";
            if (item.createDate != null)
              item.createDate =
                  yearFormat.format(yearFormat.parse(item.createDate!));
          }

          var foundMedicalHistory = state.medicalHistory.singleWhereOrNull(
              (element) => element.id == item.medicalHistoryId);

          item.medicalHistoryNo = foundMedicalHistory?.medicalHistoryNo;
        }
        DateFormat format = DateFormat('yyyy-MM-dd');
        if (sortBy == "GhostDate") {
          var currentBodypartId = state.bodyparts
              .where(
                  (element) => element.partsFor == state.selectedBodyPartGroup)
              .toList()[state.selectedBodyPartOrder!]
              .id;
          groupResult = patientImages
              .where((element) => element.bodyPartId == currentBodypartId)
              .toList();
          emit(state.copyWith(
              status: PatientStatus.success, galleryGhostData: groupResult));
          return;
        } else if (sortBy == "Date") {
          patientImages.sort((PatientImage a, PatientImage b) {
            return -DateTime.parse(a.createDate!)
                .compareTo(DateTime.parse(b.createDate!));
          });
          groupResult = groupBy(
              patientImages,
              (PatientImage obj) =>
                  format.format(format.parse(obj.createDate!)));
          emit(state.copyWith(
              status: PatientStatus.success, galleryData: groupResult));
        } else if (sortBy == "Area") {
          groupResult = groupBy(patientImages,
              (PatientImage obj) => getBodyPartName(obj.bodyPartId));
        } else if (sortBy == "Medical Records") {
          groupResult = groupBy(patientImages,
              (PatientImage obj) => obj.medicalHistoryId.toString());
        }
      } else {
        DateFormat format = DateFormat('yyyy-MM-dd');

        groupResult = groupBy(patientImages,
            (PatientImage obj) => format.format(format.parse(obj.createDate!)));
      }

      emit(state.copyWith(
          status: PatientStatus.success,
          selectedGallerySortType: sortBy,
          galleryData: groupResult));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  void _onGalleryPatientSelected(
      PatientGalleryPatientSelected event, Emitter<PatientState> emit) {
    emit(state.copyWith(status: PatientStatus.loading));
    final selectedPatientImage = event.selectedPatientImage;
    var galleryData = state.galleryData;
    galleryData!.entries.forEach((element) {
      int index = element.value
          .indexWhere((velement) => velement.id == selectedPatientImage.id);
      if (index != -1)
        element.value[index].isSelected = !element.value[index].isSelected!;
    });
    emit(state.copyWith(
        status: PatientStatus.success, galleryData: galleryData));
  }

  void _onPatientFilterDone(
      PatientFilterDone event, Emitter<PatientState> emit) {
    emit(state.copyWith(
        status: PatientStatus.success,
        filterBody: event.filterBody,
        filterKeywords: event.filterKeywords,
        filterDoctor: event.filterDoctor,
        filterHasPhoto: event.filterHasPhoto,
        filterInterval: event.filterInterval));
  }

  void _onBeforeWindowTypeChanged(
      BeforeWindowTypeChanged event, Emitter<PatientState> emit) {
    emit(state.copyWith(
        status: PatientStatus.success, beforeWindowType: event.type));
  }

  void _onGalleryPatientImageDblSelected(
      GalleryPatientImageDblSelected event, Emitter<PatientState> emit) {
    emit(state.copyWith(status: PatientStatus.loading));
    final galleryPatientImageDblSelected = event.patientImage;
    emit(state.copyWith(
        status: PatientStatus.success,
        galleryPatientImageDblSelected: galleryPatientImageDblSelected));
  }

  void _onGhostOrderSelected(
      PatientGhostOrderSelected event, Emitter<PatientState> emit) {
    emit(state.copyWith(
        status: PatientStatus.success, selectedGhostOrder: event.order));
  }

  void _onGhostOrderForward(
      PatientGhostOrderForward event, Emitter<PatientState> emit) {
    emit(state.copyWith(
        status: PatientStatus.success,
        selectedGhostOrder: state.selectedGhostOrder! + 1));
  }

  void _onGhostOrderBackward(
      PatientGhostOrderBackward event, Emitter<PatientState> emit) {
    emit(state.copyWith(
        status: PatientStatus.success,
        selectedGhostOrder: state.selectedGhostOrder! - 1));
  }

  void _onUserDataSaved(UserDataSaved event, Emitter<PatientState> emit) {
    emit(state.copyWith(currentUser: event.user));
  }

  void _onComparePatientImageSelected(
      ComparePatientImageSelected event, Emitter<PatientState> emit) {
    emit(state.copyWith(selectedCompareImages: event.patientImages));
  }

  void _onDialogInputStarted(
      PatientDialogInputStarted event, Emitter<PatientState> emit) {
    if (event.isFormatPatientInfoOnly == true) {
      emit(state.copyWith(selectedPatient: Patient(id: 0, doctorId: 0)));
      return;
    }
    if (event.isFormatSelectedPatient == true) {
      emit(state.copyWith(selectedPatient: Patient(id: 0, doctorId: 0)));
    }

    emit(state.copyWith(selectedDiagnosis: [], selectedTreatment: []));
  }

  void _onMedicalDialogInputStarted(
      MedicalHistoryDialogInputStarted event, Emitter<PatientState> emit) {
    List<String> diagnosis = [];
    List<String> treatment = [];
    List<Map<String, String>> convertedDiagnosis = [];
    List<Map<String, String>> convertedTreatment = [];
    var medicalHistory = state.medicalHistory;
    var patient = state.selectedPatient;
    final DateFormat yearFormat = DateFormat('yyyy-MM-dd');

    try {
      medicalHistory.sort((a, b) {
        if (a.lastUpdateDate != null && b.lastUpdateDate != null)
          return -a.lastUpdateDate!.compareTo(b.lastUpdateDate!);
        return 0;
      });

      for (var item in medicalHistory) {
        if (item.dateOfVisit != null)
          item.dateOfVisit =
              yearFormat.format(yearFormat.parse(item.dateOfVisit!));
      }

      if (medicalHistory.length > 0) {
        if (medicalHistory[0].diagnosis != null)
          diagnosis = medicalHistory[0].diagnosis.toString().trim().split(' ');
        if (medicalHistory[0].treatment != null)
          treatment = medicalHistory[0].treatment.toString().trim().split(' ');
      } else {
        diagnosis = patient!.diagnosis.toString().trim().split(' ');
        treatment = patient.treatment.toString().trim().split(' ');
      }

      if (diagnosis.length != 0)
        diagnosis.forEach((e) {
          try {
            Diagnosis? result;
            state.diagnosisNormalList.forEach((element) {
              if (element.id == int.parse(e)) {
                result = element;
              }
            });
            if (result != null)
              convertedDiagnosis.add(
                  {"key": result!.id.toString(), "label": result!.tagName!});
          } catch (err) {}
        });

      if (treatment.length != 0)
        treatment.forEach((e) {
          try {
            Treatment? result;
            state.treatmentNormalList.forEach((element) {
              if (element.id == int.parse(e)) {
                result = element;
              }
            });
            if (result != null)
              convertedTreatment.add(
                  {"key": result!.id.toString(), "label": result!.tagName});
          } catch (err) {}
        });

      emit(state.copyWith(
        selectedDiagnosis: convertedDiagnosis,
        selectedTreatment: convertedTreatment,
      ));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }

    emit(state.copyWith(
        status: PatientStatus.success,
        selectedMedicalHistory: MedicalHistory(id: -1, medicalHistoryNo: "")));
  }

  void _onMedicalHistoryDataRequested(
      MedicalHistoryDataRequested event, Emitter<PatientState> emit) async {
    try {
      var totalmedicalHistory = await _globalRepository.getMedicalHistory(null);
      emit(state.copyWith(
          status: PatientStatus.success,
          totalmedicalHistory: totalmedicalHistory));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  void _onMedicalHistoryDataUpdated(
      MedicalHistoryDataUpdated event, Emitter<PatientState> emit) {
    var convertedDiagnosis = event.data.diagnosis != ""
        ? event.data.diagnosis.toString().split(" ").map((e) {
            var diagnosis = state.diagnosisNormalList
                .firstWhere((element) => element.id.toString() == e.toString());
            return {
              "label": diagnosis.tagName ?? "No Tagname",
              "key": diagnosis.id.toString()
            };
          }).toList()
        : <Map<String, String>>[];
    var convertedTreatment = event.data.treatment != ""
        ? event.data.treatment.toString().split(" ").map((e) {
            var treatment = state.treatmentNormalList
                .firstWhere((element) => element.id.toString() == e.toString());
            return {"label": treatment.tagName, "key": treatment.id.toString()};
          }).toList()
        : <Map<String, String>>[];
    emit(state.copyWith(
        status: PatientStatus.success,
        selectedMedicalHistory: event.data,
        selectedDiagnosis: convertedDiagnosis,
        selectedTreatment: convertedTreatment));
  }

  void _onDeleteDiagnosis(
      PatientDeleteDiagnosis event, Emitter<PatientState> emit) async {
    final deletedDiagnosis = state.selectedDiagnosis
        .where((element) => element['key'].toString() != event.key)
        .toList();
    var sendDataForDiagnosis = "";
    for (var item in deletedDiagnosis) {
      sendDataForDiagnosis += item['key']! + " ";
    }
    // await _globalRepository.updatePatient(
    //     state.selectedPatient!.id, {"DIAGNOSIS": sendDataForDiagnosis});
    // add(PatientDataRequested());
    emit(state.copyWith(
        status: PatientStatus.success, selectedDiagnosis: deletedDiagnosis));
  }

  void _onDeleteTreatment(
      PatientDeleteTreatment event, Emitter<PatientState> emit) async {
    final deletedTreatment = state.selectedTreatment
        .where((element) => element['key'].toString() != event.key)
        .toList();
    var sendDataForTreatment = "";
    for (var item in deletedTreatment) {
      sendDataForTreatment += item['key']! + " ";
    }
    // await _globalRepository.updatePatient(
    //     state.selectedPatient!.id, {"TREATMENT": sendDataForTreatment});
    // add(PatientDataRequested());
    emit(state.copyWith(
        status: PatientStatus.success, selectedTreatment: deletedTreatment));
  }

  Future<List<Patient>> getSuggestions(String keyword) async {
    List<Patient> suggestions = [];

    try {
      suggestions = await _globalRepository.getPatientSuggestions(keyword);
    } catch (e) {}

    return suggestions;
  }

  User getUser() {
    return _globalRepository.getUser();
  }

  Future<void> _onDataRequested(
      PatientDataRequested event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      final doctors = await _globalRepository.getDoctorsInfo();
      final patients =
          await _globalRepository.getPatient(orderBy: event.orderBy);
      final diagnosis = await _globalRepository.getDiagnosis();
      final phraseResult = await _globalRepository.getCommonPhrase();
      final diagnosisNormalList = await _globalRepository.getNormalDiagnosis();
      final treatments = await _globalRepository.getTreatment();
      final treatmentInfo = await _globalRepository.getTreatmentInfo();
      final treatmentNormalList = await _globalRepository.getNormalTreatment();
      final bodyparts = await _globalRepository.getBodyPart();
      final bodypartList = await _globalRepository.getLBodypartList();
      var totalmedicalHistory = await _globalRepository.getMedicalHistory(null);

      final headBodyParts =
          bodyparts.where((element) => element.partsFor == 'Head').toList();
      final TrunkBodyParts =
          bodyparts.where((element) => element.partsFor == 'Trunk').toList();
      final LegsBodyParts =
          bodyparts.where((element) => element.partsFor == 'Legs').toList();
      var resultForBodyParts = [
        ...headBodyParts,
        ...TrunkBodyParts,
        ...LegsBodyParts
      ];
      // final patientImages =
      //     await _globalRepository.getPatientImage(state.selectedPatient!.id);
      // print("5");

      // final DateFormat yearFormat = DateFormat('yyyy-MM-dd');
      // for (var item in patientImages) {
      //   var foundBodyPart = bodyparts
      //       .singleWhereOrNull((element) => element.id == item.bodyPartId);
      //   if (foundBodyPart != null) {
      //     item.bodyPartTitle = foundBodyPart.title;
      //     if (item.createDate != null)
      //       item.createDate =
      //           yearFormat.format(yearFormat.parse(item.createDate!));
      //   }
      // }
      // emit(state.copyWith(
      //     status: PatientStatus.success,
      //     patients: patients,
      //     treatments: treatments,
      //     diagnosis: diagnosis,
      //     bodyparts: bodyparts,
      //     patientImages: patientImages));

      log(state.selectedPatient.toString());

      Patient? curPatient;

      try {
        curPatient = patients
            .firstWhere((element) => element.id == state.selectedPatient!.id);
      } catch (err) {}

      if (state.selectedPatient != null && state.selectedPatient!.id != 0) {
        emit(state.copyWith(
          selectedPatient: curPatient,
        ));
      }

      emit(state.copyWith(
          status: PatientStatus.success,
          commonPhrase: phraseResult,
          patients: patients,
          doctors: doctors,
          treatments: treatments,
          treatmentInfo: treatmentInfo,
          diagnosis: diagnosis,
          bodypartList: bodypartList,
          diagnosisNormalList: diagnosisNormalList,
          treatmentNormalList: treatmentNormalList,
          totalmedicalHistory: totalmedicalHistory,
          bodyparts: bodyparts));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(status: PatientStatus.success));
      // AlertController.show(
      //     S.current.failed, S.current.connectionError, TypeAlert.error);
    }
  }

  Future<void> _onSetGalleryType(
      SetGalleryType event, Emitter<PatientState> emit) async {
    emit(state.copyWith(isNormalGallery: event.isNormalGallery));
  }

  Future<void> _onPatientAndMedicalHistoryDataCreated(
      PatientAndMedicalHistoryDataCreated event,
      Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      var sendData = event.pData;
      sendData['DIAGNOSIS'] = '';
      sendData['TREATMENT'] = '';

      final DateFormat yearFormat = DateFormat('yyyy-MM-dd');

      if (sendData["BIRTH_DATE"] != "")
        sendData["BIRTH_DATE"] =
            yearFormat.format(yearFormat.parse(sendData["BIRTH_DATE"]));

      final createdPatient = await _globalRepository.createPatient(sendData);

      emit(state.copyWith(
          status: PatientStatus.patientCreated,
          selectedPatient: createdPatient,
          patientImages: [],
          patients: [createdPatient, ...state.patients]));

      final selectedDiagnosis = state.selectedDiagnosis;
      final selectedTreatment = state.selectedTreatment;

      var sendDataForDiagnosis = "";
      for (var item in selectedDiagnosis) {
        sendDataForDiagnosis += item['key']! + " ";
      }
      var sendDataForTreatment = "";
      for (var item in selectedTreatment) {
        sendDataForTreatment += item['key']! + " ";
      }

      sendData = event.hData;
      sendData['DIAGNOSIS'] = sendDataForDiagnosis.trim();
      sendData['TREATMENT'] = sendDataForTreatment.trim();
      sendData['MEDICAL_HISTORY_NO'] = state.selectedPatient!.medicalHistoryNo;

      if (sendData["DATEOFVISIT"] != "")
        sendData["DATEOFVISIT"] =
            yearFormat.format(yearFormat.parse(sendData["DATEOFVISIT"]));

      var createdMedicalHistory =
          await _globalRepository.createMedicalHistory(sendData);

      if (createdMedicalHistory.dateOfVisit != null)
        createdMedicalHistory.dateOfVisit = yearFormat
            .format(yearFormat.parse(createdMedicalHistory.dateOfVisit!));

      emit(state.copyWith(
        selectedDiagnosis: [],
        selectedTreatment: [],
        curMedicalNo: createdMedicalHistory.id,
        medicalHistory: [...state.medicalHistory, createdMedicalHistory],
        status: PatientStatus.success,
      ));

      add(PatientSelected(createdPatient));
      add(PatientDataRequested());
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  Future<void> _onDataCreated(
      PatientDataCreated event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      final selectedDiagnosis = state.selectedDiagnosis;
      final selectedTreatment = state.selectedTreatment;
      var sendDataForDiagnosis = "";
      for (var item in selectedDiagnosis) {
        sendDataForDiagnosis += item['key']! + " ";
      }
      var sendDataForTreatment = "";
      for (var item in selectedTreatment) {
        sendDataForTreatment += item['key']! + " ";
      }

      var sendData = event.data;
      sendData['DIAGNOSIS'] = sendDataForDiagnosis.trim();
      sendData['TREATMENT'] = sendDataForTreatment.trim();

      final createdPatient = await _globalRepository.createPatient(sendData);
      if (sendData['PICTURE_PATH'] != null) {
        File(sendData['PICTURE_PATH']).delete();
      }
      String picturePath = sendData['PICTURE_PATH'];
      int ind = picturePath.lastIndexOf("files");
      if (ind != -1) {
        final dirPath = picturePath.substring(0, ind - 1) + "/cache";
        final dir = Directory(dirPath);
        dir.deleteSync(recursive: true);
      }
      emit(state.copyWith(
          status: PatientStatus.patientCreated,
          selectedPatient: createdPatient,
          medicalHistory: [],
          patientImages: [],
          selectedDiagnosis: [],
          selectedTreatment: [],
          patients: [...state.patients, createdPatient]));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  Future<void> _onMedicalDataCreated(
      MedicalDataCreated event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      var sendData;
      final DateFormat yearFormat = DateFormat('yyyy-MM-dd');

      if (event.pData != null) {
        sendData = event.pData;
        sendData['DIAGNOSIS'] = '';
        sendData['TREATMENT'] = '';

        if (sendData["BIRTH_DATE"] != "")
          sendData["BIRTH_DATE"] =
              yearFormat.format(yearFormat.parse(sendData["BIRTH_DATE"]));

        await _globalRepository.updatePatient(
            state.selectedPatient!.id, sendData);
      }

      final selectedDiagnosis = state.selectedDiagnosis;
      final selectedTreatment = state.selectedTreatment;
      var sendDataForDiagnosis = "";
      for (var item in selectedDiagnosis) {
        sendDataForDiagnosis += item['key']! + " ";
      }
      var sendDataForTreatment = "";
      for (var item in selectedTreatment) {
        sendDataForTreatment += item['key']! + " ";
      }

      sendData = event.data;
      sendData['DIAGNOSIS'] = sendDataForDiagnosis.trim();
      sendData['TREATMENT'] = sendDataForTreatment.trim();
      sendData['MEDICAL_HISTORY_NO'] = state.selectedPatient!.medicalHistoryNo;

      if (sendData["DATEOFVISIT"] != "")
        sendData["DATEOFVISIT"] =
            yearFormat.format(yearFormat.parse(sendData["DATEOFVISIT"]));

      var createdMedicalHistory =
          await _globalRepository.createMedicalHistory(sendData);

      if (createdMedicalHistory.dateOfVisit != null)
        createdMedicalHistory.dateOfVisit = yearFormat
            .format(yearFormat.parse(createdMedicalHistory.dateOfVisit!));

      emit(state.copyWith(
          status: PatientStatus.success,
          curMedicalNo: createdMedicalHistory.id,
          medicalHistory: [...state.medicalHistory, createdMedicalHistory]));
      add(PatientDataRequested());
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  Future<void> _onMedicalDataUpdateRequested(
      MedicalDataUpdateRequested event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      final selectedDiagnosis = state.selectedDiagnosis;
      final selectedTreatment = state.selectedTreatment;
      var sendDataForDiagnosis = "";
      for (var item in selectedDiagnosis) {
        sendDataForDiagnosis += item['key']! + " ";
      }
      var sendDataForTreatment = "";
      for (var item in selectedTreatment) {
        sendDataForTreatment += item['key']! + " ";
      }
      final sendData = event.data;
      final DateFormat yearFormat = DateFormat('yyyy-MM-dd');

      if (sendData["DATEOFVISIT"] != "")
        sendData["DATEOFVISIT"] =
            yearFormat.format(yearFormat.parse(sendData["DATEOFVISIT"]));

      sendData['DIAGNOSIS'] = sendDataForDiagnosis.trim();
      sendData['TREATMENT'] = sendDataForTreatment.trim();
      sendData['MEDICAL_HISTORY_NO'] = state.selectedPatient!.medicalHistoryNo;
      sendData['ID'] = state.selectedMedicalHistory!.id.toString();
      await _globalRepository.updateMedicalHistory(sendData);

      MedicalHistory result = MedicalHistory(
          id: int.parse(sendData['ID']),
          medicalHistoryNo: sendData['MEDICAL_HISTORY_NO'],
          diagnosis: sendData['DIAGNOSIS'],
          treatment: sendData['TREATMENT'],
          attendingPhysician: sendData['ATTENDING_PHYSICIAN'],
          notes: sendData['NOTES'],
          dateOfVisit: sendData['DATEOFVISIT']);
      var updatedResult = state.medicalHistory;
      updatedResult[updatedResult
          .indexWhere((element) => element.id == result.id)] = result;

      emit(state.copyWith(
          status: PatientStatus.success,
          selectedDiagnosis: [],
          selectedTreatment: [],
          medicalHistory: updatedResult));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  Future<void> _onMedicalDataRemoved(
      MedicalDataRemoved event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      await _globalRepository.removeMedicalHistory(event.id);
      emit(state.copyWith(
          status: PatientStatus.success,
          selectedDiagnosis: [],
          selectedTreatment: [],
          medicalHistory: state.medicalHistory
              .where((element) => element.id != event.id)
              .toList()));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  Future<void> _onPatientImageUpdateRequested(
      PatientImageUpdateRequested event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      var patientImages =
          await _globalRepository.getPatientImage(state.selectedPatient!.id);
      final DateFormat yearFormat = DateFormat('yyyy-MM-dd');
      for (var item in patientImages) {
        var foundBodyPart = state.bodyparts
            .singleWhereOrNull((element) => element.id == item.bodyPartId);
        if (foundBodyPart != null) {
          item.bodyPartTitle = foundBodyPart.title;
          if (item.createDate != null)
            item.createDate =
                yearFormat.format(yearFormat.parse(item.createDate!));
        } else {
          item.bodyPartTitle = "Uncategory";
          if (item.createDate != null)
            item.createDate =
                yearFormat.format(yearFormat.parse(item.createDate!));
        }
      }

      emit(state.copyWith(
          status: PatientStatus.success, patientImages: patientImages));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  Future<void> _onPatientSelected(
      PatientSelected event, Emitter<PatientState> emit) async {
    emit(state.copyWith(
        selectedPatient: event.patient, status: PatientStatus.loading));
    // try {
    //   final diagnosis = await _globalRepository.getDiagnosis();
    //   final treatments = await _globalRepository.getTreatment();
    //   emit(state.copyWith(
    //       status: PatientStatus.success,
    //       diagnosis: diagnosis,
    //       treatments: treatments));
    // } catch (e) {
    //   emit(state.copyWith(status: PatientStatus.success));
    // }
    final patient = event.patient;
    List<String> diagnosis = [];
    List<String> treatment = [];
    List<Map<String, String>> convertedDiagnosis = [];
    List<Map<String, String>> convertedTreatment = [];
    final DateFormat yearFormat = DateFormat('yyyy-MM-dd');

    var medicalHistory = await _globalRepository
        .getMedicalHistory(event.patient.medicalHistoryNo!);

    medicalHistory.sort((a, b) {
      if (a.lastUpdateDate != null && b.lastUpdateDate != null)
        return -a.lastUpdateDate!.compareTo(b.lastUpdateDate!);
      return 0;
    });

    for (var item in medicalHistory) {
      if (item.dateOfVisit != null)
        item.dateOfVisit =
            yearFormat.format(yearFormat.parse(item.dateOfVisit!));
    }

    if (medicalHistory.length > 0) {
      if (medicalHistory[0].diagnosis != null)
        diagnosis = medicalHistory[0].diagnosis.toString().trim().split(' ');
      if (medicalHistory[0].treatment != null)
        treatment = medicalHistory[0].treatment.toString().trim().split(' ');
    } else {
      diagnosis = patient.diagnosis.toString().trim().split(' ');
      treatment = patient.treatment.toString().trim().split(' ');
    }

    if (diagnosis.length != 0)
      diagnosis.forEach((e) {
        try {
          Diagnosis? result;
          state.diagnosisNormalList.forEach((element) {
            if (element.id == int.parse(e)) {
              result = element;
            }
          });
          if (result != null)
            convertedDiagnosis
                .add({"key": result!.id.toString(), "label": result!.tagName!});
        } catch (err) {}
      });
    if (treatment.length != 0)
      treatment.forEach((e) {
        try {
          Treatment? result;
          state.treatmentNormalList.forEach((element) {
            if (element.id == int.parse(e)) {
              result = element;
            }
          });
          if (result != null)
            convertedTreatment
                .add({"key": result!.id.toString(), "label": result!.tagName});
        } catch (err) {}
      });

    try {
      var patientImages =
          await _globalRepository.getPatientImage(event.patient.id);
      for (var item in patientImages) {
        var foundBodyPart = state.bodyparts
            .singleWhereOrNull((element) => element.id == item.bodyPartId);
        if (foundBodyPart != null) {
          item.bodyPartTitle = foundBodyPart.title;
          if (item.createDate != null)
            item.createDate =
                yearFormat.format(yearFormat.parse(item.createDate!));
        } else {
          item.bodyPartTitle = "Uncategory";
          if (item.createDate != null)
            item.createDate =
                yearFormat.format(yearFormat.parse(item.createDate!));
        }
      }

      emit(state.copyWith(
          status: PatientStatus.success,
          patientImages: patientImages,
          medicalHistory: medicalHistory,
          selectedDiagnosis: convertedDiagnosis,
          selectedTreatment: convertedTreatment,
          curMedicalNo: medicalHistory.length > 0 ? medicalHistory[0].id : 0));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  Future<void> _onPhotoTaken(
      PatientPhotoTaken event, Emitter<PatientState> emit) async {
    emit(
        state.copyWith(status: PatientStatus.success, takenPhoto: event.photo));
  }

  Future<void> _onPatientImageBodyPartTypeSelected(
      PatientImageBodyPartTypeSelected event,
      Emitter<PatientState> emit) async {
    emit(state.copyWith(
        status: PatientStatus.success,
        selectedPatientImageBodypartType: event.type));
  }

  Future<void> _onBodyPartOrderSelected(
      PatientBodyPartOrderSelected event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    emit(state.copyWith(
        status: PatientStatus.success,
        selectedBodyPartOrder: event.order,
        selectedBodyPartGroup: event.partFor,
        selectedBodyPartLength: event.sectionLength));
  }

  Future<void> _onPhotoTakingMethodSelected(
      PatientPhotoTakingMethodSelected event,
      Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      List<PatientImage> patientBodyPartImages = [];
      if (event.method == "ghost") {
        patientBodyPartImages = await _globalRepository.getPatientBodyPartImage(
            state.selectedPatient!.id,
            state.bodyparts
                .where((element) =>
                    element.partsFor == state.selectedBodyPartGroup)
                .toList()[state.selectedBodyPartOrder!]
                .id);
      }
      emit(state.copyWith(
          status: PatientStatus.success,
          photoTakingMethod: event.method,
          selectedGhostOrder: 0,
          selectedPatientBodypartImages: patientBodyPartImages));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  Future<void> _onSelectNextOrder(
      PatientSelectNextOrder event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      emit(state.copyWith(
          status: PatientStatus.success,
          selectedBodyPartOrder:
              (state.selectedBodyPartOrder! + 1) % state.bodyparts.length));

      emit(state.copyWith(status: PatientStatus.loading));
      List<PatientImage> patientBodyPartImages = [];
      if (state.photoTakingMethod == "ghost") {
        patientBodyPartImages = await _globalRepository.getPatientBodyPartImage(
            state.selectedPatient!.id,
            state.bodyparts[state.selectedBodyPartOrder!].id);
      }
      emit(state.copyWith(
          status: PatientStatus.success,
          selectedPatientBodypartImages: patientBodyPartImages));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }

  Future<void> _onDiagnosisSelected(
      PatientDialogDiagnosisSelected event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      if (state.selectedDiagnosis.length == 0 ||
          state.selectedDiagnosis
                  .indexWhere((element) => element['key'] == event.key) ==
              -1) {
        final updateDiagnosis = [
          ...state.selectedDiagnosis,
          {"key": event.key, "label": event.label}
        ];
        var sendDataForDiagnosis = "";
        for (var item in updateDiagnosis) {
          sendDataForDiagnosis += item['key']! + " ";
        }
        // await _globalRepository.updatePatient(
        //     state.selectedPatient!.id, {"DIAGNOSIS": sendDataForDiagnosis});
        // add(PatientDataRequested());
        emit(state.copyWith(
            status: PatientStatus.success, selectedDiagnosis: updateDiagnosis));
      } else
        emit(state.copyWith(status: PatientStatus.success));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.failure));
    }
  }

  Future<void> _onCommonPhraseSelected(PatientDialogCommonPhraseSelected event,
      Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      if (state.selectedDiagnosis.length == 0 ||
          state.selectedDiagnosis
                  .indexWhere((element) => element['key'] == event.key) ==
              -1) {
        final updateDiagnosis = [
          ...state.selectedDiagnosis,
          {"key": event.key, "label": event.label}
        ];
        var sendDataForDiagnosis = "";
        for (var item in updateDiagnosis) {
          sendDataForDiagnosis += item['key']! + " ";
        }
        // await _globalRepository.updatePatient(
        //     state.selectedPatient!.id, {"DIAGNOSIS": sendDataForDiagnosis});
        // add(PatientDataRequested());
        emit(state.copyWith(
            status: PatientStatus.success, selectedDiagnosis: updateDiagnosis));
      } else
        emit(state.copyWith(status: PatientStatus.success));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.failure));
    }
  }

  Future<void> _onTreatmentSelected(
      PatientDialogTreatmentSelected event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      if (state.selectedTreatment.length == 0 ||
          state.selectedTreatment
                  .indexWhere((element) => element['key'] == event.key) ==
              -1) {
        final updateTreatment = [
          ...state.selectedTreatment,
          {"key": event.key, "label": event.label}
        ];
        var sendDataForTreatment = "";
        for (var item in updateTreatment) {
          sendDataForTreatment += item['key']! + " ";
        }
        // await _globalRepository.updatePatient(
        //     state.selectedPatient!.id, {"TREATMENT": sendDataForTreatment});
        // add(PatientDataRequested());
        emit(state.copyWith(
            status: PatientStatus.success, selectedTreatment: updateTreatment));
      }
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.failure));
    }
  }

  Future<void> _onNoteUpdated(
      PatientNoteUpdated event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      await _globalRepository.updatePatient(
          state.selectedPatient!.id, {"NOTES": event.noteContent});
      add(PatientDataRequested());
      var updatedSelectedPatient = state.selectedPatient;
      updatedSelectedPatient!.notes = event.noteContent;
      emit(state.copyWith(
          status: PatientStatus.success,
          selectedPatient: updatedSelectedPatient));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.success));
    }
  }
}
