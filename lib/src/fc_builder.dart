import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_extension.dart';
import 'package:full_context/src/full_context.dart';

class FCBuilder<S> extends StatelessWidget {
  const FCBuilder({
    super.key,
    required this.builder,
    this.onInit,
    this.afterInit,
  });

  final Widget Function(
    BuildContext context,
    AsyncSnapshot<S> snapshot,
  ) builder;

  final void Function(BuildContext context)? onInit;
  final void Function(BuildContext context)? afterInit;

  @override
  Widget build(BuildContext context) {
    if (onInit != null || afterInit != null) {
      return FullContext(
        onInit: onInit,
        afterInit: afterInit,
        child: FCBuilder<S>(builder: builder),
      );
    }

    return StreamBuilder<S>(
      stream: context.get$<S>(),
      builder: builder,
    );
  }
}
