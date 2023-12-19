import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_exception.dart';
import 'package:full_context/src/fc_init.dart';

class FCStateful extends StatefulWidget {
  const FCStateful({
    super.key,
    this.builder,
    this.onInit,
    this.afterInit,
    this.child,
  });

  final Widget Function(BuildContext context)? builder;
  final FCInit? Function(BuildContext context)? onInit;
  final FCInit? Function(BuildContext context)? afterInit;
  final Widget? child;

  @override
  State<FCStateful> createState() => _FCStatefulState();
}

class _FCStatefulState extends State<FCStateful> {
  final _inits = <FCInit?>[];

  @override
  void initState() {
    super.initState();
    final init = widget.onInit?.call(context);
    _inits.add(init);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final init = widget.afterInit?.call(context);
        _inits.add(init);
      },
    );
  }

  @override
  void dispose() {
    for (var init in _inits) {
      init?.dispose();
    }

    super.dispose();
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
