import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './story.dart';
import './bookmarks.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SPOOK'),
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.collections_bookmark),
          onPressed: () { _getBookmarked(); },
        ),
      ),
      body: FutureBuilder(
        future: Firestore.instance.collection('storyList').getDocuments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var stories = snapshot.data.documents;
            return _buildList(stories);
          } else {
            return Text('');
          }
        },
      ),
    );
  }

  // Make a list
  Widget _buildList(stories) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      separatorBuilder: (BuildContext ctx, int i) => Divider(),
      itemCount: stories.length,
      itemBuilder: (BuildContext ctx, int i) {
        return StreamBuilder(
          stream: SharedPreferences.getInstance().asStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              bool saved = snapshot.data.getKeys().contains(stories[i]['id']);
              return _buildListTile(stories[i], saved);
            } else {
              return Text('');
            }
          },
        );
      },
    );
  }
  Widget _buildListTile(story, saved) {
    return ListTile(
      title: Text(story['title']),
      subtitle: Text(story['date']),
      trailing: Icon(
        saved ? Icons.bookmark : Icons.bookmark_border,
        color: Colors.grey[600],
      ),
      onTap: () { _getStory(story['id'], saved); },
    );
  }

  // Other routes
  void _getStory(id, saved) {
    Navigator.push( 
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Story(id, saved),
      ),
    );
  }
  void _getBookmarked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Bookmarks(),
      ),
    );
  }
}
