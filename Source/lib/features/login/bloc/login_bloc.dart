import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:rxphoto/models/user.model.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final GlobalRepository globalRepository;
  LoginBloc({required this.globalRepository}) : super(LoginState()) {
    on<LoginBtnPressed>(_onLoginBtnPressed);
    on<LoginPassed>(_onLoginPassed);
  }

  Future<void> _onLoginPassed(
      LoginPassed event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loginSuccessed));
  }

  void _onLoginBtnPressed(
      LoginBtnPressed event, Emitter<LoginState> emit) async {
    try {
      emit(state.copyWith(status: LoginStatus.initial));
      Response saltValue = await globalRepository.dio
          .get('/api/user/login?username=${event.username}');
      Map mSaltValue = saltValue.data;
      final bytes = utf8.encode(mSaltValue['salt'] + event.password);
      final digest = sha1.convert(bytes);
      final result = "sha1\$${mSaltValue['salt']}\$${digest.toString()}";
      globalRepository.setAuthorHeader(event.username, event.password);
      Response userData = await globalRepository.dio
          .get('/api/user/login?username=${event.username}&hash=$result');

      globalRepository.setUser(User.fromJson(userData.data));
      emit(state.copyWith(
          status: LoginStatus.loginSuccess,
          user: User.fromJson(userData.data)));

      //Remove Cache files and files inside App_fluter directory(in root folder)
      // await DefaultCacheManager().emptyCache();
      // final cacheDir = await getTemporaryDirectory();
      // if (cacheDir.existsSync()) {
      //   cacheDir.deleteSync(recursive: true);
      // }
      // var appDocDir = await getApplicationDocumentsDirectory();

      // if (appDocDir.existsSync()) {
      //   appDocDir.deleteSync(recursive: true);
      // }

      AlertController.show(
          S.current.success, S.current.loginSuccess, TypeAlert.success);
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
        AlertController.show(
            S.current.wrong, S.current.wrongPassword, TypeAlert.error);
      } else {
        print('Error sending request!');
        print(e.message);
        AlertController.show(
            S.current.failed,
            S.current.connectionError +
                '\n' +
                globalRepository.dio.options.baseUrl,
            TypeAlert.error);
      }
      emit(state.copyWith(status: LoginStatus.loginFailure));
    }
  }
}
