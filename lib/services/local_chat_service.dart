import 'package:hive/hive.dart';
import '../models/hive_chat_message.dart';

class LocalChatService {
  final Box<HiveChatMessage> _box = Hive.box<HiveChatMessage>('chat_history');
  
  // Storage limits
  static const int maxMessages = 2000; // Keep last 2000 messages
  static const int maxStorageMB = 150; // Max 150MB for chat storage
  
  // Pagination settings for fast loading
  static const int pageSize = 50; // Load 50 messages at a time
  static const int preloadThreshold = 10; // Preload when 10 messages left
  
  // Cache for recent messages
  List<HiveChatMessage>? _recentMessagesCache;
  DateTime? _lastCacheTime;
  static const Duration cacheValidity = Duration(minutes: 5);

  Future<void> saveMessage(HiveChatMessage msg) async {
    await _box.add(msg);
    
    // Invalidate cache when new message is added
    _invalidateCache();
    
    // Cleanup if we exceed limits
    await _cleanupIfNeeded();
  }

  // Fast loading with pagination - like WhatsApp/Telegram
  List<HiveChatMessage> getMessages({int limit = pageSize, int offset = 0}) {
    final allMessages = _box.values.toList();
    
    // Return paginated results
    if (offset >= allMessages.length) return [];
    
    final endIndex = (offset + limit > allMessages.length) 
        ? allMessages.length 
        : offset + limit;
    
    return allMessages.sublist(offset, endIndex);
  }

  // Get recent messages with caching for instant loading
  List<HiveChatMessage> getRecentMessages({int count = 20}) {
    // Check if cache is valid
    if (_recentMessagesCache != null && 
        _lastCacheTime != null && 
        DateTime.now().difference(_lastCacheTime!) < cacheValidity) {
      return _recentMessagesCache!.take(count).toList();
    }
    
    // Load from Hive and cache
    final allMessages = _box.values.toList();
    _recentMessagesCache = allMessages.take(count).toList();
    _lastCacheTime = DateTime.now();
    
    return _recentMessagesCache!;
  }

  // Get total message count efficiently
  int getMessageCount() {
    return _box.length;
  }

  // Check if more messages are available for pagination
  bool hasMoreMessages(int currentOffset) {
    return currentOffset < _box.length;
  }

  // Get messages by date range for fast filtering
  List<HiveChatMessage> getMessagesByDateRange(DateTime startDate, DateTime endDate) {
    return _box.values.where((msg) => 
        msg.timestamp.isAfter(startDate) && 
        msg.timestamp.isBefore(endDate)
    ).toList();
  }

  // Search messages efficiently
  List<HiveChatMessage> searchMessages(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _box.values.where((msg) => 
        msg.message.toLowerCase().contains(lowercaseQuery) ||
        msg.sender.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Future<void> clearMessages() async {
    await _box.clear();
    _invalidateCache();
  }

  bool hasMessages() {
    return _box.isNotEmpty;
  }

  // Invalidate cache when data changes
  void _invalidateCache() {
    _recentMessagesCache = null;
    _lastCacheTime = null;
  }

  // Get storage info
  Map<String, dynamic> getStorageInfo() {
    final messages = _box.values.toList();
    final totalMessages = messages.length;
    final totalSize = _box.length * 200; // Rough estimate: 200 bytes per message
    final sizeMB = totalSize / (1024 * 1024);
    
    return {
      'totalMessages': totalMessages,
      'sizeMB': sizeMB.toStringAsFixed(2),
      'maxMessages': maxMessages,
      'maxStorageMB': maxStorageMB,
      'pageSize': pageSize,
    };
  }

  // Cleanup old messages if limits exceeded
  Future<void> _cleanupIfNeeded() async {
    final messages = _box.values.toList();
    
    if (messages.length > maxMessages) {
      // Keep only the most recent messages
      final messagesToKeep = messages.skip(messages.length - maxMessages).toList();
      await _box.clear();
      
      for (var msg in messagesToKeep) {
        await _box.add(msg);
      }
      
      _invalidateCache();
      print('🧹 Cleaned up chat storage: kept ${messagesToKeep.length} recent messages');
    }
  }

  // Manual cleanup - keep only last N messages
  Future<void> keepLastMessages(int count) async {
    final messages = _box.values.toList();
    if (messages.length > count) {
      final messagesToKeep = messages.skip(messages.length - count).toList();
      await _box.clear();
      
      for (var msg in messagesToKeep) {
        await _box.add(msg);
      }
      
      _invalidateCache();
      print('🧹 Kept last $count messages, removed ${messages.length - count} old messages');
    }
  }

  // Get messages from specific date
  List<HiveChatMessage> getMessagesFromDate(DateTime date) {
    return _box.values.where((msg) => msg.timestamp.isAfter(date)).toList();
  }

  // Delete messages older than specific date
  Future<void> deleteMessagesOlderThan(DateTime date) async {
    final messages = _box.values.toList();
    final messagesToKeep = messages.where((msg) => msg.timestamp.isAfter(date)).toList();
    
    await _box.clear();
    for (var msg in messagesToKeep) {
      await _box.add(msg);
    }
    
    _invalidateCache();
    print('🗑️ Deleted ${messages.length - messagesToKeep.length} messages older than ${date.toString()}');
  }

  // Preload next batch of messages for smooth scrolling
  Future<List<HiveChatMessage>> preloadMessages(int currentOffset) async {
    return getMessages(limit: pageSize, offset: currentOffset);
  }
} 