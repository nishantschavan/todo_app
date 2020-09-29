import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:todo_app/note.dart';

class DataBaseHelper{

  static DataBaseHelper _dataBaseHelper;
  static Database _database;

  String noteTable ='note_table';
  String colId='id';
  String colTitle='title';
  String colDescription='description';
  String colDate='date';
  String colPriority='priority';

  DataBaseHelper._createInstance();

  factory DataBaseHelper(){
    if(_dataBaseHelper==null){
      _dataBaseHelper = DataBaseHelper._createInstance();
    }
    return _dataBaseHelper;
  }

  Future<Database> get database async {
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{
    Directory directory=await getApplicationDocumentsDirectory();
    String path=directory.path+'notes.db';

    var notesDatabase=await openDatabase(path,version:1,onCreate:_createDb);
    return notesDatabase;
  }

  void _createDb(Database db,int newVersion) async{
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
				'$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Fetch Operation: Get all note objects from database
	Future<List<Map<String, dynamic>>> getNoteMapList() async {
		Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
		var result = await db.query(noteTable, orderBy: '$colPriority ASC');
		return result;
	}

	// Insert Operation: Insert a Note object to database
	Future<int> insertNote(Note note) async {
		Database db = await this.database;
		var result = await db.insert(noteTable, note.toMap());
		return result;
	}

	// Update Operation: Update a Note object and save it to database
	Future<int> updateNote(Note note) async {
		var db = await this.database;
		var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
		return result;
	}

	// Delete Operation: Delete a Note object from database
	Future<int> deleteNote(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
		return result;
	}

	// Get number of Note objects in database
	Future<int> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}

  Future<List<Note>> getNoteList() async{
    var mapList=await getNoteMapList();
    int count=mapList.length;

    List<Note> noteList= List<Note>();
    for(int i=0;i<count;i++){
      noteList.add(Note.fromMapObject(mapList[i]));
    }
    return noteList;
  }
}