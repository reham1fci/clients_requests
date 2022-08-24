import 'dart:convert';

import 'package:clientsrequests/Model/User.dart';
import 'package:clientsrequests/Screeens/ProductsList.dart';
import 'package:clientsrequests/Screeens/RequestsList.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import '../my_colors.dart';
import 'Login.dart';

class Splash extends StatefulWidget {

  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<Splash> {
  late SharedPreferences sharedPrefs ;
 late User user ;
  @override
  void initState() {
    super.initState();
     Future.delayed(
        const Duration(seconds: 3),
            () => checkUser()
         );
  }
 checkUser() async {
   sharedPrefs = await SharedPreferences.getInstance();

   if(sharedPrefs.containsKey("user")){

     user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;

     Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => RequestsList())) ;


     // api.login( onError:  onError, onLogin:
     //  onLogin, password: user.password , username: user.userName ) ;
   }
else{
   Navigator.pushReplacement(
     context,
     MaterialPageRoute(builder: (context) => Login()),
   ) ; }
 }
  @override
  Widget build(BuildContext context) {
    return
       Scaffold(
        backgroundColor: Colors.white,
        body:Center( child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const   Spacer(),

             Image.asset('images/logo.png',
              fit: BoxFit.cover,
              repeat: ImageRepeat.noRepeat,
              width: 200.0,
            ),
       // Padding (child:
           const   Spacer(),

              Text(AppLocalizations.of(context)?.translate("app_name") ?? "" ,style:   const  TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0 ,
            color: MyColors.blue
        ),),
       //  padding:const EdgeInsets.all(100),) ,
              const   Spacer(),

              const  CircularProgressIndicator(),
              const   Spacer(),


            ]),
        ) );
  }
}
