import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

class BluetoothDevice {
  final String name;
  final String address;
  final bool paired;
  final bool nearby;
  final String rssiDistance;
  final String rssiValue;

  const BluetoothDevice(
      this.name, this.address, this.rssiDistance, this.rssiValue,
      {this.nearby = false, this.paired = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothDevice &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          address == other.address &&
          rssiDistance == other.rssiDistance &&
          rssiValue == other.rssiValue;

  @override
  int get hashCode => name.hashCode ^ address.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'rssiDistance': rssiDistance,
      'rssiValue': rssiValue
    };
  }

  @override
  String toString() {
    return 'BluetoothDevice{name: $name, address: $address, paired: $paired, nearby: $nearby, rssiDistance:$rssiDistance, rssiValue:$rssiValue}';
  }
}

class Flutterbleplugin {
  static final _singleton = Flutterbleplugin._();
  final MethodChannel _channel = const MethodChannel('flutterbleplugin');
  final List<BluetoothDevice> _pairedDevices = [];
  final StreamController<BluetoothDevice> _controller =
      StreamController.broadcast();
  final StreamController<bool> _scanStopped = StreamController.broadcast();

  factory Flutterbleplugin() => _singleton;

  Flutterbleplugin._() {
    _channel.setMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'action_new_device':
          _newDevice(methodCall.arguments);
          break;
        case 'action_scan_stopped':
          _scanStopped.add(true);
          break;
      }
      return null;
    });
  }

  Stream<BluetoothDevice> get devices => _controller.stream;

  Stream<bool> get scanStopped => _scanStopped.stream;

  Future<void> requestPermissions() async {
    await _channel.invokeMethod('action_request_permissions');
  }

  Future<void> startScan({pairedDevices = false}) async {
    final bondedDevices =
        await _channel.invokeMethod('action_start_scan', pairedDevices);
    for (var device in bondedDevices) {
      final d = BluetoothDevice(device['name'], device['address'],
          device['rssiDistance'], device['rssiValue'],
          paired: true);
      _pairedDevices.add(d);
      _controller.add(d);
    }
  }

  Future<void> close() async {
    await _scanStopped.close();
    await _controller.close();
  }

  Future<void> stopScan() => _channel.invokeMethod('action_stop_scan');

  void _newDevice(device) {
    _controller.add(BluetoothDevice(
      device['name'],
      device['address'],
      device['rssiDistance'],
      device['rssiValue'],
      nearby: true,
      paired: _pairedDevices
              .firstWhereOrNull((item) => item.address == device['address']) !=
          null,
    ));
  }
}
