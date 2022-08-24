import 'dart:convert';
import 'package:clientsrequests/DataBase/DatabaseHelper.dart';
import 'package:clientsrequests/Model/Setting.dart';
import 'package:clientsrequests/Model/User.dart';
import 'package:clientsrequests/Model/Vendor.dart';
import 'package:clientsrequests/Screeens/RequestsList.dart';
import 'package:clientsrequests/Tools/Constant.dart';
import 'package:clientsrequests/Tools/MethodsTools.dart';
import 'package:clientsrequests/WebServices/Api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import '../my_colors.dart';

class Login  extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return   LoginState()  ;
  }

}
class LoginState  extends State<Login>{
  TextEditingController userNameEd  =  TextEditingController()  ;
  TextEditingController passEd  =  TextEditingController()  ;
  TextEditingController orgEd  =  TextEditingController()  ;
  String nameError ="" , passError = ""  , orgIdError="" ;
 late SharedPreferences sharedPrefs ;
   final  dbHelper = DatabaseHelper.instance;
  bool loading = false ;
 Api api  =  Api();
  bool isFirstLogin  = true  ;
  bool configFound  = false  ;
  bool invoicesFound  = false  ;
   Methods methodsTool = Methods() ;
  late User  user;
  bool  loginDataEnable  = true ;
  bool  connectionData  = false ;
  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
     }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      appBar:  AppBar(backgroundColor: MyColors.colorPrimary,),

      body:   Center(

  child:   Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             loading? const Center(
               child: CircularProgressIndicator(),
             ): const SizedBox(),
               Image.asset('images/logo.png'  , height: 100, width: 150,),
             orgIdEdFun(),
             userNameEdFun(),
             passEdFun(),
             loginBtn(),


           ],)),
    )  ;
  }
  void onLoginBtn() {
    methodsTool.checkInternet(onConnect: () {
    setState(() {
      String userId  = userNameEd.text ;
      String password  = passEd.text ;
      String orgId     =  orgEd.text ;
      setState(() {
        bool isValidate =   loginValidation(userId ,password , orgId)  ;
        if(isValidate){
          loading = true  ;
           api.login(userId:userId , orgId:orgId , onError:  onError, onLogin:
          onLogin, password: password) ;
        }
        else{
          onError(AppLocalizations.of(context)?.translate("fill_data")??"error")  ;
        }
      });

    });
    },notConnect: (){onError(AppLocalizations.of(context)?.translate("no_internet")??" No Internet Connection") ;}) ;
  }
  void onLogin (User  user ) {
    setState(() {
      loading = false ;
      print(user.toString());
      saveUserData(user);
      Navigator.pushReplacement( context,
          MaterialPageRoute(builder: (context) => RequestsList())) ;
    });
  }
  void saveUserData (User user )async {
    sharedPrefs = await SharedPreferences.getInstance();
    user.isSellingPriceView = true ;
    user.isCostPriceView  = false  ;
    Setting setting  = Setting(currency:"ريال"  , discountIsPer: true , priceWTax:false , taxPer:15.0 ) ;
    sharedPrefs.setString("setting", json.encode(setting.toJsonShared()) );

    sharedPrefs.setString("user", json.encode(user.toJson()) );
    api.getVendor(onSuccess:(List<Vendor> vendorsList  ){
      dbHelper.insertVendors(vendorsList, VENDOR_TB ,  err: (e) {
        {
          print(e.toString());
        }
      } , onSuccess: ( value){
        print(value) ;
      }) ;

      /* for(int i  =  0  ;  i  < vendorsList.length  ;  i  ++) {
            Vendor  vendor  =  vendorsList[i] ;
           dbHelper.insert(vendor.insertDb(), VENDOR_TB ,  err: (e){
             print (e.toString()) ;
           }) ;
         }*/

    }
        ,onError:(){



        }) ;
  }
  Future<void> onError(String message ) async {
    setState(() {
      loading = false ;
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate("error") ?? "error"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  bool loginValidation (String name  , String password , String orgId){
    if(name.isEmpty) {
      return false  ;
    }
    else if(password.isEmpty){
      return false  ;
    }
    else if(orgId.isEmpty){
      return false  ;
    }
    else{
      return true ;}

  }



  Padding loginBtn() {
    return  Padding (padding: const EdgeInsets.only(bottom: 8.0 , left: 40.0  , right: 40.0 , top: 8.0),child: Container(
      decoration:  const BoxDecoration(color:MyColors.colorPrimary
          , borderRadius:   BorderRadius.all(
             Radius.circular(8.0),)
      ),
      width  :   double.infinity,
      child  :    TextButton(
        onPressed: onLoginBtn ,
        child:  Text(AppLocalizations.of(context)?.translate("login") ??"", style:   const TextStyle(color: Colors.white),),
      ) ,
    ) )
    ;
  }

  Padding userNameEdFun() {
    return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
      child:   TextField(controller:  userNameEd,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.translate("user_name") ,
            fillColor: Colors.white,
            filled: false,
            enabled: loginDataEnable,
            errorText: nameError,
            prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
          )
      ),)

    ;
  }
  Padding orgIdEdFun() {
    return  Padding(padding: const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
      child:   TextField(controller:  orgEd,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.translate("org_id") ,
            fillColor: Colors.white,
            filled: false,
            enabled: loginDataEnable,
            errorText: orgIdError,
            prefixIcon:Image.asset('images/user_icon.png',color: MyColors.colorPrimary) ,
          )
      ),)

    ;
  }
  Padding passEdFun() {
    return   Padding(padding:const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
        child:
         TextField(controller:  passEd,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.translate("password"),
            fillColor: Colors.white,
            filled: false,
            errorText: passError,
            enabled: loginDataEnable,
            prefixIcon:Image.asset('images/pass_icon.png' ,color: MyColors.colorPrimary,) ,
          ) ,) )
    ;
  }

}