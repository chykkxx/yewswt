
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../data/colors.dart';
import '../../data/store_data.dart';
import '../../http/request.dart';
import '../../model/base_model.dart';
import '../../model/base_store.dart';
import '../message/message.dart';

class IndexFriendsPage extends StatefulWidget {
  const IndexFriendsPage({super.key});
  @override
  State<IndexFriendsPage> createState() => _IndexFriendsPageState();
}

class _IndexFriendsPageState extends State<IndexFriendsPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  late TabController _tabController;
  late List friends=[];
  bool tab0 =true;int pageNum=1;int total=0;int total125=0;
  late List groupdat=[];
  bool tab1 =true;int pageNum1=1;int total1=0;
  bool isLoading =false;
  late ToastFuture toastFuture;
  bool ifShowToast=false;

  late List openCd=[];
  late List openGroup=[];

  late int searchNum=0;
  late Map searchObj={
    'name':'','jigou_id':'','jigou':'',
  };
  void setSearch(field,value){
    setState(() {
      if(searchObj[field]=='' && value!=''){
        searchNum++;
      }else if(searchObj[field]!='' && value==''){
        searchNum--;
      }
      searchObj[field]=value;
      tab0 =true;tab1 =true;
    });
  }
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controllerKeyword = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _loadFriends(1);
    _loadGroup(1);
    _tabController.addListener(() {
      switch(_tabController.index){
        case 0:
          if(tab0) _loadFriends(1);
          break;
        case 1:
          if(tab1) _loadGroup(1);
          break;
      }
    });
    // _scrollController.addListener(() {
    //   ///滚动到底部了
    //   if(isLoading ==false && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent){
    //     setState(() {
    //       isLoading=true;
    //       switch(_tabController.index){
    //         case 0:
    //           pageNum++;
    //           _loadFriends(pageNum);
    //           break;
    //         case 1:
    //           pageNum1++;
    //           _loadGroup(pageNum1);
    //           break;
    //       }

    //     });
    //   }else if(isLoading ==false && _scrollController.position.pixels==0){ ///滚动到顶部
    //     setState(() {
    //       isLoading=true;
    //       switch(_tabController.index){
    //         case 0:
    //           pageNum=1;
    //           _loadFriends(pageNum);
    //           break;
    //         case 1:
    //           pageNum1=1;
    //           _loadGroup(pageNum1);
    //           break;
    //       }
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('通讯录'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0), // 设置TabBar的高度
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: BaseColors.gray11.withOpacity(.06), // 设置边框颜色
                  width: 1.0, // 设置边框宽度
                ),
              ),
            ),
            child: TabBar(
              indicatorColor: BaseColors.color8, //指示器的颜色
              labelColor: BaseColors.color8, //选中文字颜色
              unselectedLabelColor: BaseColors.gray11, //为选中文字颜色
              // indicatorSize: TabBarIndicatorSize.label, //指示器与文字等宽
              tabs: <Widget>[
                Tab(text: "好友(${total+total125})"),
                Tab(text: "群聊($total1)"),
              ],
              controller: _tabController,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: BaseColors.gray4,
              padding: const EdgeInsets.all(10),
              child: Container(
                color: Colors.white,
                height: 40,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15,top: 2),
                child: TextField(
                  controller: _controllerKeyword,
                  //autofocus: true,
                  //cursorHeight: 20,
                  //readOnly: true,  //只读不可编辑，点击搜索框直接跳转搜索页
                  style: const TextStyle(fontSize: 14),
                  cursorWidth: 1,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0),
                      hintText: '姓名/群名',  //搜索提示词
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),  //搜索框文字样式
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding:  const EdgeInsets.only(top: 0,left: 10),
                        child: GestureDetector(
                          child: const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                          onTap: (){
                            _controllerKeyword.clear();
                            searchObj['name']='';
                            setState(() {
                              tab0 =true;tab1 =true;
                            });
                            // if(_tabController.index==0)_loadFriends(1);
                            // if(_tabController.index==1)_loadGroup(1);
                            _loadFriends(1);
                            _loadGroup(1);
                          },
                        ),
                      )
                  ),
                  onChanged: (value){
                    searchObj['name']=value;
                    setState(() {
                      tab0 =true;tab1 =true;
                    });
                    // if(_tabController.index==0)_loadFriends(1);
                    // if(_tabController.index==1)_loadGroup(1);
                    _loadFriends(1);
                    _loadGroup(1);
                  },//onTap
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView.builder(
              
                        controller: _scrollController,
                        itemCount: friends.length, //告诉ListView总共有多少个cell
                        itemBuilder: (context, index) {
                          return Container(
                              color: Colors.white,
                              padding: const EdgeInsets.only(right: 10,left: 10),
                              //padding: const EdgeInsets.only(right: 5,left: 15),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if(!openCd.contains(friends[index]['id'])){
                                        setState(() {
                                          openCd.add(friends[index]['id']);
                                        });
                                      }else{
                                        setState(() {
                                          openCd.remove(friends[index]['id']);
                                        });
                                      }
                                    },
                                    child: Container(
                                        margin: const EdgeInsets.only(top: 5,bottom: 5),
                                        decoration: BoxDecoration(
                                            color: openCd.contains(friends[index]['id'])?Colors.grey[50]:Colors.orange[100]
                                        ),
                                        alignment: Alignment.centerLeft,
                                        height: 34,
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Row(
                                          //mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(openCd.contains(friends[index]['id'])?Icons.chevron_left:Icons.expand_more),
                                            Text(friends[index]['name']),
                                          ],
                                        )
                                    ),
                                  ),
                                  if(!openCd.contains(friends[index]['id']))ListView.builder(
                                      shrinkWrap: true,//解决无限高度问题
                                      physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                                      itemCount: friends[index]['children'].length,
                                      itemBuilder: (context, item) =>InkWell(
                                        onTap: () {
                                          _openFriendsChat(friends[index]['children'][item],true,1);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(right: 5,left: 10),
                                          child:Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: 36,
                                                height: 36,
                                                alignment: Alignment.center,
                                                //超出部分，可裁剪
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: friends[index]['children'][item]['imageurl']!='' && friends[index]['children'][item]['imageurl']!=null ?Colors.white:Color(0xFF0089FF)
                                                ),
                                                child: friends[index]['children'][item]['imageurl']!='' && friends[index]['children'][item]['imageurl']!=null ?Image.network(
                                                  friends[index]['children'][item]['imageurl'],width: 36,height: 36,
                                                  fit: BoxFit.cover,
                                                ):Text((friends[index]['children'][item]['nickname'] ?? friends[index]['children'][item]['name']).substring(0,2),style: const TextStyle(color: Colors.white,fontSize: 12)),
                                              ),
                                              const SizedBox(width: 10,),
                                              Expanded(
                                                child:Container(
                                                  height: 50,
                                                  padding: const EdgeInsets.only(left: 5,right: 5),
                                                  alignment: Alignment.centerLeft,
                                                  decoration: const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(width: 1,color: BaseColors.gray16),
                                                      )
                                                  ),
                                                  child:Row(
                                                    children: [
                                                      Text(friends[index]['children'][item]['nickname'] ?? friends[index]['children'][item]['name'],
                                                        style: const TextStyle(
                                                          //fontWeight: FontWeight.w600,
                                                          fontSize: 16.0,
                                                        ),
                                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Text('${friends[index]['short_name']}',
                                                        style: const TextStyle(
                                                          //fontWeight: FontWeight.w600,
                                                            fontSize: 12.0,
                                                            color: BaseColors.gray7
                                                        ),
                                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
              
                                              ),
                                            ],
                                          ),
                                        ),
              
                                      )
                                  )
                                ],
                              )
                          );
                        }//使用_cellForRow回调返回每个cell
                    ),
                    ListView.builder(
              
                        controller: _scrollController,
                        itemCount: groupdat.length, //告诉ListView总共有多少个cell
                        itemBuilder: (context, index) {
                          return Container(
                              color: Colors.white,
                              // margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.only(right: 10,left: 10),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if(!openGroup.contains(groupdat[index]['id'])){
                                        setState(() {
                                          openGroup.add(groupdat[index]['id']);
                                        });
                                      }else{
                                        setState(() {
                                          openGroup.remove(groupdat[index]['id']);
                                        });
                                      }
                                    },
                                    child: Container(
                                        margin: const EdgeInsets.only(top: 5,bottom: 5),
                                        decoration:  BoxDecoration(
                                            color: openGroup.contains(groupdat[index]['id'])?Colors.grey[50]:Colors.orange[100]
                                        ),
                                        alignment: Alignment.centerLeft,
                                        height: 34,
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Row(
                                          //mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(openGroup.contains(groupdat[index]['id'])?Icons.chevron_left:Icons.expand_more),
                                            Expanded(child: Text(groupdat[index]['name'],overflow: TextOverflow.ellipsis,))
              
                                          ],
                                        )
                                    ),
                                  ),
                                  if(!openGroup.contains(groupdat[index]['id']))ListView.builder(
                                      shrinkWrap: true,//解决无限高度问题
                                      physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                                      itemCount: groupdat[index]['children'].length,
                                      itemBuilder: (context, item) =>InkWell(
                                        onTap: () {
                                          _openFriendsChat(groupdat[index]['children'][item],true,2);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(right: 5,left: 10),
                                          child:Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: 36,
                                                height: 36,
                                                alignment: Alignment.center,
                                                //超出部分，可裁剪
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: groupdat[index]['children'][item]['imageurl']!='' && groupdat[index]['children'][item]['imageurl']!=null ?Colors.white:Color(0xFF0089FF)
                                                ),
                                                child: groupdat[index]['children'][item]['imageurl']!='' && groupdat[index]['children'][item]['imageurl']!=null ?Image.network(
                                                  groupdat[index]['children'][item]['imageurl'],width: 36,height: 36,
                                                  fit: BoxFit.cover,
                                                ):Text((groupdat[index]['children'][item]['nickname'] ?? groupdat[index]['children'][item]['name']).substring(0,2),style: const TextStyle(color: Colors.white,fontSize: 12)),
                                              ),
                                              const SizedBox(width: 10,),
                                              Expanded(
                                                child:Container(
                                                  height: 50,
                                                  padding: const EdgeInsets.only(left: 5,right: 5),
                                                  alignment: Alignment.centerLeft,
                                                  decoration: const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(width: 1,color: BaseColors.gray16),
                                                      )
                                                  ),
                                                  child:Row(
                                                    children: [
                                                      Text(groupdat[index]['children'][item]['name'].length>9?groupdat[index]['children'][item]['name'].substring(0,9):groupdat[index]['children'][item]['name'],
                                                        style: const TextStyle(
                                                          //fontWeight: FontWeight.w600,
                                                          fontSize: 16.0,
                                                        ),
                                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Text('${groupdat[index]['short_name']}',
                                                        style: const TextStyle(
                                                          //fontWeight: FontWeight.w600,
                                                            fontSize: 12.0,
                                                            color: BaseColors.gray7
                                                        ),
                                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
              
                                              ),
                                            ],
                                          ),
                                        ),
              
                                      )
                                  )
                                ],
                              )
                          );
                        }// 人一辆跑车
                    ),
                  ]
              ),
            ),
          ],
        ),
      ),
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
          _openChat(value['data'],isDesktop);
        }else if(value['code']==403){
          showToast(value['message']);
        }else{
          showToast(value['message']);
        }
      }).catchError((error) {
        print('报错信息：$error');
      });
    }else{
      _openChat(group,isDesktop);
    }
  }
  void _openChat(group,isDesktop){
    //widget.ifShowDb(false);
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

    baseStore.selectedChatKey = group['keyid'];
    // List<types.Message> clearMessage=[];//清空聊天记录
    // widget.setMessage(clearMessage);
    // if(isDesktop){
    //   widget.onItemTapped(
    //     0,
    //     MenuType.chatPush,
    //   );
    // }else{
      Navigator.push(context,
          MaterialPageRoute(
              builder: (context){
                return MessagePage(key: _inboxKey,title:group['name'],groupKey:group['keyid']);
              }
          )
      );
    //}
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
    var urlpath='';
    if(StoreData.gtLoginType() != -1){
      urlpath= '/api/push/member';
    }else{
      urlpath= '/api/member/index';
    }
    await HttpUtils.post(path:urlpath,data:data).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        setState(() {
          isLoading=false;
          friends = value['memabedat'];
          tab0 =false;
          total=value['total'];
          total125=value['tsuser'].length;
          pageNum=page;
        });
      }else if(value['code']==403){
        // widget.loginOut();
        showToast(value['message'],duration: const Duration(seconds: 3),);
      }else{
        showToast(value['message'],duration: const Duration(seconds: 3),);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
  //获取群聊
  Future<void> _loadGroup(int page) async {
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
    var urlpath='';
    if(StoreData.gtLoginType() != -1){
      urlpath= '/api/push/group';
    }else{
      urlpath= '/api/group/index';
    }
    await HttpUtils.post(path:urlpath,data:data).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        setState(() {
          isLoading=false;
          groupdat = value['jigouuser'];
          tab1 =false;
          total1=value['total'];
          pageNum1=page;
        });
      }else if(value['code']==403){
        // widget.loginOut();
        showToast(value['message'],duration: const Duration(seconds: 3),);
      }else{
        showToast(value['message'],duration: const Duration(seconds: 3),);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
}



