import 'package:flutter/material.dart';
import 'package:full_context/full_context.dart';

class FCAsyncExample extends StatelessWidget {
  const FCAsyncExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FullContext(
      listenables: [String],
      factories: [
        () async {
          final duration = const Duration(seconds: 2);
          await Future.delayed(duration);
          return 'Hello world!';
        },
      ],
      loadingBuilder: (context) => const CircularProgressIndicator(),
      errorBuilder: (context, error) => Text('Error: $error'),
      builder: (context) => InkWell(
        onTap: () => context.emit<String>('Hello again!'),
        child: Text(context.get<String>()),
      ),
    );
  }
}
