import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';

class FCStreamBuilder<S> extends StatelessWidget {
  const FCStreamBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    AsyncSnapshot<S> snapshot,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      stream: context.get$<S>(),
      builder: builder,
    );
  }
}
