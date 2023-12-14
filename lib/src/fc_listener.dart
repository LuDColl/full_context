import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';
import 'package:full_context/src/events/fc_event.dart';

class FCListener<S> extends StatefulWidget {
  const FCListener({super.key, required this.child, required this.listener});
  final void Function(BuildContext context, FCEvent<S> event) listener;
  final Widget child;

  @override
  State<FCListener<S>> createState() => _FCListenerState<S>();
}

class _FCListenerState<S> extends State<FCListener<S>> {
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
  Widget build(BuildContext context) => widget.child;

  void _onEvent(FCEvent<S> event) => widget.listener(context, event);
}
