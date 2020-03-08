import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  User user;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  bool _bioValid = true;
  bool _displayNameValid = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    setState(() {
      this.user = User.fromDocument(doc);
      isLoading = false;
    });
    _nameController.text = user.displayName;
    _bioController.text = user.bio;
  }

  _updateProfileData() {
    setState(() {
      _displayNameValid = _nameController.text.trim().length > 3 &&
          _nameController.text.isNotEmpty;
      _bioValid = _bioController.text.trim().length < 100;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.document(widget.currentUserId).updateData({
        'displayName': _nameController.text,
        'bio': _bioController.text,
      });
      SnackBar snackBar = SnackBar(
        content: Text('Profile updated!'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  _logout() async {
    await googleSignIn.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Home(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              color: Colors.green,
              size: 30.0,
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    backgroundColor: Colors.grey,
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _nameController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      errorText:
                          _displayNameValid ? null : 'Display name too short',
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _bioController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      errorText: _bioValid ? null : 'bio too long',
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  alignment: Alignment.center,
                  child: RaisedButton(
                    onPressed: _updateProfileData,
                    child: Text(
                      'Update Profile',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  alignment: Alignment.center,
                  child: FlatButton.icon(
                    onPressed: _logout,
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
