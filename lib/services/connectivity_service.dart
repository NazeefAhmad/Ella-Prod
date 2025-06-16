import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isDisposed = false;

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  ConnectivityService() {
    _initConnectivity();
  }

  void updateConnectionStatus(bool isConnected) {
    if (_isDisposed) return;
    _connectionStatusController.add(isConnected);
  }

  Future<void> _initConnectivity() async {
    if (_isDisposed) return;
    
    try {
      // Initial check
      ConnectivityResult result = await _connectivity.checkConnectivity();
      if (!_isDisposed) {
        _updateConnectionStatus(result);
      }

      // Listen for changes
      _connectivitySubscription?.cancel();
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (ConnectivityResult result) {
          if (!_isDisposed) {
            _updateConnectionStatus(result);
          }
        },
        onError: (error) {
          debugPrint('Connectivity error: $error');
          if (!_isDisposed) {
            _connectionStatusController.add(false);
          }
        },
      );
    } catch (e) {
      debugPrint('Error initializing connectivity: $e');
      if (!_isDisposed) {
        _connectionStatusController.add(false);
      }
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (_isDisposed) return;
    bool isConnected = result != ConnectivityResult.none;
    _connectionStatusController.add(isConnected);
  }

  void dispose() {
    _isDisposed = true;
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
} 