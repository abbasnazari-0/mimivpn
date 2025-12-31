import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_api_response.freezed.dart';
part 'app_api_response.g.dart';

@freezed
class AppApiResponse with _$AppApiResponse {
  const factory AppApiResponse({
    @JsonKey(name: "version") required Version version,
    @JsonKey(name: "forceUpdate") required Map<String, bool> forceUpdate,
    @JsonKey(name: "changeLog") required Map<String, List<String>> changeLog,
    @JsonKey(name: "testUrls") required List<String> testUrls,
  }) = _AppApiResponse;

  factory AppApiResponse.fromJson(Map<String, dynamic> json) =>
      _$AppApiResponseFromJson(json);
}

@freezed
class Version with _$Version {
  const factory Version({
    @JsonKey(name: "github") required String github,
    @JsonKey(name: "testFlight") required String testFlight,
    @JsonKey(name: "appleStore") required String appleStore,
    @JsonKey(name: "googlePlay") required String googlePlay,
  }) = _Version;

  factory Version.fromJson(Map<String, dynamic> json) =>
      _$VersionFromJson(json);
}
