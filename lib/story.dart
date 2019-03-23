import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Story extends StatelessWidget {
  final id;
  Story(this.id);

  // Used to build the story layout
  Widget _buildStory(String title, String body) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(35.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25.0),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 35.0),
          child: Text(
            body,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w300,
              color: Color(0xAAFFFFFF),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('story').document(id).snapshots(),
        builder: (context, snapshot) {
          // If no data yet
          if (!snapshot.hasData) return const Center(
            child: Text('Loading the story...'),
          );

          // Get the story and build the page
          var story = snapshot.data;
          return _buildStory(story['title'], story['body']);
        },
      ),
    );
  }
}