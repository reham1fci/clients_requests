
 import 'dart:convert';
import 'dart:io';

import 'package:clientsrequests/Model/User.dart';
import 'package:clientsrequests/Model/Vendor.dart';
 import 'package:clientsrequests/Tools/Constant.dart';
import 'package:device_info/device_info.dart';
 import 'package:http/http.dart'  as http ;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
   Future login({  required String userId ,  required String password  ,  required String orgId, required Function  onLogin  ,
     required Function onError}  )async{
     User mUser =  User.login(userId , password , orgId) ;
     String mobileMacID  = await _getId();
     http.post(Uri.parse(USERS_URL) ,body  : mUser.toMap(mobileMacID) ) .then((http.Response response) {
       print(response)  ;
       print(response.statusCode)  ;
       print(response.body)  ;
       if(response.statusCode == 200) {
         String jsonStr = json.decode(response.body);
         var jsonObj = json.decode(jsonStr);
         String  msg  = jsonObj['Msg']  ;
         print(msg)  ;
         if(msg  == "Success") {
           print(jsonObj) ;
           User c = User.fromJson(jsonObj,userId , password , orgId ) ;
           onLogin(c)  ;
           return c ;
         }
         else
         {
           onError(msg) ;
           return null  ;
         }
       }
       else {
         onError("Connection Error") ;
         return null ;
       }

     }
     );

   }
   Future  getVendor( {  required Function onSuccess ,  required Function onError} ) async {
     SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    User user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
     String mobileID  = await _getId();
     var map = <String, dynamic>{};
     List<Vendor> vendorsList  =  []  ;
     map["Org_id"]= user.orgId;
     map["user_id"]= user.userId;
     map["FuncationType"] =  "GET_VNDR";
     map["Device_Name"] =  mobileID;
     print(map.toString()) ;

     http.post(Uri.parse(INVENTORY_URL) ,body  : map ) .then((http.Response response) {
       if(response.statusCode == 200) {
         String jsonStr = json.decode(response.body);
         var jsonObj = json.decode(jsonStr);
         print(jsonObj.toString()) ;

         var  vendorsArr  = jsonObj['JS_VNDR_DTL']  ;
         for(int i  =  0 ; i  <vendorsArr.length  ; i++) {
           var vendorObj    =  vendorsArr[i]  ;
           Vendor vendor = Vendor.fromJson( vendorObj)  ;
           vendorsList.add(vendor)  ;

         }
         print(vendorsList.toString()) ;

         onSuccess(vendorsList)  ;

       }
       else{
         onError();
       }

     });

   }
   Future<String> _getId() async {
     var deviceInfo = DeviceInfoPlugin();
     if (Platform.isIOS) { // import 'dart:io'
       var iosDeviceInfo = await deviceInfo.iosInfo;
       return iosDeviceInfo.identifierForVendor; // unique ID on iOS
     } else {
       var androidDeviceInfo = await deviceInfo.androidInfo;
       return androidDeviceInfo.androidId; // unique ID on Android
     }
   }
}