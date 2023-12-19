import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_controller.dart';
import 'package:full_context/src/fc_exception.dart';
import 'package:rxdart/streams.dart';

class FCInherited extends InheritedWidget {
  const FCInherited({
    super.key,
    required super.child,
    required this.controllers,
    this.inheritedControllers,
  });

  final Map<Type, FCController> controllers;
  final Map<Type, FCController>? inheritedControllers;

  Map<Type, FCController> get allControllers {
    return {
      if (inheritedControllers != null) ...inheritedControllers!,
      ...controllers,
    };
  }

  void init<S>() {
    _noControllerValidate<S>(controllers);
    controllers[S] = FCController<S>();
  }

  void set<S>(S state) {
    _noControllerValidate<S>(controllers);
    controllers[S] = FCController<S>(state);
  }

  void emit<S>(S state) {
    _controllerValidate<S>(allControllers);
    final controller = allControllers[S] as FCController<S>;
    controller.emit(state);
  }

  void emitError<S, E extends Object>(E error, [StackTrace? stackTrace]) {
    _controllerValidate<S>(allControllers);
    final subject = allControllers[S] as FCController<S>;
    subject.emitError(error, stackTrace);
  }

  S get<S>() {
    final state = get$<S>().valueOrNull;
    if (state == null) throw throw FCException('$S not started');
    return state;
  }

  ValueStream<S> get$<S>() {
    _controllerValidate<S>(allControllers);
    final controller = allControllers[S] as FCController<S>;
    return controller.stream;
  }

  Future close<S>() {
    _controllerValidate<S>(allControllers);
    final controller = allControllers[S] as FCController<S>;
    return controller.close();
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

  static void _noControllerValidate<S>(Map<Type, FCController> controllers) {
    if (controllers.containsKey(S) && !controllers[S]!.isClosed) {
      throw FCException('$S not closed');
    }
  }

  static void _controllerValidate<S>(Map<Type, FCController> controllers) {
    if (!controllers.containsKey(S)) throw FCException('$S not started');
    if (controllers[S]!.isClosed) throw FCException('$S closed');
  }
}
