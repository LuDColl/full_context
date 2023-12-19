import 'package:flutter/widgets.dart';
import 'package:full_context/src/fc_exception.dart';
import 'package:full_context/src/fc_extension.dart';
import 'package:full_context/src/fc_init.dart';
import 'package:full_context/src/full_context.dart';

class FCBuilder<S> extends StatelessWidget {
  const FCBuilder({
    super.key,
    this.onInit,
    this.afterInit,
    this.errorBuilder,
    this.nullBuilder,
    required this.builder,
  });

  final FCInit? Function(BuildContext context)? onInit;
  final FCInit? Function(BuildContext context)? afterInit;

  final Widget Function<E extends Object>(
    BuildContext context,
    E error, [
    StackTrace? stackTrace,
  ])? errorBuilder;

  final Widget Function(BuildContext context)? nullBuilder;
  final Widget Function(BuildContext context, S state) builder;

  @override
  Widget build(BuildContext context) {
    if (onInit != null || afterInit != null) {
      return FullContext(
        onInit: onInit,
        afterInit: afterInit,
        child: FCBuilder<S>(
          errorBuilder: errorBuilder,
          nullBuilder: nullBuilder,
          builder: builder,
        ),
      );
    }

    final valueStream = context.get$<S>();
    return StreamBuilder<S>(
      initialData: valueStream.valueOrNull,
      stream: valueStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (errorBuilder == null) throw const FCException('Unhandled error');
          return errorBuilder!(context, snapshot.error!, snapshot.stackTrace);
        }

        if (!snapshot.hasData) {
          if (nullBuilder == null) throw const FCException('Unhandled null');
          return nullBuilder!(context);
        }

        return builder(context, snapshot.data as S);
      },
    );
  }
}
