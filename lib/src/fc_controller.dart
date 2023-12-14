import 'dart:async';

import 'package:full_context/src/events/fc_emit_event.dart';
import 'package:full_context/src/events/fc_event.dart';
import 'package:full_context/src/events/fc_init_event.dart';
import 'package:full_context/src/events/fc_set_event.dart';
import 'package:full_context/src/events/fc_state_event.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';

class FCController<S> {
  FCController([S? state]) {
    _subscription = _publishEvent.listen(
      _onEvent,
      onError: _onError,
      onDone: _onDone,
    );

    if (state != null) {
      _publishEvent.add(FCSetEvent<S>(state));
    } else {
      _publishEvent.add(const FCInitEvent());
    }
  }

  final _subject = BehaviorSubject<S>();
  final _publishEvent = PublishSubject<FCEvent<S>>();

  late StreamSubscription<FCEvent<S>> _subscription;

  ValueStream<S> get stream => _subject.stream;
  Stream<FCEvent<S>> get event$ => _publishEvent.stream;
  bool get isClosed => _subject.isClosed;

  void emit(S state) => _publishEvent.add(FCEmitEvent<S>(state));

  void emitError<E extends Object>(E error, [StackTrace? stackTrace]) {
    _publishEvent.addError(error, stackTrace);
  }

  Future close() => _publishEvent.close();

  void _onEvent(FCEvent<S> event) {
    if (event is FCStateEvent<S>) _subject.add(event.state);
  }

  void _onDone() {
    _subscription.cancel();
    _subject.close();
  }

  void _onError(Object error, [StackTrace? stackTrace]) {
    _subject.addError(error, stackTrace);
  }
}
