
import 'package:clientsrequests/DataBase/DatabaseHelper.dart';
import 'package:clientsrequests/Model/Requests.dart';
import 'package:clientsrequests/Model/Vendor.dart';
import 'package:clientsrequests/Tools/Constant.dart';
import 'package:clientsrequests/WebServices/Api.dart';
import 'package:clientsrequests/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_localizations.dart';
import 'ProductsList.dart';

// ignore: must_be_immutable
class NewRequest extends StatefulWidget{
    Requests? myRequest ;

    NewRequest({this.myRequest, Key? key}) : super(key: key);

    @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return  _State();
  }

}
 class _State extends State<NewRequest> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return   Scaffold(
        appBar:  AppBar(backgroundColor: MyColors.colorPrimary,
          title: Text(AppLocalizations.of(context)?.translate("new_request")??""),),

        body:
         SizedBox(
            height: double.infinity,
            child: Column(
                children: <Widget>[
                   Expanded(child:
                  Align(alignment: Alignment.center , child:
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        createDropDownList(),
                        refField(),
                        descriptionField(),
                        saveBtn()
                      ],
                    ),
                  )
                  )
                  )
                ] )
        )
    )
    ;
  }
 String? selectVendorName  = "الموردين" ;
 Vendor? selectVendor ;
  List <String> branchNameList = [] ; // هنغيرها ب class المخازن
  TextEditingController descEd   =  TextEditingController()  ;
  TextEditingController refEd    =  TextEditingController()  ;
  Requests? editReq  ;
  final dbHelper = DatabaseHelper.instance;
 // String storeErr  ;
  Api api  =  Api()   ;
 List<Vendor> vendorsList   = [];
  //User user  ;
  bool isEdit  =  false  ;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    getVendors();
    setState(() {

      editReq  = widget.myRequest  ;
    if(editReq  != null ) {
        isEdit  = true  ;
        selectVendor = Vendor( name :editReq!.vendorNm, id:editReq!.vendorID,) ;
        selectVendorName = editReq!.vendorNm;
        descEd.text  = editReq!.desc ?? "" ;
        refEd.text   =   editReq!.ref ?? ""  ;}
      });


  }
   bool isValidate(){
    if(selectVendor==null) {return false  ;}
    else if (refEd.text.isEmpty){return false ;}
    else {return true  ;}
   }
  getVendors() async {
    List<Vendor> list = [] ;
    final allRows = await dbHelper.queryAllRows(VENDOR_TB)  ;
    for(int i  =  0  ;  i  < allRows!.length  ;  i++)     {
      Map<String, dynamic> map = allRows[i]  ;
      Vendor category  = Vendor.fromDB(map)  ;
      list.add(category) ;

    }
    setState(() {
      print(list) ;
      vendorsList  = list ;
    });

  }
 void onSelectVendor(Vendor?  vendor){
    setState(() {
      selectVendorName  = vendor!.name ;
      selectVendor  = vendor ;
    });
  }
  Padding createDropDownList(){
    // selectBranch =  "test2" ;
    return
       Padding(padding:const EdgeInsets.only(bottom: 8.0 , left: 40.0  , right: 40.0 , top: 40.0) ,child:
       DropdownButton<Vendor>(
        isExpanded: true,
        items: vendorsList.map((Vendor value) {
          return  DropdownMenuItem<Vendor>(
            value: value,
            child:  Text(value.name!),
          );
        }).toList(),

        onChanged: onSelectVendor,
        hint:  Text (selectVendorName!),

        iconEnabledColor: MyColors.colorPrimary,
      )) ;
  }

  /*Future <void>getStoreList () async{
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
    api.getStores(userID: user.userId  , orgId:  user.orgId  , onError:  dialogMsg , onSuccess: (List<Store>list){
      setState(() {
        storesList  = list  ;
        if(isEdit){
          for(int i = 0  ; i  <storesList .length  ; i++)
          {
            if(storesList[i].storeID == myEditInv.invStore ) {
              setState(() {
                selectStoreId  = storesList[i].storeID  ;
                selectStore    = storesList[i].storeName  ;
              }
              );
            }
          }}
      });

    })  ;
  }*/

  Future<void> addReqToSQLite( ) async {
   if(isValidate()) {
      var now =  DateTime.now();
      var formatter =  DateFormat("EEE, MMM d, yyyy","en");
      String formattedDate = formatter.format(now);
      print( formattedDate)  ;
      Requests req = Requests(desc: descEd.text , ref:refEd.text  , vendorID: selectVendor!.id , vendorNm: selectVendor!.name  ,
          isSaved: 0 ,date: formattedDate);
      if (isEdit){
       final  id = await dbHelper.updateReqTb(req.insertDb(), editReq!.id!);
        print(id) ;
        req.id = id ;
       Navigator.of(context).pop();

        // confirmDialog(inv) ;
      }
      else{
        final id = await dbHelper.insert(req.insertDb() , REQ_TB , err: (e   ){print (e.toString());});
    print(id) ;
    req.id = id  ;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductsList(req)),
        );
      }



      // done
      // finish
      //


    }
    else{
      dialogMsg(AppLocalizations.of(context)?.translate("fill_data")??"" ,  AppLocalizations.of(context)?.translate("error")??"")  ;

    }

  }



 /* Future<void> confirmDialog(InventoryPoint inv)async {return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(AppLocalizations.of(context).translate("edit_done")),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(AppLocalizations.of(context).translate('continue')),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement( context,
                  MaterialPageRoute(builder: (context) => ProductsList(inv))) ;
            },
          ),
          FlatButton(
            child: Text(AppLocalizations.of(context).translate("back")),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();

            },
          ),
        ],
      );
    },
  );
  }*/

  Future<void> dialogMsg(String message  , String title   ) async {
    setState(() {
      // loading = false ;
    });
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
              child: Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
 /* showProgressDialog (){
    ProgressDialog  pr =  ProgressDialog(context);
    pr =  ProgressDialog(context,type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: true);
//For normal dialog
    pr.style(
        message: 'Downloading file...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );

    pr.show();


//For showing progress percentage
  }*/

  Padding refField(){
    return
       Padding(padding:  const EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
          child:
           TextField(controller:  refEd,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.translate("ref"),
              fillColor: Colors.white,
              filled: false,
            ) ,) );
  }
  Padding descriptionField(){
    return
       Padding(padding: const  EdgeInsets.only(bottom: 8.0 , left: 30.0  , right: 30.0 , top: 8.0) ,
          child:
           TextField(controller:  descEd,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.translate("description"),
              fillColor: Colors.white,
              filled: false,
            ) ,) );
  }
  void onSaveClick() {
    setState(() {
      addReqToSQLite() ;

    });
  }
  Padding saveBtn() {
    return  Padding(
        padding:
      const  EdgeInsets.only(bottom: 8.0, left: 40.0, right: 40.0, top: 8.0),
        child:  Container(
            decoration:const  BoxDecoration(
                color: MyColors.colorPrimary,
                borderRadius:  BorderRadius.all(
                   Radius.circular(8.0),
                )),
            width: double.infinity,
            child:
             FlatButton(
              onPressed: onSaveClick,
              child:
               Row(
                children: [
                   Expanded(child:
                   Text(
                    AppLocalizations.of(context)?.translate("save")??"",
                    style: const TextStyle(color: Colors.white),
                    textAlign:  TextAlign.center,
                  )),

                ],
              ),

            )


        )
    )
    ;
  }

 }