import 'package:flutter/widgets.dart';

class FCInherited extends InheritedWidget {
  final Map<String, Function> _factories = {};
  final Map<String, ValueNotifier<dynamic>> _values = {};

  FCInherited({
    super.key,
    required super.child,
    required List<Function> factories,
  }) {
    for (final factory in factories) {
      add(factory);
    }
  }

  @override
  bool updateShouldNotify(_) => false;

  void add(Function factory) {
    final runtimeType = factory.runtimeType;
    final typeString = runtimeType.toString();

    final hasReturn = typeString.contains('=>');
    assert(hasReturn, 'Factory must have a return type');

    final returnVoid = typeString.contains('=> void');
    assert(!returnVoid, 'Factory must not return void');

    final returnDynamic = typeString.contains('=> dynamic');
    assert(!returnDynamic, 'Factory must not return dynamic');

    final returnType = typeString.split('=>').last.trim();
    _factories[returnType] = factory;
  }

  T get<T>() {
    final typeString = T.toString();
    return _get<T>(typeString);
  }

  T _get<T>(String typeString) {
    final hasValue = _values.containsKey(typeString);
    if (hasValue) return _values[typeString]!.value as T;

    final hasFactory = _factories.containsKey(typeString);
    assert(hasFactory, 'No factory found for type $T');

    final factory = _factories[typeString]!;
    final runtimeType = factory.runtimeType;
    final runtimeTypeString = runtimeType.toString();

    if (runtimeTypeString.contains('()')) {
      final value = factory() as T;
      _values[typeString] = ValueNotifier<T>(value);
      return value;
    }

    final arguments = runtimeTypeString.split('=>').first.trim();

    if (arguments.contains('})')) {
      throw UnimplementedError(
        'Factories with named parameters are not supported yet',
      );
    }

    final positionalArguments = arguments
        .replaceAll('(', '')
        .replaceAll(')', '')
        .split(',')
        .map((typeString) => _get(typeString.trim()))
        .toList();

    final value = Function.apply(factory, positionalArguments) as T;
    _values[typeString] = ValueNotifier<T>(value);
    return value;
  }

  static FCInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FCInherited>();
  }

  static FCInherited of(BuildContext context) {
    final FCInherited? result = maybeOf(context);
    assert(result != null, 'No FCInherited found in context');
    return result!;
  }
}
