import 'package:credit_card_minimalist/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CreditCardInfo> cards = new List();

  @override
  void initState() { 
    super.initState();
    this.cards.add(
      CreditCardInfo(
        cardHoldname: "John Doe",
        cardtype: CardType.credit,
        creditNumber: "4242 4242 4242 4242",
        cvv: "123",
        expiryDate: "12/24",
        type: CardBrand.VISA,
        id: "0",
        color: Colors.red,

      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material App Bar'),
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text('Add a new card: '),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RaisedButton(
                    color: Theme.of(context).backgroundColor,
                    onPressed: (){
                      Navigator.of(context).pushNamed("/addCard");
                    },
                    child: Text("Add a new credit card"),
                  ),
                  RaisedButton(
                    color: Theme.of(context).backgroundColor,
                    onPressed: (){
                      
                    },
                    child: Text("Add a new prepay card"),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: this.cards.length,
                  itemBuilder: (ctx,i)  {
                    return ChangeNotifierProvider.value(
                      value: this.cards[i],
                      child: CreditCard(
                        creditCardInfo: this.cards[i],
                        canEdit: false,
                      ),
                    );
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}