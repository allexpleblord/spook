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
  // For the home title
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

  // Change route
  void _getStory(id) {
    Navigator.push( 
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Story(id),
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

  // List tile
  Widget _buildTile(post, saved) {
    return ListTile(
      title: Text(post['title']),
      subtitle: Text(post['date']),
      trailing: IconButton(
        icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
        onPressed: () {
          if (saved) {
            removeBookmark(post['id']);
          } else {
            addBookmark(post['id']);
          }
        },
      ),
      onTap: () {
        _getStory(post['id']);
      },
    );
  }

  // List builder
  // Length is `i + 1` and selector is `i - 1` so that the title can be
  // output first when i is 0
  Widget _buildList(posts) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      separatorBuilder: (BuildContext ctx, int i) => Divider(),
      itemCount: posts.length + 1,
      itemBuilder: (BuildContext ctx, int i) {
        if (i == 0) return _homeTitle();
        return FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            var keys = snapshot.data.getKeys();
            if (keys.contains(posts[i - 1]['id'])) {
              return _buildTile(posts[i - 1], true);
            } else {
              return _buildTile(posts[i - 1], false);
            }
          },
        );
      },
    );
  }


  // Main build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SPOOK'),
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.collections_bookmark),
          onPressed: () {
            _getBookmarked();
          },
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('storyList').snapshots(),
        builder: (context, snapshot) {
          // If no data yet
          if (!snapshot.hasData) return CircularProgressIndicator();

          var stories = snapshot.data.documents;
          return _buildList(stories);
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

Future<bool> checkBookmark(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool bookmarked = prefs.getBool(id);
  return bookmarked ?? false;
}
