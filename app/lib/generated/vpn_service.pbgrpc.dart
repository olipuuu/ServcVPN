// This is a generated file - do not edit.
//
// Generated from vpn_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'vpn_service.pb.dart' as $0;

export 'vpn_service.pb.dart';

@$pb.GrpcServiceName('vpnservice.VPNService')
class VPNServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  VPNServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ConnectResponse> connect(
    $0.ConnectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$connect, request, options: options);
  }

  $grpc.ResponseFuture<$0.DisconnectResponse> disconnect(
    $0.DisconnectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$disconnect, request, options: options);
  }

  $grpc.ResponseFuture<$0.StatsResponse> getStats(
    $0.StatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStats, request, options: options);
  }

  $grpc.ResponseFuture<$0.TLSProfileResponse> setTLSProfile(
    $0.TLSProfileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setTLSProfile, request, options: options);
  }

  $grpc.ResponseFuture<$0.LeakTestResponse> runLeakTest(
    $0.LeakTestRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$runLeakTest, request, options: options);
  }

  $grpc.ResponseFuture<$0.ServersResponse> getServers(
    $0.ServersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getServers, request, options: options);
  }

  $grpc.ResponseFuture<$0.SubscriptionResponse> refreshSubscription(
    $0.SubscriptionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$refreshSubscription, request, options: options);
  }

  $grpc.ResponseStream<$0.StatusEvent> onStatusChange(
    $0.StatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$onStatusChange, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.StatsResponse> streamStats(
    $0.StatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamStats, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.PingResponse> pingServer(
    $0.PingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pingServer, request, options: options);
  }

  // method descriptors

  static final _$connect =
      $grpc.ClientMethod<$0.ConnectRequest, $0.ConnectResponse>(
          '/vpnservice.VPNService/Connect',
          ($0.ConnectRequest value) => value.writeToBuffer(),
          $0.ConnectResponse.fromBuffer);
  static final _$disconnect =
      $grpc.ClientMethod<$0.DisconnectRequest, $0.DisconnectResponse>(
          '/vpnservice.VPNService/Disconnect',
          ($0.DisconnectRequest value) => value.writeToBuffer(),
          $0.DisconnectResponse.fromBuffer);
  static final _$getStats =
      $grpc.ClientMethod<$0.StatsRequest, $0.StatsResponse>(
          '/vpnservice.VPNService/GetStats',
          ($0.StatsRequest value) => value.writeToBuffer(),
          $0.StatsResponse.fromBuffer);
  static final _$setTLSProfile =
      $grpc.ClientMethod<$0.TLSProfileRequest, $0.TLSProfileResponse>(
          '/vpnservice.VPNService/SetTLSProfile',
          ($0.TLSProfileRequest value) => value.writeToBuffer(),
          $0.TLSProfileResponse.fromBuffer);
  static final _$runLeakTest =
      $grpc.ClientMethod<$0.LeakTestRequest, $0.LeakTestResponse>(
          '/vpnservice.VPNService/RunLeakTest',
          ($0.LeakTestRequest value) => value.writeToBuffer(),
          $0.LeakTestResponse.fromBuffer);
  static final _$getServers =
      $grpc.ClientMethod<$0.ServersRequest, $0.ServersResponse>(
          '/vpnservice.VPNService/GetServers',
          ($0.ServersRequest value) => value.writeToBuffer(),
          $0.ServersResponse.fromBuffer);
  static final _$refreshSubscription =
      $grpc.ClientMethod<$0.SubscriptionRequest, $0.SubscriptionResponse>(
          '/vpnservice.VPNService/RefreshSubscription',
          ($0.SubscriptionRequest value) => value.writeToBuffer(),
          $0.SubscriptionResponse.fromBuffer);
  static final _$onStatusChange =
      $grpc.ClientMethod<$0.StatusRequest, $0.StatusEvent>(
          '/vpnservice.VPNService/OnStatusChange',
          ($0.StatusRequest value) => value.writeToBuffer(),
          $0.StatusEvent.fromBuffer);
  static final _$streamStats =
      $grpc.ClientMethod<$0.StatsRequest, $0.StatsResponse>(
          '/vpnservice.VPNService/StreamStats',
          ($0.StatsRequest value) => value.writeToBuffer(),
          $0.StatsResponse.fromBuffer);
  static final _$pingServer =
      $grpc.ClientMethod<$0.PingRequest, $0.PingResponse>(
          '/vpnservice.VPNService/PingServer',
          ($0.PingRequest value) => value.writeToBuffer(),
          $0.PingResponse.fromBuffer);
}

