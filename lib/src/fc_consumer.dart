import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_builder.dart';
import 'package:full_context/src/fc_init.dart';
import 'package:full_context/src/fc_listener.dart';

class FCConsumer<S> extends StatelessWidget {
  const FCConsumer({
    super.key,
    this.onInit,
    this.afterInit,
    required this.onState,
    this.onError,
    this.errorBuilder,
    this.nullBuilder,
    required this.builder,
  });

  final FCInit? Function(BuildContext context)? onInit;
  final FCInit? Function(BuildContext context)? afterInit;
  final void Function(BuildContext context, S state) onState;
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
      onState: onState,
      onError: onError,
      child: FCBuilder(
        errorBuilder: errorBuilder,
        nullBuilder: nullBuilder,
        builder: builder,
      ),
    );
  }
}
