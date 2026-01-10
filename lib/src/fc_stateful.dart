import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';
import 'package:full_context/src/fc_inherited.dart';
import 'package:rxdart/rxdart.dart';

class FCStateful extends StatefulWidget {
  const FCStateful({super.key, this.listenables, required this.builder});

  final List<Type>? listenables;
  final Widget Function(BuildContext context) builder;

  @override
  State<FCStateful> createState() => _FCStatefulState();
}

class _FCStatefulState extends State<FCStateful> {
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
    if (widget.listenables?.isEmpty ?? true) return widget.builder(context);

    return StreamBuilder(
      stream: Rx.merge(
        widget.listenables!.map((type) => context.get$(type)).toList(),
      ),
      builder: (context, _) => widget.builder(context),
    );
  }
}
