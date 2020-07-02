import 'dart:math';
import 'package:credit_card_number_validator/credit_card_number_validator.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './utils/Colors.dart';
import 'package:provider/provider.dart';

enum CardType {
  none,
  credit,
  paypal,
  prepay,
}

class CreditCardInfo extends ChangeNotifier {
  int id;
  final double width;
  final double height;
  String cardHoldname;
  String creditNumber;
  String credit;
  String email;
  String cvv;
  String expiryDate;
  int type;
  Color color;
  bool flipped;
  CardType cardtype;

  CreditCardInfo({
    @required this.id,
    @required this.cardHoldname,
    @required this.creditNumber,
    @required this.cvv,
    @required this.expiryDate,
    @required this.cardtype,
    this.type,
    this.width,
    this.height,
    this.color,
    this.flipped,
  });

  CreditCardInfo.prepay({
    @required this.id,
    @required this.cardHoldname,
    @required this.expiryDate,
    @required this.cardtype,
    @required this.credit,
    this.width,
    this.height,
    this.color,
  });

  CreditCardInfo.empty(
      {this.id = 0,
      this.cardHoldname = '',
      this.creditNumber = '',
      this.cvv = '',
      this.expiryDate = '',
      this.height,
      this.width,
      this.cardtype = CardType.credit,
      this.email = '',
      this.credit = '',
      this.color = Colors.black,
      this.type = 0});

  bool _flipCard = false;

