import 'package:blog_app/Services/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';


class CreateBlog extends StatefulWidget {
  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {

  String authorName,title,description;
  bool _isLoading = false;


  CrudMethods crudMethods = CrudMethods();
  String imageUrl;
  File _selectedImage;
  final picker = ImagePicker();


  Future getImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void uploadBlog () async {
    if (_selectedImage != null) {
      setState(() {
        _isLoading = true;
      });

      // Upload Image to Firebase Storage


      Reference firebaseStorageRef = FirebaseStorage.instance.ref()
          .child("blogImages")
          .child("${randomAlphaNumeric(9)}.jpg");

      final UploadTask task = firebaseStorageRef.putFile(_selectedImage);

      await task.whenComplete(() async {
        try {
          imageUrl = await firebaseStorageRef.getDownloadURL();
        } catch (e) {
          print(e);
        }
      });

      Map<String, dynamic> blogMap = {
        "imageUrl": imageUrl,
        "authorName": authorName,
        "title": title,
        "description": description,
      };
      
      
      FirebaseFirestore.instance
          .collection("blogs")
          .add(blogMap)
          .catchError((onError) {
            print("facing an issue while uploading data to firestore : $onError");
      });

     // crudMethods.addData(blogMap).then((result) {
       Navigator.pop(context);
      //});
    } else {}
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
        actions: [
          GestureDetector(
            onTap: (){
              uploadBlog();
            },
            child: Container(color: Colors.transparent,

              padding: EdgeInsets.symmetric(horizontal: 15),
                child: Icon(
                  Icons.upload_rounded,),
            ),
          )
        ],
      ),

      body: _isLoading ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ) : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
          child: Column(
            children: [
              GestureDetector(

                child: GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: _selectedImage != null ? Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage,
                          fit: BoxFit.fill,)
                    ),
                  )
                      : Container(
                      height: 130,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        color: Colors.black26,size: 40,),
                  ),
                ),
              ),
              SizedBox(height: 8),

              TextField(
                onChanged:(value){
                  authorName = value;
                },
                decoration: InputDecoration(
                  hintText: 'Author Name'
                ),
              ),
              SizedBox(height: 8),

              TextField(
                onChanged:(value){
                  title = value;
                },
                decoration: InputDecoration(
                    hintText: 'Title'
                ),
              ),
              SizedBox(height: 8),

              TextField(
                onChanged:(value){
                  description = value;
                },
                decoration: InputDecoration(
                    hintText: 'Description'
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

