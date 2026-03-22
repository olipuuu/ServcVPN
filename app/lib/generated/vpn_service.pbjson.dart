// This is a generated file - do not edit.
//
// Generated from vpn_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use connectRequestDescriptor instead')
const ConnectRequest$json = {
  '1': 'ConnectRequest',
  '2': [
    {'1': 'config_uri', '3': 1, '4': 1, '5': 9, '10': 'configUri'},
    {'1': 'tls_fingerprint', '3': 2, '4': 1, '5': 9, '10': 'tlsFingerprint'},
    {'1': 'kill_switch', '3': 3, '4': 1, '5': 8, '10': 'killSwitch'},
  ],
};

/// Descriptor for `ConnectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectRequestDescriptor = $convert.base64Decode(
    'Cg5Db25uZWN0UmVxdWVzdBIdCgpjb25maWdfdXJpGAEgASgJUgljb25maWdVcmkSJwoPdGxzX2'
    'ZpbmdlcnByaW50GAIgASgJUg50bHNGaW5nZXJwcmludBIfCgtraWxsX3N3aXRjaBgDIAEoCFIK'
    'a2lsbFN3aXRjaA==');

@$core.Deprecated('Use connectResponseDescriptor instead')
const ConnectResponse$json = {
  '1': 'ConnectResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'server_ip', '3': 3, '4': 1, '5': 9, '10': 'serverIp'},
  ],
};

/// Descriptor for `ConnectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectResponseDescriptor = $convert.base64Decode(
    'Cg9Db25uZWN0UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGA'
    'IgASgJUgdtZXNzYWdlEhsKCXNlcnZlcl9pcBgDIAEoCVIIc2VydmVySXA=');

@$core.Deprecated('Use disconnectRequestDescriptor instead')
const DisconnectRequest$json = {
  '1': 'DisconnectRequest',
};

/// Descriptor for `DisconnectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disconnectRequestDescriptor =
    $convert.base64Decode('ChFEaXNjb25uZWN0UmVxdWVzdA==');

@$core.Deprecated('Use disconnectResponseDescriptor instead')
const DisconnectResponse$json = {
  '1': 'DisconnectResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DisconnectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disconnectResponseDescriptor = $convert.base64Decode(
    'ChJEaXNjb25uZWN0UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYW'
    'dlGAIgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use statsRequestDescriptor instead')
const StatsRequest$json = {
  '1': 'StatsRequest',
};

/// Descriptor for `StatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statsRequestDescriptor =
    $convert.base64Decode('CgxTdGF0c1JlcXVlc3Q=');

@$core.Deprecated('Use statsResponseDescriptor instead')
const StatsResponse$json = {
  '1': 'StatsResponse',
  '2': [
    {'1': 'upload_bytes', '3': 1, '4': 1, '5': 3, '10': 'uploadBytes'},
    {'1': 'download_bytes', '3': 2, '4': 1, '5': 3, '10': 'downloadBytes'},
    {'1': 'upload_speed', '3': 3, '4': 1, '5': 3, '10': 'uploadSpeed'},
    {'1': 'download_speed', '3': 4, '4': 1, '5': 3, '10': 'downloadSpeed'},
    {'1': 'ping_ms', '3': 5, '4': 1, '5': 5, '10': 'pingMs'},
    {'1': 'connected_since', '3': 6, '4': 1, '5': 3, '10': 'connectedSince'},
    {'1': 'state', '3': 7, '4': 1, '5': 9, '10': 'state'},
  ],
};

/// Descriptor for `StatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statsResponseDescriptor = $convert.base64Decode(
    'Cg1TdGF0c1Jlc3BvbnNlEiEKDHVwbG9hZF9ieXRlcxgBIAEoA1ILdXBsb2FkQnl0ZXMSJQoOZG'
    '93bmxvYWRfYnl0ZXMYAiABKANSDWRvd25sb2FkQnl0ZXMSIQoMdXBsb2FkX3NwZWVkGAMgASgD'
    'Ugt1cGxvYWRTcGVlZBIlCg5kb3dubG9hZF9zcGVlZBgEIAEoA1INZG93bmxvYWRTcGVlZBIXCg'
    'dwaW5nX21zGAUgASgFUgZwaW5nTXMSJwoPY29ubmVjdGVkX3NpbmNlGAYgASgDUg5jb25uZWN0'
    'ZWRTaW5jZRIUCgVzdGF0ZRgHIAEoCVIFc3RhdGU=');

