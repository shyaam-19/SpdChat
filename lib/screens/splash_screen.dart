import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spd_chat/api/apis.dart';
import 'package:spd_chat/main.dart';
import 'package:spd_chat/screens/authentication/login_screen.dart';
import 'package:spd_chat/screens/home_screen.dart';
// import 'package:spd_chat/screens/home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

//  bool _isAnimate= false;

 void initState()
 {
        super.initState();
        Future.delayed(Duration(milliseconds: 1500),(){
         SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
         SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor:Colors.white,statusBarColor: Colors.transparent));

         if(APIs.auth.currentUser!=null)
         {
          log('\nUser:${APIs.auth.currentUser}' );
        
               Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>HomeScreen()));
         }
         else
         {
         Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>LoginScreen()));
         }

        });
 }
  @override
  Widget build(BuildContext context) {
     mq=MediaQuery.of(context).size;
   
    return Scaffold(

      // appBar: AppBar(
      
      //   centerTitle: true,
      
      //   title: Text("Welcome to SpdChat"),
      
      //   ),

    

        body: Stack(children:
         [Positioned
        ( 
          top:mq.height* .15,
          width:mq.width* .5,
          right: mq.width* .25,
          child: Image.asset('images/chat.png',)
          
          ),
          
          Positioned
        (
          bottom:mq.height* .15,
          width:mq.width* .9,
          left: mq.width* .05,
          height:mq.height* .07,
         child: Text("MADE BY SHYAM 😎",style: TextStyle(fontSize: 16,color: Colors.black),textAlign:TextAlign.center,),
          
          ),
          ]
          
        
          
          ),

        
    );
  }
}