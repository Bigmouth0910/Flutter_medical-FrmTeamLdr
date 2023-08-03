part of 'patientdetail_bloc.dart';

enum PatientDetailStatus { initial, loading, success, failure }

class PatientdetailState extends Equatable {
  const PatientdetailState(
      {this.status = PatientDetailStatus.initial,
      this.bodyparts = const [],
      this.patientImages = const []});
  final PatientDetailStatus status;
  final List<BodyPart> bodyparts;
  final List<PatientImage> patientImages;

  PatientdetailState copyWith(
      {PatientDetailStatus? status,
      List<BodyPart>? bodyparts,
      List<PatientImage>? patientImages}) {
    return PatientdetailState(
        status: status ?? this.status,
        bodyparts: bodyparts ?? this.bodyparts,
        patientImages: patientImages ?? this.patientImages);
  }

  @override
  List<Object?> get props => [status, bodyparts];
}
