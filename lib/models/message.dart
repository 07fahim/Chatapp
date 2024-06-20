class Message {
  Message({
    required this.msg,
    required this.read,
    required this.told,
    required this.type,
    required this.send,
    required this.fromId,
  });
  late final String msg;
  late final String read;
  late final String told;
  late final Type type;
  late final String send;
  late final String fromId;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    read = json['read'].toString();
    told = json['told'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    send = json['send'].toString();
    fromId = json['fromId'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['told'] = told;
    data['type'] = type.name;
    data['send'] = send;
    data['fromId'] = fromId;
    return data;
  }
}

enum Type { text, image }
