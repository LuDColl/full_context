import 'package:flutter/widgets.dart';

class FCStateful extends StatefulWidget {
  const FCStateful({super.key, required this.builder, required this.onInit});
  final Widget Function(BuildContext context) builder;
  final void Function(BuildContext context) onInit;

  @override
  State<FCStateful> createState() => _FCStatefulState();
}

class _FCStatefulState extends State<FCStateful> {
  @override
  void initState() {
    super.initState();
    widget.onInit(context);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
