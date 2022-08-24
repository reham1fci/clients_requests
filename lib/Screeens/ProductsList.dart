
import 'package:clientsrequests/DataBase/DatabaseHelper.dart';
import 'package:clientsrequests/Model/Requests.dart';
import 'package:clientsrequests/Model/product.dart';
import 'package:clientsrequests/Screeens/NewProduct.dart';
import 'package:clientsrequests/Tools/Constant.dart';
import 'package:clientsrequests/Tools/MethodsTools.dart';
import 'package:clientsrequests/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart';

import '../app_localizations.dart';

class ProductsList extends StatefulWidget{
  Requests? myRequest ;

  ProductsList(this.myRequest, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return  _State();
  }

}
class _State extends State<ProductsList> {
  Methods mTools  =  Methods() ;

  bool loading = true  ;
    Requests? _request ;
    List <Product> productsList  = [] ;
   final dbHelper = DatabaseHelper.instance;
  void onFloatingActionClick() {
    setState(() {
      Navigator.push ( context,
          MaterialPageRoute(builder: (context) => NewProduct(_request, null ))).then((value) {
            getLocalProducts() ;
      });
  });}
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _request= widget.myRequest  ;
     if(_request!.isSaved==1){ // saved

     }
      else  {
getLocalProducts()  ;
     }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      backgroundColor:MyColors.grey,
        appBar:  AppBar(backgroundColor: MyColors.colorPrimary,title: Text( AppLocalizations.of(context)?.translate("products")??""),),
        floatingActionButton: FloatingActionButton(
          onPressed: onFloatingActionClick,
          child: const ImageIcon(
            AssetImage("images/add_icon.png"), color: MyColors.white,),
          backgroundColor: MyColors.colorPrimary,),
        body: loading? const Center(
    child: CircularProgressIndicator(),
    ): getView(productsList),);
  }
   getLocalProducts() async{
     List<Product> list = [] ;
     final allRows = await dbHelper.getProductsByReqId(_request!.id.toString())  ;
     for(int i  =  0  ;  i  < allRows.length  ;  i++)     {
       Map<String, dynamic> map = allRows[i]  ;
       Product product  = Product.fromDB(map)  ;
       list.add(product) ;

     }
     setState(() {
       loading = false  ;

       print(list) ;
       productsList  = list ;
     });
   }
   Widget getView(List<Product>list){
     //print(list.toString())  ;
     if(list.isNotEmpty){
       return
Column(children: [
         Row(
           // mainAxisAlignment: MainAxisAlignment.spaceBetween,

           children: <Widget>[
             Expanded(
               flex: 1,
               child: Container(
                 child:
                 Center(child:
                 Text(AppLocalizations.of(context)?.translate("id")??"")
                   ,),
                 width: MediaQuery.of(context).size.width * 0.33,
                 decoration: BoxDecoration(
                   border: Border.all(width: 1 ,color: MyColors.colorPrimary),

                 ),
               ),
             ),
             Expanded(
               flex: 1,
               child: Container(
                 child:
                 Center(child:
                 Text(AppLocalizations.of(context)?.translate("unit")??"")
                   ,),
                 width: MediaQuery.of(context).size.width * 0.33,
                 decoration: BoxDecoration(
                   border: Border.all(width: 1 ,color: MyColors.colorPrimary),

                 ),
               ),
             ),
             Expanded(
               flex: 1,
               child: Container(
                 child:
                 Center(child:
                 Text(AppLocalizations.of(context)?.translate("count")??"")
                   ,),
                 width: MediaQuery.of(context).size.width * 0.33,
                 decoration: BoxDecoration(
                   border: Border.all(width: 1 ,color: MyColors.colorPrimary),

                 ),
               ),
             ),
             //  Align(child:  Text(AppLocalizations.of(context).translate("inventory_point") +inv.invId.toString()) ,alignment: Alignment.centerLeft,),
             //   Align(child:  Text(inv.invDate) ,alignment: Alignment.centerRight,),

           ],

           mainAxisSize: MainAxisSize.max,) ,

         ListView.builder(
         itemBuilder: (context  , index ){
           return listCard( list[index]) ;
         } ,itemCount:  list.length ,shrinkWrap: true, ) ],);

     }
     else{

       return const SizedBox();

     }
   }

   GestureDetector  listCard  (Product product) {
     // getBackgroundColor(requestItem ) ;
     return  GestureDetector(
         onTapUp: (TapUpDetails details){
           showPopupMenu(product ,details.globalPosition) ;
         },
      //  child :  Padding(padding:  const EdgeInsets.only(top: 8.0  , bottom:  8.0  , right: 16.0 , left:  16.0 )  ,
             child :    Card(

               child: Container(
                 // color: backgroundReq,
                 //  padding:   EdgeInsets.all(8.0),
                 child:   Column(

                   children: <Widget>[
                      Center(child:
                      Text(product.name!)),

                    const Divider(color: Colors.black54,) ,

                      Row(
                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                       children: <Widget>[
                         Expanded(
                           flex: 1,
                           child: Container(
                             child:
                              Center(child:
                             Text(product.id.toString())
                               ,),
                             width: MediaQuery.of(context).size.width * 0.33,

                           ),
                         ),
                         Expanded(
                           flex: 1,
                           child: Container(
                             child:
                              Center(child:
                             Text(product.unit!)
                               ,),
                             width: MediaQuery.of(context).size.width * 0.33,

                           ),
                         ),
                         Expanded(
                           flex: 1,
                           child: Container(
                             child:
                              Center(child:
                             Text(product.qty.toString())
                               ,),
                             width: MediaQuery.of(context).size.width * 0.33,

                           ),
                         ),
                         //  Align(child:  Text(AppLocalizations.of(context).translate("inventory_point") +inv.invId.toString()) ,alignment: Alignment.centerLeft,),
                         //   Align(child:  Text(inv.invDate) ,alignment: Alignment.centerRight,),

                       ],

                       mainAxisSize: MainAxisSize.max,) ,



                     //   Padding(padding: EdgeInsets.all(16.0)  , child:  Text(inv.invDesc) ,) ,
                   ],),
               ) ,

               color: Theme.of(context).cardColor,
               //RoundedRectangleBorder, BeveledRectangleBorder, StadiumBorder
               shape:  const RoundedRectangleBorder(
                 borderRadius:   BorderRadius.vertical(
                     bottom: Radius.circular(10.0 ),
                     top: Radius.circular(10.0)),
              //   side:  BorderSide(color: MyColors.colorPrimary, width: 0.5),


               ),

             ) );
   }

   showPopupMenu(Product item, Offset offset) {
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
   onEditClick(Product item) {
     setState(() {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => NewProduct(_request  , item,)),
       ).then((value){
         setState(() {
           getLocalProducts();
           loading = false  ;
         });
       });
     });
   }

   onDeleteClick(Product product) {
     setState(() {
       mTools.Dialog(context: context ,
           title:AppLocalizations.of(context)?.translate("delete")??"" ,
           message:  AppLocalizations.of(context)?.translate("confirm_delete_product")??"", onOkClick: () async {
             int delete = await dbHelper.delete(id: product.id! ,
                 columnIdName: PRODUCT_TB_ID ,
                 table: PRODUCT_TB ) ;
             setState(() {
               productsList.remove(product) ;
             });



           } ,
           isCancelBtn: true ,
           onCancelClick: (){}

       );


     });
   }
}
