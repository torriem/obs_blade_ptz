import 'dart:async';
import '../models/connection.dart';

/// Web stub - autodiscovery not available on web platforms
class AutoDiscoveryHelper {
  static Future<List<Connection>> getAvailableOBSIPs(int port) async {
    throw UnsupportedError(
        'Autodiscovery is not available on web platforms. Please use manual connection entry.');
  }

  static Future<List<Connection>> checkConnectionAvailabilities(
      List<Connection> connections) async {
    throw UnsupportedError(
        'Connection availability checking is not available on web platforms.');
  }
}
