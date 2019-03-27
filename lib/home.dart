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
      body: StreamBuilder(
        stream: Firestore.instance.collection('storyList').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var stories = snapshot.data.documents;
            return _buildList(stories);
          } else {
            return Text('');
          }
        },
      ),
    );
  }

  // Home page title
  Widget _homeTitle() {
    return Padding(
      padding: EdgeInsets.all(35.0),
      child: Text(
        'A collection of hand picked spooky stories.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
    );
  }

  // Make a list
  Widget _buildList(stories) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      separatorBuilder: (BuildContext ctx, int i) => Divider(),
      itemCount: stories.length + 1, // Increase by one so that title can go in when i == 0
      itemBuilder: (BuildContext ctx, int i) {
        // Return title first
        if (i == 0) return _homeTitle();

        // Then return streambuilder to get the bookmarks
        // Selector is i - 1 since I increased the itemCount by 1
        return StreamBuilder(
          stream: SharedPreferences.getInstance().asStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              bool saved = snapshot.data.getKeys().contains(stories[i - 1]['id']);
              return _buildListTile(stories[i - 1], saved);
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
