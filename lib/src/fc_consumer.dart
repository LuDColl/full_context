import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:full_context/src/events/fc_event.dart';
import 'package:full_context/src/fc_extension.dart';

class FCConsumer<S> extends StatefulWidget {
  const FCConsumer({super.key, required this.listener, required this.builder});
  final void Function(BuildContext context, FCEvent<S> event) listener;
  final Widget Function(
    BuildContext context,
    AsyncSnapshot<S> snapshot,
  ) builder;

  @override
  State<FCConsumer<S>> createState() => FCConsumerState<S>();
}

class FCConsumerState<S> extends State<FCConsumer<S>> {
  late StreamSubscription<FCEvent<S>> _subscription;

  @override
  void initState() {
    super.initState();
    context.event$<S>().listen(_onEvent);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      stream: context.get$<S>(),
      builder: widget.builder,
    );
  }

  void _onEvent(FCEvent<S> event) => widget.listener(context, event);
}
