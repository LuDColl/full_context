import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:full_context/src/events/fc_event.dart';
import 'package:full_context/src/fc_exception.dart';
import 'package:full_context/src/fc_extension.dart';
import 'package:full_context/src/full_context.dart';

class FCListener<S> extends StatefulWidget {
  const FCListener({
    super.key,
    this.onInit,
    this.afterInit,
    required this.onEvent,
    this.onError,
    required this.child,
  });

  final void Function(BuildContext context)? onInit;
  final void Function(BuildContext context)? afterInit;

  final void Function(BuildContext context, FCEvent<S> event) onEvent;
  final void Function<E extends Object>(
    BuildContext context,
    E error, [
    StackTrace? stackTrace,
  ])? onError;

  final Widget child;

  @override
  State<FCListener<S>> createState() => _FCListenerState<S>();
}

class _FCListenerState<S> extends State<FCListener<S>> {
  late StreamSubscription<FCEvent<S>>? _subscription;
  bool get _hasInit => widget.onInit != null || widget.afterInit != null;

  @override
  void initState() {
    super.initState();
    if (_hasInit) return;
    _subscription = context.event$<S>().listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasInit) {
      return FullContext(
        onInit: widget.onInit,
        afterInit: widget.afterInit,
        child: FCListener<S>(
          onEvent: widget.onEvent,
          child: widget.child,
        ),
      );
    }

    return widget.child;
  }

  void _onEvent(FCEvent<S> event) => widget.onEvent(context, event);
  void _onError<E extends Object>(E error, [StackTrace? stackTrace]) {
    final onError = widget.onError;
    if (onError == null) throw const FCException('Unhandled error');

    onError<E>(
      context,
      error,
      stackTrace,
    );
  }
}
