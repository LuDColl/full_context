import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_inherited.dart';

extension FCBuildContext on BuildContext {
  S get<S>() => FCInherited.of(this).get<S>();
  void emit<S>(S state) => FCInherited.of(this).emit<S>(state);
  void add(Function factory) => FCInherited.of(this).add(factory);
  Stream<S> get$<S>([Type? type]) => FCInherited.of(this).get$<S>(type);
}
