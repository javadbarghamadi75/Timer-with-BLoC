import 'package:flutter/material.dart';
import 'package:flutter_timer_bloc_my_default/timer_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Timer with BLoC',
      home: TimerPage(),
    );
  }
}