@$core.Deprecated('Use tLSProfileRequestDescriptor instead')
const TLSProfileRequest$json = {
  '1': 'TLSProfileRequest',
  '2': [
    {'1': 'profile', '3': 1, '4': 1, '5': 9, '10': 'profile'},
    {'1': 'rotation_enabled', '3': 2, '4': 1, '5': 8, '10': 'rotationEnabled'},
    {
      '1': 'rotation_interval',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'rotationInterval'
    },
  ],
};

/// Descriptor for `TLSProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tLSProfileRequestDescriptor = $convert.base64Decode(
    'ChFUTFNQcm9maWxlUmVxdWVzdBIYCgdwcm9maWxlGAEgASgJUgdwcm9maWxlEikKEHJvdGF0aW'
    '9uX2VuYWJsZWQYAiABKAhSD3JvdGF0aW9uRW5hYmxlZBIrChFyb3RhdGlvbl9pbnRlcnZhbBgD'
    'IAEoBVIQcm90YXRpb25JbnRlcnZhbA==');

@$core.Deprecated('Use tLSProfileResponseDescriptor instead')
const TLSProfileResponse$json = {
  '1': 'TLSProfileResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'active_profile', '3': 2, '4': 1, '5': 9, '10': 'activeProfile'},
    {'1': 'ja3_hash', '3': 3, '4': 1, '5': 9, '10': 'ja3Hash'},
  ],
};

/// Descriptor for `TLSProfileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tLSProfileResponseDescriptor = $convert.base64Decode(
    'ChJUTFNQcm9maWxlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIlCg5hY3Rpdm'
    'VfcHJvZmlsZRgCIAEoCVINYWN0aXZlUHJvZmlsZRIZCghqYTNfaGFzaBgDIAEoCVIHamEzSGFz'
    'aA==');

@$core.Deprecated('Use leakTestRequestDescriptor instead')
const LeakTestRequest$json = {
  '1': 'LeakTestRequest',
};

/// Descriptor for `LeakTestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leakTestRequestDescriptor =
    $convert.base64Decode('Cg9MZWFrVGVzdFJlcXVlc3Q=');

@$core.Deprecated('Use leakTestResponseDescriptor instead')
const LeakTestResponse$json = {
  '1': 'LeakTestResponse',
  '2': [
    {'1': 'visible_ip', '3': 1, '4': 1, '5': 9, '10': 'visibleIp'},
    {'1': 'real_ip', '3': 2, '4': 1, '5': 9, '10': 'realIp'},
    {'1': 'ip_leaked', '3': 3, '4': 1, '5': 8, '10': 'ipLeaked'},
    {'1': 'dns_servers', '3': 4, '4': 3, '5': 9, '10': 'dnsServers'},
    {'1': 'dns_leaked', '3': 5, '4': 1, '5': 8, '10': 'dnsLeaked'},
  ],
};

/// Descriptor for `LeakTestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leakTestResponseDescriptor = $convert.base64Decode(
    'ChBMZWFrVGVzdFJlc3BvbnNlEh0KCnZpc2libGVfaXAYASABKAlSCXZpc2libGVJcBIXCgdyZW'
    'FsX2lwGAIgASgJUgZyZWFsSXASGwoJaXBfbGVha2VkGAMgASgIUghpcExlYWtlZBIfCgtkbnNf'
    'c2VydmVycxgEIAMoCVIKZG5zU2VydmVycxIdCgpkbnNfbGVha2VkGAUgASgIUglkbnNMZWFrZW'
    'Q=');

@$core.Deprecated('Use serversRequestDescriptor instead')
const ServersRequest$json = {
  '1': 'ServersRequest',
};

/// Descriptor for `ServersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serversRequestDescriptor =
    $convert.base64Decode('Cg5TZXJ2ZXJzUmVxdWVzdA==');

@$core.Deprecated('Use serversResponseDescriptor instead')
const ServersResponse$json = {
  '1': 'ServersResponse',
  '2': [
    {
      '1': 'servers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.vpnservice.ServerInfo',
      '10': 'servers'
    },
  ],
};

