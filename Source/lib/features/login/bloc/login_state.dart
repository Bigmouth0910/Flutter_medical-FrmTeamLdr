part of 'login_bloc.dart';

enum LoginStatus { initial, loginSuccess, loginSuccessed, loginFailure }

class LoginState extends Equatable {
  const LoginState({this.status = LoginStatus.initial, this.user});
  final LoginStatus status;
  final User? user;

  LoginState copyWith({LoginStatus? status, User? user}) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, user];
}
