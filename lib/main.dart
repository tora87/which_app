// @dart=2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:which_app/choice.dart';
import 'package:which_app/newPost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:which_app/myTheme.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //Firebaseを初期化
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  MyAppState createState() => MyAppState();
}

class MyAppState extends State {
  bool _themeFlg = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=>MyTheme(),
      child: Consumer<MyTheme>(
        builder: (context,theme,_){
          return MaterialApp(
              title: 'Flutter Demo',
              theme: theme.current,
          home: MyHomePage(),
          );
        }
      ),
    );

  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _uuid = '';
  dynamic _snapshot;
  bool change = false;

  @override
  void initState(){
    //アプリ起動時に実行される
    super.initState();
    _checkUUID();
    change = Provider.of<MyTheme>(context, listen: false).getTheme();
  }

  bool containsUUID(dynamic data){
    bool bool_result = false;
    if(data['user_id_list'] != null) {
      int maxlength = data['user_id_list'].toString().length;
      String arrayStr = data['user_id_list'].toString().substring(1, maxlength - 1);
      String result = arrayStr.replaceAll(RegExp(r'\s'), '');
      var array = [];
      array = result.split(",");
      array.forEach((element) {
        if(element == _uuid){
          bool_result = true;
        };
      });
    }
    return bool_result;
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> stream = FirebaseFirestore.instance.collection('posts').snapshots();
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'which one?',
            // style: TextStyle(color: Colors.pinkAccent),
          ),
          actions: <Widget>[
            IconButton(
              icon:change ? Icon(Icons.wb_sunny_outlined):Icon(Icons.mode_night_rounded),
              onPressed: (){
                setState(() {
                  change = !change;
                });
                Provider.of<MyTheme>(context, listen: false).toggle();
              },
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            _snapshot = snapshot.data!;

            return new ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                String id = document.id;
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                int amount = data['ans1_amount'] + data['ans2_amount'];
                
                return Card(
                  child: ListTile(
                    // title: Text(data['title']),
                    title: Text(containsUUID(data) ? '✓' + data['title'] : '  ' + data['title']),
                    trailing: Container(
                      width: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(Icons.remove_red_eye_sharp),
                          Text(amount.toString())
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Choice(data,id,_uuid))
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewPost(_snapshot))
            );
          },
          tooltip: 'posting',
          child: const Icon(Icons.mode_edit,color: Colors.white,),
          backgroundColor: Colors.pinkAccent,

        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: change ? ThemeData.dark().primaryColor : ThemeData.light().primaryColor,
          child: Container(
            height: 30.0,
          ),
        )
    );
  }

  //ユーザーの識別IDを取得、無ければ生成
  void _checkUUID() async {
    await SharedPreferences.getInstance().then((prefs) {
      const key = 'uuid';
      if(prefs.containsKey(key)){
        _uuid = prefs.getString(key)!;

      }else{
        prefs.setString(key, Uuid().v4());
        _uuid =prefs.getString(key)!;
      }
    });
  }
}
