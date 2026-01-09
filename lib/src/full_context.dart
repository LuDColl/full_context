import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_inherited.dart';
import 'package:full_context/src/fc_stateful.dart';

class FullContext extends StatelessWidget {
  const FullContext({
    super.key,
    required this.builder,
    required this.factories,
  });

  final WidgetBuilder builder;
  final List<Function> factories;

  @override
  Widget build(BuildContext context) => FCInherited(
    factories: factories,
    parentValues: FCInherited.maybeOf(context)?.allValues ?? {},
    parentFactories: FCInherited.maybeOf(context)?.allFactories ?? {},
    child: FCStateful(builder: builder),
  );
}
