import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_builder.dart';
import 'package:full_context/src/full_context.dart';

class FCInitBuilder<S> extends StatelessWidget {
  const FCInitBuilder({super.key, required this.onInit, required this.builder});
  final void Function(BuildContext context) onInit;
  final Widget Function(
    BuildContext context,
    AsyncSnapshot<S> snapshot,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return FullContext(
      onInit: onInit,
      builder: (_) => FCBuilder<S>(builder: builder),
    );
  }
}
