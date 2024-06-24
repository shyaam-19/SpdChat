import 'dart:developer';

import "package:flutter/material.dart";


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

import 'package:spd_chat/screens/splash_screen.dart';
import 'firebase_options.dart';

late Size mq;

void main()
{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value)
  {
    _initializeFirebase();
  runApp(MyApp());
  }

  );
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

            debugShowCheckedModeBanner: false,
            title: 'Spd Chat',
            theme:ThemeData(primarySwatch: Colors.green),
            home: SplashScreen(),

    );
  }
}


_initializeFirebase()
async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'showing msg notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',

);
 log('\nNotification Channel Result :$result');
}