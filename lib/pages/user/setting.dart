import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'package:yewswt/http/request.dart';

import '../../data/colors.dart';
import '../../data/store_data.dart';
import '../../model/base_store.dart';

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({super.key});
  @override
  State<UserSettingPage> createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  late  List<DropdownMenuItem<String>> fenlei;
  late String xsstatus;
  bool isLoading =false;
  int page=1;
  int total=0;
  final TextEditingController _controllerPassword = TextEditingController();///原密码
  final TextEditingController _controllerNewPwd = TextEditingController();///新密码
  final TextEditingController _controllerQuePwd = TextEditingController();///确认码
  @override
  void initState() {
    super.initState();
  }
  Future<void> _saveUser() async {
    if(_controllerNewPwd.text!=_controllerQuePwd.text){
      showToast('两次密码不一致！');
      return ;
    }
    Map upData={
      'oldpassword':_controllerPassword.text,
      'password':_controllerNewPwd.text,
    };
    await HttpUtils.post(path:'/api/home/index/password',data:upData).then((value) {
      if(value['code']==200){
        var baseStore = Provider.of<BaseStore>(
          context,
          listen: false,
        );
        baseStore.ifLogin=false;//退出登录
        StoreData.saveUser({});//清空登录
        Navigator.of(context).restorablePushNamed('login');
      }else{
        showToast(value['message']);
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('设置'),
          toolbarHeight:  null,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
               decoration:  null,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(15,5,15,15),
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
                              width:100,
                              child: const Text(
                                '原 密 码：',
                                style: TextStyle(
                                  color: BaseColors.gray7,
                                  fontSize:18
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controllerPassword,
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
                              width:100,
                              child: const Text(
                                '新 密 码：',
                                style: TextStyle(
                                    color: BaseColors.gray7,
                                    fontSize:18
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controllerNewPwd,
                                cursorWidth: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
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
                              width:100,
                              child: const Text(
                                '确认密码：',
                                style: TextStyle(
                                  color: BaseColors.gray7,
                                  fontSize:18
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controllerQuePwd,
                                cursorWidth: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
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