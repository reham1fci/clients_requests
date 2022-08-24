
import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:clientsrequests/DataBase/DatabaseHelper.dart';
import 'package:clientsrequests/Model/Requests.dart';
import 'package:clientsrequests/Model/Setting.dart';
import 'package:clientsrequests/Model/product.dart';
import 'package:clientsrequests/Tools/Constant.dart';
import 'package:clientsrequests/Tools/MethodsTools.dart';
import 'package:clientsrequests/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';

class NewProduct extends StatefulWidget{
  Requests? myRequest ;
  Product? product  ;

  NewProduct(this.myRequest,this.product ,  {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return  _State();
  }

}
class _State extends State<NewProduct> {
  TextEditingController pNmEd  =  TextEditingController()  ;
  TextEditingController pIdEd  =  TextEditingController()  ;
  TextEditingController pUnitEd  =  TextEditingController()  ;
  TextEditingController pPriceEd  =  TextEditingController()  ;
  TextEditingController pTaxEd  =  TextEditingController()  ;
  TextEditingController pQtyEd  =  TextEditingController()  ;
  TextEditingController pPriceTaxEd  =  TextEditingController()  ;
  TextEditingController pTotalEd  =  TextEditingController()  ;
  TextEditingController barcodeEd  =  TextEditingController()  ;
  final dbHelper = DatabaseHelper.instance;

  //String pBarcode  = "" ;
   Methods mTools = Methods()  ;
    bool? isEdit = false ;
   Requests? _request  ;
  Setting? setting ;
  bool priceWTaxEnable =true ;
  bool priceEnable  = false ;
  bool taxWTotalEnable  = false ;
  double priceWTax  = 0.0 ;
  double price  = 0.0 ;
  double tax  = 0.0 ;
   Product? edProduct  ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _request  = widget.myRequest  ;
    edProduct  = widget.product  ;
    if(edProduct !=null ) {
      isEdit  = true  ;
      pNmEd.text = edProduct!.name!  ;
      pIdEd.text = edProduct!.pId!  ;
      pUnitEd.text  =  edProduct!.unit!  ;
      pPriceEd.text  =  edProduct!.price!.toString()  ;
      pTaxEd.text  =  edProduct!.tax!.toString()  ;
      pPriceTaxEd.text  =  edProduct!.priceWTax!.toString()  ;
      pQtyEd.text  =  edProduct!.qty!.toString()  ;
      pTotalEd.text  =  edProduct!.totalPrice!.toString()  ;
      barcodeEd.text  = edProduct!.barcode!  ;
    }
   getSetting()  ;
  }
  getSetting () async {
   SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    setting  = Setting.fromJsonShared(json.decode(sharedPrefs.getString("setting") )) ;
    //setting!.priceWTax = false ;
   if(setting!.priceWTax!){
     setState(() {
       priceWTaxEnable = true  ;
       priceEnable  = false  ;
     });

   }

   else{
     setState(() {
       priceWTaxEnable = false  ;
       priceEnable  = true  ;
     });
   }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
        appBar:  AppBar(backgroundColor: MyColors.colorPrimary,),

        body:            SingleChildScrollView(
      child:  Column(
          children: [
            barcodeView(),
          const Padding(padding:  EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) , child:   Divider(color: Colors.black54,)) ,
            productNameView(),
            productNumView() ,
            productUnitView(),
            productQtyV(),
             priceV() ,
            taxV() ,
            priceWTaxV(),
            totalView()
          ],
        )
        ) ,
        bottomNavigationBar: BottomAppBar(color: MyColors.colorPrimary,

            child :TextButton(child:  Text(AppLocalizations.of(context)?.translate("save") ?? "save" ,style: const TextStyle(color: MyColors.white), ),
          onPressed: saveProductLocal,)

        )
    );
  }

   saveProductLocal()async{
     if(isValidate()) {
  if(pTaxEd.text.isEmpty){
       if(setting!.priceWTax!) {
         setState(() {
           print("done") ;
           priceWTax = double.parse(pPriceTaxEd.text) ;
           price  = (priceWTax  *100) /(100+setting!.taxPer!) ;
           tax  =  priceWTax - price  ;
           pPriceEd.text  = price.toStringAsFixed(2) ;
           pTaxEd.text  = tax.toStringAsFixed(2) ;
           if(pQtyEd.text.isNotEmpty) {
             double total = (int.parse(pQtyEd.text))*priceWTax ;
             pTotalEd.text = total.toStringAsFixed(2)  ;
           }
         });
       }
       else{
          setState(() {
         price =  double.parse(pPriceEd.text)   ;
         tax  = price  *  (setting!.taxPer!/100)  ;
         priceWTax =  price+tax  ;
         pTaxEd.text  =  tax.toStringAsFixed(2)  ;
         pPriceTaxEd.text  =  priceWTax.toStringAsFixed(2)  ;
         if(pQtyEd.text.isNotEmpty) {
           double total = (int.parse(pQtyEd.text))*priceWTax ;
           pTotalEd.text = total.toStringAsFixed(2)  ;
         }
          });
       }}
       var now =  DateTime.now();
       var formatter =  DateFormat("EEE, MMM d, yyyy","en");
       String formattedDate = formatter.format(now);
       print( formattedDate)  ;
       Product p  = Product(totalPrice:  double.parse(pTotalEd.text ) ,
           reqId: _request!.id,
           barcode: barcodeEd.text ,
           tax:  double.parse(pTaxEd.text ) ,
           qty:  int.parse(pQtyEd.text ), price: double.parse(pPriceEd.text )
            , unit:  pUnitEd.text,
           name: pNmEd.text , date: formattedDate ,pId: pIdEd.text ,
           priceWTax:  double.parse(pPriceTaxEd.text )) ;
       if (isEdit!){
         final  id = await dbHelper.updateProductTb(p.insertDb(), edProduct!.id!);

         Navigator.of(context).pop();
       }
       else{
         final id = await dbHelper.insert(p.insertDb() , PRODUCT_TB , err: (e   ){
           print (e.toString());});
         print(id) ;
         p.id = id  ;
         Navigator.of(context).pop();
       }



       // done
       // finish
       //


     }
     else{
     mTools.Dialog(context: context, title: AppLocalizations.of(context)?.translate("error")??"",
         message: AppLocalizations.of(context)?.translate("fill_data")??"", isCancelBtn: false ,onCancelClick:  (){} , onOkClick: (){})  ;


     }

   }
  bool  isValidate(){
    if(pQtyEd.text.isEmpty){
      return false   ;
    }
    if(pNmEd.text.isEmpty) {
      return false  ;
    }
     if(pUnitEd.text.isEmpty) {
       return false  ;
     }
      if(pIdEd.text.isEmpty ) {
        return false  ;
      } if(barcodeEd.text.isEmpty) {
        return false  ;
    }
    if(setting!.priceWTax!){
    if(pPriceTaxEd.text.isEmpty){ return false ; }
    }
    else{
      if(pPriceEd.text.isEmpty){ return false ; }
    }
     return true ;
  }
 Widget barcodeView(){
   return  Padding(padding: const EdgeInsets.only( left: 30.0  , right: 30.0 , top: 8.0) ,
     child:    SizedBox( width: double.infinity, child: Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
       SizedBox( width: 100, child:   TextField(controller:  barcodeEd,
         decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.translate("product_barcode") ,
           fillColor: Colors.white,
           filled: false,
           enabled: true,
           border: InputBorder.none

           // prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
         ),
     )),
       IconButton(onPressed: scan, icon: Image.asset('images/barcode_icon.png',))
       ],

     )
     )
   ) ;

}
  Future scan() async {
    try {
      ScanResult qrScanResult = await BarcodeScanner.scan();
      String barcode = qrScanResult.rawContent;
      setState(()  {
        //loading  = true ;
        barcodeEd.text = barcode;
        //print("barcode"+pBarcode) ;
        barcode  = barcode  ;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          barcodeEd.text = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() =>  barcodeEd.text= 'Unknown error: $e');
      }
    } on FormatException{
      setState(() =>   barcodeEd.text= 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() =>   barcodeEd.text = 'Unknown error: $e');
    }
  }

