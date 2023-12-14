import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_exception.dart';

class FCStateful extends StatefulWidget {
  const FCStateful({
    super.key,
    this.builder,
    this.onInit,
    this.afterInit,
    this.child,
  });

  final Widget Function(BuildContext context)? builder;
  final void Function(BuildContext context)? onInit;
  final void Function(BuildContext context)? afterInit;
  final Widget? child;

  @override
  State<FCStateful> createState() => _FCStatefulState();
}

class _FCStatefulState extends State<FCStateful> {
  @override
  void initState() {
    super.initState();
    widget.onInit?.call(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.afterInit?.call(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasChild = widget.child != null;
    if (hasChild == (widget.builder != null)) {
      throw const FCException('Child or builder only');
    }

    return hasChild ? widget.child! : widget.builder!(context);
  }
}
