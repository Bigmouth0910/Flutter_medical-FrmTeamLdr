part of 'patientdetail_bloc.dart';

abstract class PatientdetailEvent extends Equatable {
  const PatientdetailEvent();

  @override
  List<Object> get props => [];
}

class PatientDetailInitialDataRequested extends PatientdetailEvent {
  const PatientDetailInitialDataRequested();
}