@$pb.GrpcServiceName('vpnservice.VPNService')
abstract class VPNServiceBase extends $grpc.Service {
  $core.String get $name => 'vpnservice.VPNService';

  VPNServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ConnectRequest, $0.ConnectResponse>(
        'Connect',
        connect_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConnectRequest.fromBuffer(value),
        ($0.ConnectResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DisconnectRequest, $0.DisconnectResponse>(
        'Disconnect',
        disconnect_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DisconnectRequest.fromBuffer(value),
        ($0.DisconnectResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StatsRequest, $0.StatsResponse>(
        'GetStats',
        getStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StatsRequest.fromBuffer(value),
        ($0.StatsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TLSProfileRequest, $0.TLSProfileResponse>(
        'SetTLSProfile',
        setTLSProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TLSProfileRequest.fromBuffer(value),
        ($0.TLSProfileResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LeakTestRequest, $0.LeakTestResponse>(
        'RunLeakTest',
        runLeakTest_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LeakTestRequest.fromBuffer(value),
        ($0.LeakTestResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ServersRequest, $0.ServersResponse>(
        'GetServers',
        getServers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ServersRequest.fromBuffer(value),
        ($0.ServersResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SubscriptionRequest, $0.SubscriptionResponse>(
            'RefreshSubscription',
            refreshSubscription_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SubscriptionRequest.fromBuffer(value),
            ($0.SubscriptionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StatusRequest, $0.StatusEvent>(
        'OnStatusChange',
        onStatusChange_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.StatusRequest.fromBuffer(value),
        ($0.StatusEvent value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StatsRequest, $0.StatsResponse>(
        'StreamStats',
        streamStats_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.StatsRequest.fromBuffer(value),
        ($0.StatsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PingRequest, $0.PingResponse>(
        'PingServer',
        pingServer_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PingRequest.fromBuffer(value),
        ($0.PingResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ConnectResponse> connect_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ConnectRequest> $request) async {
    return connect($call, await $request);
  }

  $async.Future<$0.ConnectResponse> connect(
      $grpc.ServiceCall call, $0.ConnectRequest request);

  $async.Future<$0.DisconnectResponse> disconnect_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DisconnectRequest> $request) async {
    return disconnect($call, await $request);
  }

  $async.Future<$0.DisconnectResponse> disconnect(
      $grpc.ServiceCall call, $0.DisconnectRequest request);

  $async.Future<$0.StatsResponse> getStats_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.StatsRequest> $request) async {
    return getStats($call, await $request);
  }

  $async.Future<$0.StatsResponse> getStats(
      $grpc.ServiceCall call, $0.StatsRequest request);

  $async.Future<$0.TLSProfileResponse> setTLSProfile_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.TLSProfileRequest> $request) async {
    return setTLSProfile($call, await $request);
  }

  $async.Future<$0.TLSProfileResponse> setTLSProfile(
      $grpc.ServiceCall call, $0.TLSProfileRequest request);

  $async.Future<$0.LeakTestResponse> runLeakTest_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LeakTestRequest> $request) async {
    return runLeakTest($call, await $request);
  }

  $async.Future<$0.LeakTestResponse> runLeakTest(
      $grpc.ServiceCall call, $0.LeakTestRequest request);

  $async.Future<$0.ServersResponse> getServers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ServersRequest> $request) async {
    return getServers($call, await $request);
  }

  $async.Future<$0.ServersResponse> getServers(
      $grpc.ServiceCall call, $0.ServersRequest request);

  $async.Future<$0.SubscriptionResponse> refreshSubscription_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SubscriptionRequest> $request) async {
    return refreshSubscription($call, await $request);
  }

  $async.Future<$0.SubscriptionResponse> refreshSubscription(
      $grpc.ServiceCall call, $0.SubscriptionRequest request);

  $async.Stream<$0.StatusEvent> onStatusChange_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StatusRequest> $request) async* {
    yield* onStatusChange($call, await $request);
  }

  $async.Stream<$0.StatusEvent> onStatusChange(
      $grpc.ServiceCall call, $0.StatusRequest request);

  $async.Stream<$0.StatsResponse> streamStats_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.StatsRequest> $request) async* {
    yield* streamStats($call, await $request);
  }

  $async.Stream<$0.StatsResponse> streamStats(
      $grpc.ServiceCall call, $0.StatsRequest request);

  $async.Future<$0.PingResponse> pingServer_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.PingRequest> $request) async {
    return pingServer($call, await $request);
  }

  $async.Future<$0.PingResponse> pingServer(
      $grpc.ServiceCall call, $0.PingRequest request);
}
