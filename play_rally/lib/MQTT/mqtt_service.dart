import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // <-- for kDebugMode
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttService {
  static const String broker = 'ticker.homegroundapp.com';
  static const int port = 1883;
  static const String username = 'homeground';
  static const String password = 'supersecret';

  late MqttServerClient client;
  bool _isConnected = false;
  bool _enabled = true;
  Timer? _reconnectTimer;

  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal() {
    _loadEnabledState();
  }

  // ---- Load saved macro state ----
  Future<void> _loadEnabledState() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('mqtt_enabled') ?? true;
    if (kDebugMode) {
      print("MQTT Macro loaded: ${_enabled ? 'ENABLED' : 'DISABLED'}");
    }
  }

  // ---- Save macro state ----
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mqtt_enabled', value);
    if (kDebugMode) {
      print("MQTT Macro: ${_enabled ? 'ENABLED' : 'DISABLED'}");
    }
  }

  bool get isEnabled => _enabled;

  // ---- Connect to broker ----
  Future<void> connect() async {
    try {
      if (kDebugMode) print('Connecting to MQTT broker...');

      client = MqttServerClient.withPort(broker, 'flutter_client', port);
      client.logging(on: kDebugMode);
      client.keepAlivePeriod = 60;
      client.onConnected = () {
        _isConnected = true;
        if (kDebugMode) print('Connected to MQTT broker!');
      };
      client.onDisconnected = () {
        _isConnected = false;
        if (kDebugMode) print('Disconnected from MQTT broker.');
      };
      client.onSubscribed = (topic) {
        if (kDebugMode) print('Subscribed to topic: $topic');
      };

      client.connectionMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
          .authenticateAs(username, password)
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

      await client.connect();

      if (kDebugMode) {
        print('Connection status: ${client.connectionStatus?.state}');
        print('Return code: ${client.connectionStatus?.returnCode}');
      }
    } catch (e) {
      _isConnected = false;
      if (kDebugMode) print('MQTT connection error: $e');
    }
  }

  // ---- Publish a message ----
  void publish(String topic, Map<String, dynamic> payload) {
    if (!_enabled) {
      if (kDebugMode) print('MQTT Macro OFF — not publishing.');
      return;
    }
    if (!_isConnected) {
      if (kDebugMode) print('MQTT not connected — cannot publish.');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(payload));
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

    if (kDebugMode) print('Published to $topic: ${jsonEncode(payload)}');
  }

  // ---- Disconnect manually ----
  void disconnect() {
    _isConnected = false;
    _reconnectTimer?.cancel();
    client.disconnect();
    if (kDebugMode) print('MQTT connection closed.');
  }

  // ---- Handle disconnects ----
  void _onDisconnected() {
    _isConnected = false;
    if (kDebugMode) print('Disconnected from MQTT broker.');
    _scheduleReconnect();
  }

  // ---- Auto reconnect ----
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isConnected && _enabled) {
        if (kDebugMode) print('Attempting MQTT reconnect...');
        await connect();
      } else {
        timer.cancel();
      }
    });
  }

  bool get isConnected => _isConnected;
}
