import 'package:flutter/material.dart';
import 'package:full_context/full_context.dart';

class FCListenablesExample extends StatelessWidget {
  const FCListenablesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FullContext(
      listenables: [String],
      factories: [() => 'Hello world!'],
      builder: (context) => InkWell(
        onTap: () => context.emit<String>('Hello again!'),
        child: Text(context.get<String>()),
      ),
    );
  }
}
