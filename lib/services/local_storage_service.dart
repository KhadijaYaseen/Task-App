import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/attendance_record.dart';
import 'supabase_service.dart';

/// Provides resilient, pure-Dart offline local disk persistence
/// without requiring third-party native plugins or symlinks.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  Directory? _storageDir;

  Directory get _directory {
    if (_storageDir != null) return _storageDir!;

    try {
      if (Platform.isAndroid) {
        // App-private internal storage on Android (/data/user/0/<package>/files)
        final temp = Directory.systemTemp;
        final candidate = Directory('${temp.parent.path}/files');
        if (!candidate.existsSync()) {
          candidate.createSync(recursive: true);
        }
        _storageDir = candidate;
        return _storageDir!;
      }
    } catch (_) {}

    // Fallback for desktop/tests: use system temp directory under task_app_data
    final fallback = Directory('${Directory.systemTemp.path}/task_app_data');
    if (!fallback.existsSync()) {
      fallback.createSync(recursive: true);
    }
    _storageDir = fallback;
    return _storageDir!;
  }

  File get _attendanceFile => File('${_directory.path}/attendance_records.json');
  File get _pendingSyncFile => File('${_directory.path}/pending_attendance_sync.json');

  /// Saves full attendance records to persistent local disk.
  Future<void> saveAttendanceRecords(List<AttendanceRecord> records) async {
    try {
      final jsonList = records.map((r) => r.toJson()).toList();
      await _attendanceFile.writeAsString(jsonEncode(jsonList), flush: true);
      debugPrint('LocalStorageService: Saved ${records.length} records to local disk.');
    } catch (e) {
      debugPrint('LocalStorageService save error: $e');
    }
  }

  /// Loads attendance records from persistent local disk.
  Future<List<AttendanceRecord>> loadAttendanceRecords() async {
    try {
      if (!await _attendanceFile.exists()) return [];
      final content = await _attendanceFile.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(content);
      return decoded.map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('LocalStorageService load error: $e');
      return [];
    }
  }

  /// Saves a single record to local storage immediately and queues for cloud sync.
  Future<void> persistRecord(AttendanceRecord record) async {
    try {
      // 1. Update master local list
      final current = await loadAttendanceRecords();
      current.removeWhere((r) => r.id == record.id);
      current.insert(0, record);
      await saveAttendanceRecords(current);

      // 2. Queue for cloud sync
      final pending = await loadPendingSyncRecords();
      pending.removeWhere((r) => r.id == record.id);
      pending.insert(0, record);
      await _pendingSyncFile.writeAsString(
        jsonEncode(pending.map((r) => r.toJson()).toList()),
        flush: true,
      );
      debugPrint('LocalStorageService: Queued record ${record.id} for sync.');
    } catch (e) {
      debugPrint('LocalStorageService persistRecord error: $e');
    }
  }

  /// Loads any records waiting to be synced to cloud.
  Future<List<AttendanceRecord>> loadPendingSyncRecords() async {
    try {
      if (!await _pendingSyncFile.exists()) return [];
      final content = await _pendingSyncFile.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(content);
      return decoded.map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Attempts to sync all pending offline records to Supabase.
  Future<void> syncPendingWithCloud() async {
    try {
      final pending = await loadPendingSyncRecords();
      if (pending.isEmpty) return;

      final List<AttendanceRecord> remaining = [];
      for (final record in pending) {
        final res = await SupabaseService.instance.insertAttendanceRecord(record);
        if (res == null) {
          remaining.add(record);
        }
      }

      if (remaining.isEmpty) {
        if (await _pendingSyncFile.exists()) {
          await _pendingSyncFile.delete();
        }
        debugPrint('LocalStorageService: All pending offline records successfully synced to Supabase.');
      } else {
        await _pendingSyncFile.writeAsString(
          jsonEncode(remaining.map((r) => r.toJson()).toList()),
          flush: true,
        );
        debugPrint('LocalStorageService: ${remaining.length} records still pending sync.');
      }
    } catch (e) {
      debugPrint('LocalStorageService syncPendingWithCloud error: $e');
    }
  }
}
