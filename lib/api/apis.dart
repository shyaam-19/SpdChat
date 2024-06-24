import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
// import 'package:flutter/cupertino.dart';
import 'package:spd_chat/models/chat_user.dart';
import 'package:spd_chat/models/message.dart';

class APIs{

  static FirebaseAuth auth= FirebaseAuth.instance;

  static FirebaseFirestore firestore =FirebaseFirestore.instance;

  static FirebaseStorage storage =FirebaseStorage.instance;

  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;
  
    static Future<void> getFirebaseMessegingToken()async{

      await fmessaging.requestPermission();

      await fmessaging.getToken().then((t){
           if(t!=null)
           {
            me.pushToken=t;
            log('Push Token :$t');
           }
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
       log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
  }
});

    }

static Future<void> sendPushNotification(ChatUser chatUser,String msg) async
{
    try{
       final body ={
       "to":chatUser.pushToken,
       "notification":{
        "title":chatUser.name,
        "body":msg,
        "android_channel_id":"chats",
       },
        "data": {
    "some_data" : "User ID : ${me.id}",
  },
     };
     
       var response = await post(Uri.parse('https://googleapis.com/fcm/send'), 
       headers: {
        HttpHeaders.contentTypeHeader:'application/json',
        HttpHeaders.authorizationHeader:'key=AAAADZAOrHo:APA91bFXXKMmaefbKSr4HDWp_rRA1KkSitSxK5B4EAgQiGpwAS01zwtNyeTd48ZyL_KuMt2DaXMVos7iJZ-BK_wpkJNv7HsSrFmIBBWSxR6MlcyC6H-pvs59F6qLE8ilNl1mgki_prid'
       },
       body: jsonEncode(body));
       print('Response status: ${response.statusCode}');
       print('Response body: ${response.body}');
    }
    catch(e)
    {
       log('\nsendPushNotification:$e');
    }
}



   static User get user => auth.currentUser!;

   //for storing self information
   static late ChatUser me;

  //for checking if user exist or not?
  static Future<void> getSelfInfo()async{

       await firestore.collection('users').doc(user.uid).get().then((user) async {
           if(user.exists)
           {
            me=ChatUser.fromJson(user.data()!);
           await getFirebaseMessegingToken();
             APIs.updateActiveStatus(true);
            log('My Data:${user.data()}');
           }
           else
           {
           await createUser().then((value) => getSelfInfo());
           }
       });
  }


   static Future<bool> userExists()async{

      return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

   static Future<bool> addChatUser(String email)async{
    

      final data=await firestore.collection('users').where('email',isEqualTo: email).get();

      if(data.docs.isNotEmpty && data.docs.first.id!=user.uid)
      {
        firestore.collection('users').doc(user.uid).collection('my_users').doc(data.docs.first.id).set({});
        return true;
      }
      else
      {
        return false;
      }
  }



  //for creating a new user

   static Future<void> createUser()async{

        final time = DateTime.now().millisecondsSinceEpoch.toString();

       final chatUser =ChatUser(

   

        id:user.uid,
        name: user.displayName.toString(),
        email:user.email.toString(),
        about: "Hey ,I'm using SpdChat",
        image:user.photoURL.toString() ,
        createdAt:time ,
        isOnline:false ,
        lastActive:time ,
        pushToken: ''
        
           
        );
        return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
        
      
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>>  getMyUserId(){
    return  APIs.firestore.collection('users').doc(user.uid).collection('my_users').snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>  getAllUser(List<String> userIds){
    log('\nUserIds: $userIds');

    return  firestore.collection('users').where('id',whereIn: userIds.isEmpty?['']:userIds).snapshots();
  }

    static Future<void> sendFirstMessage(ChatUser chatUser,String msg,Type type)async{

    await firestore.collection('users').doc(chatUser.id).collection('my_user').doc(user.uid).set({}).
    then((value) =>sendMessage(chatUser, msg, type) ,);
  }


  static Future<void> updateUserInfo()async{

    await firestore.collection('users').doc(user.uid).update({'name':me.name,'about':me.about,});
  }



  static Stream<QuerySnapshot<Map<String, dynamic>>>  getUserInfo(ChatUser chatUser){

     return  APIs.firestore.collection('users').where('id',isEqualTo: chatUser.id).snapshots();

  }

  static Future<void> updateActiveStatus(bool isOnline)async
  {
     firestore.collection('users').doc(user.uid).update(
      {'is_online':isOnline,
      'last_active':DateTime.now().millisecondsSinceEpoch,
       'push_token':me.pushToken,
      
      });
  }

  static Future<void> updateProfilePicture(File file)async{
     
     final ext=file.path.split('.').last;
      log('Extension:$ext');
      final ref =storage.ref().child('profile_picture/${user.uid}.$ext');
      await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0){
        log('Data transerred :${p0.bytesTransferred/1000} kb');
      });
        me.image=await ref.getDownloadURL();
       await firestore.collection('users').doc(user.uid).update({'image':me.image});
  }

  static getConversationalID(String id)=> user.uid.hashCode<=id.hashCode
       ?'${user.uid}_$id'
       :'${id}_${user.uid}';


   static Stream<QuerySnapshot<Map<String, dynamic>>>  getAllMessages(ChatUser user){
    return  APIs.firestore.collection('chat/${getConversationalID(user.id)}/messages/')
    .orderBy('sent',descending:true)
    .snapshots();

   
  }

  static Future<void> sendMessage(ChatUser chatUser,String msg,Type type)async
  {
       final  time=DateTime.now().millisecondsSinceEpoch.toString();
       final Message message=Message(msg: msg, toId: chatUser.id, read:'', type:type, fromId: user.uid, sent:time);

         final ref=firestore.collection('chat/${getConversationalID(chatUser.id)}/messages/');
         ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser,type==Type.text?msg:'image'));
  }



  static Future<void> updateMessageReadStatus(Message message)async{


    firestore.collection('chat/${getConversationalID(message.fromId)}/messages/')
    .doc(message.sent)
    .update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
  }


  static Stream<QuerySnapshot<Map<String, dynamic>>>  getLastMessage(ChatUser user){

    return  firestore.collection('chat/${getConversationalID(user.id)}/messages/')
    .orderBy('sent',descending:true)
    .limit(1)
    .snapshots();

  }

  static Future<void> sendChatImage(ChatUser chatUser ,File file)
  async {
         final ext=file.path.split('.').last;
  
      final ref =storage.ref().child('images/${getConversationalID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
      await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0){
        log('Data transerred :${p0.bytesTransferred/1000} kb');
      });
        final imageUrl=await ref.getDownloadURL();
        sendMessage(chatUser,imageUrl, Type.image);
  }

  static Future<void> deleteMessage(Message message)async{
    
    await firestore.collection('chat/${getConversationalID(message.toId)}/messages/')
    .doc(message.sent)
    .delete();
    
    if(message.type==Type.image){
    await storage.refFromURL(message.msg).delete();
    }
  }
}