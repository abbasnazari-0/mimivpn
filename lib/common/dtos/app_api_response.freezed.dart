// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppApiResponse _$AppApiResponseFromJson(Map<String, dynamic> json) {
  return _AppApiResponse.fromJson(json);
}

/// @nodoc
mixin _$AppApiResponse {
  @JsonKey(name: "version")
  Version get version => throw _privateConstructorUsedError;
  @JsonKey(name: "forceUpdate")
  Map<String, bool> get forceUpdate => throw _privateConstructorUsedError;
  @JsonKey(name: "changeLog")
  Map<String, List<String>> get changeLog => throw _privateConstructorUsedError;
  @JsonKey(name: "testUrls")
  List<String> get testUrls => throw _privateConstructorUsedError;

  /// Serializes this AppApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppApiResponseCopyWith<AppApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppApiResponseCopyWith<$Res> {
  factory $AppApiResponseCopyWith(
          AppApiResponse value, $Res Function(AppApiResponse) then) =
      _$AppApiResponseCopyWithImpl<$Res, AppApiResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: "version") Version version,
      @JsonKey(name: "forceUpdate") Map<String, bool> forceUpdate,
      @JsonKey(name: "changeLog") Map<String, List<String>> changeLog,
      @JsonKey(name: "testUrls") List<String> testUrls});

  $VersionCopyWith<$Res> get version;
}

