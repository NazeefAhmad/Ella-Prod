import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import 'no_internet_indicator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isChecking = false;

  Future<void> _checkConnection() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      final isConnected = result != ConnectivityResult.none;
      
      if (mounted) {
        final service = Provider.of<ConnectivityService>(context, listen: false);
        service.updateConnectionStatus(isConnected);
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: context.read<ConnectivityService>().connectionStatus,
      builder: (context, snapshot) {
        // Show loading indicator only on first load
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Default to showing content if we don't have connection data
        final isConnected = snapshot.data ?? true;
        
        if (!isConnected) {
          return NoInternetIndicator(
            onRetry: _checkConnection,
            isChecking: _isChecking,
          );
        }

        return widget.child;
      },
    );
  }
} 