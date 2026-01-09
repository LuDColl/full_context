import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_inherited.dart';

class FCStateful extends StatefulWidget {
  const FCStateful({super.key, required this.builder});

  final WidgetBuilder builder;

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
  Widget build(BuildContext context) => widget.builder(context);
}
