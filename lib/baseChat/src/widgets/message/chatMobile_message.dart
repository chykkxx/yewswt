import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';


import '../../../../data/colors.dart';
import '../../util.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../state/inherited_user.dart';

/// A class that represents system message widget.
class ChatMobileMessage extends StatefulWidget {
  const ChatMobileMessage({
    super.key,
    required this.message,
    required this.messageWidth,
    required this.showName,
    required this.onMessageSd
  });

  /// System message.
  final bool showName;
  final types.Message message;
  final int messageWidth;
  final void Function(BuildContext context, types.Message,int)? onMessageSd;
  @override
  _ChatMobileMessageState createState() => _ChatMobileMessageState();
}
class _ChatMobileMessageState extends State<ChatMobileMessage> {
  String caoshi='';
  int nowtime=DateTime.now().millisecondsSinceEpoch;
  late Timer _heartBeat;
  @override
  void initState(){
    if((widget.message.metadata?['class']==2 || widget.message.metadata?['class']==4) && widget.message.metadata?['status']==2){
      _heartBeat =Timer.periodic(const Duration(seconds: 1), (timer) {
        var dd =(((widget.message.metadata?['time']??0)-nowtime)/1000+600).round();
        if(mounted) {
          setState(() {
            caoshi='${'('+_timeZh(dd)})';
            nowtime=DateTime.now().millisecondsSinceEpoch;
          });
        }
      });
    }else{
      _heartBeat =Timer.periodic(const Duration(seconds: 1), (timer) {

      });
    }
  }
  _timeZh(int num){
    if(num>=0) return '${num}s';
    if(((0-num)/3600).round()>0) return '${(num/3600).round()}h';
    if(((0-num)/60).round()>0) return '${(num/60).round()}m';
    return '${num}s';
  }
  @override
  void dispose(){
    //if (_heartBeat!=null && _heartBeat.isActive)_heartBeat.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final user = InheritedUser.of(context).user;
    final textMessage = widget.message as types.TextMessage;
    final shiCha=getVerboseDateTimeCha(widget.message.metadata?['time'],widget.message.metadata?['time']);

    var logs=[];
    if(widget.message.metadata?['time']!=null && widget.message.metadata?['time'] >= 1692078318000 && widget.message.metadata?['data']['sendtype']!=null) {
      logs = widget.message.metadata?['data']['logs']??[];
    }
    var textContent=textMessage.text;
    if(widget.message.metadata?['class']==2){
      var arr=textMessage.text.split("\n");
      textContent=arr[0];
    }

    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.white,
      //margin: InheritedChatTheme.of(context).theme.systemMessageTheme.margin,
      padding: const EdgeInsets.only(top: 10),
      // child: SelectableText(
      //   message,
      //   style:
      //       InheritedChatTheme.of(context).theme.systemMessageTheme.textStyle,
      // ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Column(
              children: [
                if(widget.message.metadata?['class']==2 && widget.message.metadata?['data']['sendtype']!=null) Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    widget.message.metadata?['data']['sendtype']==1?'重复咨询':(widget.message.metadata?['data']['sendtype']==2?'催联系':'修改信息'),
                    style: TextStyle(fontSize: 14,
                        color: widget.message.metadata?['data']['sendtype']==1?Color(0xFF3DD13E):(widget.message.metadata?['data']['sendtype']==2?Color(0xFFFF4747):Color(0xFF3363F9))
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children: [
                      const Text('信息：',style: TextStyle(color: BaseColors.gray6,fontSize: 14),),
                      Expanded(child: Text(textContent,style: TextStyle(fontSize: 14),),)
                    ],
                  ),
                ),
                if(widget.message.metadata?['data']['yixiang']!=null && widget.message.metadata?['data']['yixiang']!='')Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children: [
                      const Text('推荐：',style: TextStyle(color: BaseColors.gray6,fontSize: 14),),
                      Expanded(child: Text(widget.message.metadata?['data']['yixiang'],style: TextStyle(fontSize: 14),),)
                    ],
                  ),
                ),
                if(widget.message.metadata?['data']['remarks']!=null && widget.message.metadata?['data']['remarks']!='' )Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children: [
                      const Text('备注：',style: TextStyle(color: BaseColors.gray6,fontSize: 14),),
                      Expanded(child: Text(widget.message.metadata?['data']['remarks'],style: TextStyle(fontSize: 14),),)
                    ],
                  ),
                ),
                if(widget.message.metadata?['time']!=null && widget.message.metadata?['time'] >= 1692078318000 && widget.message.metadata?['data']['sendtype']!=null) Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(width: 0.25,color: BaseColors.gray6)
                      )
                  ),
                    child: Column(
                      children: [
                        const Text('修改了以下信息',style: TextStyle(color: Color(0xFFA06711)),),
                        ListView.builder(
                          shrinkWrap: true,//解决无限高度问题
                          physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                          itemCount: logs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Text('${logs[index][0]}：',style: const TextStyle(color: BaseColors.gray6,fontSize: 14)),
                                  Text('${logs[index][2]}',style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    )
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment : CrossAxisAlignment.center,
                    children: [
                      const Text('时间：',style: TextStyle(color: BaseColors.gray6,fontSize: 14)),
                      Expanded(child: Text(getVerboseDateTimeRepresentation(DateTime.fromMillisecondsSinceEpoch(widget.message.metadata?['time']!,isUtc: false,),),style: const TextStyle(fontSize: 14)),)
                    ],
                  ),
                ),
              ],
            ),
          ),
          if(widget.message.metadata?['class']==2 && widget.message.metadata?['status']==3)
            Container(
              margin: const EdgeInsets.only(bottom: 0,top: 5),
                padding: const EdgeInsets.only(top: 8,bottom: 0),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(width: 0.25,color: BaseColors.gray6)
                )
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment:CrossAxisAlignment.center,//mainAxisAlignment : MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 20,),
                      Text('${widget.message.metadata?['user']['name']}　',style: TextStyle(color: Color(0xFFA06711),fontSize: 14)),
                      Text(getVerboseDateTimeRepresentation(DateTime.fromMillisecondsSinceEpoch(widget.message.metadata?['usertime']!,isUtc: false,),),style: TextStyle(color: Color(0xFFA06711),fontSize: 14)),
                    ],
                  ),
                  if(widget.message.metadata?['data'].isNotEmpty && widget.message.metadata?['userkey']!=user.id) SizedBox(height: 10,),
                  TextButton(
                    // style: ButtonStyle(
                    //   padding: MaterialStateProperty.all(const EdgeInsets.only(right: 20)),
                    // ),
                      onPressed: (){
                        Clipboard.setData(ClipboardData(text: widget.message.metadata?['data']['tel']??'无'));
                        showToast('复制成功',duration: const Duration(seconds: 1));
                      },
                      child: const Text('复制电话',style: TextStyle(color: Colors.blue,fontSize: 14))
                  ),
                ],
              )

            ),
          if(widget.message.metadata?['class']==2 && widget.message.metadata?['status']==2)
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 2,top: 5),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(width: 0.25,color: BaseColors.gray6)
                )
            ),
            child: TextButton(
                onPressed: (){
                  //widget.onMessageSd!(context, widget.message,1);
                  Clipboard.setData(ClipboardData(text: widget.message.metadata?['data']['tel']??'无'));
                  showToast('复制成功',duration: const Duration(seconds: 1));
                },
                child: Text('收到$caoshi',style: const TextStyle(color: Colors.green,fontSize: 14),)
            ),
          ),
          if(widget.message.metadata?['class']==4 && widget.message.metadata?['status']==2)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 5,top: 10),
              padding: const EdgeInsets.only(top: 8,bottom: 8),
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(width: 0.25,color: BaseColors.gray6)
                  )
              ),
              child: TextButton(
                  onPressed: (){
                    //widget.onMessageSd!(context, widget.message,1);
                    // Clipboard.setData(ClipboardData(text: widget.message.metadata?['data']['tel']??'无'));
                    // showToast('复制成功',duration: const Duration(seconds: 1));
                    if(user.metadata?['type']>=4) {
                      widget.onMessageSd!(context, widget.message, 1);
                    }else{
                      showToast('你没有推送权限',duration: const Duration(seconds: 1));
                    }
                  },
                  child: Text('推送${caoshi}',style: const TextStyle(color: Colors.green,fontSize: 14),)
              ),
            ),
          if(widget.message.metadata?['class']==4 && widget.message.metadata?['status']==3)
            Container(
              margin: const EdgeInsets.only(bottom: 5,top: 10),
              padding: const EdgeInsets.only(top: 8,bottom: 8),
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(width: 0.25,color: BaseColors.gray6)
                  )
              ),
              child: Row(
                crossAxisAlignment:CrossAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Text('${widget.message.metadata?['user']['name']}　',style: const TextStyle(color: Color(0xFFA06711),fontSize: 14))
                  ),
                  Expanded(
                      child: Row(
                        mainAxisSize : MainAxisSize.max,
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children: [
                          Text(getVerboseDateTimeRepresentation(DateTime.fromMillisecondsSinceEpoch(widget.message.metadata?['usertime']!,isUtc: false,),),style: TextStyle(color: Color(0xFFA06711),fontSize: 14)),
                          TextButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(const EdgeInsets.only(right: 20)),
                              ),
                              onPressed: (){
                                if(user.metadata?['type']>=4 || widget.message.metadata?['sendkey']==user.id) {
                                  Clipboard.setData(ClipboardData(text: widget.message.metadata?['data']['tel']??'无'));
                                  showToast('复制成功',duration: const Duration(seconds: 1));
                                }else{
                                  showToast('不是你的学生不能复制！',duration: const Duration(seconds: 1));
                                }
                              },
                              child: const Text('复制电话',style: TextStyle(color: Colors.blue,fontSize: 14))
                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),
        ],
      )
    );
  }

}

@immutable
class SystemMessageTheme {
  const SystemMessageTheme({
    required this.margin,
    required this.textStyle,
  });

  /// Margin around the system message.
  final EdgeInsets margin;

  /// Text style for the system message.
  final TextStyle textStyle;
}
