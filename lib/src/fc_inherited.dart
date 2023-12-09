import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_exception.dart';
import 'package:full_context/src/fc_states.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';

class FCInherited extends InheritedWidget {
  const FCInherited({
    super.key,
    required super.child,
    required this.streams,
    this.inheritedStreams,
  });

  final Map<Type, FCStream> streams;
  final Map<Type, FCStream>? inheritedStreams;

  Map<Type, FCStream> get allStreams {
    return {if (inheritedStreams != null) ...inheritedStreams!, ...streams};
  }

  void init<S>() {
    _noStreamValidate<S>(streams);
    streams[S] = FCSubject<S>(BehaviorSubject<S>());
  }

  void set<S>(S state) {
    _noStreamValidate<S>(streams);
    streams[S] = FCSubject<S>(BehaviorSubject<S>.seeded(state));
  }

  void map<S, N>(N Function(S state) mapper) {
    _noStreamValidate<N>(streams);
    _streamValidate<S>(allStreams);
    final stream = allStreams[S] as FCStream<S>;
    final subject = stream.subject;
    final newSubject = BehaviorSubject<N>.seeded(mapper(subject.value));
    final mapStream = subject.map<N>(mapper);
    final listen = newSubject.addStream(mapStream);
    streams[N] = FCMap<N>(newSubject);
    listen.then((_) => newSubject.close());
  }

  void emit<S>(S state) {
    _streamValidate<S>(allStreams);
    _subjectValidate<S>(allStreams);
    final stream = allStreams[S] as FCSubject<S>;
    stream.subject.add(state);
  }

  void emitError<S, E extends Object>(E error, [StackTrace? stackTrace]) {
    _streamValidate<S>(allStreams);
    _subjectValidate<S>(allStreams);
    final stream = allStreams[S] as FCSubject<S>;
    stream.subject.addError(error, stackTrace);
  }

  S get<S>() {
    final state = get$<S>().valueOrNull;
    if (state == null) throw throw FCException('$S not started');
    return state;
  }

  ValueStream<S> get$<S>() {
    _streamValidate<S>(allStreams);
    final stream = allStreams[S] as FCStream<S>;
    return stream.subject;
  }

  Future close<S>() {
    _streamValidate<S>(allStreams);
    _subjectValidate<S>(allStreams);
    final stream = allStreams[S] as FCSubject;
    return stream.subject.close();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static FCInherited? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<FCInherited>();
  }

  static FCInherited of(BuildContext context) {
    final fcInherited = maybeOf(context);
    if (fcInherited == null) throw const FCException('Without full states');
    return fcInherited;
  }

  static void _noStreamValidate<S>(Map<Type, FCStream> states) {
    if (states.containsKey(S)) throw FCException('$S already exists');
  }

  static void _streamValidate<S>(Map<Type, FCStream> states) {
    if (!states.containsKey(S)) throw FCException('$S not started');
  }

  static void _subjectValidate<S>(Map<Type, FCStream> states) {
    if (states[S] is! FCSubject<S>) throw FCException('$S is not a subject');
  }
}
