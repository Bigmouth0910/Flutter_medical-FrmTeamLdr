part of 'patient_bloc.dart';

enum PatientStatus {
  initial,
  loading,
  success,
  failure,
  patientCreated,
  patientCreateFailure,
}

class PatientOrder {
  final int id;
  final String value;

  const PatientOrder(this.id, this.value);
}

class PatientState extends Equatable {
  const PatientState(
      {this.status = PatientStatus.initial,
      this.patients = const [],
      this.commonPhrase = const [],
      this.medicalHistory = const [],
      this.totalmedicalHistory = const [],
      this.selectedPatient,
      this.currentUser,
      this.galleryPatientImageDblSelected,
      this.selectedMedicalHistory,
      this.diagnosis = const [],
      this.treatments = const [],
      this.selectedCompareImages = const [],
      this.treatmentInfo = const [],
      this.treatmentNormalList = const [],
      this.selectedDiagnosis = const [],
      this.selectedTreatment = const [],
      this.selectedNotes = "",
      this.bodyparts = const [],
      this.diagnosisNormalList = const [],
      this.bodypartList = const [],
      this.patientImages = const [],
      this.doctors = const [],
      this.currentDiagnosis = const [],
      this.currentTreatment = const [],
      this.selectedPatientImages = const [],
      this.selectedPatientBodypartImages = const [],
      this.galleryData,
      this.galleryGhostData,
      this.photoTakingMethod = "template",
      this.selectedGallerySortType = "",
      this.beforeWindowType = "",
      this.selectedPatientImageBodypartType = "",
      this.selectedGhostOrder,
      this.selectedBodyPartOrder,
      this.selectedBodyPartGroup,
      this.selectedBodyPartLength,
      this.takenPhoto,
      this.filterKeywords = '',
      this.filterBody = 0,
      this.filterDoctor = 0,
      this.filterInterval = 0,
      this.filterHasPhoto = 0,
      this.curMedicalNo = 0,
      this.isNormalGallery = true});
  final PatientStatus status;
  final List<Patient> patients;
  final List<PatientImage> selectedCompareImages;
  final List<CommonPhrase> commonPhrase;
  final List<MedicalHistory> medicalHistory;
  final List<MedicalHistory> totalmedicalHistory;
  final Patient? selectedPatient;
  final PatientImage? galleryPatientImageDblSelected;
  final MedicalHistory? selectedMedicalHistory;
  final List<Diagnosis> diagnosis;
  final List<Diagnosis> diagnosisNormalList;
  final List<Treatment> treatments;
  final List<TreatmentInfo> treatmentInfo;
  final List<User> doctors;
  final String selectedNotes;
  final User? currentUser;
  final String selectedGallerySortType;
  final List<Treatment> treatmentNormalList;
  final List<PatientImage> selectedPatientImages;
  final List<PatientImage> selectedPatientBodypartImages;
  final List<Map<String, String>> selectedDiagnosis;
  final List<Map<String, String>> selectedTreatment;
  final List<Map<String, String>> currentDiagnosis;
  final List<Map<String, String>> currentTreatment;
  final List<BodyPart> bodyparts;
  final List<BodyPartList> bodypartList;
  final List<PatientImage> patientImages;

  final String photoTakingMethod;
  final String beforeWindowType;
  final String selectedPatientImageBodypartType;

  // BodyPart and Camera
  final int? selectedBodyPartOrder;
  final int? selectedGhostOrder;
  final int? selectedBodyPartLength;
  final int? selectedBodyPartGroup;
  final File? takenPhoto;
  final int? curMedicalNo;

  // Filters
  final String? filterKeywords;
  final int? filterDoctor;
  final int? filterBody;
  final int? filterInterval;
  final int? filterHasPhoto;

  // Gallery
  final Map<String, List<PatientImage>>? galleryData;
  final List<PatientImage>? galleryGhostData;
  final bool? isNormalGallery;

