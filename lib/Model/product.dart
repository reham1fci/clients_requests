
import 'package:clientsrequests/Tools/Constant.dart';

class  Product {
   String? name  ;
   int? id  ;
   String? unit;
   int? qty ;
   String? barcode;
   double? price ;
   double? tax ;
   double? priceWTax  ;
   double? totalPrice  ; // price_with_tax*qty
   String? pId  ;
   String? date;
   int?reqId  ;

   Product({this.name, this.id, this.unit, this.qty, this.barcode, this.price,
       this.tax, this.priceWTax, this.totalPrice, this.pId, this.date,
       this.reqId});

   Map<String,dynamic> insertDb() {
     return {
       PRODUCT_ID:pId ,
       PRODUCT_DATE:date ,
       PRODUCT_NAME:name  ,
       PRODUCT_UNIT: unit ,
       PRODUCT_PRICE:price ,
       PRODUCT_TAX :tax  ,
       PRICE_WITH_TAX:priceWTax ,
       BARCODE :barcode ,
       PRODUCT_TOTAl:totalPrice ,
       PRODUCT_QTY  :qty  ,
       PRODUCT_REQ_ID: reqId  ,
     };
   }
   factory Product.fromDB (Map<String  ,dynamic> json ){
     return Product(
   priceWTax: double.parse(json[PRICE_WITH_TAX] )  ,
        id: json[PRODUCT_TB_ID] ,
       date: json[PRODUCT_DATE] ,
       name:  json[PRODUCT_NAME],
        unit: json[PRODUCT_UNIT] , price: double.parse( json[PRODUCT_PRICE]) , qty: json[PRODUCT_QTY],
        tax:  double.parse(json[PRODUCT_TAX] ),
        barcode: json[BARCODE] ,
       pId: json[PRODUCT_ID] ,
       reqId: json[PRODUCT_REQ_ID] ,
       totalPrice: double.parse(json[PRODUCT_TOTAl] ),


     );

   }
}