import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});
  @override
  State<StatefulWidget> createState() {
    return _NewMessages();
  }
}

class _NewMessages extends State<NewMessages> {
  final _messagesController = TextEditingController();
  @override
  void dispose() {
    _messagesController.dispose();
    super.dispose();
  }

  void _submitMessages() async {
    final enterdMessages = _messagesController.text;
    if (enterdMessages.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _messagesController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userstoreg =
        await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

    await FirebaseFirestore.instance.collection('chat').add({
      'text': enterdMessages,
      'created_At': Timestamp.now(),
      'user_uid': user.uid,
      'userName': userstoreg.data()!['username'],
      'image': userstoreg.data()!['image_url']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 5, top: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messagesController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(
                hintText: 'Enter Message',
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1, //<-- SEE HERE
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
            onPressed: _submitMessages,
          )
        ],
      ),
    );
  }
}
