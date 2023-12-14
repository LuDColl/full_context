import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:full_context/src/events/fc_event.dart';
import 'package:full_context/src/fc_extension.dart';
import 'package:full_context/src/full_context.dart';

class FCListener<S> extends StatefulWidget {
  const FCListener({
    super.key,
    required this.child,
    required this.listener,
    this.onInit,
    this.afterInit,
  });

  final void Function(BuildContext context, FCEvent<S> event) listener;
  final Widget child;

  final void Function(BuildContext context)? onInit;
  final void Function(BuildContext context)? afterInit;

  @override
  State<FCListener<S>> createState() => _FCListenerState<S>();
}

class _FCListenerState<S> extends State<FCListener<S>> {
  late StreamSubscription<FCEvent<S>>? _subscription;
  bool get _hasInit => widget.onInit != null || widget.afterInit != null;

  @override
  void initState() {
    super.initState();
    if (!_hasInit) _subscription = context.event$<S>().listen(_onEvent);
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
          listener: widget.listener,
          child: widget.child,
        ),
      );
    }

    return widget.child;
  }

  void _onEvent(FCEvent<S> event) => widget.listener(context, event);
}
