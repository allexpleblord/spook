import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bookmarks extends StatelessWidget {
  // Individual tiles
  Widget _buildTile(story) {
    return ListTile(
      title: Text(story['title']),
      subtitle: Text(story['date']),
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
            if (!snapshot.hasData) return CircularProgressIndicator();

            var story = snapshot.data;
            return _buildTile(story);
          },
        );
      },
    );
  }

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
            return _buildBookmarked(snapshot.data.getKeys().toList());
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}