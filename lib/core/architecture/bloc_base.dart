import 'dart:async';
import 'package:flutter/widgets.dart';

/// Base class for all Business Logic Components (BLoC) in TRAVELGO.
/// Implements pure reactive unidirectional data flow (Event -> Bloc -> State).
abstract class Bloc<E, S> {
  S _state;
  final StreamController<E> _eventController = StreamController<E>.broadcast();
  final StreamController<S> _stateController = StreamController<S>.broadcast();
  late StreamSubscription<E> _eventSubscription;
  bool _isClosed = false;

  Bloc(S initialState) : _state = initialState {
    _eventSubscription = _eventController.stream.listen((event) {
      if (!_isClosed) {
        onEvent(event);
      }
    });
  }

  /// The current state of the BLoC
  S get state => _state;

  /// Stream of emitted states
  Stream<S> get stream => _stateController.stream;

  /// Whether the BLoC is closed
  bool get isClosed => _isClosed;

  /// Emits a new state to all listeners
  @protected
  void emit(S newState) {
    if (_isClosed) return;
    if (_state == newState) return;
    _state = newState;
    _stateController.add(_state);
  }

  /// Adds a new event to trigger state transitions
  void add(E event) {
    if (!_isClosed) {
      _eventController.add(event);
    }
  }

  /// Event handler to be implemented by subclasses
  @protected
  void onEvent(E event);

  /// Closes the event and state stream controllers
  @mustCallSuper
  void dispose() {
    _isClosed = true;
    _eventSubscription.cancel();
    _eventController.close();
    _stateController.close();
  }
}

/// Widget that builds UI in response to state changes of a BLoC
class BlocBuilder<B extends Bloc<dynamic, S>, S> extends StatefulWidget {
  final B bloc;
  final Widget Function(BuildContext context, S state) builder;
  final bool Function(S previous, S current)? buildWhen;

  const BlocBuilder({
    super.key,
    required this.bloc,
    required this.builder,
    this.buildWhen,
  });

  @override
  State<BlocBuilder<B, S>> createState() => _BlocBuilderState<B, S>();
}

class _BlocBuilderState<B extends Bloc<dynamic, S>, S> extends State<BlocBuilder<B, S>> {
  late S _state;
  StreamSubscription<S>? _subscription;

  @override
  void initState() {
    super.initState();
    _state = widget.bloc.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant BlocBuilder<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc != widget.bloc) {
      _subscription?.cancel();
      _state = widget.bloc.state;
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.bloc.stream.listen((newState) {
      final shouldRebuild = widget.buildWhen?.call(_state, newState) ?? true;
      if (shouldRebuild && mounted) {
        setState(() {
          _state = newState;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state);
  }
}

/// Widget that executes side-effects (listeners) and builds UI for a BLoC
class BlocConsumer<B extends Bloc<dynamic, S>, S> extends StatefulWidget {
  final B bloc;
  final Widget Function(BuildContext context, S state) builder;
  final void Function(BuildContext context, S state) listener;
  final bool Function(S previous, S current)? buildWhen;
  final bool Function(S previous, S current)? listenWhen;

  const BlocConsumer({
    super.key,
    required this.bloc,
    required this.builder,
    required this.listener,
    this.buildWhen,
    this.listenWhen,
  });

  @override
  State<BlocConsumer<B, S>> createState() => _BlocConsumerState<B, S>();
}

class _BlocConsumerState<B extends Bloc<dynamic, S>, S> extends State<BlocConsumer<B, S>> {
  late S _state;
  StreamSubscription<S>? _subscription;

  @override
  void initState() {
    super.initState();
    _state = widget.bloc.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant BlocConsumer<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc != widget.bloc) {
      _subscription?.cancel();
      _state = widget.bloc.state;
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.bloc.stream.listen((newState) {
      final shouldListen = widget.listenWhen?.call(_state, newState) ?? true;
      if (shouldListen && mounted) {
        widget.listener(context, newState);
      }

      final shouldRebuild = widget.buildWhen?.call(_state, newState) ?? true;
      if (shouldRebuild && mounted) {
        setState(() {
          _state = newState;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state);
  }
}
