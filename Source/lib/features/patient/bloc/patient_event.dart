part of 'patient_bloc.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object> get props => [];
}

class PatientDataRequested extends PatientEvent {
  const PatientDataRequested({this.orderBy = "new"});
  final String orderBy;
}

class PatientImageUpdateRequested extends PatientEvent {
  const PatientImageUpdateRequested();
}

class PatientDataCreated extends PatientEvent {
  const PatientDataCreated(this.data);
  final dynamic data;
}

class PatientAndMedicalHistoryDataCreated extends PatientEvent {
  const PatientAndMedicalHistoryDataCreated(this.pData, this.hData);
  final dynamic pData;
  final dynamic hData;
}

class MedicalDataCreated extends PatientEvent {
  const MedicalDataCreated(this.pData, this.data);
  final dynamic data;
  final dynamic pData;
}

class BeforeWindowTypeChanged extends PatientEvent {
  const BeforeWindowTypeChanged(this.type);
  final String type;
}

class MedicalDataUpdateRequested extends PatientEvent {
  const MedicalDataUpdateRequested(this.data);
  final dynamic data;
}

class MedicalDataRemoved extends PatientEvent {
  const MedicalDataRemoved(this.id);
  final int id;
}

class MedicalSuggestion extends PatientEvent {
  const MedicalSuggestion();
}

class PatientImageBodyPartTypeSelected extends PatientEvent {
  const PatientImageBodyPartTypeSelected(this.type);
  final String type;
}

class PatientNoteUpdated extends PatientEvent {
  const PatientNoteUpdated(this.noteContent);
  final String noteContent;
}

class MedicalHistoryDataRequested extends PatientEvent {
  const MedicalHistoryDataRequested();
}

class GalleryPatientImageDblSelected extends PatientEvent {
  const GalleryPatientImageDblSelected(this.patientImage);
  final PatientImage patientImage;
}

class PatientDialogDiagnosisSelected extends PatientEvent {
  const PatientDialogDiagnosisSelected(this.key, this.label);
  final String key;
  final String label;
}

class PatientDialogCommonPhraseSelected extends PatientEvent {
  const PatientDialogCommonPhraseSelected(this.key, this.label);
  final String key;
  final String label;
}

class PatientDialogTreatmentSelected extends PatientEvent {
  const PatientDialogTreatmentSelected(this.key, this.label);
  final String key;
  final String label;
}

class PatientSelected extends PatientEvent {
  const PatientSelected(this.patient);
  final Patient patient;
}

class PatientBodyPartOrderSelected extends PatientEvent {
  const PatientBodyPartOrderSelected(
      this.order, this.sectionLength, this.partFor);
  final int order;
  final int sectionLength;
  final int partFor;
}

class PatientGhostOrderSelected extends PatientEvent {
  const PatientGhostOrderSelected(this.order);
  final int order;
}

class PatientGhostOrderForward extends PatientEvent {
  const PatientGhostOrderForward();
}

class PatientGhostOrderBackward extends PatientEvent {
  const PatientGhostOrderBackward();
}

class PatientPhotoTakingMethodSelected extends PatientEvent {
  const PatientPhotoTakingMethodSelected(this.method);
  final String method;
}

class PatientPhotoTaken extends PatientEvent {
  const PatientPhotoTaken(this.photo);
  final File photo;
}

class PatientSelectNextOrder extends PatientEvent {
  const PatientSelectNextOrder();
}

class PatientDeleteDiagnosis extends PatientEvent {
  const PatientDeleteDiagnosis(this.key);
  final String key;
}

class PatientDeleteTreatment extends PatientEvent {
  const PatientDeleteTreatment(this.key);
  final String key;
}

class PatientDialogInputStarted extends PatientEvent {
  final bool isFormatSelectedPatient;
  final bool isFormatPatientInfoOnly;
  const PatientDialogInputStarted(
      {this.isFormatSelectedPatient = false,
      this.isFormatPatientInfoOnly = false});
}

class MedicalHistoryDialogInputStarted extends PatientEvent {
  const MedicalHistoryDialogInputStarted();
}

class MedicalHistoryDataUpdated extends PatientEvent {
  const MedicalHistoryDataUpdated(this.data);
  final MedicalHistory data;
}

// Gallery

class PatientGalleryDataRequested extends PatientEvent {
  const PatientGalleryDataRequested(this.sortBy, {this.orderBy = true});
  final String sortBy;
  final bool? orderBy;
}

class SetGalleryType extends PatientEvent {
  const SetGalleryType(this.isNormalGallery);
  final bool isNormalGallery;
}

class UserDataSaved extends PatientEvent {
  const UserDataSaved(this.user);
  final User user;
}

class ComparePatientImageSelected extends PatientEvent {
  const ComparePatientImageSelected(this.patientImages);
  final List<PatientImage> patientImages;
}

class PatientGalleryPatientSelected extends PatientEvent {
  const PatientGalleryPatientSelected(this.selectedPatientImage);
  final PatientImage selectedPatientImage;
}

class PatientGalleryCompareRequested extends PatientEvent {
  const PatientGalleryCompareRequested();
}

class PatientCurMedicalNo extends PatientEvent {
  final int curMedicalNo;
  const PatientCurMedicalNo(this.curMedicalNo);
}

class PatientFilterDone extends PatientEvent {
  final String? filterKeywords;
  final int? filterDoctor;
  final int? filterBody;
  final int? filterInterval;
  final int? filterHasPhoto;

  const PatientFilterDone(
    this.filterKeywords,
    this.filterDoctor,
    this.filterBody,
    this.filterInterval,
    this.filterHasPhoto,
  );
}
