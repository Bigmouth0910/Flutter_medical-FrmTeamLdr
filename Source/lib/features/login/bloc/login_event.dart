part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class InitiateLoginEvent extends LoginEvent {
  const InitiateLoginEvent();
}

class LoginPassed extends LoginEvent {
  const LoginPassed();
}

class LoginBtnPressed extends LoginEvent {
  LoginBtnPressed(this.username, this.password);

  final String username;
  final String password;

  @override
  List<Object> get props => [username, password];
}
