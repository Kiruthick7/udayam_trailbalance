import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Check current connectivity status
  Future<bool> hasInternetConnection() async {
    try {
      // First check if connected to network
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        return false;
      }

      // Then verify actual internet connectivity by pinging a reliable host
      final response = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      );

      return response.isNotEmpty && response[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Stream of connectivity changes
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }
}

// Provider for connectivity service
final connectivityServiceProvider = Provider((ref) => ConnectivityService());

// Provider for current connectivity state
final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});
