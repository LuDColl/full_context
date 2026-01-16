import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/widgets.dart';

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
class FullContext extends StatefulWidget {
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
  State<FullContext> createState() => _FullContextState();
}

class _FullContextState extends State<FullContext> {
  final Map<String, Function> factories = {};
  final Map<String, BehaviorSubject> subjects = {};
  final Map<String, StreamSubscription> subscriptions = {};

  @override
  void initState() {
    super.initState();
    final factories = widget.factories;
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
        this.factories[innerType] = factory;
        continue;
      }

      this.factories[returnType] = factory;
    }
  }

  @override
  void dispose() {
    for (final subscription in subscriptions.values) {
      subscription.cancel();
    }

    for (final subject in subjects.values) {
      subject.close();
    }

    subjects.clear();
    factories.clear();
    subscriptions.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parent = _FCInherited.maybeOf(context);

    return _FCInherited(
      parent: parent,
      subjects: subjects,
      factories: factories,
      subscriptions: subscriptions,
      child: Builder(builder: (context) {
        final listenables = widget.listenables;

        if (listenables == null) return widget.builder(context);

        if (listenables.isEmpty) return widget.builder(context);

        final streams = listenables.map((type) => context.get$('$type'));
        final stream = CombineLatestStream.list(streams);

        return StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              if (widget.errorBuilder == null) return const SizedBox.shrink();
              return widget.errorBuilder!(context, snapshot.error!);
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              if (widget.loadingBuilder == null) return const SizedBox.shrink();
              return widget.loadingBuilder!(context);
            }

            return widget.builder(context);
          },
        );
      }),
    );
  }
}