  PatientState copyWith(
      {PatientStatus? status,
      List<Patient>? patients,
      List<PatientImage>? selectedCompareImages,
      List<MedicalHistory>? medicalHistory,
      List<MedicalHistory>? totalmedicalHistory,
      Patient? selectedPatient,
      PatientImage? galleryPatientImageDblSelected,
      MedicalHistory? selectedMedicalHistory,
      List<Diagnosis>? diagnosis,
      List<CommonPhrase>? commonPhrase,
      List<Diagnosis>? diagnosisNormalList,
      List<Treatment>? treatments,
      List<User>? doctors,
      List<TreatmentInfo>? treatmentInfo,
      String? selectedNotes,
      String? beforeWindowType,
      User? currentUser,
      String? selectedGallerySortType,
      List<Treatment>? treatmentNormalList,
      List<Map<String, String>>? selectedDiagnosis,
      List<Map<String, String>>? selectedTreatment,
      List<Map<String, String>>? currentDiagnosis,
      List<Map<String, String>>? currentTreatment,
      List<BodyPart>? bodyparts,
      List<BodyPartList>? bodypartList,
      String? photoTakingMethod,
      String? selectedPatientImageBodypartType,
      List<PatientImage>? patientImages,
      List<PatientImage>? selectedPatientImages,
      List<PatientImage>? selectedPatientBodypartImages,
      Map<String, List<PatientImage>>? galleryData,
      List<PatientImage>? galleryGhostData,
      int? selectedBodyPartOrder,
      int? selectedGhostOrder,
      int? selectedBodyPartLength,
      int? selectedBodyPartGroup,
      File? takenPhoto,
      String? filterKeywords,
      int? filterDoctor,
      int? filterBody,
      int? filterInterval,
      int? filterHasPhoto,
      int? curMedicalNo,
      bool? isNormalGallery}) {
    return PatientState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      selectedBodyPartGroup:
          selectedBodyPartGroup ?? this.selectedBodyPartGroup,
      commonPhrase: commonPhrase ?? this.commonPhrase,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      doctors: doctors ?? this.doctors,
      selectedCompareImages:
          selectedCompareImages ?? this.selectedCompareImages,
      totalmedicalHistory: totalmedicalHistory ?? this.totalmedicalHistory,
      selectedNotes: selectedNotes ?? this.selectedNotes,
      beforeWindowType: beforeWindowType ?? this.beforeWindowType,
      selectedGallerySortType:
          selectedGallerySortType ?? this.selectedGallerySortType,
      galleryPatientImageDblSelected:
          galleryPatientImageDblSelected ?? this.galleryPatientImageDblSelected,
      selectedPatient: selectedPatient ?? this.selectedPatient,
      selectedMedicalHistory:
          selectedMedicalHistory ?? this.selectedMedicalHistory,
      diagnosis: diagnosis ?? this.diagnosis,
      diagnosisNormalList: diagnosisNormalList ?? this.diagnosisNormalList,
      treatments: treatments ?? this.treatments,
      treatmentInfo: treatmentInfo ?? this.treatmentInfo,
      currentUser: currentUser ?? this.currentUser,
      treatmentNormalList: treatmentNormalList ?? this.treatmentNormalList,
      selectedDiagnosis: selectedDiagnosis ?? this.selectedDiagnosis,
      selectedTreatment: selectedTreatment ?? this.selectedTreatment,
      currentDiagnosis: currentDiagnosis ?? this.currentDiagnosis,
      currentTreatment: currentTreatment ?? this.currentTreatment,
      photoTakingMethod: photoTakingMethod ?? this.photoTakingMethod,
      selectedPatientImageBodypartType: selectedPatientImageBodypartType ??
          this.selectedPatientImageBodypartType,
      selectedPatientImages:
          selectedPatientImages ?? this.selectedPatientImages,
      selectedPatientBodypartImages:
          selectedPatientBodypartImages ?? this.selectedPatientBodypartImages,
      bodyparts: bodyparts ?? this.bodyparts,
      bodypartList: bodypartList ?? this.bodypartList,
      galleryData: galleryData ?? this.galleryData,
      galleryGhostData: galleryGhostData ?? this.galleryGhostData,
      patientImages: patientImages ?? this.patientImages,
      selectedGhostOrder: selectedGhostOrder ?? this.selectedGhostOrder,
      selectedBodyPartOrder:
          selectedBodyPartOrder ?? this.selectedBodyPartOrder,
      selectedBodyPartLength:
          selectedBodyPartLength ?? this.selectedBodyPartLength,
      takenPhoto: takenPhoto ?? this.takenPhoto,
      filterKeywords: filterKeywords ?? this.filterKeywords,
      filterBody: filterBody ?? this.filterBody,
      filterInterval: filterInterval ?? this.filterInterval,
      filterDoctor: filterDoctor ?? this.filterDoctor,
      filterHasPhoto: filterHasPhoto ?? this.filterHasPhoto,
      curMedicalNo: curMedicalNo ?? this.curMedicalNo,
      isNormalGallery: isNormalGallery ?? this.isNormalGallery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        patients,
        medicalHistory,
        totalmedicalHistory,
        selectedPatient,
        selectedBodyPartGroup,
        selectedMedicalHistory,
        diagnosis,
        galleryPatientImageDblSelected,
        treatments,
        doctors,
        treatmentInfo,
        selectedCompareImages,
        beforeWindowType,
        selectedNotes,
        commonPhrase,
        currentUser,
        treatmentNormalList,
        selectedGallerySortType,
        diagnosisNormalList,
        selectedDiagnosis,
        selectedTreatment,
        currentDiagnosis,
        currentTreatment,
        selectedBodyPartOrder,
        selectedPatientImageBodypartType,
        selectedGhostOrder,
        selectedBodyPartLength,
        selectedPatientImages,
        selectedPatientBodypartImages,
        galleryData,
        galleryGhostData,
        takenPhoto,
        filterKeywords,
        filterBody,
        filterInterval,
        filterDoctor,
        filterHasPhoto,
        curMedicalNo,
        isNormalGallery
      ];
}
