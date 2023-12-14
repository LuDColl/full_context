import 'package:flutter/widgets.dart';
import 'package:full_context/src/events/fc_event.dart';
import 'package:full_context/src/fc_consumer.dart';
import 'package:full_context/src/full_context.dart';

class FCInitConsumer<S> extends StatelessWidget {
  const FCInitConsumer({
    super.key,
    required this.onInit,
    required this.listener,
    required this.builder,
  });

  final void Function(BuildContext context) onInit;
  final void Function(BuildContext context, FCEvent<S> event) listener;
  final Widget Function(
    BuildContext context,
    AsyncSnapshot<S> snapshot,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return FullContext(
      onInit: onInit,
      builder: (_) => FCConsumer(listener: listener, builder: builder),
    );
  }
}