  void updateInfo(CreditCardInfo card) {
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
  final String language;

  CreditCard(
      {@required this.creditCardInfo,
      this.width,
      this.height,
      this.canEdit = true,
      this.onChangeCard,
      this.createCard,
      this.language = 'es'});

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  List<String> types = ['mastercard', 'visa', 'amex'];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = Tween<double>(end: 1, begin: 0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });
  }

  @override
  Widget build(BuildContext context) {
    final double w =
        this.widget.width ?? MediaQuery.of(context).size.width * 0.72;
    final double h =
        this.widget.height ?? MediaQuery.of(context).size.width * 0.45;

    return Consumer<CreditCardInfo>(builder: (context, card, _) {
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
              onTap: () {
                if (_animationStatus == AnimationStatus.dismissed &&
                    this.widget.creditCardInfo.cardtype == CardType.credit) {
                  Provider.of<CreditCardInfo>(context, listen: false)
                      .flipCardBack();
                } else if (this.widget.creditCardInfo.cardtype ==
                    CardType.credit)
                  Provider.of<CreditCardInfo>(context, listen: false)
                      .flipCardUp();
              },
              onLongPress: () {
                if (this.widget.canEdit) {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      child: WillPopScope(
                          onWillPop: () async => false,
                          child: ChangeNotifierProvider.value(
                              value: card,
                              child: CreditForm(
                                this.widget.onChangeCard,
                                (_) {},
                                language: this.widget.language,
                              ))));
                }
              },
              child: Consumer<CreditCardInfo>(
                builder: (ctx, prov, _) {
                  if (prov._flipCard &&
                      _animationStatus == AnimationStatus.dismissed)
                    _animationController.forward();
                  else if (!prov._flipCard) _animationController.reverse();
                  return animation.value <= 0.5
                      ? Stack(
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
                              width: w - 30,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 50,
                                    height: 50,
                                    child: FlareActor(
                                      prov.cardtype == CardType.credit
                                          ? 'assets/cardIcons/${types[this.widget.creditCardInfo.type]}.flr'
                                          : prov.cardtype == CardType.paypal
                                              ? 'assets/cardIcons/PayPal.flr'
                                              : 'assets/cardIcons/Prepay.flr',
                                      animation: "Activate",
                                    ),
                                  ),
                                  prov.cardtype == CardType.credit
                                      ? Center(
                                          child: Text(
                                          this
                                                  .widget
                                                  .creditCardInfo
                                                  .creditNumber ??
                                              '',
                                          style: TextStyle(
                                              fontFamily: "kredit",
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                              color: Color.fromRGBO(
                                                  230, 230, 230, 1),
                                              letterSpacing: w * 0.01),
                                          textAlign: TextAlign.center,
                                        ))
                                      : prov.cardtype == CardType.paypal
                                          ? Center(
                                              child: Text(
                                              this
                                                      .widget
                                                      .creditCardInfo
                                                      .email ??
                                                  '',
                                              style: TextStyle(
                                                  fontFamily: "Baloo Baihna 2",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18,
                                                  color: Color.fromRGBO(
                                                      230, 230, 230, 1),
                                                  letterSpacing: w * 0.01),
                                              textAlign: TextAlign.center,
                                            ))
                                          : Center(
                                              child: Text(
                                              this
                                                      .widget
                                                      .creditCardInfo
                                                      .credit ??
                                                  '',
                                              style: TextStyle(
                                                  fontFamily: "Baloo Baihna 2",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18,
                                                  color: Color.fromRGBO(
                                                      230, 230, 230, 1),
                                                  letterSpacing: w * 0.01),
                                              textAlign: TextAlign.center,
                                            )),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      ConstrainedBox(
                                          constraints:
                                              BoxConstraints(maxWidth: w * 0.6),
                                          child: Text(
                                              this
                                                      .widget
                                                      .creditCardInfo
                                                      .cardHoldname ??
                                                  '',
                                              style: TextStyle(
                                                  fontFamily: "Baloo Baihna 2",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: Colors.grey))),
                                      prov.cardtype == CardType.prepay ||
                                              prov.cardtype == CardType.credit
                                          ? Text(
                                              this
                                                      .widget
                                                      .creditCardInfo
                                                      .expiryDate ??
                                                  '',
                                              style: TextStyle(
                                                  fontFamily: "Baloo Baihna 2",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18,
                                                  color: mainWhite))
                                          : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      : prov.cardtype == CardType.credit
                          ? _backCard(w, h)
                          : Container();
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _backCard(w, h) {
    return Stack(alignment: Alignment.center, children: <Widget>[
      Positioned(
        top: 0,
        left: 0,
        height: h,
        width: w,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Provider.of<CreditCardInfo>(context, listen: false).color),
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
              transform: Matrix4.identity()..rotateY(pi),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    height: h * 0.2,
                    decoration: BoxDecoration(color: Colors.black),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                            width: w * 0.5, height: h * 0.1, color: mainWhite),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text("cvv",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: "Baloo Baihna 2",
                                    color: Color.fromRGBO(230, 230, 230, 1),
                                    fontWeight: FontWeight.w200)),
                            SizedBox(
                              width: 15,
                            ),
                            Text(this.widget.creditCardInfo.cvv,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: "Baloo Baihna 2",
                                    color: mainWhite,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(right: 15),
                    child: FlareActor(
                      'assets/cardIcons/${this.types[this.widget.creditCardInfo.type]}.flr',
                      animation: 'Activate',
                    ),
                  )
                ],
              ),
            ),
          ))
    ]);
  }
}

class CreditForm extends StatefulWidget {
  final Function(CreditCardInfo cardInfo) onChangedCard;
  final Function(CreditCardInfo cardInfo) dropCardOnCancel;
  final Future Function(String code) validateCode;
  final int codeLength;
  final String language;
  CreditForm(this.onChangedCard, this.dropCardOnCancel,
      {this.validateCode, this.codeLength, this.language});

  @override
  _CreditFormState createState() => _CreditFormState();
}

class _CreditFormState extends State<CreditForm> {
  final _formKey = GlobalKey<FormState>();
  String language;
  TextEditingController _number = new TextEditingController(),
      _name = new TextEditingController(text: ''),
      _date = new TextEditingController(text: ''),
      _cvv = new TextEditingController(text: ''),
      _email = new TextEditingController(text: ''),
      _code = new TextEditingController(text: '');

