import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/widgets.dart';

part 'src/fc_stateful.dart';
part 'src/fc_inherited.dart';
part 'src/fc_build_context.dart';

/// A widget that provides a full context management system.
/// 
/// ### Getting started
/// 
/// ```dart
/// FullContext(
///   listenables: [String],
///   loadingBuilder: (context) =>
///       const Center(child: CircularProgressIndicator()),
///   factories: [
///     () async {
///       final duration = const Duration(seconds: 2);
///       await Future.delayed(duration);
///       return 1;
///     },
///     (int number) => number.toString(),
///   ],
///   builder: (context) => InkWell(
///     onTap: () => context.emit<int>(context.get<int>() + 1),
///     child: Text(context.get<String>()),
///  ),
/// );
/// ```
class FullContext extends StatelessWidget {

  /// Creates a FullContext widget:
  /// - required [builder] is the widget builder.
  /// - [listenables] is a list of types to listen to.
  /// - [errorBuilder] is a widget builder for error state.
  /// - [loadingBuilder] is a widget builder for loading state.
  /// - [factories] is a list of factory functions to create states.
  const FullContext({
    super.key,
    this.factories,
    this.listenables,
    this.errorBuilder,
    this.loadingBuilder,
    required this.builder,
  });

  /// The list of types to listen to.
  /// 
  /// If null or empty, no listening is performed.
  /// ```dart
  /// FullContext(
  ///   listenables: [String],
  ///   builder: (context) => Center(child: Text(context.get<String>())),
  /// );
  /// ```
  final List<Type>? listenables;

  /// The list of factory functions to create states.
  /// ```dart
  /// FullContext(
  ///   factories: [() => 'Hello, FullContext!'],
  ///   builder: (context) => Text(context.get<String>()),
  /// );
  /// ```
  final List<Function>? factories;

  /// The widget builder for the FullContext.
  /// ```dart
  /// FullContext(
  ///   builder: (context) => Text(context.get<String>()),
  /// );
  /// ```
  final Widget Function(BuildContext context) builder;

  /// The widget builder for loading state.
  /// ```dart
  /// FullContext(
  ///   loadingBuilder: (context) => CircularProgressIndicator(),
  ///   builder: (context) => Text(context.get<String>()),
  /// );
  /// ```
  final Widget Function(BuildContext context)? loadingBuilder;

  /// The widget builder for error state.
  /// ```dart
  /// FullContext(
  ///   errorBuilder: (context, error) => Text('Error: $error'),
  ///   builder: (context) => Text(context.get<String>()),
  /// );
  /// ```
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  Widget build(BuildContext context) => _FCInherited(
    factories: factories ?? [],
    parentSubjects: _FCInherited.maybeOf(context)?.allSubjects ?? {},
    parentFactories: _FCInherited.maybeOf(context)?.allFactories ?? {},
    child: _FCStateful(
      builder: builder,
      listenables: listenables,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    ),
  );
}
