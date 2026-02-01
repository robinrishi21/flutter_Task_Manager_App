import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DB{
  DB._();
  static final DB getInstance = DB._();
  static final String TABLE_NAME = 'todo_v2';
  static final String COLUMN_SNO = 's_no';
  static final String COLUMN_TITLE = 'title';
  static final String COLUMN_PRIORITY = 'priority';
  static const COLUMN_COMPLETED = 'is_completed';


  Database? myDB;

  //db open (if exist then open else create)
Future<Database> getDB() async {
    if(myDB!=null){
      return myDB!;
    } else {
      myDB = await openDB();
      return myDB!;
    }
  }

  Future<Database> openDB() async {
     Directory appdir = await getApplicationDocumentsDirectory();
     String dbpath = join(appdir.path,'taskDB.db');
     await deleteDatabase(dbpath);
    return await openDatabase(dbpath, onCreate: (db, version) {
       //create all your tables here
      print("!!!!!!!!!!onCreate CALLED!!!!!!!!!!!!!!!!!!!");
       db.execute('''create table $TABLE_NAME($COLUMN_SNO integer primary key autoincrement, $COLUMN_TITLE text, $COLUMN_PRIORITY text, $COLUMN_COMPLETED integer)''');
     }, version: 3);
  }


  //All queries

//insertation
 Future<bool> addTask({required String mtitle, required String mpriority}) async {
   var db = await getDB();
   int rowsEffected = await db.insert(TABLE_NAME, {
     COLUMN_TITLE: mtitle,
     COLUMN_PRIORITY: mpriority,
     COLUMN_COMPLETED:0,
   });
   return rowsEffected>0;
 }

 //get all task
Future<List<Map<String, dynamic>>> getAllTask() async {
  var db = await getDB();
 List<Map<String, dynamic>> mData = await db.query(TABLE_NAME,);
 return mData;
}

//update queries
Future<bool> updateTask({required String mtitle, required String mpriority, required int sno}) async {
  var db = await getDB();
  int rowsEffect = await db.update(TABLE_NAME, {
    COLUMN_TITLE: mtitle,
    COLUMN_PRIORITY: mpriority
  }, where: '$COLUMN_SNO = $sno');
  return rowsEffect > 0;
}

//delete queries
Future<bool> deleteTask({required int sno}) async {
  var db = await getDB();
  int rowsEffect = await db.delete(TABLE_NAME, where: "$COLUMN_SNO = $sno");
  return rowsEffect>0;
}

//update CheckBox
Future<bool> updateTaskStatus({required int sno, required int isCompleted})async{
  var db = await getDB();
  int rowsEffect = await db.update(TABLE_NAME, {
    COLUMN_COMPLETED:isCompleted
  }, where: '$COLUMN_SNO = $sno');
  return rowsEffect>0;
}

//Filter Completed Task
Future<List<Map<String, dynamic>>>getCompletedTask()async{
  var db = await getDB();
  return await db.query(TABLE_NAME, where: '$COLUMN_COMPLETED = ?',whereArgs: [1]);
}

//Filter Pending Task
  Future<List<Map<String, dynamic>>>getPendingTask()async{
    var db = await getDB();
    return await db.query(TABLE_NAME, where: '$COLUMN_COMPLETED = ?',whereArgs: [0]);
  }

}