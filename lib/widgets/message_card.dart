// import 'package:flutter/gestures.dart';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:spd_chat/api/apis.dart';
import 'package:spd_chat/helper/dialogs.dart';
import 'package:spd_chat/helper/my_date_util.dart';
import 'package:spd_chat/main.dart';
import 'package:spd_chat/models/message.dart';
class MessageCard extends StatefulWidget {

  const MessageCard({super.key, required this.message});
  
  final Message message;
  

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {

    bool isMe= APIs.user.uid==widget.message.fromId ;
    
   
    return  InkWell(
      onLongPress: ()
      {
            _showBottomSheet(isMe);
      },
      child: isMe ?_blueMessage():_greenMessage());
  }

//sender or another user message(same vada mokle te)
Widget _greenMessage()
  {

        if(widget.message.read.isEmpty)
        {
          APIs.updateMessageReadStatus(widget.message);
          log('message read updated' );
        }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04,vertical: mq.height*.01),
            decoration: BoxDecoration(color: Colors.green[200],
            border: Border.all(color:Colors.green),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30),bottomRight: Radius.circular(30))),
            child: 
            widget.message.type==Type.text?
            
            Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.black87),):
            ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(
            // width: mq.height* .05,
            // height: mq.height* .05,
          imageUrl: widget.message.msg,
          placeholder: (context, url) => CircularProgressIndicator(),
          // placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.image,size: 70,),
             ),
        ),
          ),
        ),

        Padding(
          padding:EdgeInsets.only(right: mq.width*.04),
          child: Text(MyDateUtil.getFormattedTime(context: context,time: widget.message.sent),
          style: TextStyle(fontSize: 13,color: Colors.black54),),
        )

      ],
    );
  }

//blue our message or user message (aapde mokli te)
  Widget _blueMessage()
  {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       

        Row(
          children: [
            
            if(widget.message.read.isNotEmpty)
            Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),


            Text(MyDateUtil.getFormattedTime(context: context,time: widget.message.sent),
            style: TextStyle(fontSize: 13,color: Colors.black54),),
            
          ],
        ),

        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04,vertical: mq.height*.01),
            decoration: BoxDecoration(color: Colors.blue[200],
            border: Border.all(color:Colors.blue),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30),bottomLeft: Radius.circular(30))),
            child:   widget.message.type==Type.text?
            
            Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.black87),):
            ClipRRect(
          borderRadius: BorderRadius.circular(mq.height*.03),
          child: CachedNetworkImage(
            // width: mq.height* .05,
            // height: mq.height* .05,
          imageUrl: widget.message.msg,
           placeholder: (context, url) => CircularProgressIndicator(),
          // placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.image,size: 40,),
             ),)
,       
          ),
        ),
      ],
    );
  }

  
 void _showBottomSheet(bool isMe)
  {
    showModalBottomSheet(
      context: context,shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight:Radius.circular(20) )), builder: (_)
    {
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: mq.height*.02,bottom: mq.height*.05),
        children: [
          
          Container(
            height: 4,
            margin: EdgeInsets.symmetric(
              vertical: mq.height*.015,horizontal: mq.width*.4
            ),
            decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(8)),
          ),
           
           widget.message.type==Type.text?
          _OptionItem(icon:Icon(Icons.copy_all_rounded,color:Colors.green,size:26), name:'Copy Text', onTap:() async {
            await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value) {
             Navigator.pop(context);
             Dialogs.showSnackbar(context,"Text Copied!");
            });
          })
          :_OptionItem(icon:Icon(Icons.download_rounded,color:Colors.green,size:26), name:'Save Image', onTap:() async {
             try{
              log('Image Ulr: ${widget.message.msg}');
                await GallerySaver.saveImage(widget.message.msg,albumName:'Spd Chat').then((success) {
                  Navigator.pop(context);
                  if(success!=null && success)
                  {
                    Dialogs.showSnackbar(context,"Image Saved Successfully!");
                  }
             });
             }
             catch(e)
             {
                 log('ErrorWhileSavingImage: $e');
             }
          }),
          Divider(
            color: Colors.black,
            endIndent: mq.width*.04,
            indent: mq.width*.04,
          ),
          if(isMe)
          _OptionItem(icon:Icon(Icons.delete_forever,color:Colors.red,size:26), name:'Delete Message', onTap:(){
            APIs.deleteMessage(widget.message).then((value){
             Navigator.pop(context);
            });
          }),
          if(isMe)
           Divider(
            color: Colors.black,
            endIndent: mq.width*.04,
            indent: mq.width*.04,
          ),
          _OptionItem(icon:Icon(Icons.remove_red_eye,color:Colors.green,size:26),
           name:'Sent At : ${MyDateUtil.getMessageTime(context: context, time:widget.message.sent)} ', onTap:(){}),
           Divider(
            color: Colors.black,
            endIndent: mq.width*.04,
            indent: mq.width*.04,
          ),
          _OptionItem(icon:Icon(Icons.remove_red_eye,color:Colors.red,size:26),
           name:widget.message.read.isEmpty
           ?'Read At: Not seen yet'
           :'Read At: ${MyDateUtil.getMessageTime(context: context, time:widget.message.read)} ', onTap:(){}),
          

        ],
      );
    });
  }



}

class _OptionItem extends StatelessWidget {

  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=>onTap(),
      
      child: Padding(
        padding: EdgeInsets.only(left: mq.width*.05,top: mq.height*.015,bottom: mq.height*.02),
        child: Row(children: [icon,Flexible(child: Text('  $name',style: TextStyle(fontSize: 15),))],),
      ),
    );
  }
}



