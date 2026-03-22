// This is a generated file - do not edit.
//
// Generated from vpn_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ConnectRequest extends $pb.GeneratedMessage {
  factory ConnectRequest({
    $core.String? configUri,
    $core.String? tlsFingerprint,
    $core.bool? killSwitch,
    $core.String? maskingSni,
  }) {
    final result = create();
    if (configUri != null) result.configUri = configUri;
    if (tlsFingerprint != null) result.tlsFingerprint = tlsFingerprint;
    if (killSwitch != null) result.killSwitch = killSwitch;
    if (maskingSni != null) result.maskingSni = maskingSni;
    return result;
  }

  ConnectRequest._();

  factory ConnectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configUri')
    ..aOS(2, _omitFieldNames ? '' : 'tlsFingerprint')
    ..aOB(3, _omitFieldNames ? '' : 'killSwitch')
    ..aOS(4, _omitFieldNames ? '' : 'maskingSni')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectRequest copyWith(void Function(ConnectRequest) updates) =>
      super.copyWith((message) => updates(message as ConnectRequest))
          as ConnectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectRequest create() => ConnectRequest._();
  @$core.override
  ConnectRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectRequest>(create);
  static ConnectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configUri => $_getSZ(0);
  @$pb.TagNumber(1)
  set configUri($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigUri() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tlsFingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set tlsFingerprint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTlsFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearTlsFingerprint() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get killSwitch => $_getBF(2);
  @$pb.TagNumber(3)
  set killSwitch($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKillSwitch() => $_has(2);
  @$pb.TagNumber(3)
  void clearKillSwitch() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get maskingSni => $_getSZ(3);
  @$pb.TagNumber(4)
  set maskingSni($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaskingSni() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaskingSni() => $_clearField(4);
}

class ConnectResponse extends $pb.GeneratedMessage {
  factory ConnectResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? serverIp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (serverIp != null) result.serverIp = serverIp;
    return result;
  }

  ConnectResponse._();

  factory ConnectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'serverIp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectResponse copyWith(void Function(ConnectResponse) updates) =>
      super.copyWith((message) => updates(message as ConnectResponse))
          as ConnectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectResponse create() => ConnectResponse._();
  @$core.override
  ConnectResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectResponse>(create);
  static ConnectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get serverIp => $_getSZ(2);
  @$pb.TagNumber(3)
  set serverIp($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasServerIp() => $_has(2);
  @$pb.TagNumber(3)
  void clearServerIp() => $_clearField(3);
}

class DisconnectRequest extends $pb.GeneratedMessage {
  factory DisconnectRequest() => create();

  DisconnectRequest._();

  factory DisconnectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisconnectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisconnectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisconnectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisconnectRequest copyWith(void Function(DisconnectRequest) updates) =>
      super.copyWith((message) => updates(message as DisconnectRequest))
          as DisconnectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisconnectRequest create() => DisconnectRequest._();
  @$core.override
  DisconnectRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DisconnectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisconnectRequest>(create);
  static DisconnectRequest? _defaultInstance;
}

class DisconnectResponse extends $pb.GeneratedMessage {
  factory DisconnectResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    return result;
  }

  DisconnectResponse._();

  factory DisconnectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisconnectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisconnectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisconnectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisconnectResponse copyWith(void Function(DisconnectResponse) updates) =>
      super.copyWith((message) => updates(message as DisconnectResponse))
          as DisconnectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisconnectResponse create() => DisconnectResponse._();
  @$core.override
  DisconnectResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DisconnectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisconnectResponse>(create);
  static DisconnectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class StatsRequest extends $pb.GeneratedMessage {
  factory StatsRequest() => create();

  StatsRequest._();

  factory StatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsRequest copyWith(void Function(StatsRequest) updates) =>
      super.copyWith((message) => updates(message as StatsRequest))
          as StatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatsRequest create() => StatsRequest._();
  @$core.override
  StatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatsRequest>(create);
  static StatsRequest? _defaultInstance;
}

class StatsResponse extends $pb.GeneratedMessage {
  factory StatsResponse({
    $fixnum.Int64? uploadBytes,
    $fixnum.Int64? downloadBytes,
    $fixnum.Int64? uploadSpeed,
    $fixnum.Int64? downloadSpeed,
    $core.int? pingMs,
    $fixnum.Int64? connectedSince,
    $core.String? state,
  }) {
    final result = create();
    if (uploadBytes != null) result.uploadBytes = uploadBytes;
    if (downloadBytes != null) result.downloadBytes = downloadBytes;
    if (uploadSpeed != null) result.uploadSpeed = uploadSpeed;
    if (downloadSpeed != null) result.downloadSpeed = downloadSpeed;
    if (pingMs != null) result.pingMs = pingMs;
    if (connectedSince != null) result.connectedSince = connectedSince;
    if (state != null) result.state = state;
    return result;
  }

  StatsResponse._();

  factory StatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'uploadBytes')
    ..aInt64(2, _omitFieldNames ? '' : 'downloadBytes')
    ..aInt64(3, _omitFieldNames ? '' : 'uploadSpeed')
    ..aInt64(4, _omitFieldNames ? '' : 'downloadSpeed')
    ..aI(5, _omitFieldNames ? '' : 'pingMs')
    ..aInt64(6, _omitFieldNames ? '' : 'connectedSince')
    ..aOS(7, _omitFieldNames ? '' : 'state')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsResponse copyWith(void Function(StatsResponse) updates) =>
      super.copyWith((message) => updates(message as StatsResponse))
          as StatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatsResponse create() => StatsResponse._();
  @$core.override
  StatsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatsResponse>(create);
  static StatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uploadBytes => $_getI64(0);
  @$pb.TagNumber(1)
  set uploadBytes($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUploadBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearUploadBytes() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get downloadBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set downloadBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDownloadBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearDownloadBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get uploadSpeed => $_getI64(2);
  @$pb.TagNumber(3)
  set uploadSpeed($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUploadSpeed() => $_has(2);
  @$pb.TagNumber(3)
  void clearUploadSpeed() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get downloadSpeed => $_getI64(3);
  @$pb.TagNumber(4)
  set downloadSpeed($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDownloadSpeed() => $_has(3);
  @$pb.TagNumber(4)
  void clearDownloadSpeed() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pingMs => $_getIZ(4);
  @$pb.TagNumber(5)
  set pingMs($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPingMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearPingMs() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get connectedSince => $_getI64(5);
  @$pb.TagNumber(6)
  set connectedSince($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConnectedSince() => $_has(5);
  @$pb.TagNumber(6)
  void clearConnectedSince() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get state => $_getSZ(6);
  @$pb.TagNumber(7)
  set state($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasState() => $_has(6);
  @$pb.TagNumber(7)
  void clearState() => $_clearField(7);
}

class TLSProfileRequest extends $pb.GeneratedMessage {
  factory TLSProfileRequest({
    $core.String? profile,
    $core.bool? rotationEnabled,
    $core.int? rotationInterval,
  }) {
    final result = create();
    if (profile != null) result.profile = profile;
    if (rotationEnabled != null) result.rotationEnabled = rotationEnabled;
    if (rotationInterval != null) result.rotationInterval = rotationInterval;
    return result;
  }

  TLSProfileRequest._();

  factory TLSProfileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TLSProfileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TLSProfileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'profile')
    ..aOB(2, _omitFieldNames ? '' : 'rotationEnabled')
    ..aI(3, _omitFieldNames ? '' : 'rotationInterval')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TLSProfileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TLSProfileRequest copyWith(void Function(TLSProfileRequest) updates) =>
      super.copyWith((message) => updates(message as TLSProfileRequest))
          as TLSProfileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TLSProfileRequest create() => TLSProfileRequest._();
  @$core.override
  TLSProfileRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TLSProfileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TLSProfileRequest>(create);
  static TLSProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get profile => $_getSZ(0);
  @$pb.TagNumber(1)
  set profile($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get rotationEnabled => $_getBF(1);
  @$pb.TagNumber(2)
  set rotationEnabled($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRotationEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearRotationEnabled() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get rotationInterval => $_getIZ(2);
  @$pb.TagNumber(3)
  set rotationInterval($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRotationInterval() => $_has(2);
  @$pb.TagNumber(3)
  void clearRotationInterval() => $_clearField(3);
}

class TLSProfileResponse extends $pb.GeneratedMessage {
  factory TLSProfileResponse({
    $core.bool? success,
    $core.String? activeProfile,
    $core.String? ja3Hash,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (activeProfile != null) result.activeProfile = activeProfile;
    if (ja3Hash != null) result.ja3Hash = ja3Hash;
    return result;
  }

  TLSProfileResponse._();

  factory TLSProfileResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TLSProfileResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TLSProfileResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'activeProfile')
    ..aOS(3, _omitFieldNames ? '' : 'ja3Hash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TLSProfileResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TLSProfileResponse copyWith(void Function(TLSProfileResponse) updates) =>
      super.copyWith((message) => updates(message as TLSProfileResponse))
          as TLSProfileResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TLSProfileResponse create() => TLSProfileResponse._();
  @$core.override
  TLSProfileResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TLSProfileResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TLSProfileResponse>(create);
  static TLSProfileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get activeProfile => $_getSZ(1);
  @$pb.TagNumber(2)
  set activeProfile($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActiveProfile() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveProfile() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ja3Hash => $_getSZ(2);
  @$pb.TagNumber(3)
  set ja3Hash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasJa3Hash() => $_has(2);
  @$pb.TagNumber(3)
  void clearJa3Hash() => $_clearField(3);
}

class LeakTestRequest extends $pb.GeneratedMessage {
  factory LeakTestRequest() => create();

  LeakTestRequest._();

  factory LeakTestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeakTestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeakTestRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeakTestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeakTestRequest copyWith(void Function(LeakTestRequest) updates) =>
      super.copyWith((message) => updates(message as LeakTestRequest))
          as LeakTestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeakTestRequest create() => LeakTestRequest._();
  @$core.override
  LeakTestRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeakTestRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeakTestRequest>(create);
  static LeakTestRequest? _defaultInstance;
}

class LeakTestResponse extends $pb.GeneratedMessage {
  factory LeakTestResponse({
    $core.String? visibleIp,
    $core.String? realIp,
    $core.bool? ipLeaked,
    $core.Iterable<$core.String>? dnsServers,
    $core.bool? dnsLeaked,
  }) {
    final result = create();
    if (visibleIp != null) result.visibleIp = visibleIp;
    if (realIp != null) result.realIp = realIp;
    if (ipLeaked != null) result.ipLeaked = ipLeaked;
    if (dnsServers != null) result.dnsServers.addAll(dnsServers);
    if (dnsLeaked != null) result.dnsLeaked = dnsLeaked;
    return result;
  }

  LeakTestResponse._();

  factory LeakTestResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeakTestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeakTestResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'visibleIp')
    ..aOS(2, _omitFieldNames ? '' : 'realIp')
    ..aOB(3, _omitFieldNames ? '' : 'ipLeaked')
    ..pPS(4, _omitFieldNames ? '' : 'dnsServers')
    ..aOB(5, _omitFieldNames ? '' : 'dnsLeaked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeakTestResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeakTestResponse copyWith(void Function(LeakTestResponse) updates) =>
      super.copyWith((message) => updates(message as LeakTestResponse))
          as LeakTestResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeakTestResponse create() => LeakTestResponse._();
  @$core.override
  LeakTestResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeakTestResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeakTestResponse>(create);
  static LeakTestResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get visibleIp => $_getSZ(0);
  @$pb.TagNumber(1)
  set visibleIp($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVisibleIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearVisibleIp() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get realIp => $_getSZ(1);
  @$pb.TagNumber(2)
  set realIp($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRealIp() => $_has(1);
  @$pb.TagNumber(2)
  void clearRealIp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get ipLeaked => $_getBF(2);
  @$pb.TagNumber(3)
  set ipLeaked($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIpLeaked() => $_has(2);
  @$pb.TagNumber(3)
  void clearIpLeaked() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get dnsServers => $_getList(3);

  @$pb.TagNumber(5)
  $core.bool get dnsLeaked => $_getBF(4);
  @$pb.TagNumber(5)
  set dnsLeaked($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDnsLeaked() => $_has(4);
  @$pb.TagNumber(5)
  void clearDnsLeaked() => $_clearField(5);
}

class ServersRequest extends $pb.GeneratedMessage {
  factory ServersRequest() => create();

  ServersRequest._();

  factory ServersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServersRequest copyWith(void Function(ServersRequest) updates) =>
      super.copyWith((message) => updates(message as ServersRequest))
          as ServersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServersRequest create() => ServersRequest._();
  @$core.override
  ServersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServersRequest>(create);
  static ServersRequest? _defaultInstance;
}

class ServersResponse extends $pb.GeneratedMessage {
  factory ServersResponse({
    $core.Iterable<ServerInfo>? servers,
  }) {
    final result = create();
    if (servers != null) result.servers.addAll(servers);
    return result;
  }

  ServersResponse._();

  factory ServersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..pPM<ServerInfo>(1, _omitFieldNames ? '' : 'servers',
        subBuilder: ServerInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServersResponse copyWith(void Function(ServersResponse) updates) =>
      super.copyWith((message) => updates(message as ServersResponse))
          as ServersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServersResponse create() => ServersResponse._();
  @$core.override
  ServersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServersResponse>(create);
  static ServersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ServerInfo> get servers => $_getList(0);
}

class ServerInfo extends $pb.GeneratedMessage {
  factory ServerInfo({
    $core.String? name,
    $core.String? address,
    $core.int? port,
    $core.String? protocol,
    $core.int? pingMs,
    $core.String? configUri,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (address != null) result.address = address;
    if (port != null) result.port = port;
    if (protocol != null) result.protocol = protocol;
    if (pingMs != null) result.pingMs = pingMs;
    if (configUri != null) result.configUri = configUri;
    return result;
  }

  ServerInfo._();

  factory ServerInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServerInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aI(3, _omitFieldNames ? '' : 'port')
    ..aOS(4, _omitFieldNames ? '' : 'protocol')
    ..aI(5, _omitFieldNames ? '' : 'pingMs')
    ..aOS(6, _omitFieldNames ? '' : 'configUri')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerInfo copyWith(void Function(ServerInfo) updates) =>
      super.copyWith((message) => updates(message as ServerInfo)) as ServerInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerInfo create() => ServerInfo._();
  @$core.override
  ServerInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServerInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerInfo>(create);
  static ServerInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get port => $_getIZ(2);
  @$pb.TagNumber(3)
  set port($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPort() => $_has(2);
  @$pb.TagNumber(3)
  void clearPort() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get protocol => $_getSZ(3);
  @$pb.TagNumber(4)
  set protocol($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProtocol() => $_has(3);
  @$pb.TagNumber(4)
  void clearProtocol() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pingMs => $_getIZ(4);
  @$pb.TagNumber(5)
  set pingMs($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPingMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearPingMs() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get configUri => $_getSZ(5);
  @$pb.TagNumber(6)
  set configUri($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfigUri() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfigUri() => $_clearField(6);
}

class SubscriptionRequest extends $pb.GeneratedMessage {
  factory SubscriptionRequest({
    $core.String? url,
  }) {
    final result = create();
    if (url != null) result.url = url;
    return result;
  }

  SubscriptionRequest._();

  factory SubscriptionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscriptionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscriptionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscriptionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscriptionRequest copyWith(void Function(SubscriptionRequest) updates) =>
      super.copyWith((message) => updates(message as SubscriptionRequest))
          as SubscriptionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscriptionRequest create() => SubscriptionRequest._();
  @$core.override
  SubscriptionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscriptionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscriptionRequest>(create);
  static SubscriptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);
}

class SubscriptionResponse extends $pb.GeneratedMessage {
  factory SubscriptionResponse({
    $core.bool? success,
    $core.int? serversCount,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (serversCount != null) result.serversCount = serversCount;
    if (message != null) result.message = message;
    return result;
  }

  SubscriptionResponse._();

  factory SubscriptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscriptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscriptionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aI(2, _omitFieldNames ? '' : 'serversCount')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscriptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscriptionResponse copyWith(void Function(SubscriptionResponse) updates) =>
      super.copyWith((message) => updates(message as SubscriptionResponse))
          as SubscriptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscriptionResponse create() => SubscriptionResponse._();
  @$core.override
  SubscriptionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscriptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscriptionResponse>(create);
  static SubscriptionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get serversCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set serversCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasServersCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearServersCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);
}

class PingRequest extends $pb.GeneratedMessage {
  factory PingRequest({
    $core.String? address,
    $core.int? port,
  }) {
    final result = create();
    if (address != null) result.address = address;
    if (port != null) result.port = port;
    return result;
  }

  PingRequest._();

  factory PingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aI(2, _omitFieldNames ? '' : 'port')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingRequest copyWith(void Function(PingRequest) updates) =>
      super.copyWith((message) => updates(message as PingRequest))
          as PingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingRequest create() => PingRequest._();
  @$core.override
  PingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PingRequest>(create);
  static PingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get port => $_getIZ(1);
  @$pb.TagNumber(2)
  set port($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearPort() => $_clearField(2);
}

class PingResponse extends $pb.GeneratedMessage {
  factory PingResponse({
    $core.int? pingMs,
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (pingMs != null) result.pingMs = pingMs;
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  PingResponse._();

  factory PingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pingMs')
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingResponse copyWith(void Function(PingResponse) updates) =>
      super.copyWith((message) => updates(message as PingResponse))
          as PingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingResponse create() => PingResponse._();
  @$core.override
  PingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PingResponse>(create);
  static PingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pingMs => $_getIZ(0);
  @$pb.TagNumber(1)
  set pingMs($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPingMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearPingMs() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
}

class StatusRequest extends $pb.GeneratedMessage {
  factory StatusRequest() => create();

  StatusRequest._();

  factory StatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusRequest copyWith(void Function(StatusRequest) updates) =>
      super.copyWith((message) => updates(message as StatusRequest))
          as StatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatusRequest create() => StatusRequest._();
  @$core.override
  StatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatusRequest>(create);
  static StatusRequest? _defaultInstance;
}

class StatusEvent extends $pb.GeneratedMessage {
  factory StatusEvent({
    $core.String? state,
    $core.String? message,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (state != null) result.state = state;
    if (message != null) result.message = message;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  StatusEvent._();

  factory StatusEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatusEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatusEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'vpnservice'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'state')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusEvent copyWith(void Function(StatusEvent) updates) =>
      super.copyWith((message) => updates(message as StatusEvent))
          as StatusEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatusEvent create() => StatusEvent._();
  @$core.override
  StatusEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StatusEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatusEvent>(create);
  static StatusEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get state => $_getSZ(0);
  @$pb.TagNumber(1)
  set state($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasState() => $_has(0);
  @$pb.TagNumber(1)
  void clearState() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
