import 'package:database_intro/model/board.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';


void main(){
  runApp(MaterialApp(
    title: 'board',
    home: Home(),
  ));
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Board> boardMessages = List();
  Board board;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;
  @override
  void initState() {
    super.initState();
    board = Board("","");
    databaseReference = database.reference().child("community_board");
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildChanged.listen(_onEntryChanged);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Board"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 0,
              child: Center(
                child: Form(
                  key: formKey,
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.subject),
                        title: TextFormField(
                          initialValue: "",
                          onSaved: (val) => board.subject = val,
                          validator: (val) => val == "" ? val : null,
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.message),
                        title: TextFormField(
                          initialValue: "",
                          onSaved: (val) => board.body = val,
                          validator: (val) => val == "" ? val : null,
                        ),
                      ),
                      FlatButton(
                        child: Text("Post",
                        style: TextStyle(
                          color: Colors.white
                        ),),
                        onPressed: () => handleSubmit(),
                        color: Colors.blue,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: FirebaseAnimatedList(
                query: databaseReference,
                itemBuilder: (_, DataSnapshot snapshot,
                    Animation<double> animation, int index){
                  return Card(
                    color: Colors.white70,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                      ),
                      title: Text(boardMessages[index].subject),
                      subtitle: Text(boardMessages[index].body),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onEntryAdded(Event event) {
    setState(() {
      boardMessages.add(Board.fromSnapshot(event.snapshot));
    });
  }
  void _onEntryChanged(Event event) {
    var oldEntry = boardMessages.singleWhere((entry){
      return entry.key == event.snapshot.key;
    });
    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)] =
          Board.fromSnapshot(event.snapshot);
    });
  }

  handleSubmit() {
    final FormState form = formKey.currentState;
    if(form.validate()){
      form.save();
      form.reset();

      databaseReference.push().set(board.toJson());
    }
  }
}
