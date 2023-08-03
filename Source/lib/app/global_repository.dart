import 'dart:developer';

import 'package:dio/adapter.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxphoto/common/constants/environment.dart';
import 'package:rxphoto/generated/l10n.dart';
import 'package:rxphoto/models/bodypart.model.dart';
import 'package:rxphoto/models/bodypartlist.model.dart';
import 'package:rxphoto/models/commonphrase.model.dart';
import 'package:rxphoto/models/diagnosis.model.dart';
import 'package:rxphoto/models/medicalhistory.model.dart';
import 'dart:io';

import 'package:rxphoto/models/patient.model.dart';
import 'package:rxphoto/models/patientImage.model.dart';
import 'package:rxphoto/models/totalDiagnosis.model.dart';
import 'package:rxphoto/models/totalTreatment.model.dart';
import 'package:rxphoto/models/treatment.model.dart';
import 'package:rxphoto/models/treatmentInfo.model.dart';
import 'package:rxphoto/models/user.model.dart';

class DataRequestFailure implements Exception {}

class NoInternetConnection implements Exception {}

class GlobalRepository {
  User? _user;
  Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    ),
  );
  GlobalRepository() {
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

  void setUser(User user) {
    userName = user.firstName! + " " + user.lastName!;
    _user = user;
  }

  User getUser() {
    return _user!;
  }

  void setAuthorHeader(String username, String password) {
    String credentials = "$username:$password";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = 'Basic ' + stringToBase64.encode(credentials);
    dio.options.headers['authorization'] = encoded;
    authString = encoded;
  }

  Future<Patient> createPatient(dynamic patient) async {
    Patient result;
    try {
      var data = FormData.fromMap(patient);
      Response response = await dio.post('/api/patient', data: data);
      result = Patient.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
        AlertController.show(
            S.current.failed, S.current.connectionError, TypeAlert.error);
      }
      throw DataRequestFailure();
    }
    return result;
  }

  Future<MedicalHistory> createMedicalHistory(dynamic medicalHistory) async {
    MedicalHistory result;
    try {
      // var data = FormData.fromMap(medicalHistory);
      Response response =
          await dio.post('/api/medicalInfo', data: medicalHistory);
      result = MedicalHistory.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
        AlertController.show(
            S.current.failed, S.current.connectionError, TypeAlert.error);
      }
      throw DataRequestFailure();
    }
    return result;
  }

  Future<void> updateMedicalHistory(dynamic data) async {
    try {
      await dio.put('/api/medicalInfo', data: data);
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
        AlertController.show(
            S.current.failed, S.current.connectionError, TypeAlert.error);
      }
      throw DataRequestFailure();
    }
  }

  Future<void> removeMedicalHistory(int medicalHistoryId) async {
    try {
      await dio.delete('/api/medicalInfo/$medicalHistoryId');
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
        AlertController.show(
            S.current.failed, S.current.connectionError, TypeAlert.error);
      }
      throw DataRequestFailure();
    }
  }

  Future<void> addPatientImage(dynamic patient, {bool flag = false}) async {
    try {
      var data = FormData.fromMap(patient);
      String url = '/api/patient/image';

      if (flag == true) {
        url = '/api/patient/uncategorized-image';
      }

      await dio.post(url, data: data, onSendProgress: (sent, total) {
        print(
            'progress: ${(sent / total * 100).toStringAsFixed(0)}% ($sent/$total)');
      });
    } on DioError catch (e) {
      AlertController.show(
          S.current.uploadFailed, S.current.uploadFailedDesc, TypeAlert.error);
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    var appDocDir = await getApplicationDocumentsDirectory();
    if (appDocDir.existsSync()) {
      appDocDir.deleteSync(recursive: true);
    }
  }

  Future<void> createAlbumPatientImages(dynamic patient) async {
    try {
      var data = FormData.fromMap(patient);
      String url = '/api/patient/createAlbumPatientImages';

      log(patient.toString());

      await dio.post(url, data: patient, onSendProgress: (sent, total) {
        print(
            'progress: ${(sent / total * 100).toStringAsFixed(0)}% ($sent/$total)');
      });
    } on DioError catch (e) {
      AlertController.show(
          S.current.uploadFailed, S.current.uploadFailedDesc, TypeAlert.error);
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    var appDocDir = await getApplicationDocumentsDirectory();
    if (appDocDir.existsSync()) {
      appDocDir.deleteSync(recursive: true);
    }
  }

  Future<void> updatePatient(int id, dynamic patient) async {
    try {
      await dio.put('/api/patient/$id', data: patient);
    } on DioError catch (e) {
      AlertController.show(
          S.current.uploadFailed, S.current.uploadFailedDesc, TypeAlert.error);
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
  }

  // Future<void> updatePatientImageNote(int id, dynamic patient) async {
  //   try {
  //     await dio.put('/api/patient/$id', data: patient);
  //   } on DioError catch (e) {
  //     AlertController.show("Save Failed",
  //         "Save photo was failed from some error", TypeAlert.error);
  //     if (e.response != null) {
  //       print('Dio error!');
  //       print('STATUS: ${e.response?.statusCode}');
  //       print('DATA: ${e.response?.data}');
  //       print('HEADERS: ${e.response?.headers}');
  //     } else {
  //       print('Error sending request!');
  //       print(e.message);
  //     }
  //     throw DataRequestFailure();
  //   }
  // }

  Future<List<Patient>> getPatient({String orderBy = "new"}) async {
    List<Patient> patients = <Patient>[];
    try {
      Response response = await dio
          .get('/api/patient?doctor_id=${_user!.id}&order_by=${orderBy}');
      for (var item in response.data) {
        patients.add(Patient.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
        AlertController.show(
            S.current.failed, S.current.connectionError, TypeAlert.error);
      }
      throw DataRequestFailure();
    }

    return patients;
  }

  Future<List<Patient>> getPatientSuggestions(String keyword) async {
    List<Patient> patients = <Patient>[];
    try {
      Response response =
          await dio.get('/api/getPatient?searchInput=${keyword}');

      for (var item in response.data) {
        patients.add(Patient.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
        AlertController.show(
            S.current.failed, S.current.connectionError, TypeAlert.error);
      }
      throw DataRequestFailure();
    }

    return patients;
  }

  Future<List<User>> getDoctorsInfo() async {
    List<User> doctors = <User>[];
    try {
      Response response = await dio.get('/api/doctorsInfo');
      for (var item in response.data) {
        doctors.add(User.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
        AlertController.show(
            S.current.failed, S.current.connectionError, TypeAlert.error);
      }
      throw DataRequestFailure();
    }
    return doctors;
  }

  Future<List<PatientImage>> getPatientImage(int id,
      {bool isNormalGallery = true, bool orderBy = true}) async {
    List<PatientImage> patientImages = <PatientImage>[];
    try {
      var url = "";

      if (isNormalGallery)
        url = '/api/patient/image?patient_id=$id';
      else
        url =
            '/api/patient/get-uncategorized-images?doctor_id=$id&order=$orderBy';

      Response response = await dio.get(url);
      for (var item in response.data) {
        patientImages.add(PatientImage.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
        throw DataRequestFailure();
      } else {
        print('Error sending request!');
        print(e.message);
        AlertController.show(
            S.current.failed, S.current.connectionError, TypeAlert.error);
        throw NoInternetConnection();
      }
    }
    return patientImages;
  }

  Future<List<MedicalHistory>> getMedicalHistory(
      String? medicalHistoryNo) async {
    List<MedicalHistory> medicalHistory = <MedicalHistory>[];
    try {
      var url = '/api/medicalInfo';
      Response response;
      if (medicalHistoryNo != null)
        response = await dio.get(url,
            queryParameters: {'MEDICAL_HISTORY_NO': medicalHistoryNo});
      else
        response = await dio.get(url);

      for (var item in response.data) {
        medicalHistory.add(MedicalHistory.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return medicalHistory;
  }

  Future<List<PatientImage>> getPatientBodyPartImage(
      int patientId, int bodyPartId) async {
    List<PatientImage> patientImages = <PatientImage>[];
    try {
      var url =
          '/api/patient/image?patient_id=$patientId&body_part_id=$bodyPartId';
      Response response = await dio.get(url);
      for (var item in response.data) {
        patientImages.add(PatientImage.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return patientImages;
  }

  Future<List<BodyPart>> getBodyPart() async {
    List<BodyPart> bodyparts = <BodyPart>[];
    try {
      Response response = await dio.get('/api/body_part');
      for (var item in response.data) {
        bodyparts.add(BodyPart.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return bodyparts;
  }

  Future<List<BodyPartList>> getLBodypartList() async {
    List<BodyPartList> bodypartlist = <BodyPartList>[];
    try {
      Response response = await dio.get('/api/Lbody_part');
      for (var item in response.data) {
        bodypartlist.add(BodyPartList.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return bodypartlist;
  }

  Future<List<BodyPart>> getBodyPartList() async {
    List<BodyPart> bodyParts = <BodyPart>[];
    try {
      Response response = await dio.get('/api/body_part');
      for (var item in response.data) {
        bodyParts.add(BodyPart.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return bodyParts;
  }

  Future<List<Diagnosis>> getDiagnosis() async {
    List<Diagnosis> diagnosis = <Diagnosis>[];
    try {
      Response response = await dio.get('/api/diagnosis');
      TotalDiagnosis total = TotalDiagnosis.fromJson(response.data);
      diagnosis = total.rows;
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return diagnosis;
  }

  Future<List<CommonPhrase>> getCommonPhrase() async {
    List<CommonPhrase> commonPhrases = <CommonPhrase>[];
    try {
      Response response = await dio.get('/api/commonPhrase');
      for (var item in response.data) {
        commonPhrases.add(CommonPhrase.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return commonPhrases;
  }

  Future<List<Diagnosis>> getNormalDiagnosis() async {
    List<Diagnosis> diagnosis = <Diagnosis>[];
    try {
      Response response = await dio.get('/api/diagnosis_list');
      for (var item in response.data) {
        diagnosis.add(Diagnosis.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return diagnosis;
  }

  Future<List<Treatment>> getTreatment() async {
    List<Treatment> treatments = <Treatment>[];
    try {
      Response response = await dio.get('/api/treatment');
      TotalTreatment total = TotalTreatment.fromJson(response.data);
      treatments = total.rows!;
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return treatments;
  }

  Future<List<TreatmentInfo>> getTreatmentInfo() async {
    List<TreatmentInfo> treatmentInfo = <TreatmentInfo>[];
    try {
      Response response = await dio.get('/api/treatmentInfo');
      for (var item in response.data) {
        treatmentInfo.add(TreatmentInfo.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return treatmentInfo;
  }

  Future<List<Treatment>> getNormalTreatment() async {
    List<Treatment> treatments = <Treatment>[];
    try {
      Response response = await dio.get('/api/treatment_list');
      for (var item in response.data) {
        treatments.add(Treatment.fromJson(item));
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error sending request!');
        print(e.message);
      }
      throw DataRequestFailure();
    }
    return treatments;
  }
}
