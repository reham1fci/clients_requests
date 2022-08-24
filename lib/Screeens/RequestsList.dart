
import 'package:clientsrequests/DataBase/DatabaseHelper.dart';
import 'package:clientsrequests/Model/Requests.dart';
import 'package:clientsrequests/Model/User.dart';
import 'package:clientsrequests/Screeens/Login.dart';
import 'package:clientsrequests/Screeens/NewRequest.dart';
import 'package:clientsrequests/Screeens/ProductsList.dart';
import 'package:clientsrequests/Screeens/Settings.dart';
import 'package:clientsrequests/Tools/Constant.dart';
import 'package:clientsrequests/Tools/MethodsTools.dart';
import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';
import '../my_colors.dart';

class RequestsList extends StatefulWidget  {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return   RequestsState()  ;

  }
}
 class RequestsState  extends State <RequestsList>with SingleTickerProviderStateMixin {
   late TabController _tabController;

   // Api api  =  Api()  ;
   late User user;

   int count = 0;

    Methods mTools  =  Methods() ;
   final dbHelper = DatabaseHelper.instance;

   List<Requests> serverReqList = [];

   List<Requests> localReqList = [];

   bool loading = true;

   @override
   void initState() {
     super.initState();
     _tabController = TabController(length: 2, vsync: this);
      getLocalRequests();
     //getInventoryPointRequests();
   }

   void onFloatingActionClick() {
     setState(() {
        Navigator.push ( context,
           MaterialPageRoute(builder: (context) => NewRequest())).then((value) {
          print("back");
          setState(() {
            getLocalRequests();
            loading = false  ;
          });
        }
        ) ;
     });
   }

   @override
   Widget build(BuildContext context) {
     final List<Tab> myTabs = <Tab>[
       Tab(text: AppLocalizations.of(context)?.translate("requests_saved")),
       Tab(text: AppLocalizations.of(context)?.translate("requests_not_saved")),
     ];
     // TODO: implement build
     return Scaffold(
         floatingActionButton: FloatingActionButton(
           onPressed: onFloatingActionClick,
           child: const ImageIcon(
         AssetImage("images/add_icon.png"), color: MyColors.white,),
           backgroundColor: MyColors.colorPrimary,),
         appBar: AppBar(
           backgroundColor: MyColors.colorPrimary,
           title: Text(
               AppLocalizations.of(context)?.translate("requests") ??
                   ""),
           bottom: TabBar(
             controller: _tabController,
             tabs: myTabs,
             labelColor: MyColors.white,
             indicatorColor: MyColors.white,
           ),actions: [
             IconButton(onPressed: (){
               Navigator.push ( context,
                   MaterialPageRoute(builder: (context) => Settings())) ;
             }, icon: Image.asset('images/setting.png',color: Colors.white,),
             ) ,
           IconButton(onPressed: (){
               logout() ;
             }, icon: Image.asset('images/logout.png',color: Colors.white),
           )
         ],
         ),
         body: loading ? const Center(
           child: CircularProgressIndicator(),
         ) : TabBarView(
             controller: _tabController,
             children:
             myTabs.map((Tab tab) {
               int index = myTabs.indexOf(tab);
               if (index == 0) {
                 return getView(serverReqList, 1);
               }
               else if (index == 1) {
                 return getView(localReqList, 0);
               }
               else {
                 return Center(child: Text(tab.text!));
               }
             }).toList()
         ));
   }
   Future<void> logout () async {
     SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
     sharedPrefs.remove("user");
     // sharedPrefs.clear()  ;
     sharedPrefs.commit()  ;
     int delete = await dbHelper.deleteTb(table: REQ_TB)  ;
     int delete2 = await dbHelper.deleteTb(table:   PRODUCT_TB)  ;

     Navigator.pushReplacement( context,
         MaterialPageRoute(builder: (context) => Login())) ;


   }
    getLocalRequests() async{
      List<Requests> list = [] ;
      final allRows = await dbHelper.queryAllRows(REQ_TB)  ;
      for(int i  =  0  ;  i  < allRows!.length  ;  i++)     {
        Map<String, dynamic> map = allRows[i]  ;
        Requests req  = Requests.fromDB(map)  ;
        list.add(req) ;

      }
      setState(() {
        loading = false  ;

        print(list) ;
        localReqList  = list ;
      });
    }

   /* onRequestSuccess(List<InventoryPoint> invList){
     setState(() {
       this .invList  = invList  ;


     });
   }*/
   Future<void> onError(String message) async {
     setState(() {
       loading = false;
     });
     return showDialog<void>(
       context: context,
       barrierDismissible: false, // user must tap button!
       builder: (BuildContext context) {
         return AlertDialog(
           title: Text(AppLocalizations.of(context)?.translate("error") ?? ""),
           content: SingleChildScrollView(
             child: ListBody(
               children: <Widget>[
                 Text(message),
               ],
             ),
           ),
           actions: <Widget>[
             FlatButton(
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

   Widget getView(List<Requests>list, int type) {
     if (list.isNotEmpty) {
       return ListView.builder(
         itemBuilder: (context, index) {
           return listCard(list[index], type);
         }, itemCount: list.length,);
     }
     else {
       return noThingView();
     }
   }

   Widget noThingView() {
     return SizedBox(child:
     Center(
       child: Column(children: <Widget>[
         //  Image.asset('images/nothing.png', fit: BoxFit.contain),
         Text(AppLocalizations.of(context)?.translate("no_requests") ?? "")
       ], mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.center,),
     ), height: double.infinity,);
   }


   /* Future <void> getInventoryPointRequests() async{
     SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
     user = User.fromJsonShared(json.decode(sharedPrefs.getString("user") )) ;
     api.getInvList(userID: user.userId ,orgId: user.orgId , onError: onError ,
         onSuccess: (List<InventoryPoint> list){
           setState(() {
             loading  = false ;
             invList  = list ;
           });

         }) ;
   }*/
   /*  Future <void> getInventoryPointLocal() async{
     List<InventoryPoint> list = [] ;
     final allRows = await dbHelper.queryAllRows(DatabaseHelper.inv_table_name)  ;
     for(int i  =  0  ;  i  < allRows.length  ;  i++)     {
       Map<String, dynamic> map = allRows[i]  ;
       InventoryPoint inv  = InventoryPoint.fromSql(map)  ;
       list.add(inv) ;

     }
     setState(() {
       localInvList  = list ;
     });

   }*/
   showPopupMenu(Requests item, Offset offset) {
     PopupMenu menu = PopupMenu(
       backgroundColor: MyColors.colorPrimary,
       // lineColor: Colors.tealAccent,
       maxColumn: 2,

       context: context,
       items: [
         MenuItem(title: AppLocalizations.of(context)?.translate("edit"),
             image: const Icon(Icons.edit, color: Colors.white,)),
         MenuItem(title: AppLocalizations.of(context)?.translate("delete"),
             image: const Icon(Icons.delete, color: Colors.white,)),
       ],
       onClickMenu: (MenuItemProvider menuItem) {
         if (menuItem.menuTitle ==
             AppLocalizations.of(context)?.translate("edit")) {
           onEditClick(item);
         }
         else {
           onDeleteClick(item);
         }
       },
     );
     menu.show(rect: Rect.fromPoints(offset, offset));
   }

   onEditClick(Requests item) {
     setState(() {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => NewRequest(myRequest: item,)),
       ).then((value){
         setState(() {
           getLocalRequests();
           loading = false  ;
         });
       });
     });
   }

   onDeleteClick(Requests req) {
     setState(() {
        mTools.Dialog(context: context ,
            title:"" ,
          message:  AppLocalizations.of(context)?.translate("confirm_delete")??"", onOkClick: () async {
            int delete = await dbHelper.delete(id: req.id! ,
                 columnIdName: PRODUCT_REQ_ID ,
                 table: PRODUCT_TB ) ;
               // itemsList.remove(item) ;
               int delete2 = await dbHelper.delete(id: req.id! ,
                   columnIdName: REQ_ID ,
                   table: REQ_TB ) ;
               setState(() {
                 localReqList.remove(req) ;
              /* mTools.Dialog(title:AppLocalizations.of(context)?.translate("delete")??"",
                  message: AppLocalizations.of(context)?.translate("delete")??"",
                   context:context,
                   isCancelBtn: false) ;*/
             });



           } ,
            isCancelBtn: true ,
           onCancelClick: (){}

           );


     });
   }

   GestureDetector listCard(Requests req, int type) {
     //  InventoryPoint inv  = list[index] ;
     // getBackgroundColor(requestItem ) ;
     return GestureDetector(
         onTap: () {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => ProductsList(req)),
           );
           // String name  =  list[index].  name ;
           //  print(name )  ;
         },

         onLongPressEnd: (LongPressEndDetails details) {
           if (type == 0) { // local
             showPopupMenu(req, details.globalPosition);
           }
         },
         child: Padding(padding:const EdgeInsets.only(
             top: 8.0, bottom: 8.0, right: 16.0, left: 16.0),
             child: Card(

               child: Container(
                 // color: backgroundReq,
                 //  padding:   EdgeInsets.all(8.0),
                 child: Column(

                   children: <Widget>[
                     Container(
                       padding: const EdgeInsets.all(8.0),

                       child:
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                         children: <Widget>[
                           Align(child: Text((AppLocalizations.of(context)?.translate("request") ?? "" )+'# '+ req.id.toString())

                             , alignment: Alignment.centerLeft,)
                           ,
                           Align(child: Text(req.date!), alignment: Alignment.centerRight,),

                         ], mainAxisSize: MainAxisSize.max,),),


                     Padding(padding:const     EdgeInsets.all(16.0), child: Text(req.desc!
                       //inv.invDesc
                     ),),
                   ],),
               ),

               color: Theme
                   .of(context)
                   .cardColor,
               //RoundedRectangleBorder, BeveledRectangleBorder, StadiumBorder
               shape:   const RoundedRectangleBorder(
                 borderRadius: BorderRadius.vertical(
                     bottom: Radius.circular(10.0),
                     top: Radius.circular(10.0)),
               ),

             )));
   }
 }