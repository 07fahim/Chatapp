import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gropie/helper/my_date_utill.dart';
import 'package:gropie/models/chat_user.dart';
import 'package:gropie/models/message.dart';
import 'package:gropie/widgets/dialogs/profile_dialog.dart';

import '../api/apis.dart';
import '../main.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Theme.of(context).colorScheme.background.withOpacity(.08),
      elevation: 0.5,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: CircleAvatar(
                    //child: Icon(CupertinoIcons.person),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        width: mq.height * .055,
                        height: mq.height * .055,
                        imageUrl: widget.user.image,
                        //placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                    ),

                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  widget.user.name,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? 'You Sent a Photo'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1,
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 16, 247, 135),
                                borderRadius: BorderRadius.circular(10)),
                          )
                        : Text(
                            MyDateUtill.getLastMessageTime(
                                context: context, time: _message!.send),
                            style: const TextStyle(color: Colors.black54),
                          ),
              );
            },
          )),
    );
  }
}
