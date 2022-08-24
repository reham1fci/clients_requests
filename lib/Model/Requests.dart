
import 'package:clientsrequests/Tools/Constant.dart';

class  Requests  {
   int? id  ;
   String? vendorNm ;
   String? vendorID  ;
     String? ref ;
  String? desc ;
   int isSaved = 0 ; // not saved
    String? date  ;

  Requests({this.id, this.vendorNm, this.vendorID, this.ref, this.desc  , required this.isSaved , this.date});


   Map<String,dynamic> insertDb() {
     return {
       VENDOR_NAME: vendorNm ,
       VENDOR_ID: vendorID ,
       REQ_REF : ref,
       REQ_DES :desc ,
       REQ_SAVED:isSaved,
       REQ_DATE  :date


     };
   }
   factory Requests.fromDB (Map<String  ,dynamic> json ){
     return Requests(
         isSaved: json[REQ_SAVED] ,
       date:  json[REQ_DATE],
       vendorNm:  json[VENDOR_NAME],
        vendorID:  json[VENDOR_ID],
        ref:  json[REQ_REF],
       desc: json[REQ_DES] ,
       id:  json[REQ_ID],
     );

   }
}