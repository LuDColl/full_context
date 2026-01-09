import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_inherited.dart';

class FullContext extends StatefulWidget {
  const FullContext({required this.child, super.key, required this.factories});

  final Widget child;
  final List<Function> factories;

  @override
  State<FullContext> createState() => _FullContextState();
}

class _FullContextState extends State<FullContext> {
  @override
  Widget build(BuildContext context) =>
      FCInherited(factories: widget.factories, child: widget.child);
}
