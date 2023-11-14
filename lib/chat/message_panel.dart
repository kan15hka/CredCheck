import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credcheck/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessagePanel extends StatefulWidget {
  const MessagePanel({super.key});

  @override
  State<MessagePanel> createState() {
    return _MessagePanelState();
  }
}

class _MessagePanelState extends State<MessagePanel> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('userverif')
        .doc(user.email)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userName': userData.data()!['name'],
      'userImage': userData.data()!['imageUrl'],
      'userRole': userData.data()!['role'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 15, top: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                hintText: 'Send a message...',
                enabledBorder: OutlineInputBorder(
                  //gapPadding: 0.0,
                  borderSide:
                      const BorderSide(width: 2, color: kBlack), //<-- SEE HERE
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  //gapPadding: 0.0,
                  borderSide:
                      const BorderSide(width: 2, color: kBlack), //<-- SEE HERE
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(
              Icons.send,
              color: kBlack,
            ),
            onPressed: _submitMessage,
          ),
        ],
      ),
    );
  }
}
