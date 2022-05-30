import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_timer_bloc_my_default/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _initialStateDuration = 60;
  static const int _completeStateDuration = 0;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,

        /// Bloc(`State` initialState)
        super(const TimerInitialState(_initialStateDuration)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgressState(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgressState) {
      _tickerSubscription?.pause();
      emit(TimerRunPauseState(state.duration));
    }
  }

  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPauseState) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgressState(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitialState(_initialStateDuration));
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    /// works `right` by using event.duration > 0
    event.duration > 0
        ? emit(TimerRunInProgressState(event.duration))
        : emit(const TimerRunCompleteState(_completeStateDuration));

    // /// works `wrong` by using state.duration > 0
    // state.duration > 0
    //     ? emit(TimerRunInProgressState(event.duration))
    //     : emit(const TimerRunCompleteState(_completeStateDuration));

    log('onTick method | duration : ${event.duration}');
    log('onTick method | state.duration : ${state.duration}');
    log('onTick method | state : $state');
  }
}
