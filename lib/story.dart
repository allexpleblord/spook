import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Story extends StatefulWidget {
  final id;
  final saved;
  Story(this.id, this.saved);

  @override
  _StoryState createState() => _StoryState(id, saved);
}

class _StoryState extends State<Story> {
  String id;
  bool saved;
  _StoryState(this.id, this.saved);

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
        actions: <Widget>[
          IconButton(
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              // Change the icon appearance and remove/add bookmark
              setState(() {
                if (saved) {
                  saved = false;
                  removeBookmark(id);
                } else {
                  saved = true;
                  addBookmark(id);
                }
              });
            },
          ),
        ],
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

Future addBookmark(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(id, true);
}

Future removeBookmark(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(id);
}
