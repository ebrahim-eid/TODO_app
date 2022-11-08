import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'cubit/bloc_observer.dart';
import 'modules/home_layout.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeLayout()
    );
  }
}
