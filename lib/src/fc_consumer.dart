import 'package:flutter/widgets.dart';
import 'package:full_context/src/events/fc_event.dart';
import 'package:full_context/src/fc_builder.dart';
import 'package:full_context/src/fc_listener.dart';

class FCConsumer<S> extends StatelessWidget {
  const FCConsumer({
    super.key,
    this.onInit,
    this.afterInit,
    required this.onEvent,
    this.onError,
    this.errorBuilder,
    this.nullBuilder,
    required this.builder,
  });

  final void Function(BuildContext context)? onInit;
  final void Function(BuildContext context)? afterInit;
  final void Function(BuildContext context, FCEvent<S> event) onEvent;
  final void Function<E extends Object>(
    BuildContext context,
    E error, [
    StackTrace? stackTrace,
  ])? onError;

  final Widget Function<E extends Object>(
    BuildContext context,
    E error, [
    StackTrace? stackTrace,
  ])? errorBuilder;

  final Widget Function(BuildContext context)? nullBuilder;
  final Widget Function(BuildContext context, S snapshot) builder;

  @override
  Widget build(BuildContext context) {
    return FCListener(
      onInit: onInit,
      afterInit: afterInit,
      onEvent: onEvent,
      onError: onError,
      child: FCBuilder(
        errorBuilder: errorBuilder,
        nullBuilder: nullBuilder,
        builder: builder,
      ),
    );
  }
}
