import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import '../../data/colors.dart';

import '../../http/request.dart';

class StudentAddPage extends StatefulWidget {
  const StudentAddPage({super.key,});
  @override
  State<StudentAddPage> createState() => _StudentAddPageState();
}
//
class _StudentAddPageState extends State<StudentAddPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  late Map students={
    'id':0,
    's_name':'',
    'tel':'',
    'weixin':'',
    'email':'',
    'school':'',
    'education':'',
    'graduate':'',
    'status':0,
    'manage_id':0,
    'jggroup_id':0,
    'address':'',
    'sex':3,
    'bmremark':'',
    'remarks':'',
  };
  late  List fenleiobj=[];
  late  List manageobj=[];
  late  List jggroupobj=[];
  late  List<DropdownMenuItem<String>> fenlei;
  late  List<DropdownMenuItem<String>> manage;
  late  List<DropdownMenuItem<String>> jggroup;
  late String xsstatus;
  late String manage_id;
  late String jggroup_id;
  bool isLoading =false;
  int page=1;
  int total=0;
  final TextEditingController _controllerName = TextEditingController();///姓名
  final TextEditingController _controllerTel = TextEditingController();///电话
  final TextEditingController _controllerWeixin = TextEditingController();///微信
  final TextEditingController _controllerEmail = TextEditingController();///邮箱
  final TextEditingController _controllerSchool = TextEditingController();///学校
  final TextEditingController _controllerEducation = TextEditingController();///学历
  final TextEditingController _controllerGraduate = TextEditingController();///毕业时间
  final TextEditingController _controllerAddress = TextEditingController();///所在城市
  final TextEditingController _controllerBmRemark = TextEditingController();///报名专业
  final TextEditingController _controllerRemarks = TextEditingController();///备注

  final ScrollController _scrollController = ScrollController();///整体滚动，输入框点击时防止底部按钮挡住输入框

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ///防止底部按钮挡住输入框
  void _clickDelayedScroll() {
    Future.delayed(const Duration(milliseconds: 600), () {
      var nowTop=_scrollController.position.pixels;
      _scrollController.animateTo(
        nowTop + 60,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _loadStudent(0);
    _controllerName.addListener(() {
      print(_controllerName.hashCode);
      // if(_controllerName.hashCode){
      //   print("获取焦点");
      // }else{
      //   print("失去焦点");
      // }
    });
  }
  Future<void> _saveStudent() async {
    Map upData={
      'id':0,
      's_name':_controllerName.text,
      'tel':_controllerTel.text,
      'weixin':_controllerWeixin.text,
      'email':_controllerEmail.text,
      'school':_controllerSchool.text,
      'education':_controllerEducation.text,
      'graduate':_controllerGraduate.text,
      'status':xsstatus,
      'manage_id':manage_id,
      'address':_controllerAddress.text,
      'bmremark':_controllerBmRemark.text,
      'remarks':_controllerRemarks.text,
    };
    await HttpUtils.post(path:'/api/Student/create',data:upData).then((value) {
      if(value['code']==200){
        Navigator.pop(context);
      }
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('添加学生'),
      ),


      body: isLoading?SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [

            Container(
              decoration: BoxDecoration(
                color: Colors.white, // 底色
                borderRadius: BorderRadius.circular(2),
              ),
              //color: Colors.white,
              margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
              padding: const EdgeInsets.fromLTRB(15,5,15,15),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '状　　态',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 8),
                              height: 40,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none, labelText: '',
                                  //contentPadding: EdgeInsets.only(top: 0,bottom: 12),
                                  isCollapsed: true,
                                ),
                                // 设置默认值
                                value: xsstatus,
                                // 选择回调
                                onChanged: (String? newPosition) {
                                  setState(() {
                                    xsstatus=newPosition!;
                                  });
                                },
                                // 传入可选的数组
                                items:fenlei,
                              ),
                            ),
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '项　　目',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 8),
                              height: 40,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none, labelText: '',
                                  //contentPadding: EdgeInsets.only(top: 0,bottom: 12),
                                  isCollapsed: true,

                                ),
                                // 设置默认值
                                value: manage_id,
                                // 选择回调
                                onChanged: (String? newPosition) {
                                  setState(() {
                                    manage_id=newPosition!;
                                  });
                                },
                                // 传入可选的数组
                                items:manage,
                              ),
                            ),
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '姓　　名',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 40,
                              child: TextField(
                                style: const TextStyle(fontSize: 16,height: 1.2),
                                controller: _controllerName,
                                cursorWidth: 1,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 12),
                                    isCollapsed: true,
                                ),
                              ),
                            ),

                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '电　　话',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                height: 40,
                                child: TextField(
                                  style: const TextStyle(fontSize: 16,height: 1.2),
                                  controller: _controllerTel,
                                  cursorWidth: 1,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(top: 12),
                                      isCollapsed: true,
                                  ),
                                ),
                              )
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '微　　信',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                height: 40,
                                child: TextField(
                                  style: const TextStyle(fontSize: 16,height: 1.2),
                                  controller: _controllerWeixin,
                                  cursorWidth: 1,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(top: 12),
                                      isCollapsed: true,
                                  ),
                                ),
                              )
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '学　　历',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                height: 40,
                                child: TextField(
                                  style: const TextStyle(fontSize: 16,height: 1.2),
                                  controller: _controllerEducation,
                                  cursorWidth: 1,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(top: 12),
                                      isCollapsed: true,
                                  ),
                                ),
                              )
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),


                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '毕业学校',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                height: 40,
                                child: TextField(
                                  style: const TextStyle(fontSize: 16,height: 1.2),
                                  controller: _controllerSchool,
                                  cursorWidth: 1,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(top: 12),
                                      isCollapsed: true,
                                  ),
                                ),
                              )
                          ),
                          //const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '毕业时间',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                height: 40,
                                child: TextField(
                                  style: const TextStyle(fontSize: 16,height: 1.2),
                                  controller: _controllerGraduate,
                                  cursorWidth: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 12),
                                    isCollapsed: true,
                                  ),
                                  onTap: (){
                                    _clickDelayedScroll();
                                  },
                                ),
                              )
                          ),
                          //const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '所在城市',
                              style: TextStyle(
                                color: BaseColors.gray6,
                                fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                height: 40,
                                child: TextField(
                                  style: const TextStyle(fontSize: 16,height: 1.2),
                                  controller: _controllerAddress,
                                  cursorWidth: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 12),
                                    isCollapsed: true,
                                  ),
                                  onTap: (){
                                    _clickDelayedScroll();
                                  },
                                ),
                              )

                          ),
                          //const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '邮　　箱',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                height: 40,
                                child: TextField(
                                  style: const TextStyle(fontSize: 16,height: 1.2),
                                  controller: _controllerEmail,
                                  cursorWidth: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 12),
                                    isCollapsed: true,
                                  ),
                                  onTap: (){
                                    _clickDelayedScroll();
                                  },
                                ),
                              )

                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 2,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width:80,
                            child: Text(
                              '报名专业',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                height: 40,
                                child: TextField(
                                  style: const TextStyle(fontSize: 16,height: 1.2),
                                  controller: _controllerBmRemark,
                                  cursorWidth: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 12),
                                    isCollapsed: true,
                                  ),
                                  onTap: (){
                                    _clickDelayedScroll();
                                  },
                                ),
                              )
                          ),
                          //const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 12,left: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                          )
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width:80,
                            child: Text(
                              '备　　注',
                              style: TextStyle(
                                color: BaseColors.gray6,
                                fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                //height: 40,
                                child: TextField(
                                  style: const TextStyle(fontSize: 16,height: 1.2),
                                  controller: _controllerRemarks,
                                  cursorWidth: 1,
                                  maxLines: 5,
                                  minLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 12),
                                    isCollapsed: true,
                                  ),
                                  onTap: (){
                                    _clickDelayedScroll();
                                  },
                                ),
                              )
                          ),
                          //const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60,)
          ],
        ),
      ):Center(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        alignment: Alignment.center,
        height: 50,width: 120,
        //color: Colors.red,
        child: ElevatedButton(
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
            onPressed: (){
              _saveStudent();
            },
            child: const Text('保存')
        ),
      ),
    );
  }

  Future<void> _loadStudent(int id) async {
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
    await HttpUtils.post(path:'/api/Student/show',data:{'id':id}).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        List<DropdownMenuItem<String>> fenleilist=[];
        value['fenlei'].forEach((item){
          fenleilist.add(DropdownMenuItem(value: item['id'].toString(), child: Text(item['name'])));
        });
        //print(value['xiangmu']);
        List<DropdownMenuItem<String>> managelist=[];
        value['xiangmu'].forEach((item){
          managelist.add(DropdownMenuItem(value: item['id'].toString(), child: Text(item['name'])));
        });
        List<DropdownMenuItem<String>> grouplist=[];
        value['group'].forEach((item){
          grouplist.add(DropdownMenuItem(value: item['id'].toString(), child: Text(item['name'])));
        });
        xsstatus = (value['fenlei'][0]['id']!=null?(value['fenlei'][0]['id'].toString()):null)!;///群
        manage_id = (value['xiangmu'][0]['id']!=null?(value['xiangmu'][0]['id'].toString()):null)!;///项目
        jggroup_id = (value['group'][0]['id']!=null?(value['group'][0]['id'].toString()):null)!;///分组
        setState(() {
          fenleiobj = value['fenlei'];
          manageobj = value['xiangmu'];
          jggroupobj = value['group'];
          fenlei=fenleilist.toList();
          manage=managelist.toList();
          jggroup=grouplist.toList();
          isLoading=true;
        });
      }else{
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
}