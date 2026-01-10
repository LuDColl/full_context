import 'package:flutter/widgets.dart';

class FCInherited extends InheritedWidget {
  FCInherited({
    super.key,
    required super.child,
    required List<Function> factories,
    required Map<String, Function> parentFactories,
    required Map<String, ValueNotifier<dynamic>> parentValues,
  }) {
    _parentValues = parentValues;
    _parentFactories = parentFactories;

    for (final factory in factories) {
      add(factory);
    }
  }

  final Map<String, Function> _factories = {};
  final Map<String, ValueNotifier> _values = {};
  late final Map<String, Function> _parentFactories;
  late final Map<String, ValueNotifier> _parentValues;
  Map<String, ValueNotifier> get allValues => {..._parentValues, ..._values};

  Map<String, Function> get allFactories => {
    ..._parentFactories,
    ..._factories,
  };

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

  void emit<T>(T state) {
    final typeString = T.toString();
    final listenable = _get$<T>(typeString);
    listenable.value = state;
  }

  ValueNotifier get$<T>([Type? type]) {
    final typeString = type?.toString() ?? T.toString();
    return _get$<T>(typeString);
  }

  T _get<T>(String typeString) {
    final listenable = _get$<T>(typeString);
    return listenable.value;
  }

  ValueNotifier _get$<T>(String typeString) {
    final hasValue = allValues.containsKey(typeString);
    if (hasValue) return allValues[typeString]!;

    final hasFactory = allFactories.containsKey(typeString);
    assert(hasFactory, 'No factory found for type $T');

    final factory = allFactories[typeString]!;
    final runtimeType = factory.runtimeType;
    final runtimeTypeString = runtimeType.toString();

    if (runtimeTypeString.contains('()')) {
      final value = factory() as T;
      final listenable = ValueNotifier<T>(value);
      _values[typeString] = listenable;
      return listenable;
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
    final listenable = ValueNotifier<T>(value);
    _values[typeString] = listenable;
    return listenable;
  }

  void dispose() {
    for (final value in _values.values) {
      value.dispose();
    }

    _values.clear();
    _factories.clear();
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
