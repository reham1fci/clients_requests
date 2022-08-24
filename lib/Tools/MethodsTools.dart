
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Methods {
  Future<void> Dialog({required BuildContext context ,  required String title  , required String message   ,
    required  bool isCancelBtn ,Function? onOkClick , Function? onCancelClick}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                onOkClick!();
              },
            ),
           isCancelBtn? FlatButton(
              child:  const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                 onCancelClick!();
              },
            ): const SizedBox(),
          ],
        );
      },
    );
  }
  Future<bool> checkInternet({required Function onConnect ,required Function notConnect}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      onConnect() ;
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      onConnect() ;

      return true;
    }
    notConnect();
    return false;
  }
   static List<String>  getDateTime( int lateHour) {
    List<String> dates =  [] ;
    var now = new DateTime.now();
    String  timeFormat = new DateFormat('hh:mm:ss a').format(now);
    var duration = new Duration(hours : lateHour);
    var date  =  now.add(duration)  ;
    String dateFormat  = new DateFormat('dd/MM/yyyy').format(date)  ;
    dates.add(dateFormat +" " +timeFormat)  ;
    dates.add(dateFormat)  ;
    return dates;



  }




}