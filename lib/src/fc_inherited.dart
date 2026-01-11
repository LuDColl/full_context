part of '../full_context.dart';

class _FCInherited extends InheritedWidget {
  _FCInherited({
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
  final Map<String, StreamSubscription> _subscriptions = {};

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
      final innerType = returnType.substring(7, returnType.length - 1);
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

  static _FCInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FCInherited>();
  }

  static _FCInherited of(BuildContext context) {
    final _FCInherited? result = maybeOf(context);
    assert(result != null, 'No FCInherited found in context');
    return result!;
  }

  BehaviorSubject _get$<T>(String typeString) {
    _factory$<T>(typeString);
    return allSubjects[typeString]!;
  }

  void _factory$<T>(String typeString) {
    final hasSubject = allSubjects.containsKey(typeString);
    if (hasSubject) return;

    final hasFactory = allFactories.containsKey(typeString);
    assert(hasFactory, 'No factory found for type $typeString');

    final factory = allFactories[typeString]!;
    final runtimeType = factory.runtimeType;
    final runtimeTypeString = runtimeType.toString();

    if (runtimeTypeString.contains('()')) {
      final value = factory();

      if (value is! Future<T>) {
        final subject = BehaviorSubject<T>.seeded(value);
        _subjects[typeString] = subject;
        return;
      }

      final subject = BehaviorSubject<T>();
      value.then(subject.add, onError: subject.addError);
      _subjects[typeString] = subject;
      return;
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

    final positionalArguments = subjects
        .map((subject) => subject.valueOrNull)
        .toList();

    final waiting = subjects.any((subject) => !subject.hasValue);
    late final BehaviorSubject<T> subject;

    if (waiting) {
      subject = BehaviorSubject<T>();
    } else {
      final value = Function.apply(factory, positionalArguments);

      if (value is! Future<T>) {
        subject = BehaviorSubject<T>.seeded(value);
      } else {
        subject = BehaviorSubject<T>();
        value.then(subject.add, onError: subject.addError);
      }
    }

    _subjects[typeString] = subject;
    final streams = Rx.combineLatestList(subjects);

    _subscriptions[typeString] = streams.listen((args) {
      final value = Function.apply(factory, positionalArguments);

      if (value is! Future<T>) {
        subject.add(value);
      } else {
        value.then(subject.add, onError: subject.addError);
      }
    });
  }
}
