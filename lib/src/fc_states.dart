import 'package:rxdart/subjects.dart';

abstract class FCStream<S> {
  const FCStream(this.subject);
  final BehaviorSubject<S> subject;
}

class FCSubject<S> extends FCStream<S> {
  FCSubject(super.subject);
}

class FCMap<S> extends FCStream<S> {
  FCMap(super.subject);
}
