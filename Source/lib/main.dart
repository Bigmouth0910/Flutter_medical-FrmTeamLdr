import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxphoto/app/global_repository.dart';
import 'package:rxphoto/app/mobile_application.dart';
import 'package:rxphoto/app_observer.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];
var proxyHost;
var proxyPort;
Future<void> main() async {
  // HttpClient client = HttpClient();
  // client.findProxy = (url) {
  //   return HttpClient.findProxyFromEnvironment(url, environment: {
  //     "http_proxy": "172.25.1.2:3129",
  //     "https_proxy": "172.25.1.2:3129",
  //     "HTTPS_PROXY": "172.25.1.2:3129",
  //     "no_proxy": "localhost,10.97.5.38"
  //   });
  // };
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }

  BlocOverrides.runZoned(
    () => runApp(MobileApplication(globalRepository: GlobalRepository())),
    blocObserver: AppObserver(),
  );
}
