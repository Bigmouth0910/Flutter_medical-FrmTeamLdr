import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/models/bodypart.model.dart';
import 'package:rxphoto/models/patientImage.model.dart';

part 'patientdetail_event.dart';
part 'patientdetail_state.dart';

class PatientdetailBloc extends Bloc<PatientdetailEvent, PatientdetailState> {
  PatientdetailBloc({required GlobalRepository globalRepository})
      : _globalRepository = globalRepository,
        super(PatientdetailState()) {
    on<PatientDetailInitialDataRequested>(_onInitialDataRequested);
  }
  final GlobalRepository _globalRepository;

  Future<void> _onInitialDataRequested(PatientDetailInitialDataRequested event,
      Emitter<PatientdetailState> emit) async {
    emit(state.copyWith(status: PatientDetailStatus.loading));
    try {
      final bodyparts = await _globalRepository.getBodyPart();
      // final patientImages = await _globalRepository.getPatientImage();
      // emit(state.copyWith(
      //     status: PatientDetailStatus.success,
      //     bodyparts: bodyparts,
      //     patientImages: patientImages));
    } catch (e) {
      emit(state.copyWith(status: PatientDetailStatus.failure));
    }
  }
}
