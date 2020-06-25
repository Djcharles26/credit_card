import 'dart:math';
import 'package:credit_card_number_validator/credit_card_number_validator.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './utils/Colors.dart';
import 'package:provider/provider.dart';


class CreditCardInfo extends ChangeNotifier{
  int id;
  final double width;
  final double height;
  String cardHoldname;
  String creditNumber;
  String cvv;
  String expiryDate;
  int type;
  Color color;
  bool flipped;


  CreditCardInfo(
    {
      @required this.id,
      @required this.cardHoldname,
      @required this.creditNumber,
      @required this.cvv,
      @required this.expiryDate,
      this.type,
      this.width,
      this.height,
      this.color,
      this.flipped,
    }
  );



  CreditCardInfo.empty({
    
    this.cardHoldname = '',
    this.creditNumber = '',
    this.cvv = '',
    this.expiryDate = '',
    this.height,
    this.width,
    this.color = Colors.black,
    this.type = 0
  });

  bool _flipCard = false;

  void updateInfo (CreditCardInfo card) {
    this.cardHoldname = card.cardHoldname;
    this.creditNumber = card.creditNumber;
    this.cvv = card.cvv;
    this.expiryDate = card.expiryDate;
    notifyListeners(); 
  }

  void flipCardBack() {
    _flipCard = true;
    notifyListeners();
  }

  void flipCardUp() {
    _flipCard = false;
    notifyListeners();
  }


  

}


class CreditCard extends StatefulWidget {
  final CreditCardInfo creditCardInfo;
  final width;
  final height;
  final Function(CreditCardInfo card) onChangeCard;
  final bool createCard;
  final bool canEdit;

