
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:html';

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spd_chat/api/apis.dart';
import 'package:spd_chat/helper/dialogs.dart';
import 'package:spd_chat/main.dart';
import 'package:spd_chat/models/chat_user.dart';
import 'package:spd_chat/screens/authentication/login_screen.dart';

class ProfileScreen extends StatefulWidget {

  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProfileScreen> {


  final _formKey =GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
     return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
       child: Scaffold(
     
        appBar: AppBar(
        
          centerTitle: true,
          
          title: Text("Profile Screen"),
         
        
          
          ),
     
           floatingActionButton:Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.amber,
              onPressed:()async{
             Dialogs.showProgressBar(context);

             await APIs.updateActiveStatus(false);

             await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value){
                    Navigator.pop(context);
                    
                      Navigator.pop(context);

                      APIs.auth=FirebaseAuth.instance;
                    
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
                    });
     
             });
             
            },
            icon:Icon(Icons.logout) ,label: Text('Logout')),
          ),
     
           body: Form(
            key: _formKey,
             child: Padding(
               padding: EdgeInsets.symmetric(horizontal: mq.width*.05),
               child: SingleChildScrollView(
                 child: Column(children: [
                    
                  SizedBox(width: mq.width,height: mq.height*.03),
                  Stack(
                    children: [

                      _image!=null ?  ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height*.1),
                      child: Image.file(
                        File(_image!),
                        width: mq.height* .2,
                        height: mq.height* .2,
                        fit: BoxFit.cover,

                       
                         ),
                       )  :   ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height*.1),
                      child: CachedNetworkImage(
                        width: mq.height* .2,
                        height: mq.height* .2,
                        fit:BoxFit.fill,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(child:Icon(CupertinoIcons.person) ),
                         ),
                           ),
                    
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(elevation:1,onPressed:(){
                          _showBottomSheet();
                        } ,shape:CircleBorder(),color:Colors.white,child: Icon(Icons.edit,color: Colors.blue,),))
                    ],
                  ),
                    
                    
                   SizedBox(width: mq.width,height: mq.height*.03),
                   Text(widget.user.email,style: TextStyle(color: Colors.black54,fontSize: 16)),
                   SizedBox(height: mq.height*.05),
                    
                   TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val)=>APIs.me.name=val ??'',
                    validator: (val)=>val!=null  && val.isNotEmpty?null:'Required Field',                    
                    decoration: InputDecoration(prefixIcon:Icon(Icons.person,color: Colors.green[400],),border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),hintText: 'eg . Shyam',label: Text('Name')),
                    
                   ),
                    
                    SizedBox(height: mq.height*.02),
                    
                    TextFormField(
                    initialValue: widget.user.about,
                     onSaved: (val)=>APIs.me.about=val ??'',
                    validator: (val)=>val!=null  && val.isNotEmpty?null:'Required Field', 
                    decoration: InputDecoration(prefixIcon:Icon(Icons.info_outline,color: Colors.green[400],),border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),hintText: 'eg .From...',label: Text('About')),
                    
                   ),
                    
                     SizedBox(height: mq.height*.05),
                    
                   ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(shape: StadiumBorder(),minimumSize: Size(mq.width*.5, mq.height*.06)),
                    onPressed:(){
                      if(_formKey.currentState!.validate())
                      {
                        _formKey.currentState!.save();
                        log('inside vaidate');
                        APIs.updateUserInfo().then((value) {

                          Dialogs.showSnackbar(context,'Profile Updated Successfully!');
                        });
                      }
                    }, icon:Icon(Icons.edit),label:Text('UPDATE',style:TextStyle(fontSize: 16)))
                          
                 ],),
               ),
             ),
           )
     
         
         ),
     );
  }



  void _showBottomSheet()
  {
    showModalBottomSheet(context: context,shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight:Radius.circular(20) )), builder: (_)
    {
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: mq.height*.02,bottom: mq.height*.05),
        children: [

          Text('Pick Profile Picture',textAlign:TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),

          SizedBox(height: mq.height*.02,),

          Row(
            
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            ElevatedButton(
            
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape:CircleBorder(),
              fixedSize:Size(mq.width*.3, mq.height*.15),
            ),
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);
              if(image!=null)
              {
                 setState(() {
                   _image=image.path;
                 });

                 APIs.updateProfilePicture(File(_image!));
                log('Image path:${image.path}--MimeType:${image.mimeType}');
                Navigator.pop(context);
              }
            }, child:Image.asset('images/photo.png')),

            ElevatedButton(
            
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape:CircleBorder(),
              fixedSize:Size(mq.width*.3, mq.height*.15),
            ),
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 80);
              if(image!=null)
              {
                 setState(() {
                   _image=image.path;
                 });
                  APIs.updateProfilePicture(File(_image!));
                log('Image path:${image.path}--MimeType:${image.mimeType}');
                Navigator.pop(context);
              }
            }, child:Image.asset('images/photo-camera.png'))
            
            ],)
        ],
      );
    });
  }
}

