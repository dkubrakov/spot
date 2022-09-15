library spot;

import 'dart:async';

import 'package:logger/logger.dart';

class SpotTask {}

class SpotFutureTask {
  final Completer completer;
  final SpotTask task;

  SpotFutureTask({required this.completer, required this.task});
}

typedef HandlerCallback = Future<void> Function(SpotFutureTask futureTask);

class Spot {
  static const bool skip = false;
  int seqnr = 0;
  final tasks = StreamController<SpotFutureTask>();

  HandlerCallback? _handle;

  Logger? _logger;

  static final Spot _singleton = Spot._internal();

  factory Spot() {
    return _singleton;
  }

  Spot._internal() {
    tasks.stream.listen(_taskHandler);
  }

  void logStack({String? label}) {
    if (label != null) {
      _logger?.i(label);
    }
    _logger?.i(StackTrace.current.toString());
  }

  Future<void> initialize({
    HandlerCallback? handler,
    Logger? logger,
  }) {
    _handle = handler;
    _logger = logger;
    return Future.value();
  }

  void add(SpotFutureTask futureTask) {
    tasks.add(futureTask);
  }

  Future<void> _taskHandler(SpotFutureTask futureTask) async {
    final task = futureTask.task;
    _logger?.i('[spot] _taskHandler[$seqnr]($task)');
    seqnr++;

    if (_handle != null) {
      _handle!(futureTask);
    }
  }

}
