import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/architecture/bloc_base.dart';

class CounterEvent {
  final int increment;
  const CounterEvent(this.increment);
}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  void onEvent(CounterEvent event) {
    emit(state + event.increment);
  }
}

void main() {
  group('Pure Reactive BLoC Base Tests', () {
    test('Bloc emits states on events correctly', () async {
      final bloc = CounterBloc();
      expect(bloc.state, equals(0));

      final states = <int>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const CounterEvent(5));
      bloc.add(const CounterEvent(10));

      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, equals([5, 15]));
      expect(bloc.state, equals(15));

      await sub.cancel();
      bloc.dispose();
      expect(bloc.isClosed, isTrue);
    });

    testWidgets('BlocBuilder rebuilds UI when state updates', (tester) async {
      final bloc = CounterBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocBuilder<CounterBloc, int>(
              bloc: bloc,
              builder: (context, count) => Text('Count: $count'),
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      bloc.add(const CounterEvent(3));
      await tester.pumpAndSettle();

      expect(find.text('Count: 3'), findsOneWidget);
      bloc.dispose();
    });
  });
}
