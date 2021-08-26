import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:which_app/myTheme.dart';
import 'package:provider/provider.dart';

class Choice extends StatefulWidget {
  Choice(this.data,this.id,this.uuid);
  Map<String,dynamic> data;
  String id;
  String uuid;

  ChoiceState createState() => ChoiceState();
}

class ChoiceState extends State<Choice> {
  String id = "";
  int amount = 0;
  int ans1_amount = 0;
  int ans2_amount = 0;
  double percent = 0;
  bool isPressed = false;
  bool change = false;

  @override
  void initState(){
    super.initState();
    id = widget.id;
    ans1_amount = widget.data['ans1_amount'];
    ans2_amount = widget.data['ans2_amount'];
    amount = ans1_amount + ans2_amount;
    percent = widget.data['ans1_amount']/amount;
    isContainsUUID(widget.uuid);
    change = Provider.of<MyTheme>(context, listen: false).getTheme();
  }

    void pressed(String ans){
    int ans_amount = 0;
    setState(() {
      if(ans == 'ans1_amount'){
        ans_amount = ++ans1_amount;
      }else if(ans == "ans2_amount"){
        ans_amount = ++ans2_amount;
      }

      amount++;
      percent = ans_amount/amount;
      isPressed = true;
    });

    firestore_increment(ans,ans_amount);
  }

  void firestore_increment(String ans_number,int ans_amount) async{
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(id)
        .update({
          ans_number:ans_amount,
          'user_id_list': FieldValue.arrayUnion([widget.uuid])
        });
  }
  void isContainsUUID(String uuid){

    if(!widget.data.containsKey('user_id_list')) return;

    for(int i = 0; i < widget.data['user_id_list'].length; i++){
      if(widget.data['user_id_list'][i].toString() == uuid.toString()){
        isPressed = true;
        return;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: new AppBar(
        title: new Text('投票'),
        actions: <Widget>[
          IconButton(
            icon:change ? Icon(Icons.wb_sunny_outlined):Icon(Icons.mode_night_rounded),
            onPressed: (){
              setState(() {
                change = Provider.of<MyTheme>(context, listen: false).toggle();
              });
              Provider.of<MyTheme>(context, listen: false).toggle();
            },
          )
        ],
      ),
      body:Container(
        width: size.width,
        height: size.height,
        padding: EdgeInsets.all(40),
        child:Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Text(
                    widget.data['title'],
                    style: TextStyle(
                      fontSize: 30
                    ),
                )
            ),
            // Visibility(
            //   visible: false,
            //   child:
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Text('総投票数：' + amount.toString()),
            ),

            if(isPressed == true)Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: LinearPercentIndicator(
                animation: true,
                lineHeight: 40.0,
                animationDuration: 1500,
                percent: percent,
                center: Text(
                    (percent*100).toStringAsFixed(1)+"%",
                    style: TextStyle(color: Colors.white)
                ),
                backgroundColor: Colors.black12,
                linearStrokeCap: LinearStrokeCap.butt,
                progressColor: Colors.pinkAccent,
              ),
            )
            ,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    width: 130,
                    height: 100,
                    child: OutlinedButton(
                      onPressed: isPressed ?
                          null
                          :
                          (){pressed('ans1_amount');},

                      child: Text(widget.data['ans1_name']),
                    )
                ),
                Container(
                    width: 130,
                    height: 100,
                    child: OutlinedButton(
                      onPressed: isPressed ?
                          null
                          :
                          (){pressed('ans2_amount');},
                      child: Text(widget.data['ans2_name']),
                    )
                ),
              ],
            ),
          ],
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

