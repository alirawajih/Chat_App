import 'package:chatapp/widget/chat_messages.dart';
import 'package:chatapp/widget/new_messages.dart';
// import 'package:chatapp/widget/timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? action = '';
  void setupnotification() async {
    final firebasNotification = FirebaseMessaging.instance;
    await firebasNotification.requestPermission();
    final token = await firebasNotification.getToken();

    print(token);
    firebasNotification.subscribeToTopic('chat');
  }

  void getemail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      action = prefs.getString('email');
      // print(action);
    });
  }

  @override
  void initState() {
    super.initState();
    setupnotification();
    getemail();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[200],
            title: Text.rich(
              TextSpan(
                text: 'Chat app   ',
                children: <TextSpan>[
                  TextSpan(
                      text: '$action',
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue)),
                ],
              ),
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      // turns: animation,
                      turns: Tween(begin: 0.7, end: 1.0).animate(animation),
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.exit_to_app,
                  ),
                ),
              )
            ],
            // leading: const Center(child: Timer()),
          ),
          body: Column(
            children: [
              const Expanded(child: ChatMessages()),
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 236, 232, 232),
                ),
                child: const NewMessages(),
              ),
            ],
          )),
    );
  }
}
