// import 'dart:async';
// import 'package:rxdart/streams.dart';
// import 'package:rxdart/subjects.dart';

// class FCController<S> {
//   FCController([S? state]) {
//     if (state != null) {
//       _subject = BehaviorSubject<S>.seeded(state);
//     } else {
//       _subject = BehaviorSubject<S>();
//     }
//   }

//   late BehaviorSubject<S> _subject;

//   ValueStream<S> get stream => _subject.stream;
//   bool get isClosed => _subject.isClosed;

//   void emit(S state) => _subject.add(state);

//   void emitError<E extends Object>(E error, [StackTrace? stackTrace]) {
//     _subject.addError(error, stackTrace);
//   }

//   Future close() => _subject.close();
// }
