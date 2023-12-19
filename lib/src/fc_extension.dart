import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_inherited.dart';
import 'package:rxdart/streams.dart';

extension FCExtension on BuildContext {
  void init<S>() => FCInherited.of(this).init<S>();
  void set<S>(S state) => FCInherited.of(this).set<S>(state);

  void emit<S>(S state) => FCInherited.of(this).emit<S>(state);
  void emitError<S, E extends Object>(E error) {
    FCInherited.of(this).emitError<S, E>(error);
  }

  S get<S>() => FCInherited.of(this).get<S>();
  ValueStream<S> get$<S>() => FCInherited.of(this).get$<S>();

  Future close<S>() => FCInherited.of(this).close<S>();
}
