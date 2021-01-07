
import 'package:blog_app/Screens/create_blog.dart';
import 'package:blog_app/Services/crud.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  CrudMethods crudMethods = CrudMethods();
  QuerySnapshot blogsSnapshot;

  // ignore: non_constant_identifier_names
  Widget BlogList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("blogs").snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Error ${snapshot.hasError}");
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text("Loading....");
                    break;
                  default:
                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          return BlogsTile(
                            authorName: snapshot.data.docs[index]['authorName'],
                            description: snapshot.data.docs[index]['description'],
                            imageUrl: snapshot.data.docs[index]['imageUrl'],
                            title: snapshot.data.docs[index]['title'],
                          );
                        });
                }
              }),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    crudMethods.getData().then((result) {
       blogsSnapshot = result;
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Flutter',
            style: TextStyle(
                fontSize: 24),
            ),
            Text('Blog',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.blueAccent),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: BlogList(),
      ) ,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateBlog()),
            );
          },
          child: Icon(Icons.add),
        )
      ),
    );
  }
}


class BlogsTile extends StatelessWidget {

  String imageUrl,authorName,title,description;
  BlogsTile(
      { @required this.imageUrl,
        @required this.authorName,
        @required this.title,
        @required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 19),
      height: 150,
      child: Stack(
        children: <Widget> [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.fill,
                height: 150,
                width: MediaQuery.of(context).size.width,
                placeholder: (context,url) => CircularProgressIndicator(),
              ),
          ),

          Container(
            decoration: BoxDecoration (
              color: Colors.black45.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  authorName,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4,),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 4,),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

