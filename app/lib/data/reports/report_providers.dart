import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/time/clock.dart';
import '../db/database_provider.dart';
import 'report_queue.dart';
import 'report_sender.dart';

final reportSenderConfigProvider = Provider<ReportSenderConfig>(
  (ref) => ReportSenderConfig.fromEnvironment(),
);

final reportSenderProvider = Provider<ReportSender>((ref) {
  final endpoint = ref.watch(reportSenderConfigProvider).endpoint;
  if (endpoint == null) return const UnconfiguredReportSender(); // TODO(Q6)
  final client = http.Client();
  ref.onDispose(client.close);
  return HttpReportSender(client, endpoint);
});

final reportQueueProvider = Provider<ReportQueue>(
  (ref) => ReportQueue(
    ref.watch(appDatabaseProvider),
    ref.watch(reportSenderProvider),
    now: ref.watch(clockProvider),
  ),
);
