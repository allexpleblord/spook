import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './story.dart';

class Bookmarks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Bookmarks'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.getKeys().length <= 0)
              return _noBookmarks();
            else
              return _buildBookmarked(snapshot.data.getKeys().toList());
          } else {
            return Text('');
          }
        },
      ),
    );
  }

  // No bookmarks message
  Widget _noBookmarks() {
    return Container(
      padding: EdgeInsets.only(top: 40.0, right: 15.0, left: 15.0),
      child: Text(
        'Seems like you don\'t have any bookmarked stories. Head over to a story and tap the button on the top right corner to bookmark it.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 19.0,
        ),
      ),
    );
  }

  // List builder
  Widget _buildBookmarked(bookmarks) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      separatorBuilder: (BuildContext ctx, int i) => Divider(),
      itemCount: bookmarks.length,
      itemBuilder: (BuildContext ctx, int i) {
        return StreamBuilder(
          stream: Firestore.instance.collection('storyList').document(bookmarks[i]).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('');

            var story = snapshot.data;
            return _buildTile(story, context);
          },
        );
      },
    );
  }

  // Individual tiles
  Widget _buildTile(story, context) {
    return ListTile(
      title: Text(story['title']),
      subtitle: Text(story['date']),
      onTap: () {
        _getStory(story['id'], context);
      },
    );
  }

  // Route to the story
  void _getStory(id, context) {
    Navigator.push( 
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Story(id, true),
      ),
    );
  }

}