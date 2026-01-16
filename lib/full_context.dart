import 'dart:async';
import 'package:full_context/src/fc_core.dart';
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
  bool _init = false;
  late final FCCore core;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;

    _init = true;
    final parent = _FCInherited.maybeOf(context);
    core = FCCore(parent: parent?.core, factories: widget.factories);
  }

  @override
  void dispose() {
    core.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FCInherited(
      core: core,
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
