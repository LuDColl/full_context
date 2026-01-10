import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_model.dart';
import 'package:rxdart/rxdart.dart';

class FCInherited extends InheritedWidget {
  FCInherited({
    super.key,
    required super.child,
    required List<Function> factories,
    required Map<String, Function> parentFactories,
    required Map<String, BehaviorSubject<FCModel>> parentSubjects,
  }) {
    _parentSubjects = parentSubjects;
    _parentFactories = parentFactories;

    for (final factory in factories) {
      add(factory);
    }
  }

  final Map<String, Function> _factories = {};
  late final Map<String, Function> _parentFactories;
  final Map<String, BehaviorSubject<FCModel>> _subjects = {};
  late final Map<String, BehaviorSubject<FCModel>> _parentSubjects;

  Map<String, BehaviorSubject<FCModel>> get allValues => {
    ..._parentSubjects,
    ..._subjects,
  };

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
    final subject = _get$<T>(typeString);
    subject.add(FCModel(value: state, loading: false));
  }

  Stream<T> get$<T>([Type? type]) {
    final typeString = type?.toString() ?? T.toString();
    final subject = _get$<T>(typeString);
    return subject.map((event) => event.value as T);
  }

  T _get<T>(String typeString) {
    final subject = _get$<T>(typeString);
    return subject.value.value as T;
  }

  void dispose() {
    for (final value in _subjects.values) {
      value.close();
    }

    _subjects.clear();
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

  BehaviorSubject<FCModel> _get$<T>(String typeString) {
    final hasValue = allValues.containsKey(typeString);
    if (hasValue) return allValues[typeString]!;

    final futureTypeString = 'Future<$typeString>';
    final hasFutureFactory = allFactories.containsKey(futureTypeString);

    // if (hasFutureFactory) return _get$Async<T>(futureTypeString);

    final hasFactory = allFactories.containsKey(typeString);
    assert(hasFactory, 'No factory found for type $T');

    return _get$Sync<T>(typeString);
  }

  BehaviorSubject<FCModel> _get$Sync<T>(String typeString) {
    final factory = allFactories[typeString]!;
    final runtimeType = factory.runtimeType;
    final runtimeTypeString = runtimeType.toString();

    if (runtimeTypeString.contains('()')) {
      final value = factory() as T;

      final subject = BehaviorSubject<FCModel>.seeded(
        FCModel(value: value, loading: false),
      );

      _subjects[typeString] = subject;
      return subject;
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

    final subject = BehaviorSubject<FCModel>.seeded(
      FCModel(value: value, loading: false),
    );

    _subjects[typeString] = subject;
    return subject;
  }
}
