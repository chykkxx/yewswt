import 'dart:async';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../../baseChat/src/util.dart';
import '../../data/colors.dart';
import '../../data/store_data.dart';
import '../../http/request.dart';
import '../../model/base_model.dart';
import '../../model/base_store.dart';
import '../friends/search_friends.dart';
import 'message.dart';
var messageList=[];
bool ifForeach=true;
class IndexMessagePage extends StatefulWidget {
  const IndexMessagePage({super.key,});
  @override
  State<IndexMessagePage> createState() => _IndexMessagePageState();
}

class _IndexMessagePageState extends State<IndexMessagePage> {
  final UniqueKey _inboxKey = UniqueKey();
  int numb=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var uptallkey='';
    ///循环处理数据
    Timer.periodic(const Duration(milliseconds:  100), (Timer timer) {
      if(ifForeach) xiaoxiList();///循环处理数据
    });
    FlutterBackgroundService().on('update').listen((data) {
      // 处理从服务接收到的消息
      if(mounted && uptallkey!=data?['data']['tallkey']){
        messageList.add(data);
        uptallkey=data?['data']['tallkey'];
      }
    });

    FlutterBackgroundService().on('say').listen((data) {
      // 处理从服务接收到的消息
      if(mounted && uptallkey!=data?['data']['tallkey']){
        messageList.add(data);
        uptallkey=data?['data']['tallkey'];
      }
    });
  }
  ///循环处理数据
  void xiaoxiList(){
    ifForeach=false;
    if(messageList.isNotEmpty){
      var baseStore = Provider.of<BaseStore>(
        context,
        listen: false,
      );
      var chatList=baseStore.chatList;
      for(var index=0;index<messageList.length;index++){
        var data=messageList[index];
        var group=data?['data']['group'];
        messageList.removeAt(index);
        var selectedIndex =
        chatList.indexWhere((destination) {
          return destination.keyid == data?['data']['groupkey'];
        });
        if (selectedIndex != -1) {
          chatList[selectedIndex] = ChatItem(
              id: group['id'],
              keyid: group['keyid'],
              name: group['name'],
              avatar: group['imageurl']??'',
              message: data?['data']['text'] ?? '',
              time: data?['data']['time'],
              num: chatList[selectedIndex].num + (data?['data']['class']==2?0:1),
              nochuli: group['nochuli']??0,
              zhiding: chatList[selectedIndex].zhiding
          );
        }else{
          chatList.add(ChatItem(
              id: group['id'],
              keyid: group['keyid'],
              name: group['name'],
              avatar: group['imageurl']??'',
              message: data?['data']['text'] ?? '',
              time: data?['data']['time'],
              num: (data?['data']['class']==2?0:1),
              nochuli: group['nochuli']??0,
              zhiding: 0
          ));
        }
      }
      chatList.sort(((a, b){
        return (b.time+(b.zhiding*10000000000)).compareTo(a.time+(a.zhiding*10000000000));
      }));
      baseStore.chatList=chatList;
      ifForeach=true;
    }else{
      ifForeach=true;
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(numb>0?'消息(${numb})':'消息'),
      ),
      body: ContextMenuOverlay(
        buttonStyle:const ContextMenuButtonStyle(
            textStyle:TextStyle(
                fontSize: 14
            ),
            padding: EdgeInsets.zero
        ),
        child: Consumer<BaseStore>(
            builder: (context, model, child) {
              numb=0;int noChuli=0;
              model.chatList.forEach((element) {
                numb+=element.num;
                noChuli+=element.nochuli;
              });
              FlutterBackgroundService().invoke('badgerNumbService',{'BadgerNumb':numb});
              return Column(
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>FriendsSeach(key: _inboxKey)
                      ));
                    },
                    child: Container(
                      height: 32,  //搜索框高度
                      width: MediaQuery.of(context).size.width-20,
                      margin: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,  // 搜索框背景色-灰色
                        borderRadius: BorderRadius.circular(4), // 设置搜索框圆角
                      ),
                      child: const Row(
                        mainAxisSize:MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 24,
                            child: Icon(Icons.search, size: 20, color: Color(0xFF999999)),  //搜索框图标
                          ),
                          Text('搜索',style: TextStyle(color: Color(0xFF999999)),)
                        ],
                      ),
                    ),
                  ),
                  if(noChuli>0) Container(margin: EdgeInsets.only(bottom: 5),child: Text('还有($noChuli)位学生未接收！',style: const TextStyle(color: Colors.red),),),
                  Expanded(
                      child: ListView.builder(
                        //shrinkWrap: true,//解决无限高度问题
                        //physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                          itemCount: model.chatList.length, //告诉ListView总共有多少个cell
                          itemBuilder: (context, index){
                            return Container(
                              color: model.chatList[index].zhiding==10?BaseColors.gray4:Colors.white,
                              //margin: const EdgeInsets.all(2),
                              padding: const EdgeInsets.only(left: 10,right: 4),
                              child: ContextMenuRegion(
                                contextMenu: GenericContextMenu(
                                  buttonConfigs: [
                                    ContextMenuButtonConfig(
                                      model.chatList[index].zhiding==10?"取消置顶":'置顶',
                                      onPressed: (){
                                        var chatlistx=model.chatList;
                                        ///执行后台数操作
                                        setZhiding(chatlistx[index].id,chatlistx[index].keyid,model.chatList[index].zhiding==10?0:10);
                                        var baseStore = Provider.of<BaseStore>(
                                          context,
                                          listen: false,
                                        );
                                        chatlistx[index]=ChatItem(
                                            id: chatlistx[index].id,
                                            keyid: chatlistx[index].keyid,
                                            name: chatlistx[index].name,
                                            avatar: chatlistx[index].avatar,
                                            message: chatlistx[index].message,
                                            time: chatlistx[index].time,
                                            num: chatlistx[index].num,
                                            nochuli: chatlistx[index].nochuli,
                                            zhiding: chatlistx[index].zhiding==10?0:10
                                        );
                                        chatlistx.sort(((a, b){
                                          return (b.time+(b.zhiding*10000000000)).compareTo(a.time+(a.zhiding*10000000000));
                                        }));
                                        baseStore.chatList=chatlistx;
                                        model.chatList=chatlistx;

                                        var ctLists=[];
                                        for (var itemc in chatlistx) {
                                          ctLists.add(
                                              {
                                                'id': itemc.id,
                                                'keyid': itemc.keyid,
                                                'name': itemc.name,
                                                'avatar': itemc.avatar,
                                                'message': itemc.message,
                                                'time': itemc.time,
                                                'num': itemc.num,
                                                'nochuli': itemc.nochuli,
                                                'zhiding': itemc.zhiding
                                              }
                                          );
                                        }
                                        StoreData.setChatList(ctLists);//本地存储
                                      },
                                    ),
                                    ContextMenuButtonConfig(
                                      "删除",
                                      onPressed: (){
                                        var chatlistx=model.chatList;
                                        ///执行后台数操作
                                        setDelete(chatlistx[index].id,chatlistx[index].keyid,);
                                        chatlistx.removeAt(index);
                                        var baseStore = Provider.of<BaseStore>(
                                          context,
                                          listen: false,
                                        );
                                        chatlistx.sort(((a, b){
                                          return (b.time+(b.zhiding*10000000000)).compareTo(a.time+(a.zhiding*10000000000));
                                        }));
                                        baseStore.chatList=chatlistx;
                                        model.chatList=chatlistx;
                                        var ctLists=[];
                                        for (var itemc in chatlistx) {
                                          ctLists.add(
                                              {
                                                'id': itemc.id,
                                                'keyid': itemc.keyid,
                                                'name': itemc.name,
                                                'avatar': itemc.avatar,
                                                'message': itemc.message,
                                                'time': itemc.time,
                                                'num': itemc.num,
                                                'nochuli': itemc.nochuli,
                                                'zhiding': itemc.zhiding
                                              }
                                          );
                                        }
                                        StoreData.setChatList(ctLists);//本地存储

                                      },
                                    )
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // widget.chatMessages;
                                    // widget.onItemTapped(
                                    //   index,
                                    //   model.chatList[index].keyid,
                                    // );
                                    // widget.ifShowDb(false);
                                    var baseStore = Provider.of<BaseStore>(
                                      context,
                                      listen: false,
                                    );
                                    var chatList=baseStore.chatList;

                                    chatList[index]=ChatItem(
                                      id: chatList[index].id,
                                      keyid: chatList[index].keyid,
                                      name: chatList[index].name,
                                      avatar: chatList[index].avatar,
                                      message: chatList[index].message,
                                      time: chatList[index].time,
                                      num: 0,
                                      nochuli: chatList[index].nochuli,
                                      zhiding: chatList[index].zhiding,
                                    );
                                    baseStore.chatList=chatList;
                                    var ctLists=[];
                                    for (var itemc in chatList) {
                                      ctLists.add(
                                          {
                                            'id': itemc.id,
                                            'keyid': itemc.keyid,
                                            'name': itemc.name,
                                            'avatar': itemc.avatar,
                                            'message': itemc.message,
                                            'time': itemc.time,
                                            'num': itemc.num,
                                            'nochuli': itemc.nochuli,
                                            'zhiding': itemc.zhiding
                                          }
                                      );
                                    }
                                    StoreData.setChatList(ctLists);//本地存储
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(
                                    //         builder: (context){
                                    //           ///return ChatPage(channel:channel,title: strS[0],linkUerkey:'',linkGroupkey:strS[1],datalist:_listmessages[strS[1]],sendMassage: (message) => sendMassage(message));
                                    //           return MobileTopChatPage(key: _inboxKey,groupKey: model.chatList[index].keyid,title:model.chatList[index].name,sendData:widget.sendData,chatMessages:widget.chatMessages,objChatMessages:widget.objChatMessages,objUpdateMessage:widget.objUpdateMessage,setMessage:widget.setMessage,objAppLifecycle:widget.objAppLifecycle);
                                    //         }
                                    //     )
                                    // ).then((value) => widget.ifShowDb(true));
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (context){
                                              ///return ChatPage(channel:channel,title: strS[0],linkUerkey:'',linkGroupkey:strS[1],datalist:_listmessages[strS[1]],sendMassage: (message) => sendMassage(message));
                                              return MessagePage(key: _inboxKey,groupKey: model.chatList[index].keyid,title:model.chatList[index].name);
                                            }
                                        )
                                    );

                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 5,left: 5),

                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        badges.Badge(
                                          showBadge: model.chatList[index].num>0,
                                          position: badges.BadgePosition.topEnd(top: -5, end: -5),
                                          badgeStyle: const badges.BadgeStyle(
                                              badgeColor: Colors.red
                                          ),
                                          badgeContent: Text(
                                            model.chatList[index].num<100?model.chatList[index].num.toString():'99+',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: BaseColors.white50
                                            ),
                                          ),
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            alignment: Alignment.center,
                                            //margin: EdgeInsets.only(bottom: 4),
                                            //超出部分，可裁剪
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4),
                                                color: model.chatList[index].avatar!='' && model.chatList[index].avatar!=null ?Colors.white:Color(0xFF0089FF)
                                            ),
                                            child: model.chatList[index].avatar!='' && model.chatList[index].avatar!=null ?Image.network(
                                              model.chatList[index].avatar,width: 44,height: 44,
                                              fit: BoxFit.cover,
                                            ):Text(model.chatList[index].name.length>2?model.chatList[index].name.substring(0,2):model.chatList[index].name,style: const TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                        const SizedBox(width: 8,),
                                        Expanded(
                                          child:Container(
                                            height: 70,
                                            padding: const EdgeInsets.only(left: 5,right: 2),
                                            //margin: EdgeInsets.only(top: 5),
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                                                  //top: BorderSide(width: 0.25,color: Colors.red),
                                                )
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(top: 12),
                                                  child: Row(
                                                    children: [
                                                      Expanded(child:Text(model.chatList[index].name,
                                                        style: const TextStyle(
                                                          //fontWeight: FontWeight.w600,
                                                          fontSize: 16.0,
                                                        ),
                                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                                      )),
                                                      Container(
                                                        width: 88,
                                                        //margin: const EdgeInsets.only(right: 5),
                                                        alignment: Alignment.centerRight,
                                                        child: Text(
                                                          model.chatList[index].time>0?
                                                          getDateTimeRepresentation(DateTime.fromMillisecondsSinceEpoch(model.chatList[index].time)):'',

                                                          style: const TextStyle(
                                                              fontSize: 12.0,
                                                              color: BaseColors.gray7
                                                          ),maxLines: 1,overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                    height: 24,
                                                    alignment: Alignment.centerLeft,
                                                    child:Row(
                                                      children: [
                                                        if(model.chatList[index].nochuli!=null && model.chatList[index].nochuli>0) Text('[${model.chatList[index].nochuli}]',style: const TextStyle(color: Colors.redAccent,fontWeight: FontWeight.w500),),
                                                        Expanded(
                                                          child: Text(
                                                            model.chatList[index].message,maxLines: 1,overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(color: BaseColors.gray7,fontSize: 12),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ) ,
                              ),
                            );
                          }
                        //使用_cellForRow回调返回每个cell
                      )
                  )

                ],
              );

            }
        ),
      ),
    );
  }
  ///置顶
  Future<void> setZhiding(int id,String keyid,int zhiding) async {
    await HttpUtils.post(path:'/api/login/zhiding',data:{'id':id,'keyid':keyid,'zhiding':zhiding}).then((value) {
      if(value['code']==200){

      }else{
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
  ///删除
  Future<void> setDelete(int id,String keyid) async {
    await HttpUtils.post(path:'/api/login/deletechat',data:{'id':id,'keyid':keyid}).then((value) {
      if(value['code']==200){

      }else{
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
}