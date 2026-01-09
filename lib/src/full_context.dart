import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_inherited.dart';
import 'package:full_context/src/fc_stateful.dart';

class FullContext<T> extends StatelessWidget {
  const FullContext({super.key, this.factories, required this.builder});

  final List<Function>? factories;
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) => FCInherited(
    factories: factories ?? [],
    parentValues: FCInherited.maybeOf(context)?.allValues ?? {},
    parentFactories: FCInherited.maybeOf(context)?.allFactories ?? {},
    child: FCStateful(builder: builder),
  );
}
