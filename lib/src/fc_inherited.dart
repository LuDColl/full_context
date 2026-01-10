import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class FCInherited extends InheritedWidget {
  FCInherited({
    super.key,
    required super.child,
    required List<Function> factories,
    required Map<String, Function> parentFactories,
    required Map<String, BehaviorSubject> parentSubjects,
  }) {
    _parentSubjects = parentSubjects;
    _parentFactories = parentFactories;

    for (final factory in factories) {
      add(factory);
    }
  }

  final Map<String, Function> _factories = {};
  late final Map<String, Function> _parentFactories;
  final Map<String, BehaviorSubject> _subjects = {};

  late final Map<String, BehaviorSubject> _parentSubjects;

  Map<String, BehaviorSubject> get allSubjects => {
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

    if (returnType.startsWith('Future<')) {
      final innerType = returnType
          .replaceAll('Future<', '')
          .replaceAll('>', '');

      _factories[innerType] = factory;
      return;
    }

    _factories[returnType] = factory;
  }

  T get<T>() {
    final typeString = T.toString();
    final subject = _get$<T>(typeString);
    assert(subject.hasValue, 'No value found for type $T');
    return subject.value as T;
  }

  void emit<T>(T state) {
    final typeString = T.toString();
    final subject = _get$<T>(typeString);
    subject.add(state);
  }

  Stream<T> get$<T>([Type? type]) {
    final typeString = type?.toString() ?? T.toString();
    final subject = _get$<T>(typeString);
    return subject as Stream<T>;
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

  BehaviorSubject _get$<T>(String typeString) {
    final hasSubject = allSubjects.containsKey(typeString);
    if (hasSubject) return allSubjects[typeString]!;

    final hasFactory = allFactories.containsKey(typeString);
    assert(hasFactory, 'No factory found for type $T');

    final factory = allFactories[typeString]!;
    final runtimeType = factory.runtimeType;
    final runtimeTypeString = runtimeType.toString();

    if (runtimeTypeString.contains('()')) {
      final value = factory();
      return _set$(typeString, value);
    }

    final arguments = runtimeTypeString.split('=>').first.trim();

    if (arguments.contains('})')) {
      throw UnimplementedError(
        'Factories with named parameters are not supported yet',
      );
    }

    final subjects = arguments
        .replaceAll('(', '')
        .replaceAll(')', '')
        .split(',')
        .map((arg) => _get$(arg.trim()))
        .toList();

    final subjectsWithOutValues = subjects
        .where((subject) => !subject.hasValue)
        .toList();

    if (subjectsWithOutValues.isEmpty) {
      final value = _set<T>(factory, typeString, subjects);
      return _set$(typeString, value);
    }

    final subject = BehaviorSubject<T>();
    final stream = Rx.combineLatestList(subjectsWithOutValues);

    stream.first.then((_) {
      final value = _set<T>(factory, typeString, subjects);
      subject.add(value);
    });

    _subjects[typeString] = subject;
    return subject;
  }

  T _set<T>(
    Function factory,
    String typeString,
    List<BehaviorSubject> subjects,
  ) {
    final positionalArguments = subjects
        .map((subject) => subject.value)
        .toList();

    final value = Function.apply(factory, positionalArguments);
    return value as T;
  }

  BehaviorSubject _set$<T>(String typeString, T value) {
    if (value is! Future<T>) {
      final subject = BehaviorSubject<T>.seeded(value);
      _subjects[typeString] = subject;
      return subject;
    }

    final subject = BehaviorSubject<T>();
    value.then(subject.add, onError: subject.addError);
    return subject;
  }
}
