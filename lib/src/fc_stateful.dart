import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';
import 'package:full_context/src/fc_inherited.dart';
import 'package:rxdart/rxdart.dart';

class FCStateful extends StatefulWidget {
  const FCStateful({
    super.key,
    this.listenables,
    this.errorBuilder,
    this.loadingBuilder,
    required this.builder,
  });

  final List<Type>? listenables;
  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

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
      stream: Rx.combineLatestList(
        widget.listenables!.map((type) => context.get$(type)).toList(),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (widget.errorBuilder == null) return const SizedBox.shrink();
          return widget.errorBuilder!(context, snapshot.error!);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          if (widget.loadingBuilder == null) return const SizedBox.shrink();
          return widget.loadingBuilder!(context);
        }

        return widget.builder(context);
      },
    );
  }
}
