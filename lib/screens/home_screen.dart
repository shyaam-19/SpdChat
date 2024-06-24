
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:html';

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:spd_chat/api/apis.dart';
import 'package:spd_chat/helper/dialogs.dart';
import 'package:spd_chat/main.dart';
import 'package:spd_chat/models/chat_user.dart';
import 'package:spd_chat/screens/profile_screen.dart';
import 'package:spd_chat/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeScreen> {

   List<ChatUser> _list=[];
   final List<ChatUser> _searchList=[];

   bool _isSearching=false;

   
   @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  
    SystemChannels.lifecycle.setMessageHandler((message) {

      log('Message:$message');
      if(APIs.auth.currentUser!=null){
      if(message.toString().contains('resume'))APIs.updateActiveStatus(true);
      if(message.toString().contains('pause'))APIs.updateActiveStatus(false);
      }


       return Future.value(message);

    });
  }
  @override
  Widget build(BuildContext context) {
     return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
       child: WillPopScope(

        onWillPop: () {
          if(_isSearching){
            setState(() {
               _isSearching=!_isSearching;

            });
            return Future.value(false);
          }
          else
          {
            return Future.value(true);
          }
         

        },
         child: Scaffold(
            
          appBar: AppBar(
          
            centerTitle: true,
            
            
            leading: Icon(CupertinoIcons.home),
            title:_isSearching ?TextField(
              decoration: InputDecoration(border: InputBorder.none,hintText: 'Name,Email..'),
              autofocus: true,
              style: TextStyle(fontSize: 17,letterSpacing: 0.5),
              onChanged: (value) {
                _searchList.clear();
                for(var i in _list)
                {
                  if(i.name.toLowerCase().contains(value.toLowerCase()) || i.email.toLowerCase().contains(value.toLowerCase()) )
                  {
                    _searchList.add(i);
                  }
            
                  setState(() {
                    _searchList;
                  });
                }
              },
            ):Text("Spd Chat"),
            actions: [
              IconButton(onPressed:(){
                setState(() {
                  _isSearching =!_isSearching;
                });
              }, icon:Icon(_isSearching ?CupertinoIcons.clear_circled_solid:Icons.search)),
               IconButton(onPressed:(){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen(user:APIs.me)));
               }, icon:Icon(Icons.more_vert)),
            ],
          
            
            ),
            
            body: StreamBuilder(
               
              stream: APIs.getMyUserId(),
              builder: (context,snapshot){
                 
                  switch(snapshot.connectionState)
                {
                   case ConnectionState.waiting:
                   case ConnectionState.none:
                   return const Center(child: CircularProgressIndicator(),);
            
                   case ConnectionState.active:
                   case ConnectionState.done:
                  return StreamBuilder(
            
              stream:APIs.getAllUser(snapshot.data?.docs.map((e) => e.id).toList()??[]),
              builder: (context, snapshot) {
            
                switch(snapshot.connectionState)
                {
                   case ConnectionState.waiting:
                   case ConnectionState.none:
                   return const Center(child: CircularProgressIndicator(),);
            
                   case ConnectionState.active:
                   case ConnectionState.done:
            
                    
              
                  final data=snapshot.data?.docs;
                   _list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];
                  
                if(_list.isNotEmpty)
                {
                return  ListView.builder(
                itemCount:_isSearching?_searchList.length:_list.length,
                padding: EdgeInsets.only(top: mq.height*.01),
                physics: BouncingScrollPhysics(),
                itemBuilder:(context, index){
                return ChatUserCard(user:_isSearching? _searchList[index]:_list[index],);
                // return Text('Name:${list[index]}');
              },);
                }
                else
                {
                  return Center(child: Text("No Connections found!",style: TextStyle(fontSize:20 ),));
                }
            
            
                  
            
                }
            
             
              },
            );
                 }
                 
            },),
            
            floatingActionButton:Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(onPressed:()async{
                 _addChatUserDialog();
              },child:Icon(Icons.add_comment_rounded) ,),
            ),
           ),
       ),
     );
  }

  void  _addChatUserDialog()
  {
       String email= ' ';

       showDialog(context: context, builder:(_)=>AlertDialog(

              contentPadding: EdgeInsets.only(bottom:10 ,left:24 ,right:24 ,top:20 ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

              title: Row(children: [
                Icon(Icons.person_add,color: Colors.green,size:28),
                Text('  Add User')
              ],),

              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email=value,
                decoration: InputDecoration(
                  hintText: "Email Id",
                  prefixIcon: Icon(Icons.email,color:Colors.green),
                  border:OutlineInputBorder(borderRadius:BorderRadius.circular(15))
                ),
              ),

              actions: [
                MaterialButton(onPressed: (){
                  Navigator.pop(context);
                },

                child:Text('Cancel',style: TextStyle(color: Colors.green,fontSize: 16),)
                
                ),


                MaterialButton(onPressed: (){
                  Navigator.pop(context);
                  if(email.isNotEmpty)
                  APIs.addChatUser(email).then((value) => {
                    if(!value)
                    {
                      Dialogs.showSnackbar(context,'User does not Exists!')
                    }
                  });
                },
                child:Text('Add',style: TextStyle(color: Colors.green,fontSize: 16),)
                )
              ],
       ));
  }



}