import 'package:flutter/widgets.dart';
import 'package:full_context/src/events/fc_event.dart';
import 'package:full_context/src/fc_inherited.dart';
import 'package:rxdart/streams.dart';

extension FCExtension on BuildContext {
  void init<S>() => FCInherited.of(this).init<S>();
  void set<S>(S state) => FCInherited.of(this).set<S>(state);
  void map<S, T>(T Function(BuildContext context, S state) mapper) {
    FCInherited.of(this).map<S, T>(this, mapper);
  }

  void emit<S>(S state) => FCInherited.of(this).emit<S>(state);
  void emitError<S, E extends Object>(E error) {
    FCInherited.of(this).emitError<S, E>(error);
  }

  S get<S>() => FCInherited.of(this).get<S>();
  ValueStream<S> get$<S>() => FCInherited.of(this).get$<S>();
  Stream<FCEvent<S>> event$<S>() => FCInherited.of(this).event$<S>();
  Future close<S>() => FCInherited.of(this).close<S>();
}
