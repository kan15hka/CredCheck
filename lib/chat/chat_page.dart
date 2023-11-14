import 'package:credcheck/chat/chat_messages.dart';
import 'package:credcheck/chat/message_panel.dart';
import 'package:credcheck/constants.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Cred Chat",
          style: TextStyle(color: Colors.white, fontSize: 25.0),
        ),
      ),
      body: const Column(
        children: [
          Expanded(
            // child: Container(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       MessageBubble(false, "Hi Sir"),
            //       MessageBubble(
            //           false, "The Document uploaded has been rejected"),
            //       MessageBubble(false, "May I know the reason"),
            //       MessageBubble(true, "Sure"),
            //       MessageBubble(
            //           true, "That was not approved by the organisation")
            //     ],
            //   ),
            // ),
            child: ChatMessages(),
          ),
          MessagePanel()
        ],
      ),
    );
  }
}

Widget MessageBubble(bool isMe, String message) {
  return Row(
    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          color: isMe ? kBlack : kGrey,
          borderRadius: BorderRadius.only(
            topLeft: !isMe ? Radius.zero : const Radius.circular(12),
            topRight: isMe ? Radius.zero : const Radius.circular(12),
            bottomLeft: const Radius.circular(12),
            bottomRight: const Radius.circular(12),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 14,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 12,
        ),
        child: Text(
          message,
          style: TextStyle(
            height: 1.3,
            fontSize: 15.0,
            color: isMe ? kWhite : kBlack,
          ),
          softWrap: true,
        ),
      ),
    ],
  );
}
