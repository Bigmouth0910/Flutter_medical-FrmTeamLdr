import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:rxphoto/common/constants/environment.dart';

class ApiClient {
  String baseUrl;
  late Dio dio;
  ApiClient(this.baseUrl) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: 5000,
        receiveTimeout: 3000,
      ),
    );
    // String credentials =
    //     "${appController.user.userName}:${appController.user.password}";
    // Codec<String, String> stringToBase64 = utf8.fuse(base64);
    // String encoded = 'Basic ' + stringToBase64.encode(credentials);
    // dio.options.headers['authorization'] = encoded;

    //For Proxy settings
    // More about HttpClient proxy topic please refer to Dart SDK doc.
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      // client.findProxy = (uri) {
      //   // proxy all request to 172.25.1.2:3129
      //   return 'PROXY 172.25.1.2:3129';
      // };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
  }
  // DioClient() {
  //   dio = Dio(
  //     BaseOptions(
  //       baseUrl: 'https://127.0.0.1:8100',
  //       connectTimeout: 5000,
  //       receiveTimeout: 3000,
  //     ),
  //   );
  //   dio.options.headers['authorization'] =

  //       //For Proxy settings
  //       // More about HttpClient proxy topic please refer to Dart SDK doc.
  //       (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
  //           (HttpClient client) {
  //     // client.findProxy = (uri) {
  //     //   //proxy all request to 172.25.1.2:3129
  //     //   return 'PROXY 172.25.1.2:3129';
  //     // };
  //     client.badCertificateCallback =
  //         (X509Certificate cert, String host, int port) => true;
  //   };
  // }
  // Future<UserInfo?> createUser({required UserInfo userInfo}) async {
  //   UserInfo? retrievedUser;

  //   try {
  //     Response response = await _dio.post(
  //       '/users',
  //       data: userInfo.toJson(),
  //     );

  //     print('User created: ${response.data}');

  //     retrievedUser = UserInfo.fromJson(response.data);
  //   } catch (e) {
  //     print('Error creating user: $e');
  //   }

  //   return retrievedUser;
  // }

  // Future<UserInfo?> updateUser({
  //   required UserInfo userInfo,
  //   required String id,
  // }) async {
  //   UserInfo? updatedUser;

  //   try {
  //     Response response = await _dio.put(
  //       '/users/$id',
  //       data: userInfo.toJson(),
  //     );

  //     print('User updated: ${response.data}');

  //     updatedUser = UserInfo.fromJson(response.data);
  //   } catch (e) {
  //     print('Error updating user: $e');
  //   }

  //   return updatedUser;
  // }

  // Future<void> deleteUser({required String id}) async {
  //   try {
  //     await _dio.delete('/users/$id');
  //     print('User deleted!');
  //   } catch (e) {
  //     print('Error deleting user: $e');
  //   }
  // }
}
