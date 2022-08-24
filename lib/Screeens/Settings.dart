
import 'dart:convert';

import 'package:clientsrequests/Model/Setting.dart';
import 'package:clientsrequests/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';

class Settings extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return  _State();
  }

}
enum discountOp { percentage, amount }

class _State extends State<Settings> {
  TextEditingController taxPercentageEd  =  TextEditingController()  ;
  TextEditingController currencyEd  =  TextEditingController()  ;
  bool? checkedValue = true   ;
  double taxPercentage  =  15.0 ;
  String currencyStr ="ريال"  ;
  Setting? setting;
 late SharedPreferences sharedPrefs ;
  discountOp? _character = discountOp.percentage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSetting() ;

  }
   getSetting () async {
      sharedPrefs = await SharedPreferences.getInstance();
     setting  = Setting.fromJsonShared(json.decode(sharedPrefs.getString("setting") )) ;
setState(() {
  taxPercentageEd.text = setting!.taxPer.toString()  ;
  currencyEd.text =setting!.currency! ;
   checkedValue = setting!.priceWTax  ;
   if(setting!.discountIsPer!){
     _character  =   discountOp.percentage ;
   }
    else{
     _character  =   discountOp.amount ;

   }
});
   }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
        appBar:  AppBar(backgroundColor: MyColors.colorPrimary,),

        body:  Column(
        children: [
          currencyView()  , const Divider() ,
          taxView(),const Divider() ,
          priceTaxCheckBox() , const Divider() ,
          discountView()
          ])
    );
  }
 Widget taxView(){
     return
      Padding(padding: const EdgeInsets.only( left: 20.0  , right: 20.0 , top: 10.0 ) , child:   SizedBox( width: double.infinity, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
    Text(AppLocalizations.of(context)?.translate("tax_per")??"نسبة الضريبة") ,
   SizedBox( width: 100, child:
   TextField(controller:  taxPercentageEd,
     decoration:  const InputDecoration(
       fillColor: MyColors.colorPrimary,
       filled: false,
       enabled: true,

     ) ,onEditingComplete: (){
     setState(() {
       setState(() {
         setting!.taxPer  = double.parse(taxPercentageEd.text) ;
          updateSetting()  ;
       });
     });
     },))
 ],

          ))
      ) ;

}
  Widget currencyView(){
    return
      Padding(padding: const EdgeInsets.only( left: 20.0  , right: 20.0 ,top: 10.0 ) , child:   SizedBox( width: double.infinity, child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalizations.of(context)?.translate("currency")??"العملة") ,
    SizedBox( width: 100, child:

    TextField(controller:  currencyEd,
            decoration:  const InputDecoration(
              fillColor: MyColors.colorPrimary,
              filled: false,
              enabled: true,
            ) ,onEditingComplete: (){
        setState(() {
          setState(() {
            setting!.currency  = currencyEd.text ;
            updateSetting()  ;
          });
        });
      },),
    )
        ],
      )
      )
      ) ;

  }
 Widget priceTaxCheckBox(){
    return CheckboxListTile(
      title:Text(AppLocalizations.of(context)?.translate("price_w_tax")??"السعر شامل الضريبة") ,
      value: checkedValue,
      onChanged: (newValue) {
        setState(() {
          checkedValue = newValue;
          setting!.priceWTax =  checkedValue;
           updateSetting() ;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
    ) ;
 }
  Widget discountView(){
    return Column(
    children: <Widget>[
    ListTile(
    title:  Text(AppLocalizations.of(context)?.translate("discount_per")??""),
    leading: Radio<discountOp>(
    value: discountOp.percentage,
    groupValue: _character,
    onChanged: (discountOp? value) {
    setState(() { _character = value;
    setting!.discountIsPer = true  ;
    updateSetting() ;

    });
    },
    ),
    ),
    ListTile(
    title:  Text(AppLocalizations.of(context)?.translate("discount_amount")??""),
    leading: Radio<discountOp>(
    value: discountOp.amount,
    groupValue: _character,
    onChanged: (discountOp? value) {
    setState(() { _character = value;

    setting!.discountIsPer = false   ;
    updateSetting() ; });
    },
    ),
    ),
    ],
    );
    }
 updateSetting  (){
   sharedPrefs.setString("setting", json.encode(setting!.toJsonShared()) );

 }
}