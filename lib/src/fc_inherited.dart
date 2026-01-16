part of '../full_context.dart';

class _FCInherited extends InheritedWidget {
  const _FCInherited({
    required this.core,
    required super.child,
  });

  final FCCore core;

  @override
  bool updateShouldNotify(_FCInherited oldWidget) => false;

  T get<T>() => core.get<T>();

  void emit<T>(T state) => core.emit<T>(state);

  Stream<T> get$<T>([String? typeString]) => core.get$<T>(typeString);

  static _FCInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FCInherited>();
  }

  static _FCInherited of(BuildContext context) {
    final _FCInherited? result = maybeOf(context);
    assert(result != null, 'No FCInherited found in context');
    return result!;
  }
}
