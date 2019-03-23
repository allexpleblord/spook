import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './story.dart';

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
        builder: (BuildContext context) => Story(id)
      ),
    );
  }

  // List tile
  Widget _buildTile(post) {
    return ListTile(
      title: Text(post['title']),
      subtitle: Text(post['date']),
      trailing: Icon(Icons.bookmark_border),
      onTap: () {
        _getStory(post['id']);
      }
    );
  }

  // List builder
  Widget _buildList(posts) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      separatorBuilder: (BuildContext ctx, int i) => Divider(),
      itemCount: posts.length,
      itemBuilder: (BuildContext ctx, int i) {
        return _buildTile(posts[i]);
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
          
          // Else get the data and build the list
          return _buildList(snapshot.data.documents);
        },
      ),
    );
  }
}
