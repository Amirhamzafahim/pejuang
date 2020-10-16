import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:pejuang/collection.dart';
import 'package:pejuang/helper/authenticate.dart';
import 'package:pejuang/services/auth.dart';

class Feedpage extends StatefulWidget {
  @override
  _FeedpageState createState() => _FeedpageState();
}

class _FeedpageState extends State<Feedpage> {
  Stream mystream;
  initState() {
    super.initState();
    getStream();
  }

  getStream() async {
    setState(() {
      mystream = postcollection.snapshots();
    });
  }

  buildcard(String text, Widget widget, IconData icon) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => widget)),
      child: Container(
        width: double.infinity,
        height: 70,
        child: Card(
          child: Row(
            children: <Widget>[
              Icon(icon, size: 35),
              SizedBox(
                width: 10,
              ),
              Text(
                text,
                style: mystyle(26, Colors.black, FontWeight.w700),
              )
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      appBar: AppBar(
        title: Text("News Feed"),
        centerTitle: true,

     
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              AuthService().signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Authenticate()));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),

      body: StreamBuilder(
          stream: mystream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot post = snapshot.data.documents[index];
                return Container(
                  // height: 200,
                  child: Card(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(post['title'],textAlign: TextAlign.justify,),
                        ),
                        SizedBox(height: 10,),

                        Image(image:NetworkImage(post['picture']),fit: BoxFit.cover, ),

                      ],

                    ),
               
                  ),
                );
              },
            );
          }),
    );
  }
}
