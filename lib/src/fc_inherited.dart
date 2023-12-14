import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:full_context/src/events/fc_event.dart';
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

  StreamSubscription<S> map<S, T>(
    BuildContext context,
    T Function(BuildContext context, S state) mapper,
  ) {
    _controllerValidate<S>(allControllers);
    _controllerValidate<T>(allControllers);

    final controller = allControllers[S] as FCController<S>;
    final toController = allControllers[T] as FCController<T>;

    late StreamSubscription<S> subscription;

    subscription = controller.stream.listen(
      (state) {
        final newState = mapper(context, state);
        toController.emit(newState);
      },
      onError: (Object error, [StackTrace? stackTrace]) {
        toController.emitError(error, stackTrace);
      },
      onDone: () => subscription.cancel(),
    );

    return subscription;
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

  Stream<FCEvent<S>> event$<S>() {
    _controllerValidate<S>(allControllers);
    final controller = allControllers[S] as FCController<S>;
    return controller.event$;
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
