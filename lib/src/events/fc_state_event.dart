import 'package:full_context/src/events/fc_event.dart';

abstract class FCStateEvent<S> extends FCEvent<S> {
  const FCStateEvent(this.state);
  final S state;
}
