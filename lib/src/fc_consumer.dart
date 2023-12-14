import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:full_context/src/events/fc_event.dart';
import 'package:full_context/src/fc_extension.dart';
import 'package:full_context/src/full_context.dart';

class FCConsumer<S> extends StatefulWidget {
  const FCConsumer({
    super.key,
    required this.listener,
    required this.builder,
    this.onInit,
    this.afterInit,
  });

  final void Function(BuildContext context, FCEvent<S> event) listener;
  final Widget Function(
    BuildContext context,
    AsyncSnapshot<S> snapshot,
  ) builder;

  final void Function(BuildContext context)? onInit;
  final void Function(BuildContext context)? afterInit;

  @override
  State<FCConsumer<S>> createState() => FCConsumerState<S>();
}

class FCConsumerState<S> extends State<FCConsumer<S>> {
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
        child: FCConsumer<S>(
          listener: widget.listener,
          builder: widget.builder,
        ),
      );
    }

    return StreamBuilder<S>(
      stream: context.get$<S>(),
      builder: widget.builder,
    );
  }

  void _onEvent(FCEvent<S> event) => widget.listener(context, event);
}
