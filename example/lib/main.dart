import 'package:example/pages/AddCreditCard.dart';
import 'package:example/pages/Home.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Material App',
        routes: <String, WidgetBuilder>{"/addCard": (ctx) => AddCard()},
        home: Home());
  }
}