/// Descriptor for `ServersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serversResponseDescriptor = $convert.base64Decode(
    'Cg9TZXJ2ZXJzUmVzcG9uc2USMAoHc2VydmVycxgBIAMoCzIWLnZwbnNlcnZpY2UuU2VydmVySW'
    '5mb1IHc2VydmVycw==');

@$core.Deprecated('Use serverInfoDescriptor instead')
const ServerInfo$json = {
  '1': 'ServerInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'port', '3': 3, '4': 1, '5': 5, '10': 'port'},
    {'1': 'protocol', '3': 4, '4': 1, '5': 9, '10': 'protocol'},
    {'1': 'ping_ms', '3': 5, '4': 1, '5': 5, '10': 'pingMs'},
    {'1': 'config_uri', '3': 6, '4': 1, '5': 9, '10': 'configUri'},
  ],
};

/// Descriptor for `ServerInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverInfoDescriptor = $convert.base64Decode(
    'CgpTZXJ2ZXJJbmZvEhIKBG5hbWUYASABKAlSBG5hbWUSGAoHYWRkcmVzcxgCIAEoCVIHYWRkcm'
    'VzcxISCgRwb3J0GAMgASgFUgRwb3J0EhoKCHByb3RvY29sGAQgASgJUghwcm90b2NvbBIXCgdw'
    'aW5nX21zGAUgASgFUgZwaW5nTXMSHQoKY29uZmlnX3VyaRgGIAEoCVIJY29uZmlnVXJp');

@$core.Deprecated('Use subscriptionRequestDescriptor instead')
const SubscriptionRequest$json = {
  '1': 'SubscriptionRequest',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `SubscriptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscriptionRequestDescriptor = $convert
    .base64Decode('ChNTdWJzY3JpcHRpb25SZXF1ZXN0EhAKA3VybBgBIAEoCVIDdXJs');

@$core.Deprecated('Use subscriptionResponseDescriptor instead')
const SubscriptionResponse$json = {
  '1': 'SubscriptionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'servers_count', '3': 2, '4': 1, '5': 5, '10': 'serversCount'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SubscriptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscriptionResponseDescriptor = $convert.base64Decode(
    'ChRTdWJzY3JpcHRpb25SZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiMKDXNlcn'
    'ZlcnNfY291bnQYAiABKAVSDHNlcnZlcnNDb3VudBIYCgdtZXNzYWdlGAMgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use pingRequestDescriptor instead')
const PingRequest$json = {
  '1': 'PingRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'port', '3': 2, '4': 1, '5': 5, '10': 'port'},
  ],
};

/// Descriptor for `PingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingRequestDescriptor = $convert.base64Decode(
    'CgtQaW5nUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhIKBHBvcnQYAiABKAVSBH'
    'BvcnQ=');

@$core.Deprecated('Use pingResponseDescriptor instead')
const PingResponse$json = {
  '1': 'PingResponse',
  '2': [
    {'1': 'ping_ms', '3': 1, '4': 1, '5': 5, '10': 'pingMs'},
    {'1': 'success', '3': 2, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `PingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingResponseDescriptor = $convert.base64Decode(
    'CgxQaW5nUmVzcG9uc2USFwoHcGluZ19tcxgBIAEoBVIGcGluZ01zEhgKB3N1Y2Nlc3MYAiABKA'
    'hSB3N1Y2Nlc3MSFAoFZXJyb3IYAyABKAlSBWVycm9y');

@$core.Deprecated('Use statusRequestDescriptor instead')
const StatusRequest$json = {
  '1': 'StatusRequest',
};

/// Descriptor for `StatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusRequestDescriptor =
    $convert.base64Decode('Cg1TdGF0dXNSZXF1ZXN0');

@$core.Deprecated('Use statusEventDescriptor instead')
const StatusEvent$json = {
  '1': 'StatusEvent',
  '2': [
    {'1': 'state', '3': 1, '4': 1, '5': 9, '10': 'state'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `StatusEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusEventDescriptor = $convert.base64Decode(
    'CgtTdGF0dXNFdmVudBIUCgVzdGF0ZRgBIAEoCVIFc3RhdGUSGAoHbWVzc2FnZRgCIAEoCVIHbW'
    'Vzc2FnZRIcCgl0aW1lc3RhbXAYAyABKANSCXRpbWVzdGFtcA==');
