
import 'package:clientsrequests/Tools/Constant.dart';

class Vendor {
  String? name ;
   String? id  ;


 Vendor({ this.name, this.id});
 factory Vendor.fromJson(Map<String  ,dynamic> json){
   return  Vendor(name: json["V_L_NAME"] , id: json["VNDR_ID"])   ;
 }

 @override
 String toString() {
   return 'Vendor{name: $name, id: $id}';
 }
  Map<String,dynamic> insertDb() {
    return {
      VENDOR_NAME: name ,
      VENDOR_ID: id ,


    };
  }

  factory Vendor.fromDB (Map<String  ,dynamic> json ){
    return Vendor(
      id: json [VENDOR_ID] ,
        name: json [VENDOR_NAME]
    );

}
}