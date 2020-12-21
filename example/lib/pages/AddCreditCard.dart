import 'package:credit_card_minimalist/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCard extends StatefulWidget {
  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider.value(
      value: new CreditCardInfo.empty(cardtype: CardType.credit),
      child: CreditForm(
        onChangedCard: (info) async {
          print(info.toString());
        },
        dropCardOnCancel: (_) {
        },
        // mainColor: Colors.red,
        // secondaryColor: Colors.white,
        // backgroundColor: Colors.green,
      )
    );
  }
}