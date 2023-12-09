library full_context;

import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_inherited.dart';
import 'package:full_context/src/fc_stateful.dart';
import 'package:full_context/src/fc_states.dart';

export 'package:full_context/src/fc_builder.dart';
export 'package:full_context/src/fc_exception.dart';
export 'package:full_context/src/fc_extension.dart';
export 'package:full_context/src/fc_stream_builder.dart';

class FullContext extends StatefulWidget {
  const FullContext({super.key, required this.builder, required this.onInit});
  final Widget Function(BuildContext context) builder;
  final void Function(BuildContext context) onInit;

  @override
  State<FullContext> createState() => _FullContextState();
}

class _FullContextState extends State<FullContext> {
  final _streams = <Type, FCStream>{};

  @override
  void dispose() {
    for (var stream in _streams.values) {
      if (stream is FCSubject) stream.subject.close();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FCInherited(
      inheritedStreams: FCInherited.maybeOf(context)?.allStreams,
      streams: _streams,
      child: FCStateful(
        builder: widget.builder,
        onInit: widget.onInit,
      ),
    );
  }
}