Widget productNameView(){
   return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
     child:   TextField(controller:  pNmEd,
         decoration: InputDecoration(
           hintText: AppLocalizations.of(context)?.translate("product_name") ,
           fillColor: Colors.white,
           filled: false,
           enabled: true,
          // prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
         )
     ),)
   ;
}
Widget productUnitView(){
   return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
     child:   TextField(controller:  pUnitEd,
         decoration: InputDecoration(
           hintText: AppLocalizations.of(context)?.translate("product_unit") ,
           fillColor: Colors.white,
           filled: false,
           enabled: true,
         //  prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
         )
     ),)

   ;

}
  Widget productNumView(){
    return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
      child:   TextField(controller:  pIdEd,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.translate("product_num") ,
            fillColor: Colors.white,
            filled: false,
            enabled: true,
           // prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
          )
      ),)

    ;

  }Widget productQtyV(){
    return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
      child:   TextField(controller:  pQtyEd,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.translate("product_qty") ,
            fillColor: Colors.white,
            filled: false,
            enabled: true,
           // prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
          )
      ),)

    ;

  }
  Widget priceV(){
    return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
      child:   TextField(controller:  pPriceEd,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.translate("product_price") ,
            fillColor: Colors.white,
            filled: false,
            enabled: priceEnable,

           // prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
          ) ,
         onEditingComplete: (){
        setState(() {


        price =  double.parse(pPriceEd.text)   ;
        tax  = price  *  (setting!.taxPer!/100)  ;
         priceWTax =  price+tax  ;
         pTaxEd.text  =  tax.toStringAsFixed(2)  ;
        pPriceTaxEd.text  =  priceWTax.toStringAsFixed(2)  ;
        if(pQtyEd.text.isNotEmpty) {
          double total = (int.parse(pQtyEd.text))*priceWTax ;
          pTotalEd.text = total.toStringAsFixed(2)  ;
        }
          });},
      ),)

    ;

  } Widget taxV(){
    return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
      child:   TextField(controller:  pTaxEd,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.translate("product_tax") ,
            fillColor: Colors.white,
            filled: false,
            enabled: false,
           // prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
          )
      ),)

    ;

  } Widget priceWTaxV(){
    return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
      child:   TextField(controller:  pPriceTaxEd,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.translate("price_w_tax") ,
            fillColor: Colors.white,
            filled: false,
            enabled: priceWTaxEnable,

            //prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
          ) ,
           onEditingComplete: (){
         setState(() {
            print("done") ;
priceWTax = double.parse(pPriceTaxEd.text) ;
price  = (priceWTax  *100) /(100+setting!.taxPer!) ;
tax  =  priceWTax - price  ;
pPriceEd.text  = price.toStringAsFixed(2);
pTaxEd.text  = tax.toStringAsFixed(2) ;
 if(pQtyEd.text.isNotEmpty) {
   double total = (int.parse(pQtyEd.text))*priceWTax ;
   pTotalEd.text = total.toStringAsFixed(2)  ;
 }
         });
      },
      ),)

    ;

  } Widget totalView(){
    return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
      child:   TextField(controller:  pTotalEd,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.translate("product_total") ,
            fillColor: Colors.white,
            filled: false,
            enabled: false,
           // prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
          )
      ),)

    ;

  }
}