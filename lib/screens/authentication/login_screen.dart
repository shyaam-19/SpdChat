import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spd_chat/api/apis.dart';
import 'package:spd_chat/helper/dialogs.dart';
import 'package:spd_chat/main.dart';
import 'package:spd_chat/screens/home_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

 bool _isAnimate= false;

 void initState()
 {
        super.initState();
        Future.delayed(Duration(milliseconds: 500),(){
          setState(() {
            _isAnimate=true;
          });
        });
 }

 _handlegoogleBtnClick()     //made by own
 {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {

      Navigator.pop(context);
      if(user !=null)
      {
      log('\nUser:${user.user}' );
      log('\nUserAdditionalInfo:${user.additionalUserInfo}');


      if((await APIs.userExists()))
      {
           Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>HomeScreen()));
      }
      else
      {
        await APIs.createUser().then((value){
          Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>HomeScreen()));
        });
      }

      
      }
    });
 }



Future<UserCredential?> _signInWithGoogle() async {
 
 try{
  await InternetAddress.lookup('google.com');

   // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await APIs.auth.signInWithCredential(credential);
 }catch(e){
   log('\n_signInWithGoogle:$e');
   Dialogs.showSnackbar(context,'Something Went Wrong(Check Internet!)');

 }
 return null;
}


// sign out Function
// _signOut()async{
//   await FirebaseAuth.instance.signOut();
//   await GoogleSignIn().signOut();
// }
  @override
  Widget build(BuildContext context) {
     mq=MediaQuery.of(context).size;
   
    return Scaffold(

      appBar: AppBar(
      
        centerTitle: true,
      
        title: Text("Welcome to SpdChat"),
      
        ),

    

        body: Stack(children:
         [AnimatedPositioned
        ( duration:Duration(seconds: 1) ,
          top:mq.height* .15,
          width:mq.width* .5,
          right:_isAnimate? mq.width* .25:-mq.width*.5,
          child: Image.asset('images/chat.png',)
          
          ),
          
          Positioned
        (
          bottom:mq.height* .15,
          width:mq.width* .9,
          left: mq.width* .05,
          height:mq.height* .07,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor:Color.fromARGB(255, 99, 162, 101),shape: StadiumBorder()),
            
            onPressed:(){
             _handlegoogleBtnClick();
            }, icon:Image.asset('images/google.png',height: mq.height*0.05), label:RichText(text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [

                TextSpan(text: '   Login with'),
                TextSpan(text: ' Google',style:TextStyle(fontWeight: FontWeight.bold) ),

            ]

              
            )))
          
          ),
          ]
          
        
          
          ),

        
    );
  }
}