/// @nodoc
class _$AppApiResponseCopyWithImpl<$Res, $Val extends AppApiResponse>
    implements $AppApiResponseCopyWith<$Res> {
  _$AppApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? forceUpdate = null,
    Object? changeLog = null,
    Object? testUrls = null,
  }) {
    return _then(_value.copyWith(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as Version,
      forceUpdate: null == forceUpdate
          ? _value.forceUpdate
          : forceUpdate // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      changeLog: null == changeLog
          ? _value.changeLog
          : changeLog // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      testUrls: null == testUrls
          ? _value.testUrls
          : testUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VersionCopyWith<$Res> get version {
    return $VersionCopyWith<$Res>(_value.version, (value) {
      return _then(_value.copyWith(version: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppApiResponseImplCopyWith<$Res>
    implements $AppApiResponseCopyWith<$Res> {
  factory _$$AppApiResponseImplCopyWith(_$AppApiResponseImpl value,
          $Res Function(_$AppApiResponseImpl) then) =
      __$$AppApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "version") Version version,
      @JsonKey(name: "forceUpdate") Map<String, bool> forceUpdate,
      @JsonKey(name: "changeLog") Map<String, List<String>> changeLog,
      @JsonKey(name: "testUrls") List<String> testUrls});

  @override
  $VersionCopyWith<$Res> get version;
}

/// @nodoc
class __$$AppApiResponseImplCopyWithImpl<$Res>
    extends _$AppApiResponseCopyWithImpl<$Res, _$AppApiResponseImpl>
    implements _$$AppApiResponseImplCopyWith<$Res> {
  __$$AppApiResponseImplCopyWithImpl(
      _$AppApiResponseImpl _value, $Res Function(_$AppApiResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? forceUpdate = null,
    Object? changeLog = null,
    Object? testUrls = null,
  }) {
    return _then(_$AppApiResponseImpl(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as Version,
      forceUpdate: null == forceUpdate
          ? _value._forceUpdate
          : forceUpdate // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      changeLog: null == changeLog
          ? _value._changeLog
          : changeLog // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      testUrls: null == testUrls
          ? _value._testUrls
          : testUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppApiResponseImpl implements _AppApiResponse {
  const _$AppApiResponseImpl(
      {@JsonKey(name: "version") required this.version,
      @JsonKey(name: "forceUpdate")
      required final Map<String, bool> forceUpdate,
      @JsonKey(name: "changeLog")
      required final Map<String, List<String>> changeLog,
      @JsonKey(name: "testUrls") required final List<String> testUrls})
      : _forceUpdate = forceUpdate,
        _changeLog = changeLog,
        _testUrls = testUrls;

  factory _$AppApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppApiResponseImplFromJson(json);

  @override
  @JsonKey(name: "version")
  final Version version;
  final Map<String, bool> _forceUpdate;
  @override
  @JsonKey(name: "forceUpdate")
  Map<String, bool> get forceUpdate {
    if (_forceUpdate is EqualUnmodifiableMapView) return _forceUpdate;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_forceUpdate);
  }

  final Map<String, List<String>> _changeLog;
  @override
  @JsonKey(name: "changeLog")
  Map<String, List<String>> get changeLog {
    if (_changeLog is EqualUnmodifiableMapView) return _changeLog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_changeLog);
  }

  final List<String> _testUrls;
  @override
  @JsonKey(name: "testUrls")
  List<String> get testUrls {
    if (_testUrls is EqualUnmodifiableListView) return _testUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_testUrls);
  }

  @override
  String toString() {
    return 'AppApiResponse(version: $version, forceUpdate: $forceUpdate, changeLog: $changeLog, testUrls: $testUrls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppApiResponseImpl &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality()
                .equals(other._forceUpdate, _forceUpdate) &&
            const DeepCollectionEquality()
                .equals(other._changeLog, _changeLog) &&
            const DeepCollectionEquality().equals(other._testUrls, _testUrls));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      version,
      const DeepCollectionEquality().hash(_forceUpdate),
      const DeepCollectionEquality().hash(_changeLog),
      const DeepCollectionEquality().hash(_testUrls));

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppApiResponseImplCopyWith<_$AppApiResponseImpl> get copyWith =>
      __$$AppApiResponseImplCopyWithImpl<_$AppApiResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppApiResponseImplToJson(
      this,
    );
  }
}

abstract class _AppApiResponse implements AppApiResponse {
  const factory _AppApiResponse(
          {@JsonKey(name: "version") required final Version version,
          @JsonKey(name: "forceUpdate")
          required final Map<String, bool> forceUpdate,
          @JsonKey(name: "changeLog")
          required final Map<String, List<String>> changeLog,
          @JsonKey(name: "testUrls") required final List<String> testUrls}) =
      _$AppApiResponseImpl;

  factory _AppApiResponse.fromJson(Map<String, dynamic> json) =
      _$AppApiResponseImpl.fromJson;

  @override
  @JsonKey(name: "version")
  Version get version;
  @override
  @JsonKey(name: "forceUpdate")
  Map<String, bool> get forceUpdate;
  @override
  @JsonKey(name: "changeLog")
  Map<String, List<String>> get changeLog;
  @override
  @JsonKey(name: "testUrls")
  List<String> get testUrls;

  /// Create a copy of AppApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppApiResponseImplCopyWith<_$AppApiResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Version _$VersionFromJson(Map<String, dynamic> json) {
  return _Version.fromJson(json);
}

/// @nodoc
mixin _$Version {
  @JsonKey(name: "github")
  String get github => throw _privateConstructorUsedError;
  @JsonKey(name: "testFlight")
  String get testFlight => throw _privateConstructorUsedError;
  @JsonKey(name: "appleStore")
  String get appleStore => throw _privateConstructorUsedError;
  @JsonKey(name: "googlePlay")
  String get googlePlay => throw _privateConstructorUsedError;

  /// Serializes this Version to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VersionCopyWith<Version> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VersionCopyWith<$Res> {
  factory $VersionCopyWith(Version value, $Res Function(Version) then) =
      _$VersionCopyWithImpl<$Res, Version>;
  @useResult
  $Res call(
      {@JsonKey(name: "github") String github,
      @JsonKey(name: "testFlight") String testFlight,
      @JsonKey(name: "appleStore") String appleStore,
      @JsonKey(name: "googlePlay") String googlePlay});
}

/// @nodoc
class _$VersionCopyWithImpl<$Res, $Val extends Version>
    implements $VersionCopyWith<$Res> {
  _$VersionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? github = null,
    Object? testFlight = null,
    Object? appleStore = null,
    Object? googlePlay = null,
  }) {
    return _then(_value.copyWith(
      github: null == github
          ? _value.github
          : github // ignore: cast_nullable_to_non_nullable
              as String,
      testFlight: null == testFlight
          ? _value.testFlight
          : testFlight // ignore: cast_nullable_to_non_nullable
              as String,
      appleStore: null == appleStore
          ? _value.appleStore
          : appleStore // ignore: cast_nullable_to_non_nullable
              as String,
      googlePlay: null == googlePlay
          ? _value.googlePlay
          : googlePlay // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VersionImplCopyWith<$Res> implements $VersionCopyWith<$Res> {
  factory _$$VersionImplCopyWith(
          _$VersionImpl value, $Res Function(_$VersionImpl) then) =
      __$$VersionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "github") String github,
      @JsonKey(name: "testFlight") String testFlight,
      @JsonKey(name: "appleStore") String appleStore,
      @JsonKey(name: "googlePlay") String googlePlay});
}

/// @nodoc
class __$$VersionImplCopyWithImpl<$Res>
    extends _$VersionCopyWithImpl<$Res, _$VersionImpl>
    implements _$$VersionImplCopyWith<$Res> {
  __$$VersionImplCopyWithImpl(
      _$VersionImpl _value, $Res Function(_$VersionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? github = null,
    Object? testFlight = null,
    Object? appleStore = null,
    Object? googlePlay = null,
  }) {
    return _then(_$VersionImpl(
      github: null == github
          ? _value.github
          : github // ignore: cast_nullable_to_non_nullable
              as String,
      testFlight: null == testFlight
          ? _value.testFlight
          : testFlight // ignore: cast_nullable_to_non_nullable
              as String,
      appleStore: null == appleStore
          ? _value.appleStore
          : appleStore // ignore: cast_nullable_to_non_nullable
              as String,
      googlePlay: null == googlePlay
          ? _value.googlePlay
          : googlePlay // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VersionImpl implements _Version {
  const _$VersionImpl(
      {@JsonKey(name: "github") required this.github,
      @JsonKey(name: "testFlight") required this.testFlight,
      @JsonKey(name: "appleStore") required this.appleStore,
      @JsonKey(name: "googlePlay") required this.googlePlay});

  factory _$VersionImpl.fromJson(Map<String, dynamic> json) =>
      _$$VersionImplFromJson(json);

  @override
  @JsonKey(name: "github")
  final String github;
  @override
  @JsonKey(name: "testFlight")
  final String testFlight;
  @override
  @JsonKey(name: "appleStore")
  final String appleStore;
  @override
  @JsonKey(name: "googlePlay")
  final String googlePlay;

  @override
  String toString() {
    return 'Version(github: $github, testFlight: $testFlight, appleStore: $appleStore, googlePlay: $googlePlay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VersionImpl &&
            (identical(other.github, github) || other.github == github) &&
            (identical(other.testFlight, testFlight) ||
                other.testFlight == testFlight) &&
            (identical(other.appleStore, appleStore) ||
                other.appleStore == appleStore) &&
            (identical(other.googlePlay, googlePlay) ||
                other.googlePlay == googlePlay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, github, testFlight, appleStore, googlePlay);

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VersionImplCopyWith<_$VersionImpl> get copyWith =>
      __$$VersionImplCopyWithImpl<_$VersionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VersionImplToJson(
      this,
    );
  }
}

abstract class _Version implements Version {
  const factory _Version(
          {@JsonKey(name: "github") required final String github,
          @JsonKey(name: "testFlight") required final String testFlight,
          @JsonKey(name: "appleStore") required final String appleStore,
          @JsonKey(name: "googlePlay") required final String googlePlay}) =
      _$VersionImpl;

  factory _Version.fromJson(Map<String, dynamic> json) = _$VersionImpl.fromJson;

  @override
  @JsonKey(name: "github")
  String get github;
  @override
  @JsonKey(name: "testFlight")
  String get testFlight;
  @override
  @JsonKey(name: "appleStore")
  String get appleStore;
  @override
  @JsonKey(name: "googlePlay")
  String get googlePlay;

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VersionImplCopyWith<_$VersionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
