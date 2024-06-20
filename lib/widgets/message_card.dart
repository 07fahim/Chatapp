import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gropie/api/apis.dart';
import 'package:gropie/helper/dialogs.dart';
import 'package:gropie/helper/my_date_utill.dart';
import 'package:gropie/main.dart';
import 'package:gropie/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _redMessage() : _pinkMessage(),
    );
  }

  Widget _pinkMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 249, 160, 160),
                // border: Border.all(color: Color.fromARGB(206, 254, 74, 74)),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtill.getFormattedTime(
                context: context, time: widget.message.send),
            style: TextStyle(fontSize: 13, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  Widget _redMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .04),
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Color.fromARGB(179, 249, 51, 51),
                size: 20,
              ),
            SizedBox(width: 2),
            Text(
              MyDateUtill.getFormattedTime(
                  context: context, time: widget.message.send),
              style: TextStyle(fontSize: 13, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 251, 84, 84),
                // border: Border.all(color: Color.fromARGB(206, 254, 74, 74)),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: Icon(
                        Icons.copy,
                        color: const Color.fromARGB(255, 243, 85, 74),
                        size: 26,
                      ),
                      name: "Copy",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);

                          Dialogs.showSnackBar(context, 'Text Copied!');
                        });
                      })
                  : _OptionItem(
                      icon: Icon(
                        Icons.download_rounded,
                        color: const Color.fromARGB(255, 243, 85, 74),
                        size: 26,
                      ),
                      name: "Save image",
                      onTap: () {}),
              Divider(
                color: Color.fromARGB(255, 249, 15, 66),
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: Icon(
                      Icons.edit,
                      color: Color.fromARGB(255, 255, 67, 67),
                      size: 26,
                    ),
                    name: "Edit Message",
                    onTap: () {
                      Navigator.pop(context);

                      _showMessageUpdateDialog();
                    }),
              if (isMe)
                _OptionItem(
                    icon: Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                      size: 26,
                    ),
                    name: "Delete Message",
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {});

                      Navigator.pop(context);
                    }),
              Divider(
                color: Color.fromARGB(255, 249, 15, 66),
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                  ),
                  name:
                      "Sent :  ${MyDateUtill.getMessageTime(context: context, time: widget.message.send)}",
                  onTap: () {}),
              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Color.fromARGB(255, 253, 28, 92),
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Seen : Not seen yet'
                      : "Seen : ${MyDateUtill.getMessageTime(context: context, time: widget.message.read)}",
                  onTap: () {}),
            ],
          );
        });
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(children: const [
                Icon(
                  Icons.message,
                  color: Color.fromARGB(255, 255, 67, 67),
                  size: 28,
                ),
                Text(' Update Message')
              ]),
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Color.fromARGB(255, 250, 103, 103),
                        fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.updateMessage(widget.message, updatedMsg);
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(
                        color: Color.fromARGB(255, 250, 103, 103),
                        fontSize: 16),
                  ),
                )
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          right: mq.height * .015,
          bottom: mq.height * .015,
        ),
        child: Row(children: [
          icon,
          Flexible(
              child: Text('   $name',
                  style: const TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(136, 246, 77, 128),
                      letterSpacing: 0.5)))
        ]),
      ),
    );
  }
}
