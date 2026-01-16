import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// Core class for managing state and factories in FullContext.
///
/// ### Get started
///
/// ```dart
/// final core = FCCore(
///   factories: [() => 'Hello, FullContext!'],
/// );
///
/// final myString = core.get<String>();
///
/// print(myString); // Output: Hello, FullContext!
/// ```
class FCCore {
  /// Creates an instance of [FCCore].
  ///
  /// ```dart
  /// final core = FCCore(
  ///   factories: [() => 0],
  /// );
  ///
  /// final childCore = FCCore(
  ///   parent: core,
  ///   factories: [(int number) => 'Number: $number'],
  /// );
  ///
  /// final myString = childCore.get<String>();
  /// print(myString); // Output: Number: 0
  /// ```
  FCCore({List<Function>? factories, required FCCore? parent})
      : _parent = parent {
    if (factories == null) return;

    if (factories.isEmpty) return;

    for (final factory in factories) {
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
        continue;
      }

      _factories[returnType] = factory;
    }
  }

  final FCCore? _parent;
  final Map<String, Function> _factories = {};
  final Map<String, BehaviorSubject> _subjects = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  /// Disposes the FCCore, closing all subjects and cancelling subscriptions.
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }

    for (final subject in _subjects.values) {
      subject.close();
    }

    _subjects.clear();
    _factories.clear();
    _subscriptions.clear();
  }

  /// Retrieves the current value of the specified type [T].
  ///
  /// Throws an assertion error if no value is found for the type.
  T get<T>() {
    final typeString = T.toString();
    final subject = _get$<T>(typeString);
    assert(subject.hasValue, 'No value found for type $T');
    return subject.value as T;
  }

  /// Emits a new value of type [T].
  /// If no subject exists for the type, it will be created.
  void emit<T>(T state) {
    final typeString = T.toString();
    final subject = _get$<T>(typeString);
    subject.add(state);
  }

  /// Retrieves a stream of values of type [T].
  Stream<T> get$<T>([String? typeString]) {
    typeString ??= T.toString();
    final subject = _get$<T>(typeString);
    return subject as Stream<T>;
  }

  BehaviorSubject _get$<T>(String typeString) {
    _factory$<T>(typeString);
    return _subjects[typeString] ?? _parent!._subjects[typeString]!;
  }

  void _factory$<T>(String typeString) {
    final hasSubject = _subjects.containsKey(typeString);
    if (hasSubject) return;

    final hasFactory = _factories.containsKey(typeString);

    if (!hasFactory) {
      final hasParent = _parent != null;
      assert(hasParent, 'No factory found for type $typeString');
      return _parent!._factory$<T>(typeString);
    }

    final factory = _factories[typeString]!;
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

      value.then(
        (value) {
          if (subject.isClosed) return;
          subject.add(value);
        },
        onError: (error) {
          if (subject.isClosed) return;
          subject.addError(error);
        },
      );

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
        .map((arg) => _get$(arg.trim()));

    final positionalArguments =
        subjects.map((subject) => subject.valueOrNull).toList();

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

        value.then(
          (value) {
            if (subject.isClosed) return;
            subject.add(value);
          },
          onError: (error) {
            if (subject.isClosed) return;
            subject.addError(error);
          },
        );
      }
    }

    _subjects[typeString] = subject;
    final streams = CombineLatestStream.list(subjects);

    _subscriptions[typeString] = streams.listen((positionalArguments) {
      if (subject.isClosed) return;

      final value = Function.apply(factory, positionalArguments);

      if (value is! Future<T>) {
        subject.add(value);
      } else {
        value.then(
          (value) {
            if (subject.isClosed) return;
            subject.add(value);
          },
          onError: (error) {
            if (subject.isClosed) return;
            subject.addError(error);
          },
        );
      }
    });
  }
}
