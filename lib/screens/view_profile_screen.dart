
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:html';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spd_chat/helper/my_date_util.dart';
import 'package:spd_chat/main.dart';
import 'package:spd_chat/models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {

  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ViewProfileScreen> {




  @override
  Widget build(BuildContext context) {
     return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
       child: Scaffold(
     
        appBar: AppBar(
        
          centerTitle: true,
          
          title: Text(widget.user.name),
         
        
          
          ),

            //  SizedBox(height: mq.height*.02),
          
          floatingActionButton:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Joined On:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 16),),
                      Text(MyDateUtil.getLastMessageTime(context: context, time:widget.user.createdAt,showYear: true),style: TextStyle(color: Colors.black54,fontSize: 16)),
                    ],
                  ),
     
         
           body: Padding(
             padding: EdgeInsets.symmetric(horizontal: mq.width*.05),
             child: SingleChildScrollView(
               child: Column(children: [
                  
                SizedBox(width: mq.width,height: mq.height*.03),
                ClipRRect(
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
                  
                  
                 SizedBox(width: mq.width,height: mq.height*.03),
                 Text(widget.user.email,style: TextStyle(color: Colors.black,fontSize: 16)),
                 SizedBox(height: mq.height*.02),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('About : ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 16),),
                      Text(widget.user.about,style: TextStyle(color: Colors.black54,fontSize: 16)),
                    ],
                  ),
                  
                
                  
                   SizedBox(height: mq.height*.05),
                  
               
                        
               ],),
             ),
           )
     
         
         ),
     );
  }



  
}

