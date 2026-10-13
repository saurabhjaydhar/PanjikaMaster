import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../domain/reports/error_report.dart';
import '../db/app_database.dart';
import 'report_sender.dart';

/// Error reports wait here until they can be sent (T-604, US-07): submitting works
/// offline, and the queue is sent when the app starts, returns to the foreground or
/// queues a new report.
class ReportQueue {
  ReportQueue(this._db, this._sender, {required this.now});

  /// The oldest reports are dropped beyond this, so the table cannot grow without end.
  static const maxQueued = 50;

  final AppDatabase _db;
  final ReportSender _sender;
  final DateTime Function() now;
  Future<int>? _flushing;

  Future<void> enqueue(ErrorReport report) async {
    await _db
        .into(_db.errorReportsQueue)
        .insert(
          ErrorReportsQueueCompanion.insert(
            payload: jsonEncode(report.toJson()),
            createdAt: now().toUtc().toIso8601String(),
          ),
        );
    final ids =
        await (_db.selectOnly(_db.errorReportsQueue)
              ..addColumns([_db.errorReportsQueue.id])
              ..orderBy([OrderingTerm.desc(_db.errorReportsQueue.id)]))
            .map((r) => r.read(_db.errorReportsQueue.id)!)
            .get();
    if (ids.length > maxQueued) {
      await (_db.delete(
        _db.errorReportsQueue,
      )..where((q) => q.id.isSmallerOrEqualValue(ids[maxQueued]))).go();
    }
  }

  Future<int> pending() async =>
      (await _db.select(_db.errorReportsQueue).get()).length;

  /// Sends queued reports oldest first and returns how many were sent. Stops at the
  /// first one that has to wait, so the order is kept. Concurrent calls share a run.
  Future<int> flush() => _flushing ??= _flush().whenComplete(() {
    _flushing = null;
  });

  Future<int> _flush() async {
    final rows = await (_db.select(
      _db.errorReportsQueue,
    )..orderBy([(q) => OrderingTerm.asc(q.id)])).get();
    var sent = 0;
    for (final row in rows) {
      final outcome = await _sender.send(row.payload);
      if (outcome == SendOutcome.retryLater) break;
      if (outcome == SendOutcome.rejected) {
        debugPrint('reports: server rejected report ${row.id}; dropped');
      } else {
        sent++;
      }
      await (_db.delete(
        _db.errorReportsQueue,
      )..where((q) => q.id.equals(row.id))).go();
    }
    return sent;
  }
}
