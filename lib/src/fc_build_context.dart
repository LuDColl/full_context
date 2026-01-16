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

  /// Retrieves a stream of state of type [S] from the FullContext.
  /// ```dart
  /// final myStringStream = context.get$<String>();
  /// ```
  Stream<S> get$<S>([String? typeString]) =>
      _FCInherited.of(this).get$<S>(typeString);
}
