import 'package:provider/provider.dart';

import '../lib/CreditCard.dart';
import 'package:flutter/material.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CreditCardInfo card = new CreditCardInfo.empty();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: Column(
          children: <Widget>[
            FlatButton(
              child: Text("Press me"),
              onPressed:(){
                showDialog(
                  context: context,
                  child: ChangeNotifierProvider.value(
                    value: card,
                    child: CreditForm(
                      (info) {
                        setState(() {
                          this.card = info;
                        });
                      },
                      (info){
                        this.card = CreditCardInfo.empty();
                      }
                    ),
                  ),
                );
              } 
            ),
            card.creditNumber == null ?
            ChangeNotifierProvider.value(
              value: card,
              child: CreditCard(
                creditCardInfo: card,
                onChangeCard: (info){
                  setState(() {
                    this.card = info;
                  });
                },
              ),
            ) : Container()
          ],
        )
        
      ),
    );
  }
}