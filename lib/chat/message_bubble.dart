import 'package:cached_network_image/cached_network_image.dart';
import 'package:credcheck/constants.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.userName,
    required this.userRole,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.userRole,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        userName = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? userName;
  final String message;
  final bool isMe;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Stack(
          children: [
            if (userImage != null)
              Positioned(
                  top: 15, right: isMe ? 0 : null, child: ProfileImage()),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 46),
              child: Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (isFirstInSequence) const SizedBox(height: 18),
                      if (userName != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 13,
                            right: 13,
                          ),
                          child: Text(
                            userName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: isMe
                              ? kBlack
                              : const Color.fromARGB(255, 194, 194, 194),
                          borderRadius: BorderRadius.only(
                            topLeft: !isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(8),
                            topRight: isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(8),
                            bottomLeft: const Radius.circular(8),
                            bottomRight: const Radius.circular(8),
                          ),
                        ),
                        constraints: const BoxConstraints(maxWidth: 200),
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
                            color: isMe ? kWhite : kBlack,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: kBlack,
          child: CircleAvatar(
            radius: 24,
            child: ClipRRect(
              child: CachedNetworkImage(
                imageUrl: userImage!,
                imageBuilder: (context, imageProvider) => Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                fit: BoxFit.cover,
                placeholder: (context, url) => Image.asset(
                    "assets/images/placeholder.jpg",
                    width: 80.0,
                    height: 80.0,
                    fit: BoxFit.cover),
                errorWidget: (context, url, error) => Image.asset(
                    "assets/images/placeholderError.jpg",
                    width: 80.0,
                    height: 80.0,
                    fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        if (userRole == "verifier")
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Container(
              height: 20.0,
              width: 20.0,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.green),
            ),
          )
      ],
    );
  }
}
