
import 'dart:ffi';
import 'dart:io';
import 'package:clientsrequests/Model/Vendor.dart';
import 'package:clientsrequests/Tools/Constant.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
class DatabaseHelper  {


  late final _databaseName = "MyDatabase.db";
  late final _databaseVersion = 1;
   Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();


  // only have a single app-wide reference to the database
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
      String reqTbStr ="CREATE TABLE $REQ_TB (\n" +
        "  $REQ_ID     INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
        "  $REQ_DES  varchar(255), \n" +
        "  $REQ_DATE  varchar(200) NOT NULL, \n" +
        "  $VENDOR_ID  varchar(200) NOT NULL, \n" +
        "  $VENDOR_NAME  varchar(200) NOT NULL, \n" +
        "  $REQ_REF   varchar(200), \n" +
        "  $REQ_SAVED      integer(10) NOT NULL);" ;
      await db.execute(reqTbStr);
      String productTbStr ="CREATE TABLE $PRODUCT_TB (\n" +
          "  $PRODUCT_TB_ID    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
          "  $PRODUCT_ID       varchar(255), \n" +
          "  $PRODUCT_DATE     varchar(200) NOT NULL, \n" +
          "  $PRODUCT_NAME     varchar(200) NOT NULL, \n" +
          "  $PRODUCT_UNIT     varchar(200), \n" +
          "  $PRODUCT_PRICE    varchar(200), \n" +
          "  $PRODUCT_TAX      varchar(200), \n" +
          "  $PRICE_WITH_TAX   varchar(200), \n" +
          "  $BARCODE          varchar(200), \n" +
          "  $PRODUCT_TOTAl    varchar(200), \n" +
          "  $PRODUCT_QTY      INTEGER(200), \n" +
          "  $PRODUCT_REQ_ID   INTEGER(200) NOT NULL, \n" +
          "  FOREIGN KEY($PRODUCT_REQ_ID) REFERENCES $REQ_TB($REQ_ID));" ;
      await db.execute(productTbStr);
      String vendorTbStr ="CREATE TABLE $VENDOR_TB (\n" +
          "  $VENDOR_ID     varchar(255) NOT NULL PRIMARY KEY , \n" +
          "  $VENDOR_NAME   varchar(255) NOT NULL  );" ;
      await db.execute(vendorTbStr);
  }
  Future<void> insertVendors(List<Vendor> vendors,String tableName , { Function? onSuccess ,Function? err}) async {
    try{
      Database? db = await instance.database;
      await db?.transaction((txn) async{
      var batch = txn.batch();
      for(int i  =  0  ;  i  < vendors.length  ;  i  ++) {
        Vendor  vendor  =  vendors[i] ;
      batch.insert(tableName, vendor.insertDb());
      }
       await batch.commit();

      });
      onSuccess!("Data Saved") ;
    }

    on Exception catch (e){
      err!(e.toString());

    }
  }

  Future<int> insert(Map<String, dynamic> row ,String tableName , {Function? err}) async {
    try{
      Database? db = await instance.database;
      return await db!.insert(tableName, row);}
    on Exception catch (e){
      err!(e.toString());
      return -1 ;

    }
  }  Future<int> delete({ required int id ,  required  String columnIdName  ,   required String table}) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnIdName = ?', whereArgs: [id]);
  }

  Future<int> deleteTb({ required String table}) async {
    Database? db = await instance.database;
    return await db!.delete(table);
  }
  Future<int> updateReqTb(Map<String, dynamic> row  ,int id ) async {
    Database? db = await instance.database;
    return await db!.update(REQ_TB, row, where: '$REQ_ID = ?', whereArgs: [id]);

  }Future<int> updateProductTb(Map<String, dynamic> row  ,int id ) async {
    Database? db = await instance.database;
    return await db!.update(PRODUCT_TB, row, where: '$PRODUCT_TB_ID = ?', whereArgs: [id]);

  }
  Future<List<Map<String, dynamic>>?> queryAllRows(String tableName) async {
    Database? db = await instance.database;
    return await db?.query(tableName);
  }
  Future<List<Map<String, dynamic>>> getProductsByReqId(String reqID ) async {
    Database? db = await instance.database;
    return await db!.rawQuery('select * from $PRODUCT_TB where $PRODUCT_REQ_ID  = ? ' ,
        [reqID] );
  }
}