// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppApiResponseImpl _$$AppApiResponseImplFromJson(Map<String, dynamic> json) =>
    _$AppApiResponseImpl(
      version: Version.fromJson(json['version'] as Map<String, dynamic>),
      forceUpdate: Map<String, bool>.from(json['forceUpdate'] as Map),
      changeLog: (json['changeLog'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      testUrls:
          (json['testUrls'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$AppApiResponseImplToJson(
        _$AppApiResponseImpl instance) =>
    <String, dynamic>{
      'version': instance.version,
      'forceUpdate': instance.forceUpdate,
      'changeLog': instance.changeLog,
      'testUrls': instance.testUrls,
    };

_$VersionImpl _$$VersionImplFromJson(Map<String, dynamic> json) =>
    _$VersionImpl(
      github: json['github'] as String,
      testFlight: json['testFlight'] as String,
      appleStore: json['appleStore'] as String,
      googlePlay: json['googlePlay'] as String,
    );

Map<String, dynamic> _$$VersionImplToJson(_$VersionImpl instance) =>
    <String, dynamic>{
      'github': instance.github,
      'testFlight': instance.testFlight,
      'appleStore': instance.appleStore,
      'googlePlay': instance.googlePlay,
    };