  CreditCardInfo info;
  bool _isLoading = false;
  int _error;
  String _errorS;
  int _selectedIdx = -1;

  List<Color> _colors = [
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
    this.language = this.widget.language ?? 'es';
    _getCard();
    _setListeners();
  }

  void _setListeners() {
    _number.addListener(onChangeNumber);
    _name.addListener(() {
      info.cardHoldname = _name.text;
      Provider.of<CreditCardInfo>(context, listen: false).updateInfo(info);
    });
    _email.addListener(() {
      info.email = _email.text;
      Provider.of<CreditCardInfo>(context, listen: false).updateInfo(info);
    });
    _code.addListener(() async {
      setState(() {
        _isLoading = false;
      });
      if (_code.text.length > this.widget.codeLength) {
        _code.text = _code.text.substring(0, this.widget.codeLength);
        _code.selection = TextSelection.collapsed(offset: _code.text.length);
      } else if (_code.text.length == this.widget.codeLength) {
        try {
          setState(() {
            _isLoading = true;
          });
          Map<String, String> codeValues =
              await this.widget.validateCode(_code.text);
          info.cardHoldname = codeValues['name'];
          info.expiryDate = codeValues['expiryDate'];
          info.credit = codeValues['credit'];
          Provider.of<CreditCardInfo>(context, listen: false).updateInfo(info);
          setState(() {
            _isLoading = false;
          });
        } catch (error) {}
      } else {
        info.credit = this.language == 'es' ? 'Invalido' : "Not valid";
        Provider.of<CreditCardInfo>(context, listen: false).updateInfo(info);
      }
    });
    _date.addListener(onChangeDate);
    _cvv.addListener(() {
      if (_cvv.text.length > 3) {
        _cvv.text = _cvv.text.substring(0, 3);
        _cvv.selection = TextSelection.collapsed(offset: 3);
      } else if (_cvv.text.length == 3) {
        if (double.tryParse(_cvv.text) == null) {
          _error = 4;
          _errorS =
              this.language == "es" ? "Debe ser numérico" : 'Must be numeric';
        } else {
          _error = 0;
          _errorS = "";
        }
      }

      info.cvv = _cvv.text;
      Provider.of<CreditCardInfo>(context, listen: false).updateInfo(info);
    });
  }

