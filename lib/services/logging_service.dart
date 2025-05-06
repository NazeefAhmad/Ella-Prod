import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  static const String _logFileName = 'chat_logs.txt';
  late File _logFile;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$_logFileName');
      
      // Create the file if it doesn't exist
      if (!await _logFile.exists()) {
        await _logFile.create();
      }
      
      _isInitialized = true;
      await log('LoggingService initialized');
    } catch (e) {
      print('Error initializing LoggingService: $e');
    }
  }

  Future<void> log(String message, {String? userId, String? messageType}) async {
    if (!_isInitialized) await initialize();

    try {
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final logEntry = '[$timestamp] ${userId != null ? 'User: $userId | ' : ''}${messageType != null ? 'Type: $messageType | ' : ''}$message\n';
      
      await _logFile.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      print('Error writing to log file: $e');
    }
  }

  Future<String> getLogs() async {
    if (!_isInitialized) await initialize();

    try {
      return await _logFile.readAsString();
    } catch (e) {
      print('Error reading log file: $e');
      return 'Error reading logs: $e';
    }
  }

  Future<void> clearLogs() async {
    if (!_isInitialized) await initialize();

    try {
      await _logFile.writeAsString('');
      await log('Logs cleared');
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }
} 