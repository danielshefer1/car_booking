// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Car _$CarFromJson(Map<String, dynamic> json) => _Car(
  id: (json['id'] as num).toInt(),
  company: json['company'] as String,
  model: json['model'] as String,
  year: (json['year'] as num).toInt(),
);

Map<String, dynamic> _$CarToJson(_Car instance) => <String, dynamic>{
  'id': instance.id,
  'company': instance.company,
  'model': instance.model,
  'year': instance.year,
};
