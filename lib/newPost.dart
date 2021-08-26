import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:which_app/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:which_app/myTheme.dart';
import 'package:provider/provider.dart';


class NewPost extends StatefulWidget {
  NewPost(this.snapshot);
  QuerySnapshot snapshot;
  @override
  NewPostState createState() => NewPostState();
}

class NewPostState extends State<NewPost> {
  String newTitle = '';
  String newItem1 = '';
  String newItem2 = '';
  dynamic snapshot;
  bool change = false;

  @override
  void initState(){
    super.initState();
    snapshot = widget.snapshot;
    change = Provider.of<MyTheme>(context, listen: false).getTheme();
  }

  //現在のIDの最大値を取得し、そのID+1の値を新たなIDとして返す。
  int getId(){
    int max = 0;
    for(int i = 0; i < snapshot.size; i++){
      if(max < int.parse(snapshot.docs[i].id)){
        max = int.parse(snapshot.docs[i].id);
      }
    }
    return max+1;
  }

  void newRegister() async{
    int id = getId();
    await FirebaseFirestore.instance.
      collection('posts').
      doc(id.toString()).
      set(
        {
          'title':newTitle,
          'ans1_name':newItem1,
          'ans2_name':newItem2,
          'ans1_amount':0,
          'ans2_amount':0,
        }
      );

    Fluttertoast.showToast(
        msg: '登録しました',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black38,
        fontSize: 16
    );

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage())
    );
  }


  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: new AppBar(
        title: new Text('登録画面'),
          actions: <Widget>[
            IconButton(
              icon:change ? Icon(Icons.wb_sunny_outlined):Icon(Icons.mode_night_rounded),
              onPressed: (){
                Provider.of<MyTheme>(context, listen: false).toggle();
                setState(() {
                  change = Provider.of<MyTheme>(context, listen: false).getTheme();
                });

              },
            )
          ]
      ),
      body: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.all(40),
          child:SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: TextField(
                    decoration: InputDecoration(
                        labelText: 'タイトル',
                        hintText: '(例)好きなのはどっち？',
                    ),
                    onChanged: (String text){
                        setState(() {
                          newTitle = text;
                        });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '項目1',
                      hintText: '(例)きのこの山',
                    ),
                    onChanged: (String text){
                      setState(() {
                        newItem1 = text;
                      });
                    },
                  ),
                ),
                Container(
                  child: Text(
                    'VS',
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '項目2',
                      hintText: '(例)たけのこの里',
                    ),
                    onChanged: (String text){
                      setState(() {
                        newItem2 = text;
                      });
                    },
                  ),
                ),
                Container(
                  child: ElevatedButton(
                      onPressed: newRegister,
                      child: Text(
                        '投稿',
                        style: TextStyle(
                            color: Colors.white
                        ),
                      )
                  ),
                ),
              ],
            ),
          )
      ),
      bottomNavigationBar: BottomAppBar(
        color: change ? ThemeData.dark().primaryColor : ThemeData.light().primaryColor,
        child: Container(
          height: 30.0,
        ),
      )
    );
  }
}