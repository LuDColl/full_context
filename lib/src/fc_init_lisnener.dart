import 'package:flutter/widgets.dart';
import 'package:full_context/src/events/fc_event.dart';
import 'package:full_context/src/fc_listener.dart';
import 'package:full_context/src/full_context.dart';

class FCInitListener<S> extends StatelessWidget {
  const FCInitListener({
    super.key,
    required this.onInit,
    required this.child,
    required this.listener,
  });

  final void Function(BuildContext context) onInit;
  final void Function(BuildContext context, FCEvent<S> event) listener;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FullContext(
      onInit: onInit,
      builder: (_) => FCListener(listener: listener, child: child),
    );
  }
}
