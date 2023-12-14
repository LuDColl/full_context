import 'package:full_context/src/events/fc_state_event.dart';

class FCSetEvent<S> extends FCStateEvent<S> {
  const FCSetEvent(super.state);
}
