part of '../full_context.dart';

/// Extension methods on BuildContext for FullContext functionality.
extension FCBuildContext on BuildContext {

  /// Retrieves the current state of type [S] from the FullContext.
  /// ```dart
  /// final myString = context.get<String>();
  /// ```
  S get<S>() => _FCInherited.of(this).get<S>();

  /// Emits a new state of type [S] to the FullContext.
  /// ```dart
  /// context.emit<String>('New value');
  /// ```
  void emit<S>(S state) => _FCInherited.of(this).emit<S>(state);

  /// Adds a factory function to create state of type [S] in the FullContext.
  /// ```dart
  /// context.add<String>(() => 'Hello, FullContext!');
  /// ```
  void add(Function factory) => _FCInherited.of(this).add(factory);

  /// Retrieves a stream of state of type [S] from the FullContext.
  /// ```dart
  /// final myStringStream = context.get$<String>();
  /// ```
  Stream<S> get$<S>([Type? type]) => _FCInherited.of(this).get$<S>(type);
}
