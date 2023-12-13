import 'package:chatapp/widget/messages_buble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('created_At', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('no data yet'));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong ...'));
        }
        final loadMessages = snapshot.data!.docs;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 0),
          child: ListView.builder(
              reverse: true,
              itemCount: loadMessages.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadMessages[index].data();
                final nextChatMessage = index + 1 < loadMessages.length
                    ? loadMessages[index + 1].data()
                    : null;
                final currentMessageuseruid = chatMessage['user_uid'];
                final nextMessageuseruid = nextChatMessage != null
                    ? nextChatMessage['user_uid']
                    : null;
                final nextMessageIsSame =
                    nextMessageuseruid == currentMessageuseruid;
                if (nextMessageIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: user.uid == currentMessageuseruid);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['image'],
                      username: chatMessage['userName'],
                      message: chatMessage['text'],
                      isMe: user.uid == currentMessageuseruid);
                }

                // return Container(
                //   margin: const EdgeInsets.all(5),
                //   decoration: const BoxDecoration(
                //     color: Color.fromARGB(255, 236, 232, 232),
                //   ),
                //   child: Container(
                //     margin: const EdgeInsets.only(left: 15),
                //     child: Text(
                //       loadMessages[index].data()['text'],
                //     ),
                //   ),
                // );
              }),
        );
      },
    );
  }
}
