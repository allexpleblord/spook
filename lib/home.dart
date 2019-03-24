import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './story.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Set<String> bookmarked = {};

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

  // Will fill the bookmarked set
  void _fillBookmarks(posts) {
    for (var i = 0; i < posts.length; i++) {
      checkBookmark(posts[i]['id']).then((value) {
        if (value) setState(() {
          bookmarked.add(posts[i]['id']);
        });
      });
    }
  }

  // Change route
  void _getStory(id) {
    Navigator.push( 
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Story(id)
      ),
    );
  }

  // List tile
  Widget _buildTile(post) {
    return ListTile(
      title: Text(post['title']),
      subtitle: Text(post['date']),
      trailing: IconButton(
        icon: Icon(
          bookmarked.contains(post['id']) ? Icons.bookmark : Icons.bookmark_border,
        ),
        onPressed: () {
          // Set state and update preferences
          setState(() {
            if (bookmarked.contains(post['id'])) {
              removeBookmark(post['id']);
              bookmarked.remove(post['id']);
              print(bookmarked);
            } else {
              addBookmark(post['id']);
              bookmarked.add(post['id']);
              print(bookmarked);
            }
          });
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
        return _buildTile(posts[i - 1]);
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
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('storyList').snapshots(),
        builder: (context, snapshot) {
          // If no data yet
          if (!snapshot.hasData) return const Center(
            child: Text('Loading posts...'),
          );

          var stories = snapshot.data.documents;
          _fillBookmarks(stories);
          // Else get the data and build the list
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
  prefs.setBool(id, false);
}

Future<bool> checkBookmark(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool bookmarked = prefs.getBool(id);
  return bookmarked ?? false;
}
