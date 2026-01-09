import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_inherited.dart';

extension FCBuildContext on BuildContext {
  // void init<S>() => FCInherited.of(this).init<S>();
  // void set<S>(S state) => FCInherited.of(this).set<S>(state);

  // void emit<S>(S state) => FCInherited.of(this).emit<S>(state);
  // void emitError<S, E extends Object>(E error) {
  //   FCInherited.of(this).emitError<S, E>(error);
  // }

  S get<S>() => FCInherited.of(this).get<S>();
  void add(Function factory) => FCInherited.of(this).add(factory);

  // ValueStream<S> get$<S>() => FCInherited.of(this).get$<S>();

  // Future close<S>() => FCInherited.of(this).close<S>();
}