  CreditCard(
    {
      @required this.creditCardInfo,
      this.width,
      this.height,
      this.canEdit = true,
      this.onChangeCard,
      this.createCard
    }
  );

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> with SingleTickerProviderStateMixin {

  AnimationController _animationController;
  Animation<double> animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  List<String> types = ['mastercard', 'visa', 'amex'];

  @override
  void initState() { 
    super.initState();
    _animationController = AnimationController(vsync: this, duration : Duration(milliseconds: 500));
    animation = Tween<double>(end: 1, begin: 0).animate(_animationController)
    ..addListener(() {
      setState(() {
        
      });
    })
    ..addStatusListener((status) {
      _animationStatus = status;
    });
    
  }

  @override
  Widget build(BuildContext context) {

    final double w = this.widget.width ?? MediaQuery.of(context).size.width * 0.72;
    final double h = this.widget.height ?? MediaQuery.of(context).size.width * 0.45;

    return Consumer<CreditCardInfo>(
      builder: (context, card, _) {
        return Container(
          height: h,
          width: w,
          color: Colors.transparent,
          child: Center(
            child: Transform(
              alignment: FractionalOffset.center,
              transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(pi * animation.value),
              child: GestureDetector(
                onTap: (){
                  if(_animationStatus == AnimationStatus.dismissed){
                    Provider.of<CreditCardInfo>(context,listen: false).flipCardBack();
                  }else Provider.of<CreditCardInfo>(context,listen: false).flipCardUp();
                },
                onLongPress: (){
                  if(this.widget.canEdit){

                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    child: WillPopScope(
                      onWillPop: () async => false,
                      child: ChangeNotifierProvider.value
                      (
                        value: card,
                        child: CreditForm(this.widget.onChangeCard, (_){})
                    )
                    )
                  );
                  }
                },
                child: Consumer<CreditCardInfo>(
                  builder: (ctx, prov, _) {
                    if(prov._flipCard && _animationStatus == AnimationStatus.dismissed) _animationController.forward();
                    else if(!prov._flipCard) _animationController.reverse();
                    return animation.value <= 0.5 ? Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Positioned(
                          top: 0,
                          left: 0,
                          height: h,
                          width: w,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: prov.color,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          left: 15,
                          height: h,
                          width: w-30,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                
                              Container(
                                width: 50,
                                height: 50,
                                child: FlareActor(
                                  'assets/cardIcons/${types[this.widget.creditCardInfo.type]}.flr',
                                  animation: "Activate",
                                ),
                              ),
                              Center(child: Text(this.widget.creditCardInfo.creditNumber ?? '', style: TextStyle(fontFamily: "kredit", fontWeight: FontWeight.w700, fontSize: 18, color: Color.fromRGBO(230, 230, 230, 1), letterSpacing: w*0.01),textAlign: TextAlign.center, )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: w*0.6),
                                    child: Text(this.widget.creditCardInfo.cardHoldname ?? '', style: TextStyle(fontFamily: "Baloo Baihna 2", fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey))),
                                  Text(this.widget.creditCardInfo.expiryDate ?? '', style: TextStyle(fontFamily: "Baloo Baihna 2", fontWeight: FontWeight.w700, fontSize: 18, color: mainWhite)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ) : _backCard(w,h);
                  },
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _backCard(w,h){
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          height: h,
          width: w,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Provider.of<CreditCardInfo>(context,listen: false).color
            ),
          ),
        ),
        Positioned(
          top: 15,
          left: 0,
          width: w,
          height: h,
          child: Transform.translate(
            offset: Offset(w, 0.0),
            child: Transform(
              transform: Matrix4.identity()
              ..rotateY(pi),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    height: h* 0.2,
                    decoration: BoxDecoration(
                      color: Colors.black
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: w* 0.5,
                          height: h*0.1,
                          color: mainWhite
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            
                            Text("cvv", style: TextStyle(fontSize: 15, fontFamily: "Baloo Baihna 2", color: Color.fromRGBO(230, 230, 230, 1), fontWeight: FontWeight.w200)),
                            SizedBox(width: 15,),
                            Text(this.widget.creditCardInfo.cvv, style:TextStyle(fontSize: 20, fontFamily: "Baloo Baihna 2", color: mainWhite,fontWeight: FontWeight.w600 ))
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(right: 15),
                    child: FlareActor('assets/cardIcons/${this.types[this.widget.creditCardInfo.type]}.flr', animation: 'Activate',),
                  )

                ],
              ),
            ),
          )
        )
      ]
    );
  }

}


class CreditForm extends StatefulWidget {
  final Function(CreditCardInfo cardInfo) onChangedCard;
  final Function(CreditCardInfo cardInfo) dropCardOnCancel;
  CreditForm(
    this.onChangedCard,
    this.dropCardOnCancel,
  );

  @override
  _CreditFormState createState() => _CreditFormState();
}

class _CreditFormState extends State<CreditForm> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController  _number = new TextEditingController(),
    _name  = new TextEditingController(), _date  = new TextEditingController(), _cvv = new TextEditingController();
  CreditCardInfo info;
  bool _isLoading = false;
  int _error;
  String _errorS;
  int _selectedIdx = -1;

  List <Color> _colors = [
    Color.fromRGBO(22, 160, 133, 1),
    Color.fromRGBO(39, 174, 96, 1),
    Color.fromRGBO(41, 128, 185, 1),
    Color.fromRGBO(142, 68, 173, 1),
    Color.fromRGBO(44, 62, 80, 1),
    yellowOrange,
    orangePeel,
    Color.fromRGBO(231, 76, 60, 1),
    Color.fromRGBO(192, 57, 43, 1),
    Color.fromRGBO(189, 195, 199, 1),
    Color.fromRGBO(127, 140, 141, 1),
    mainBlack,

  ];

  @override
  void initState() { 
    super.initState();
    _getCard();
    _setListeners();

  }


