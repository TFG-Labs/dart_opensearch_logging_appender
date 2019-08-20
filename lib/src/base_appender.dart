import 'dart:async';

import 'package:logging/logging.dart';
import 'package:logging_appenders/src/logrecord_formatter.dart';
import 'package:meta/meta.dart';

typedef LogRecordListener = void Function(LogRecord rec);

abstract class BaseLogAppender {
  BaseLogAppender(LogRecordFormatter formatter)
      : formatter = formatter ?? const DefaultLogRecordFormatter();

  final LogRecordFormatter formatter;
  final List<StreamSubscription<dynamic>> _subscriptions = <StreamSubscription<dynamic>>[];

  @protected
  void handle(LogRecord record);

  LogRecordListener logListener() => (LogRecord record) => handle(record);

  void attachToLogger(Logger logger) {
    _subscriptions.add(logger.onRecord.listen(logListener()));
  }

  void call(LogRecord record) => handle(record);

  @mustCallSuper
  Future<void> dispose() async {
    await _cancelSubscriptions();
  }

  Future<void> _cancelSubscriptions() async {
    final futures = _subscriptions.map((sub) => sub.cancel()).toList(growable: false);
    _subscriptions.clear();
    await Future.wait<dynamic>(futures);
  }
}