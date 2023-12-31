import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_exception.dart';
import 'package:full_context/src/fc_extension.dart';
import 'package:full_context/src/fc_init.dart';
import 'package:full_context/src/full_context.dart';

class FCListener<S> extends StatefulWidget {
  const FCListener({
    super.key,
    this.onInit,
    this.afterInit,
    required this.onState,
    this.onError,
    required this.child,
  });

  final FCInit? Function(BuildContext context)? onInit;
  final FCInit? Function(BuildContext context)? afterInit;

  final void Function(BuildContext context, S state) onState;
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
  late StreamSubscription<S>? _subscription;
  bool get _hasInit => widget.onInit != null || widget.afterInit != null;

  @override
  void initState() {
    super.initState();
    if (_hasInit) return;
    _subscription = context.get$<S>().listen(_onState, onError: _onError);
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
          onState: widget.onState,
          child: widget.child,
        ),
      );
    }

    return widget.child;
  }

  void _onState(S state) => widget.onState(context, state);
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
