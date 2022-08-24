
import 'package:clientsrequests/Tools/Constant.dart';

class Setting  {
  String? currency ;
  bool? priceWTax ;
  double? taxPer  ;
  bool? discountIsPer  ;

  Setting({this.currency, this.priceWTax, this.taxPer, this.discountIsPer});
  factory Setting.fromJsonShared (Map<String  ,dynamic> json ){
    return Setting(
        currency:json[CURRENCY] ,
        priceWTax:json[PRICE_WITH_TAX] ,
        taxPer:json[TAX_PERCENTAGE]  ,
        discountIsPer:json[DISCOUNT_IS_PER] ,

    );
  }
  Map<String, dynamic> toJsonShared( ) {
    return {
      CURRENCY : currency,
      PRICE_WITH_TAX: priceWTax ,
      TAX_PERCENTAGE: taxPer ,
      DISCOUNT_IS_PER: discountIsPer ,

    };
  }

}