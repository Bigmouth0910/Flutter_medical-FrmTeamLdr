import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxphoto/app/global_repository.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc({required GlobalRepository globalRepository})
      : _globalRepository = globalRepository,
        super(CameraState()) {
    on<CameraStarted>(_onStarted);
  }
  final GlobalRepository _globalRepository;
  Future<void> _onStarted(
      CameraStarted event, Emitter<CameraState> emit) async {}
}