  void _getCard() {
    info = Provider.of<CreditCardInfo>(context, listen: false);
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
            border: this._selectedIdx == idx
                ? Border.all(color: this._colors[idx], width: 8)
                : null,
            color: this._selectedIdx != idx ? this._colors[idx] : null,
            borderRadius: BorderRadius.circular(6)),
      ),
      onTap: () {
        this.setState(() => this._selectedIdx = idx);
        Provider.of<CreditCardInfo>(context, listen: false).color =
            this._colors[this._selectedIdx];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Consumer<CreditCardInfo>(builder: (context, card, _) {
      return Scaffold(
        backgroundColor: mainWhite,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SizedBox(
              height: h * 0.1,
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    _isLoading
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.72,
                            height: MediaQuery.of(context).size.width * 0.45,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(yellowOrange),
                              ),
                            ),
                          )
                        : Material(
                            elevation: 8,
                            color: Colors.transparent,
                            shadowColor: Color.fromRGBO(250, 250, 250, .5),
                            child: CreditCard(
                              creditCardInfo: Provider.of<CreditCardInfo>(
                                  context,
                                  listen: true),
                              canEdit: false,
                            )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: w * 0.72,
                      ),
                      child: Center(
                          child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  new SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8),
                              itemCount: this._colors.length,
                              itemBuilder: (BuildContext context, int index) {
                                return this._label(index);
                              })),
                    ),
                    Container(
                      margin: EdgeInsets.all(15),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: info.cardtype == CardType.credit
                              ? <Widget>[
                                  textForm(
                                      this.language == 'es' ? "Nombre" : "Name",
                                      w,
                                      _name),
                                  textForm(
                                      this.language == 'es'
                                          ? "Número de tarjeta"
                                          : 'Card Number',
                                      w,
                                      _number),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        textForm(
                                            this.language == 'es'
                                                ? "Fecha de expiración"
                                                : "Valid Thru",
                                            w * 0.4,
                                            _date),
                                        textForm("CVV", w * 0.4, _cvv)
                                      ],
                                    ),
                                  )
                                ]
                              : info.cardtype == CardType.paypal
                                  ? <Widget>[
                                      emailTextForm(w),
                                      passwordTextForm(w),
                                    ]
                                  : <Widget>[codeTextForm(w)],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.05,
                    ),
                    RaisedButton(
                      color: yellowOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Container(
                          width: w * 0.72,
                          height: 60,
                          child: Center(
                              child: Text(
                                  this.language == "es"
                                      ? "Confirmar"
                                      : "Confirm",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Baloo Baihna 2",
                                      color: mainBlack)))),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          this.widget.onChangedCard(Provider.of<CreditCardInfo>(
                              context,
                              listen: false));
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
                child: Text("x",
                    style: TextStyle(
                        color: mainBlack,
                        fontSize: 32,
                        fontWeight: FontWeight.w300)),
                onPressed: () {
                  this.widget.dropCardOnCancel(info);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget passwordTextForm(double w) {
    return Container(
      width: w,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: new TextFormField(
        autofocus: false,
        enableInteractiveSelection: false,
        style: new TextStyle(fontSize: 20),
        controller: _code,
        decoration: InputDecoration(
          labelText: this.language == "es" ? 'Contraseña' : "Password",
          labelStyle: TextStyle(
            fontFamily: "Baloo Baihna 2",
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.black38,
          ),
          focusColor: mainGrey,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: mainGrey),
          ),
        ),
        keyboardType: TextInputType.text,
        obscureText: true,
        validator: (value) {
          if (value.isEmpty) {
            return this.language == "es" ? 'Obligatorio' : 'Required';
          } else {
            return null;
          }
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget codeTextForm(double w) {
    return Container(
      width: w,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: new TextFormField(
        autofocus: false,
        enableInteractiveSelection: false,
        style: new TextStyle(fontSize: 20),
        controller: _code,
        decoration: InputDecoration(
          labelText: this.language == "es" ? 'Código' : "Code",
          labelStyle: TextStyle(
            fontFamily: "Baloo Baihna 2",
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.black38,
          ),
          focusColor: mainGrey,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: mainGrey),
          ),
        ),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value.isEmpty) {
            return this.language == "es" ? 'Obligatorio' : 'Required';
          } else {
            return null;
          }
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget emailTextForm(double w) {
    return Container(
      width: w,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: new TextFormField(
        autofocus: false,
        enableInteractiveSelection: false,
        style: new TextStyle(fontSize: 20),
        controller: _email,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(
            fontFamily: "Baloo Baihna 2",
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.black38,
          ),
          focusColor: mainGrey,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: mainGrey),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value.isEmpty) {
            return this.language == "es" ? 'Obligatorio' : 'Required';
          } else {
            Pattern pat =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp exp = new RegExp(pat);
            if (!exp.hasMatch(value)) {
              return this.language == "es"
                  ? "Email invalido"
                  : 'Email is invalid';
            }
            return null;
          }
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget textForm(
      String _labelText, double w, TextEditingController controller) {
    return Container(
      width: w,
      padding: EdgeInsets.symmetric(vertical: 8),
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
            borderSide: BorderSide(color: mainGrey),
          ),
        ),
        obscureText: _labelText == 'CVV',
        keyboardType: (_labelText == 'Nombre' || _labelText == 'Name')
            ? TextInputType.text
            : TextInputType.number,
        inputFormatters: [
          (_labelText != 'Nombre' && _labelText != 'Name')
              ? FilteringTextInputFormatter.allow(RegExp("[0-9·\ /]"))
              : FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\ ]"))
        ],
        validator: (value) {
          if (value.isEmpty) {
            return this.language == "es" ? "Obligatorio" : 'Required';
          } else {
            switch (_error) {
              case 1:
                if (_labelText == 'Nombre' || _labelText == 'Name') {
                  return _errorS;
                } else
                  return null;
                break;
              case 2:
                if (_labelText == 'Número de tarjeta' ||
                    _labelText == 'Card Number') {
                  return _errorS;
                } else
                  return null;
                break;
              case 3:
                if (_labelText == 'Fecha de expiración' ||
                    _labelText == 'Valid Thru') {
                  return _errorS;
                } else
                  return null;
                break;
              case 4:
                if (_labelText == 'CVV') {
                  return _errorS;
                } else
                  return null;
                break;
              default:
                return null;
                break;
            }
          }
        },
        textInputAction: TextInputAction.next,
        onTap: () {
          if (_labelText == 'CVV')
            Provider.of<CreditCardInfo>(context, listen: false).flipCardBack();
          else
            Provider.of<CreditCardInfo>(context, listen: false).flipCardUp();
        },
      ),
    );
  }

  void onChangeNumber() {
    if (_number.text.length > 19) {
      _number.text = _number.text.substring(0, 19);
      _number.selection = TextSelection.collapsed(offset: 19);
    }
    try {
      if (_number.text[_number.text.length - 1] == " ") {
        _number.text = _number.text.substring(0, _number.text.length - 1);
        _number.selection =
            TextSelection.collapsed(offset: _number.text.length);
      } else if (_number.text.length == 5 ||
          _number.text.length == 10 ||
          _number.text.length == 15) {
        _number.text = _number.text.substring(0, _number.text.length - 1) +
            ' ' +
            _number.text
                .substring(_number.text.length - 1, _number.text.length);
        _number.selection =
            TextSelection.collapsed(offset: _number.text.length);
      }
    } catch (error) {
      print("Long error");
    }

    Map<dynamic, dynamic> cardData =
        CreditCardValidator.getCard(_number.text.replaceAll(" ", ""));
    String cardType = cardData[CreditCardValidator.cardType];
    switch (cardType) {
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
    if (cardData[CreditCardValidator.isValidCard]) {
      setState(() {
        _error = 0;
        _errorS = "";
      });
    } else {
      setState(() {
        _error = 2;
        _errorS = this.language == 'es'
            ? "La tarjeta no es valida, reintente"
            : 'Invalid card number, retry';
      });
    }
    info.creditNumber = _number.text;
    Provider.of<CreditCardInfo>(context, listen: false).updateInfo(info);
  }

  void onChangeDate() {
    if (_date.text.length > 5) {
      _date.text = _date.text.substring(0, 5);
      _date.selection = TextSelection.collapsed(offset: 5);
    } else if (_date.text[_date.text.length - 1] == "/") {
      _date.text = _date.text.substring(0, 2);
      _date.selection = TextSelection.collapsed(offset: 2);
    } else if (_date.text.length == 3) {
      print(_date.text.substring(0, 2));
      _date.text = _date.text.substring(0, 2) + "/" + _date.text.substring(2);
      _date.selection = TextSelection.collapsed(offset: _date.text.length);
    }

    if (_date.text.length == 5) {
      int month = int.parse(_date.text.substring(0, 2));
      int currYear = DateTime.now().year % 100;
      int year = int.parse(_date.text.substring(3, 5));

      if (year < currYear) {
        print("year less than current Year");
        setState(() {
          _error = 3;
          _errorS = this.language == 'es' ? "Año invalido" : 'Invalid Year';
        });
      } else {
        if (month > 12 || month <= 0) {
          setState(() {
            _error = 3;
            _errorS = this.language == 'es' ? "Mes invalido" : 'Invalid Month';
          });
        } else {
          setState(() {
            _error = 0;
          });
        }
      }
    }
    info.expiryDate = _date.text;
    Provider.of<CreditCardInfo>(context, listen: false).updateInfo(info);
  }
}
