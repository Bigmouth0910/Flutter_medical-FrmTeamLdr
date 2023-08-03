import 'package:json_annotation/json_annotation.dart';
import 'package:rxphoto/models/treatment.model.dart';

part 'totalTreatment.model.g.dart';

@JsonSerializable()
class TotalTreatment {
  TotalTreatment({
    this.count,
    this.rows,
  });
  @JsonKey(name: 'count')
  int? count;
  @JsonKey(name: 'rows')
  List<Treatment>? rows;

  factory TotalTreatment.fromJson(Map<String, dynamic> json) =>
      _$TotalTreatmentFromJson(json);

  Map<String, dynamic> toJson() => _$TotalTreatmentToJson(this);
}
