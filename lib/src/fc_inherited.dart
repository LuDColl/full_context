part of '../full_context.dart';

class _FCInherited extends InheritedWidget {
  const _FCInherited({
    required this.parent,
    required super.child,
    required this.subjects,
    required this.factories,
    required this.subscriptions,
  });

  final _FCInherited? parent;
  final Map<String, Function> factories;
  final Map<String, BehaviorSubject> subjects;
  final Map<String, StreamSubscription> subscriptions;

  @override
  bool updateShouldNotify(_FCInherited oldWidget) => false;

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

  Stream<T> get$<T>([String? typeString]) {
    typeString ??= T.toString();
    final subject = _get$<T>(typeString);
    return subject as Stream<T>;
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
    return subjects[typeString] ?? parent!.subjects[typeString]!;
  }

  void _factory$<T>(String typeString) {
    final hasSubject = this.subjects.containsKey(typeString);
    if (hasSubject) return;

    final hasFactory = factories.containsKey(typeString);

    if (!hasFactory) {
      final hasParent = parent != null;
      assert(hasParent, 'No factory found for type $typeString');
      return parent!._factory$<T>(typeString);
    }

    final factory = factories[typeString]!;
    final runtimeType = factory.runtimeType;
    final runtimeTypeString = runtimeType.toString();

    if (runtimeTypeString.contains('()')) {
      final value = factory();

      if (value is! Future<T>) {
        final subject = BehaviorSubject<T>.seeded(value);
        this.subjects[typeString] = subject;
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

      this.subjects[typeString] = subject;
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

    this.subjects[typeString] = subject;
    final streams = CombineLatestStream.list(subjects);

    subscriptions[typeString] = streams.listen((positionalArguments) {
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
