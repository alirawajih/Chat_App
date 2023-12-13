import 'dart:io';

import 'package:chatapp/widget/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _islogin = true;
  var _email = '';
  var _name = '';
  var _password = '';
  File? _imageuser;
  bool _imageIsEmpty = false;
  var _isAuthenticating = false;
  // String masseges = 'should Fill  all fields';
  void _submit() async {
    final isValoid = _formKey.currentState!.validate();

    if (!isValoid || !_islogin && _imageuser == null) {
      if (!_islogin && _imageuser == null)
        setState(() {
          _imageIsEmpty = true;
        });
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      if (_islogin) {
        final userAuth = await _firebase.signInWithEmailAndPassword(
            email: _email, password: _password);
        await prefs.setString('email', _email);
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        final storegpath = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredential.user!.uid}.jpg');
        await prefs.setString('email', _email);

        await storegpath.putFile(_imageuser!);
        final imageurl = await storegpath.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('user')
            .doc(userCredential.user!.uid)
            .set({'username': _name, 'email': _email, 'image_url': imageurl});
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //...
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed .'),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      // appBar: AppBar(
      //   title: const Text('Auth User in Chat App'),
      // ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  top: 30, bottom: 20, left: 20, right: 20),
              width: 200,
              child: Image.asset('assets/images/chat.png'),
            ),
            Card(
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_islogin)
                            Container(
                              // elevation: 0,
                              decoration: _imageIsEmpty
                                  ? BoxDecoration(
                                      border: Border.all(color: Colors.red))
                                  : null,
                              // shape:
                              //      RoundedRectangleBorder(
                              //         side: BorderSide(color: Colors.red),
                              //         borderRadius: BorderRadius.circular(15.0),
                              //       )
                              //     ,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: ImagePickerUser(
                                  onPickImage: (image) {
                                    _imageuser = image;
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!_islogin)
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Name',
                          ),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.trim().length < 4) {
                              return 'the name not valid should at least 4 characters.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _name = value!;
                          },
                        ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains(RegExp(r'\S+@\S+$'))) {
                            return 'the email not valid.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length <= 6) {
                            return 'Passwerd must be at least 6 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              child: Text(_islogin ? 'login' : 'signup'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _islogin = !_islogin;
                                    _formKey.currentState?.reset();
                                    _imageIsEmpty = false;
                                  });
                                },
                                child: Text(
                                  _islogin
                                      ? 'Create new account'
                                      : 'I already have an account ',
                                  style: const TextStyle(color: Colors.black54),
                                ))
                        ],
                      )
                    ]),
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
