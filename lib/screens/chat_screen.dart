// import "dart:convert";
// import "dart:developer";

import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:emoji_picker_flutter/emoji_picker_flutter.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:spd_chat/api/apis.dart";
import "package:spd_chat/helper/my_date_util.dart";
import "package:spd_chat/main.dart";
import "package:spd_chat/models/chat_user.dart";
import "package:spd_chat/models/message.dart";
import "package:spd_chat/screens/view_profile_screen.dart";
import "package:spd_chat/widgets/message_card.dart";

// import Material:flutter/cupertino.dart';

class ChatScreen extends StatefulWidget {

  final ChatUser user;

  const ChatScreen({super.key,required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

 List<Message> _list=[];
 final _textController =TextEditingController();


 bool _showEmoji=false,_isUploding=false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
           onWillPop: () {
          if(_showEmoji){
            setState(() {
               _showEmoji=!_showEmoji;

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
              backgroundColor:Colors.white,
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            
            body: Column(
            
              children: [
            
                Expanded(
                  child: StreamBuilder(
                  
                    stream:APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                  
                      switch(snapshot.connectionState)
                      {
                         case ConnectionState.waiting:
                         case ConnectionState.none:
                         return const Center(child: CircularProgressIndicator(),);
                  
                         case ConnectionState.active:
                         case ConnectionState.done:
                  
                          
                          // final _list=['hii','hello'];
                
                        final data=snapshot.data?.docs;
                        
                          
                      
                      
                         _list=data!.map((e) => Message.fromJson(e.data())).toList();
                        
                      if(_list.isNotEmpty)
                      {
                          
                      return  ListView.builder(
                        reverse: true,
                      itemCount:_list.length,
                      padding: EdgeInsets.only(top: mq.height*.01),
                      physics: BouncingScrollPhysics(),
                      itemBuilder:(context, index){
                      return MessageCard(message: _list[index],);
                    },);
                      }
                      else
                      {
                        return Center(child: Text("Say Hii👋! ",style: TextStyle(fontSize:20 ),));
                      }
                  
                  
                        
                  
                      }
                  
                   
                    }, 
                  ),
                ),
                if(_isUploding)
                Align(
                  alignment: Alignment.centerRight,

                  child:Padding(
                    padding: EdgeInsets.symmetric(vertical:8,horizontal: 20),
                    child: CircularProgressIndicator())),
                _chatInput(),
              if(_showEmoji)
             SizedBox(
              height: mq.height*.35,
            
            
               child: EmojiPicker(
                 
                 
                    textEditingController: _textController,
                    config: Config(
                     columns: 8,
                     emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0), 
                     
                 ),
                   ),
             )
            
            
            
              ],
            ),
          ),
        ),
      ),
    );
  }



Widget _appBar()
{
  return InkWell(
    onTap: (){
     Navigator.push(context,MaterialPageRoute(builder: (_)=>ViewProfileScreen(user:widget.user)));

    },
    child: StreamBuilder(stream:APIs.getUserInfo(widget.user) , builder:(context,snapshot){
          final data=snapshot.data?.docs;

              
            final list=data?.map((e) => ChatUser.fromJson(e.data() )).toList()??[];
             

      return Row(
  
      children: [
        IconButton(onPressed: (){
  
          Navigator.pop(context);
        }, icon:Icon(Icons.arrow_back,color: Colors.black54,)),
  
         ClipRRect(
            borderRadius: BorderRadius.circular(mq.height*.3),
            child: CachedNetworkImage(
              width: mq.height* .05,
              height: mq.height* .05,
            imageUrl: widget.user.image,
            // imageUrl:list.isNotEmpty?list[0].image: widget.user.image,
            // placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => const CircleAvatar(child:Icon(CupertinoIcons.person) ),
               ),
          ),
  
          SizedBox(width: 10),
  
            Column(
              
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // list.isNotEmpty?list[0].name:
              Text( widget.user.name,style:TextStyle(fontSize: 16,color: Colors.black87,fontWeight: FontWeight.w500)),
              SizedBox(height: 2,),
              Text(list.isNotEmpty?
              list[0].isOnline?'Online':
              MyDateUtil.getLastActiveTime(context: context, lastActive:list[0].lastActive)
              :MyDateUtil.getLastActiveTime(context: context, lastActive:widget.user.lastActive),style:TextStyle(fontSize: 13,color: Colors.black54)),
  
              
              
              
              ],)
      ],
  
    
  
    );

    })
  );
}


Widget _chatInput()
{
  return Padding(
    padding:EdgeInsets.symmetric(vertical: mq.height*.01,horizontal: mq.width*.025),
    child: Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
          
                  IconButton(onPressed: ()
                  {FocusScope.of(context).unfocus();
                    setState(() {
                      _showEmoji=!_showEmoji;
                    });
                  }, icon:Icon(Icons.emoji_emotions,color: Colors.greenAccent,)),
                  Expanded(child: TextField(
                    controller: _textController,
                     keyboardType: TextInputType.multiline,
                     maxLines:null,
                     onTap: (){
                      if(_showEmoji)
                       setState(() {
                      _showEmoji=!_showEmoji;
                    });


                     },
                    decoration: InputDecoration(
                      hintText:'Type something..',hintStyle:TextStyle(color: Colors.greenAccent),border: InputBorder.none),
                  )),
                  IconButton(onPressed: ()
                  async {
                     final ImagePicker picker = ImagePicker();
              final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);

              for(var i in images)
              {
                  setState(() {
                     _isUploding=true;
                  });
                 await  APIs.sendChatImage(widget.user,File(i.path));

                  setState(() {
                     _isUploding=false;
                  });
              }
             

                  }, icon:Icon(Icons.image,color: Colors.greenAccent,)),
                   IconButton(onPressed: ()
                  async {
                    final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 70);
              if(image!=null)
              {
                 setState(() {
                     _isUploding=true;
                  });
                 await  APIs.sendChatImage(widget.user,File(image.path));
               setState(() {
                     _isUploding=false;
                  });
               
              }
                  }, icon:Icon(Icons.camera_alt_rounded,color: Colors.greenAccent,)),
          
               
              ],
            ),
          ),
        ),
  
        MaterialButton(onPressed: (){
          if(_textController.text.isNotEmpty)
          {
            if(_list.isEmpty)
            {
             APIs.sendFirstMessage(widget.user,_textController.text,Type.text);
            }
            else
            {
            APIs.sendMessage(widget.user,_textController.text,Type.text);
            }
            _textController.text='';
          }
        },
        color: Colors.greenAccent,
        minWidth: 0,
        padding: EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10),
        shape: CircleBorder(),
        
        child: Icon(Icons.send,color: Colors.white,size:27),)
      ],
    ),
  );
}

}