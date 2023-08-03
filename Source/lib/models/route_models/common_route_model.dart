import 'package:flutter/cupertino.dart';

// CommonRouteModel commonRouteModelFromJson(String str) =>
//     CommonRouteModel.fromJson(json.decode(str));
//
// String commonRouteModelToJson(CommonRouteModel data) =>
//     json.encode(data.toJson());

class CommonRouteModel {
  CommonRouteModel({
    this.context,
    this.data,
  });

  BuildContext? context;
  dynamic data;

  // factory CommonRouteModel.fromJson(Map<String, dynamic> json) =>
  //     CommonRouteModel(
  //       context: json["context"],
  //     );
  //
  // Map<String, dynamic> toJson() => {
  //       "context": context,
  //     };
}
