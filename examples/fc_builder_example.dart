import 'package:flutter/widgets.dart';
import 'package:full_context/full_context.dart';

class FCBuilderExample extends StatelessWidget {
  const FCBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FullContext(builder: (context) => Text('Hello world!'));
  }
}
