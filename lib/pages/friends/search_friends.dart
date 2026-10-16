import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


import '../../data/colors.dart';
import '../../http/request.dart';
import '../../model/base_model.dart';
import '../../model/base_store.dart';
import '../message/message.dart';



class FriendsSeach extends StatefulWidget {
  const FriendsSeach({super.key});

  @override
  State<FriendsSeach> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsSeach> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  late TabController _tabController;
  late List friends=[];
  bool tab0 =true;int pageNum=1;int total=0;int total125=0;
  late List groupdat=[];
  bool tab1 =true;int pageNum1=1;int total1=0;
  bool isLoading =false;
  late ToastFuture toastFuture;
  bool ifShowToast=false;

  late int searchNum=0;
  late Map searchObj={
    'name':'','jigou_id':'','jigou':'',
  };
  final TextEditingController _controllerKeyword = TextEditingController();///关键词搜索
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    //_loadFriends(1);
    _controllerKeyword.addListener(() {
      if(isLoading==false){
        searchObj['name']=_controllerKeyword.text;
        setState(() {
          //keyword=_controllerKeyword.text;
          isLoading=true;
          pageNum=1;
          _loadFriends(pageNum);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              height: 35,
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    //margin: const EdgeInsets.only(left: 10,right: 10,top: 40,bottom: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,  // 搜索框背景色-灰色
                      borderRadius: BorderRadius.circular(10), // 设置搜索框圆角
                    ),
                    child: Row(
                      //mainAxisSize:MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 10,),
                        const Icon(Icons.search, size: 18, color: Color(0xFF999999)),
                        Container(
                          width: MediaQuery.of(context).size.width-90,
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: _controllerKeyword,
                            autofocus: true,
                            cursorWidth: 1,
                            style: const TextStyle(fontSize: 14,height: 1.3),
                            decoration: InputDecoration(
                                hintText: '姓名/群名',  //搜索提示词
                                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),  //搜索框文字样式
                                border: InputBorder.none,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: GestureDetector(
                                    child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                                    onTap: (){
                                      _controllerKeyword.clear();
                                    },
                                  ),
                                )
                            ),//onTap
                          ),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      //width: 50,
                        margin: const EdgeInsets.only(left: 10),
                        child: const Text('取消',style: TextStyle(color: Colors.blue),)
                    ),
                  )
        
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  //controller: _scrollController,
                  itemCount: friends.length, //告诉ListView总共有多少个cell
                  itemBuilder: (context, index) {
                    if(total>0 && index==0){
                      return Column(
                        children: [
                          Container(
                            alignment:Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 15),
                            height: 30,
                            color: BaseColors.gray5,
                            child: const Text('内部员工',style: TextStyle(fontSize: 12,color: BaseColors.gray8),),
                          ),
                          Container(
                              color: Colors.white,
                              //margin: const EdgeInsets.all(2),
                              padding: const EdgeInsets.only(right: 5,left: 15),
                              child: InkWell(
                                onTap: () {
                                  _openFriendsChat(friends[index],false,1);
                                },
                                child: Container(
                                  //padding: const EdgeInsets.only(bottom: 2,left: 5),
                                  child:Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        //超出部分，可裁剪
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: friends[index]['imageurl']!='' && friends[index]['imageurl']!=null ?Colors.white:Color(0xFF0089FF)
                                        ),
                                        child: friends[index]['imageurl']!='' && friends[index]['imageurl']!=null ?Image.network(
                                          friends[index]['imageurl'],width: 40,height: 40,
                                          fit: BoxFit.cover,
                                        ):Text((friends[index]['nickname'] ?? friends[index]['name']).substring(0,2),style: const TextStyle(color: Colors.white)),
                                      ),
                                      const SizedBox(width: 10,),
                                      Expanded(
                                        child:Container(
                                          height: 50,
                                          padding: const EdgeInsets.only(bottom: 10,right: 5),
                                          margin: const EdgeInsets.only(top: 5),
                                          alignment: Alignment.centerLeft,
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                                              )
                                          ),
                                          child:Text(friends[index]['nickname'] ?? friends[index]['name'],
                                            style: const TextStyle(
                                              //fontWeight: FontWeight.w600,
                                              fontSize: 16.0,
                                            ),
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
        
                                      ),
                                    ],
                                  ),
                                ),
        
                              )
                          )
                        ],
                      );
                    }else if(total125 >0 && total==index){
                      return Column(
                        children: [
                          Container(
                            alignment:Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 15),
                            height: 30,
                            child: const Text('125科技',style: TextStyle(fontSize: 12,color: BaseColors.gray8),),
                          ),
                          Container(
                              color: Colors.white,
                              //margin: const EdgeInsets.all(2),
                              padding: const EdgeInsets.only(right: 5,left: 15),
                              child: InkWell(
                                onTap: () {
                                  _openFriendsChat(friends[index],false,1);
                                },
                                child: Container(
                                  //padding: const EdgeInsets.only(bottom: 2,left: 5),
                                  child:Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        //超出部分，可裁剪
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: friends[index]['imageurl']!='' && friends[index]['imageurl']!=null ?Colors.white:Color(0xFF0089FF)
                                        ),
                                        child: friends[index]['imageurl']!='' && friends[index]['imageurl']!=null ?Image.network(
                                          friends[index]['imageurl'],width: 40,height: 40,
                                          fit: BoxFit.cover,
                                        ):Text((friends[index]['nickname'] ?? friends[index]['name']).substring(0,2),style: const TextStyle(color: Colors.white)),
                                      ),
                                      const SizedBox(width: 10,),
                                      Expanded(
                                        child:Container(
                                          height: 50,
                                          padding: const EdgeInsets.only(bottom: 10,right: 5),
                                          margin: const EdgeInsets.only(top: 5),
                                          alignment: Alignment.centerLeft,
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                                              )
                                          ),
                                          child:Text(friends[index]['nickname'] ?? friends[index]['name'],
                                            style: const TextStyle(
                                              //fontWeight: FontWeight.w600,
                                              fontSize: 16.0,
                                            ),
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
        
                                      ),
                                    ],
                                  ),
                                ),
        
                              )
                          )
                        ],
                      );
                    }else if(total+total125==index){
                      return Column(
                        children: [
                          Container(
                            alignment:Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 15),
                            height: 30,
                            child: const Text('群聊',style: TextStyle(fontSize: 12,color: BaseColors.gray8),),
                          ),
                          Container(
                              color: Colors.white,
                              //margin: const EdgeInsets.all(2),
                              padding: const EdgeInsets.only(right: 5,left: 15),
                              child: InkWell(
                                onTap: () {
                                  _openFriendsChat(friends[index], false, 2);
                                },
                                child: Container(
                                  //padding: const EdgeInsets.only(bottom: 2,left: 5),
                                  child:Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        //超出部分，可裁剪
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: friends[index]['imageurl']!='' && friends[index]['imageurl']!=null ?Colors.white:Color(0xFF0089FF)
                                        ),
                                        child: friends[index]['imageurl']!='' && friends[index]['imageurl']!=null ?Image.network(
                                          friends[index]['imageurl'],width: 40,height: 40,
                                          fit: BoxFit.cover,
                                        ):Text((friends[index]['nickname'] ?? friends[index]['name']).substring(0,2),style: const TextStyle(color: Colors.white)),
                                      ),
                                      const SizedBox(width: 10,),
                                      Expanded(
                                        child:Container(
                                          height: 50,
                                          padding: const EdgeInsets.only(bottom: 10,right: 5),
                                          margin: const EdgeInsets.only(top: 5),
                                          alignment: Alignment.centerLeft,
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                                              )
                                          ),
                                          child:Text(friends[index]['nickname'] ?? friends[index]['name'],
                                            style: const TextStyle(
                                              //fontWeight: FontWeight.w600,
                                              fontSize: 16.0,
                                            ),
                                            maxLines: 1,overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
        
                                      ),
                                    ],
                                  ),
                                ),
        
                              )
                          )
                        ],
                      );
                    }else{
                      return Container(
                          color: Colors.white,
                          //margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.only(right: 5,left: 15),
                          child: InkWell(
                            onTap: () {
                              if(total+total125<=index) {
                                _openFriendsChat(friends[index], false, 2);
                              }else{
                                _openFriendsChat(friends[index], false, 1);
                              }
                            },
                            child: Container(
                              //padding: const EdgeInsets.only(bottom: 2,left: 5),
                              child:Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    //超出部分，可裁剪
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: friends[index]['imageurl']!='' && friends[index]['imageurl']!=null ?Colors.white:Color(0xFF0089FF)
                                    ),
                                    child: friends[index]['imageurl']!='' && friends[index]['imageurl']!=null ?Image.network(
                                      friends[index]['imageurl'],width: 40,height: 40,
                                      fit: BoxFit.cover,
                                    ):Text((friends[index]['nickname'] ?? friends[index]['name']).substring(0,2),style: const TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 10,),
                                  Expanded(
                                    child:Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(bottom: 10,right: 5),
                                      margin: const EdgeInsets.only(top: 5),
                                      alignment: Alignment.centerLeft,
                                      decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                                          )
                                      ),
                                      child:Text(friends[index]['nickname'] ?? friends[index]['name'],
                                        style: const TextStyle(
                                          //fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                        ),
                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
        
                                  ),
                                ],
                              ),
                            ),
        
                          )
                      );
                    }
                  }//使用_cellForRow回调返回每个cell
              ),
            )
          ],
        ),
      )
    );
  }
  //打开聊天框
  Future<void> _openFriendsChat(group,isDesktop,type) async {
    if(type==1){//用户发起对话 需要获取组
      await HttpUtils.post(
          path:'/api/member/userown',
          data:{'userid':group['id']}
      ).then((value) {
        if(value['code']==200){
          _openChat(value['data']);
        }else if(value['code']==403){
          showToast(value['message']);
        }else{
          showToast(value['message']);
        }
      }).catchError((error) {
        print('报错信息：$error');
      });
    }else{
      _openChat(group);
    }
  }
  void _openChat(group){

    var baseStore = Provider.of<BaseStore>(
      context,
      listen: false,
    );
    //if (baseStore.selectedChatKey != group['keyid']) {
    _inboxKey = UniqueKey();
    //}
    var chatList = baseStore.chatList;
    final selectedIndex =
    chatList.indexWhere((destination) {
      return destination.keyid == group['keyid'];
    });
    if (selectedIndex == -1) {
      var upgroup = ChatItem(
        id: group['id'],
        keyid: group['keyid'],
        name: group['name'],
        avatar: group['imageurl']??'',
        message: '',
        time: DateTime.now().millisecondsSinceEpoch,
        num: 0,
      );
      chatList.add(upgroup);
    }
    baseStore.chatList = chatList;

    //baseStore.selectedChatKey = group['keyid'];
    List<types.Message> clearMessage=[];//清空聊天记录
    //widget.setMessage(clearMessage);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context){
              return MessagePage(key: _inboxKey,title:group['name'],groupKey:group['keyid'],);
            }
        )
    );

  }
  //获取好友
  Future<void> _loadFriends(int page) async {
    var data=searchObj;
    data['current']=page;
    final ToastFuture toastFuture = showToastWidget(
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            //color: Colors.grey.withOpacity(0.3),
            child: Image.asset('static/images/loading.gif',fit: BoxFit.cover,
              width: 100,),
          ),
        ),
      ),
      duration: const Duration(seconds: 3),
      onDismiss: () {
        // The method will be called on toast dismiss.
        //debugPrint('Toast has been dismissed.');
      },
    );
    await HttpUtils.post(path:'/api/member/search',data:data).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        var studentArr=[];
        if(page>1){
          studentArr=friends+value['data'];
        }else{
          studentArr=value['data'];
          if(value['tsuser'].length>0){
            studentArr=studentArr+value['tsuser'];
          }
          if(value['gdata'].length>0){
            studentArr=studentArr+value['gdata'];
          }
        }
        setState(() {
          isLoading=false;
          friends = studentArr;
          tab0 =false;
          total=value['total'];
          total125=value['tsuser'].length;
          total1=value['gdata'].length;
          pageNum=page;
        });
        if(value['data'].length==0){
          setState(() {
            isLoading=false;
            //friends=[];
            tab0 =false;
            pageNum=page-1;
          });
          print('已经到底');
        }
      }else if(value['code']==403){
        //widget.loginOut();
        showToast(value['message']);
      }else{
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }

}
