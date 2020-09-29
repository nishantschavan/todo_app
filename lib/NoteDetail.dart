import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'note.dart';
import 'utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() =>
      _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  var _formkey = GlobalKey<FormState>();

  Note note;
  String appBarTitle;

  _NoteDetailState(this.note, this.appBarTitle);

  static var _priorities = ['High', 'Low'];

  DataBaseHelper helper = DataBaseHelper();

  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titlecontroller.text = note.title;
    descriptioncontroller.text = note.description;

    TextStyle textStyle = Theme.of(context).textTheme.bodyText2;

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Form(
            key: _formkey,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem),
                          );
                        }).toList(),
                        style: textStyle,
                        value: getpriorityAsString(note.priority),
                        onChanged: (valueSelected) {
                          setState(() {
                            debugPrint('user selected $valueSelected');
                            updatepriorityAsInt(valueSelected);
                          });
                        }),
                  ),
                  //first texfield
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: TextFormField(
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'please enter title';
                        }
                      },
                      controller: titlecontroller,
                      style: textStyle,
                      onChanged: (value) {
                        // debugPrint('something changed in title text field');
                        updateTitle();
                      },
                      decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),

                  //second texfield
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: descriptioncontroller,
                      style: textStyle,
                      onChanged: (value) {
                        // debugPrint('something changed in title text field');
                        updateDescription();
                      },
                      decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(children: <Widget>[
                      Expanded(
                          child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              child: Text(
                                'Save',
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_formkey.currentState.validate()) {
                                    debugPrint("save button clicked");
                                    _save();
                                  }
                                });
                              })),
                      SizedBox(
                        width: 3.0,
                      ),
                      // Container(width:5.0),
                      //delete button
                      Expanded(
                          child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              child: Text(
                                'Delete',
                              ),
                              onPressed: () {
                                setState(() {
                                  debugPrint("delete button clicked");
                                  _delete();
                                });
                              }))
                    ]),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatepriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String getpriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    note.title = titlecontroller.text;
  }

  void updateDescription() {
    note.description = descriptioncontroller.text;
  }

  void _delete() async {
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note deleted successfully');
    } else {
      _showAlertDialog('Status', 'Error occured while deleting note');
    }
  }

  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Note saved successfully');
    } else {
      _showAlertDialog('Status', 'Problem saving Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
