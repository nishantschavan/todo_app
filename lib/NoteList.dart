import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/NoteDetail.dart';
import 'package:todo_app/utils/database_helper.dart';

import 'note.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DataBaseHelper dataBaseHelper = DataBaseHelper();
  List<Note> notelist;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (notelist == null) {
      notelist = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("fab clicked");
          navigateToDetail(Note('','',2),context, 'Add Note');
        },
        tooltip: 'Add note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: getColor(this.notelist[position].priority),
                  child: getPriorityIcon(this.notelist[position].priority),
                ),
                title: Text(
                  this.notelist[position].title,
                  style: titleStyle,
                ),
                subtitle: Text(this.notelist[position].date),
                trailing: GestureDetector(
                    child: Icon(
                      Icons.delete,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _delete(context, notelist[position]);
                    }),
                onTap: () {
                  debugPrint("button clicked");
                  navigateToDetail(notelist[position],context, 'Edit Note');
                }),
          );
        });
  }

  void navigateToDetail(Note note,BuildContext context, String title) async{
   bool result=await  Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note,title);
    }));

    if(result == true){
      updateListView();
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow,color: Colors.white,);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right,color: Colors.white,);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right,color: Colors.white,);
    }
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await dataBaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackbar(context, "Note deleted successfully");
      updateListView();
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackbar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackbar);
  }

  void updateListView(){
    final Future<Database> dbfuture = dataBaseHelper.initializeDatabase();
    dbfuture.then((database) 
    {
      Future<List<Note>> noteListFuture = dataBaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.notelist=noteList;
          this.count=noteList.length;
        });
      });
    });
  }
}
