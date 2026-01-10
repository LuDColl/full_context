import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_inherited.dart';
import 'package:full_context/src/fc_stateful.dart';

class FullContext extends StatelessWidget {
  const FullContext({
    super.key,
    this.factories,
    this.listenables,
    this.errorBuilder,
    this.loadingBuilder,
    required this.builder,
  });

  final List<Type>? listenables;
  final List<Function>? factories;
  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  Widget build(BuildContext context) => FCInherited(
    factories: factories ?? [],
    parentSubjects: FCInherited.maybeOf(context)?.allSubjects ?? {},
    parentFactories: FCInherited.maybeOf(context)?.allFactories ?? {},
    child: FCStateful(
      builder: builder,
      listenables: listenables,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    ),
  );
}
