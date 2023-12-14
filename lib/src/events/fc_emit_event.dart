import 'package:full_context/src/events/fc_state_event.dart';

class FCEmitEvent<S> extends FCStateEvent<S> {
  FCEmitEvent(super.state);
}
