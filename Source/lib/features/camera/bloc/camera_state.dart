part of 'camera_bloc.dart';

enum CameraStatus { initial, loading, success, failure }

class CameraState extends Equatable {
  const CameraState({this.status = CameraStatus.initial});
  final CameraStatus status;
  @override
  List<Object?> get props => [
        status,
      ];
}
