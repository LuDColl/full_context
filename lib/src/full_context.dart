import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_controller.dart';
import 'package:full_context/src/fc_inherited.dart';
import 'package:full_context/src/fc_stateful.dart';

class FullContext extends StatefulWidget {
  const FullContext({super.key, required this.builder, required this.onInit});
  final Widget Function(BuildContext context) builder;
  final void Function(BuildContext context) onInit;

  @override
  State<FullContext> createState() => _FullContextState();
}

class _FullContextState extends State<FullContext> {
  final _controllers = <Type, FCController>{};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.close();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FCInherited(
      controllers: _controllers,
      inheritedControllers: FCInherited.maybeOf(context)?.allControllers,
      child: FCStateful(
        builder: widget.builder,
        onInit: widget.onInit,
      ),
    );
  }
}
