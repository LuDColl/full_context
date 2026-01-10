import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';

class FCFactoriesExample extends StatelessWidget {
  const FCFactoriesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FullContext(
      factories: [() => 'Hello world!'],
      builder: (context) => Text(context.get<String>()),
    );
  }
}
