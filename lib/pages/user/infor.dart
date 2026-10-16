import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:yewswt/http/request.dart';

import '../../data/colors.dart';
import '../../data/store_data.dart';
import '../../model/base_model.dart';
import '../../model/base_store.dart';



class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});
  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  late  List<DropdownMenuItem<String>> fenlei;
  late String xsstatus;
  bool isLoading =false;
  int page=1;
  int total=0;
  late final TextEditingController _controllerName ;///姓名
  late final TextEditingController _controllerTel ;///电话
  late final TextEditingController _controllerNickname ;///昵称
  @override
  void initState() {
    super.initState();
    var baseStore = Provider.of<BaseStore>(
      context,
      listen: false,
    );
    _controllerName = TextEditingController(text: baseStore.userData.name);///姓名
    _controllerTel = TextEditingController(text: baseStore.userData.tel);///电话
    _controllerNickname = TextEditingController(text: baseStore.userData.nickname);///昵称
  }
  Future<void> _saveUser() async {
    Map upData={
      'name':_controllerName.text,
      'tel':_controllerTel.text,
      'nickname':_controllerNickname.text,
    };
    await HttpUtils.post(path:'/api/home/index/inforup',data:upData).then((value) {
      if(value['code']==200){
        var baseStore = Provider.of<BaseStore>(
          context,
          listen: false,
        );
        StoreData.saveUser(value['data']);
        UserItem userItem=UserItem(id:baseStore.userData.id,name:_controllerName.text,nickname:_controllerNickname.text,zhiwu:baseStore.userData.zhiwu,tel:_controllerTel.text,keyid:baseStore.userData.keyid,avatar:baseStore.userData.avatar,created_at:baseStore.userData.created_at);
        baseStore.userData=userItem;
        var chatList=baseStore.chatList;
        final selectedIndex =
        chatList.indexWhere((destination) {
          return destination.keyid == baseStore.userData.keyid;
        });
        if(selectedIndex!=-1){
          chatList[selectedIndex]=ChatItem(
              id: chatList[selectedIndex].id,
              keyid: chatList[selectedIndex].keyid,
              name: _controllerNickname.text,
              avatar: chatList[selectedIndex].avatar,
              message: chatList[selectedIndex].message,
              time: chatList[selectedIndex].time,
              num: chatList[selectedIndex].num
          );
        }
        baseStore.chatList=chatList;
        Navigator.pop(context);
      }else{
        showToast(value['message']);
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        toolbarHeight:  null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration:  null,
              //color: Colors.white,
              child: Container(
                color: Colors.white,
                padding:  EdgeInsets.fromLTRB(15,5,15,15),
                margin: EdgeInsets.all(10),

                child: Column(
                  children: <Widget>[
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 5,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          Container(
                            width:80,
                            child: const Text(
                              '姓名：',
                              style: TextStyle(
                                  color: BaseColors.gray7,
                                  fontSize:18
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controllerName,
                              cursorWidth: 1,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              style:const TextStyle(color: Colors.orange),
                              readOnly:true
                            ),
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 5,top:5,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          Container(
                            width:80,
                            child: const Text(
                              '电话：',
                              style: TextStyle(
                                  color: BaseColors.gray7,
                                  fontSize:18
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controllerTel,
                              cursorWidth: 1,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 5,top:5,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          Container(
                            width:80,
                            child: const Text(
                              '昵称：',
                              style: TextStyle(
                                  color: BaseColors.gray7,
                                  fontSize:18
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controllerNickname,
                              cursorWidth: 1,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.only(top: 30,bottom: 20),
                    //   alignment: Alignment.center,
                    //   child: ElevatedButton(
                    //       style: ButtonStyle(
                    //         backgroundColor: MaterialStateProperty.all(BaseColors.blue7),
                    //         textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                    //         fixedSize: MaterialStateProperty.all(Size(160, 44)),
                    //         shape: MaterialStateProperty.all(
                    //           RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(2.0),
                    //           ),
                    //         ),
                    //       ),
                    //       onPressed: _saveUser,
                    //       child: const Text('保存')
                    //   ),
                    // ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        alignment: Alignment.center,
        height: 50,width: 120,
        //color: Colors.red,
        child: Row(
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(BaseColors.blue7),
                    textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                    fixedSize: MaterialStateProperty.all(Size(120, 44)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  onPressed: _saveUser,
                  child: const Text('保存')
              ),
              // const SizedBox(width: 10,),
              // Transform.scale(  
              //   scale: 0.9,
              //   child: FloatingActionButton(
              //       backgroundColor: BaseColors.gray4,
              //       onPressed: () async {
              //         Navigator.of(context).pop();
              //       },
              //       child: const Icon(Icons.arrow_back,color: BaseColors.gray10,),
              //   ),  
              // ),
            ]
        ),
      ),

    );
  }
}