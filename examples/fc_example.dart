import 'package:flutter/material.dart';
import 'package:full_context/full_context.dart';

class FCExample extends StatelessWidget {
  const FCExample({super.key});

  @override
  Widget build(BuildContext context) => FullContext(
    listenables: [String],
    loadingBuilder: (context) =>
        const Center(child: CircularProgressIndicator()),
    factories: [
      () async {
        final duration = const Duration(seconds: 2);
        await Future.delayed(duration);
        return 1;
      },
      (int number) => number.toString(),
    ],
    builder: (context) => InkWell(
      onTap: () => context.emit<int>(context.get<int>() + 1),
      child: Text(context.get<String>()),
    ),
  );
}
