import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';

class FCBuilder<S> extends StatelessWidget {
  const FCBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, S state) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      initialData: context.get<S>(),
      stream: context.get$<S>(),
      builder: (context, snapshot) => builder(context, snapshot.data as S),
    );
  }
}
