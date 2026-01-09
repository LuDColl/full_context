import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';
import 'package:full_context/src/fc_inherited.dart';

class FCStateful<T> extends StatefulWidget {
  const FCStateful({super.key, required this.builder});

  final Widget Function(BuildContext context, T value) builder;

  @override
  State<FCStateful<T>> createState() => _FCStatefulState<T>();
}

class _FCStatefulState<T> extends State<FCStateful<T>> {
  late final FCInherited _fcInherited;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _fcInherited = FCInherited.of(context),
    );
  }

  @override
  void dispose() {
    _fcInherited.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (T.toString() == 'Object?') return widget.builder(context, null as T);

    return ValueListenableBuilder(
      valueListenable: context.get$<T>(),
      builder: (context, value, _) => widget.builder(context, value),
    );
  }
}
