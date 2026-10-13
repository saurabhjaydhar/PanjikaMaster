import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Where reports go. TODO(Q6): our own endpoint on the VPS or a form service. Until
/// that is decided no URL is configured, and reports wait in the queue.
class ReportSenderConfig {
  const ReportSenderConfig({this.endpoint});

  /// From `--dart-define=PANJIKA_REPORTS_URL=…` (the full `POST /v1/reports` URL).
  factory ReportSenderConfig.fromEnvironment() {
    const url = String.fromEnvironment('PANJIKA_REPORTS_URL');
    return ReportSenderConfig(endpoint: url.isEmpty ? null : Uri.parse(url));
  }

  final Uri? endpoint;
}

enum SendOutcome {
  /// Accepted: remove it from the queue.
  sent,

  /// Offline, server busy or not configured: keep it and try again later.
  retryLater,

  /// The server refuses this payload for good (a 4xx other than 408/429): retrying
  /// would never succeed.
  rejected,
}

abstract interface class ReportSender {
  /// [payload] is the JSON of one report, exactly as queued.
  Future<SendOutcome> send(String payload);
}

/// No endpoint yet (TODO(Q6)): every report stays queued.
class UnconfiguredReportSender implements ReportSender {
  const UnconfiguredReportSender();

  @override
  Future<SendOutcome> send(String payload) async => SendOutcome.retryLater;
}

/// `POST` the JSON to the configured endpoint (spec §15.3).
class HttpReportSender implements ReportSender {
  HttpReportSender(
    this._client,
    this._endpoint, {
    this.timeout = const Duration(seconds: 20),
  });

  final http.Client _client;
  final Uri _endpoint;
  final Duration timeout;

  @override
  Future<SendOutcome> send(String payload) async {
    try {
      final response = await _client
          .post(
            _endpoint,
            headers: {'content-type': 'application/json; charset=utf-8'},
            body: utf8.encode(payload),
          )
          .timeout(timeout);
      final code = response.statusCode;
      if (code >= 200 && code < 300) return SendOutcome.sent;
      if (code == 408 || code == 429 || code >= 500) {
        return SendOutcome.retryLater;
      }
      return SendOutcome.rejected;
    } on Exception {
      // No connection, DNS, TLS or timeout: the phone is offline as far as we know.
      return SendOutcome.retryLater;
    }
  }
}