  void _setListeners(){
    _number.addListener(onChangeNumber);
    _name.addListener((){
      info.cardHoldname = _name.text;
      Provider.of<CreditCardInfo>(context,listen: false).updateInfo(info);
    });
    _date.addListener(onChangeDate);
    _cvv.addListener(() {
      if(_cvv.text.length > 3) {
        _cvv.text = _cvv.text.substring(0,3);
        _cvv.selection = TextSelection.collapsed(offset: 3);
      }else if(_cvv.text.length == 3) {
        if(double.tryParse(_cvv.text) == null){
          _error = 4;
          _errorS = "Debe ser numérico";
        }else {
          _error = 0;
          _errorS = "";
        }
      }

      info.cvv = _cvv.text;
      Provider.of<CreditCardInfo>(context,listen: false).updateInfo(info);
    });
  }

  void _getCard(){
    info = Provider.of<CreditCardInfo>(context,listen: false);
    setState(() => _isLoading = true);
    _name.text = info.cardHoldname;
    _number.text = info.creditNumber;
    _date.text = info.expiryDate;
    _cvv.text = info.cvv;

    setState(() => _isLoading = false);
  }



  Widget _label(int idx) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(right: 8, bottom: 6),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          border: this._selectedIdx == idx ? Border.all(
            color: this._colors[idx],
            width: 8
          ) : null,
          color: this._selectedIdx != idx ? this._colors[idx] : null,
          borderRadius: BorderRadius.circular(6)
        ),
      ),
      onTap: ()  {
        this.setState(() => this._selectedIdx = idx);
        Provider.of<CreditCardInfo>(context,listen:false).color = this._colors[this._selectedIdx];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return _isLoading ? CircularProgressIndicator( valueColor: AlwaysStoppedAnimation(yellowOrange),) 
    :Consumer<CreditCardInfo>(
      builder: (context,card, _) {
        return Scaffold(
          backgroundColor: mainWhite,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              
              SizedBox(height: h*0.1,),
              SingleChildScrollView(
                
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height* 0.05,),
                      Material(
                        elevation: 8,
                        color: Colors.transparent,
                        shadowColor: Color.fromRGBO(250, 250, 250, .5),
                        child: CreditCard(creditCardInfo: Provider.of<CreditCardInfo>(context,listen: true), canEdit: false,)
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: w*0.72,
                        ),
                        child: Center(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                            itemCount: this._colors.length,
                            itemBuilder: (BuildContext context, int index) {
                              return this._label(index);
                            }
                          )
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(15),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[

                              textForm("Nombre",w, _name),
                              textForm("Número de tarjeta",w, _number),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    textForm("Fecha de expiración",w * 0.4, _date),
                                    textForm("CVV",w * 0.4, _cvv)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: h*0.05,),
                      RaisedButton(
                        color: yellowOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Container(
                          width: w*0.72,
                          height: 60,
                          child: Center(child: Text("Confirmar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: "Baloo Baihna 2", color: mainBlack)))
                        ),
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                            this.widget.onChangedCard(Provider.of<CreditCardInfo>(context,listen: false));
                            Navigator.pop(context);
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: -16,
                child: FlatButton(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Text("x", style: TextStyle( color: mainBlack, fontSize: 32, fontWeight: FontWeight.w300)),
                  onPressed: (){
                    this.widget.dropCardOnCancel(info);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
     
      
  }

  Widget textForm(String _labelText, double w, TextEditingController controller) {
    return Container(
      width: w,
      padding: EdgeInsets.symmetric(vertical:8),
      child: new TextFormField(
        autofocus: false,
        enableInteractiveSelection: false,
        style: new TextStyle(fontSize: 20),
        
        controller: controller,
        decoration: InputDecoration(
          
          labelText: _labelText,
          labelStyle: TextStyle(
            fontFamily: "Baloo Baihna 2",
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.black38,
          ),
          focusColor: mainGrey,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: mainGrey
            ),
          ),
        ),
        obscureText: _labelText == 'CVV',
         keyboardType: _labelText == 'Nombre' ? TextInputType.text: TextInputType.number,
            inputFormatters:  [ _labelText != 'Nombre' ?WhitelistingTextInputFormatter(RegExp("[0-9·\ /]")) : WhitelistingTextInputFormatter(RegExp("[a-zA-Z\ ]"))],
        validator: (value) {
          if(value.isEmpty){
            return 'Required';
          }else {
            switch(_error){
              case 1:
                if(_labelText == 'Nombre'){
                  return _errorS;
                }else   return null;
              break;
              case 2: 
                if(_labelText == 'Número de tarjeta'){
                  return _errorS;
                }else return null;
              break;
              case 3: 
                if(_labelText == 'Fecha de expiración'){
                  return _errorS;
                }else return null;
              break;
              case 4:
                if(_labelText == 'CVV'){
                  return _errorS;
                }else return null;
              break;
              default: return null;
              break;
            }
          }
        },
        textInputAction: TextInputAction.next,
        onTap: (){
          if(_labelText=='CVV') Provider.of<CreditCardInfo>(context,listen:false).flipCardBack();
          else Provider.of<CreditCardInfo>(context,listen:false).flipCardUp();
        },
      ),
    );
    
  }


  void onChangeNumber(){
    if(_number.text.length > 19) {
      _number.text  = _number.text.substring(0,19);
      _number.selection = TextSelection.collapsed(offset: 19);
    }
    try {
      if(_number.text[_number.text.length-1] == " "){
        _number.text = _number.text.substring(0, _number.text.length-1);
        _number.selection = TextSelection.collapsed(offset: _number.text.length);
      } else if(_number.text.length == 5 || _number.text.length == 10 || _number.text.length == 15) {
        _number.text = _number.text.substring(0, _number.text.length -1) + ' ' + _number.text.substring(_number.text.length -1, _number.text.length); 
        _number.selection = TextSelection.collapsed(offset: _number.text.length);
      }
    }catch(error){
      print("Long error");
    }


      Map<dynamic, dynamic> cardData =  CreditCardValidator.getCard(_number.text.replaceAll(" ", ""));
      String cardType = cardData[CreditCardValidator.cardType];
      switch(cardType) {
        case "MASTERCARD": 
          info.type = 0;
        break;
        case "VISA": 
          info.type = 1;
        break;
        case "AMEX": 
          info.type = 2;
        break;
        default: 
          
        break;
      }
      if(cardData[CreditCardValidator.isValidCard]){
        setState(() {
          _error = 0;
          _errorS = "";
        });
        
      }else {
        setState(() {
          _error = 2;
          _errorS = "La tarjeta no es valida, reintente";
        });
        
      
    }
    info.creditNumber = _number.text;
    Provider.of<CreditCardInfo>(context,listen: false).updateInfo(info);

  }

  void onChangeDate(){
    if(_date.text.length > 5){
      _date.text = _date.text.substring(0,5);
      _date.selection = TextSelection.collapsed(offset: 5);
    }else if(_date.text[_date.text.length-1]  == "/") {
      _date.text = _date.text.substring(0,2);
      _date.selection = TextSelection.collapsed(offset: 2);
    }else if(_date.text.length == 3) {
      print(_date.text.substring(0,2));
      _date.text  = _date.text.substring(0,2) + "/" + _date.text.substring(2);
      _date.selection = TextSelection.collapsed(offset: _date.text.length);
    }

    if(_date.text.length == 5){
      int month = int.parse( _date.text.substring(0,2));
      int currYear = DateTime.now().year % 100;
      int year = int.parse( _date.text.substring(3,5));

      if(year< currYear) {
        print("year less than current Year");
        setState(() {
          _error = 3;
          _errorS = "Año invalido";
        });
      }else{
        if(month > 12 || month <=0){
          setState(() {
            _error = 3;
            _errorS = "Mes invalido";
          });
        }else {
          setState(() {
            _error = 0;
          });

        }
      }
      
    }
    info.expiryDate = _date.text;
    Provider.of<CreditCardInfo>(context,listen: false).updateInfo(info);
  }



}
