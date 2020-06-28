# credit_card

Credit card widget, a beautiful election for adding cards to your app, can be used as a good complement
for store apps, gives a minimalist style.

### Now implementing prepay cards

## Dependencies used

This package uses 2 extern dependencies: 

- ### Flare Flutter
  -   flare_flutter : any
  -   #### reference: https://pub.dev/packages/flare_flutter
- ### Credit_Card_number_validator
  -   credit_card_number_validator: ^1.0.4
  -   #### reference: https://pub.dev/packages/credit_card_number_validator

## Now you can put 'es' or 'en' in your CreditCard() or CreditForm() language

## Using cards

For using this widget we need to have a CreditCardInfo component created like in the example 

```dart
  CreditCardInfo card = new CreditCardInfo(
    color: mainBlack,
    id: 1,
    cardHoldname: "User Name",
    creditNumber: "4040 5050 4400 4040",
    cvv: "123",
    expiryDate: "12/22",
    type: 1, //1: Mastercard, 2 Visa,3 Mastercard
    cardtype: CardType.credit
  );
```

Or an empty card

```dart
  CreditCardInfo card = new CreditCardInfo.empty();
```

It also can be a prepay card

```dart
  CreditCardInfo card = new CreditCardInfo(
    color: mainblack,
    id: 1,
    cardHoldname: "Prepay Card",
    credit: "\$50.0",
    cardtype: CardType.prepay,
    expiryDate: "02/20"
  )
```

 ##### Soon including PayPal !!

### Note
> This isnt just a simple class, this is a ChangeNotifier Class, which means we are creating a Provider for our card, this Provider help us to change at realtime the information inside our CreditCard Widget. In order to use this in correct way, we have to make the parent of this Widget be a ChangeNotifierProvider, in this way, all children of this will now absorb information and will have complete control. 

Then we need to create a CreditCard widget for displaying this info (Remember using notifier): 

```dart
  return ChangeNotifierProvider.value(
    value: card,
    child: CreditCard(
      creditCardInfo: card,
      onChangeCard(CreditCardInfo info) {
        //Do whatever you want to new information of card
      },
      //language: 'en'
    )
  );
```

## Creating cards

To create new cards we can use a simple button to trigger a showDialog, and this will push us to a new screen or use a Navigator.pop and call CreditForm widget inside a new Screen, up to your taste.

- ### First way
```dart
  FlatButton(
    child: Text("Press me"),
    onPressed(){
      CreditCardInfo card = new CreditCardInfo.empty();
      showDialog(
        context: context,
        child: ChangeNotifierProvider.value(
          value: card,
          child: CreditForm(
            //Method to update card object
            (info) {
              card = info;
            },
            //Method to discard any changes if card was created
            (info) {
              card = null;
            },
            language: 'en'
            //values if we want to create a prepay card
            validateCode: (String code){
              /*Validate code here*/
            },
            codeLength: 12
          )
        )
      );
    }
  )
```
- ### Second way
```dart
  FlatButton(
    child: Text("Press me"),
    onPressed(){
      CreditCardInfo card = new CreditCardInfo.empty();
      Navigator.of(context).pushNamed("/createCard"), {card});

    }
  )

  // In other screen

  return ChangeNotifierProvider.value(
    value: card,
    child: CreditForm(
      //Method to update card object
      (info) {
        card = info;
      },
      //Method to discard any changes if card was created
      (info) {
        card = null;
      },
      //language: 'en'
    )
  );
```

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
