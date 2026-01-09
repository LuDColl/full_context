import 'package:flutter/widgets.dart';

class FCStateful extends StatefulWidget {
  const FCStateful({super.key, required this.child, required this.factory});

  final Widget child;
  final void Function(BuildContext context) factory;

  @override
  State<FCStateful> createState() => _FCStatefulState();
}

class _FCStatefulState extends State<FCStateful> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.factory(context),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
