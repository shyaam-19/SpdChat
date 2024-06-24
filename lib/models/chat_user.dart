// class ChatUser{

// }



//serach in the google json to dart will null safety

class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
  });
  late  String image;
  late  String name;
  late  String about;
  late  String createdAt;
  late  bool isOnline;
  late  String id;
  late  String lastActive;
  late  String email;
  late  String pushToken;
  
  ChatUser.fromJson(Map<String, dynamic> json){
    image = json['image'].toString();
    name = json['name'].toString();
    about = json['about'].toString();
    createdAt = json['created_at'].toString();
    isOnline = json['is_online']?? '';
    id = json['id'].toString();
    lastActive = json['last_active'].toString();
    email = json['email'].toString();
    pushToken = json['push_token'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}