import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/colors.dart';
import 'student_push.dart';

import '../../http/request.dart';

class StudentShowPage extends StatefulWidget {
  const StudentShowPage({super.key,required this.student});
  final  student;
  @override
  State<StudentShowPage> createState() => _StudentShowPageState();
}

class _StudentShowPageState extends State<StudentShowPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();

  late  List<DropdownMenuItem<String>> fenlei;
  late  List datas =[];
  late  List ytxiangmu=[];
  late String xsstatus;
  bool ifUpdate=false;
  bool isLoading =false;
  bool isPush =false;
  int page=1;
  int total=0;
  var crmstudent;

  @override
  void initState() {
    super.initState();
    crmstudent=widget.student;
    _loadStudent(widget.student['id']);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.student['s_name']}(${widget.student['tel']})')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2), //边框颜色
                  width: 1, //边框宽度
                ), // 边色与边宽度
                color: Colors.white, // 底色
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10, //阴影范围
                    spreadRadius: 0.1, //阴影浓度
                    color: Colors.grey.withOpacity(0.2), //阴影颜色
                  ),
                ],
                borderRadius: BorderRadius.circular(4),
              ),
              //color: Colors.white,
              margin: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 4),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              constraints: const BoxConstraints(
                                maxWidth: 120,
                              ),
                              child: Text('${crmstudent['s_name']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                ), maxLines: 1,overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            Text('(${crmstudent['id']})')
                          ],
                        ),

                        Text('${crmstudent['belong']}',
                          style: const TextStyle(color: BaseColors.orange500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5,left: 5),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-20)/2,
                          child: InkWell(
                            child: Row(
                              children: [
                                const Text(
                                  '电话：',
                                  style: TextStyle(color: BaseColors.gray6),
                                ),
                                Text('${crmstudent['tel']}'),
                                //const Icon(Icons.phone_forwarded,size: 14,color: BaseColors.orange500,)
                                const SizedBox(width: 5,),
                                const Image(image: AssetImage('static/images/tel.png'),width: 20,)
                              ],
                            ),
                            onTap: () async {
                              final Uri launchUri = Uri(
                                scheme: 'tel',
                                path: crmstudent['tel'],
                              );
                              await launchUrl(launchUri);
                            },
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              '微信：',
                              style: TextStyle(color: BaseColors.gray6),
                            ),
                            Text('${crmstudent['weixin']}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5,left: 5),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-20)/2,
                          child: Row(
                            children: [
                              const Text(
                                '学历：',
                                style: TextStyle(color: BaseColors.gray6),
                              ),
                              Text("${crmstudent['educationname']}"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                '地区：',
                                style: TextStyle(color: BaseColors.gray6),
                              ),
                              Expanded(
                                child: Text("${crmstudent['address']??''}",maxLines: 1,overflow: TextOverflow.ellipsis,),
                              )

                            ],
                          ),
                        )

                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5,left: 5),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-20)/2,
                          child: Row(
                            children: [
                              const Text(
                                '毕业时间：',
                                style: TextStyle(color: BaseColors.gray6),
                              ),
                              Text("${crmstudent['graduate']}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          //width: 40,
                          child: const Text('推荐：',
                            style: TextStyle(color: BaseColors.gray6),
                          ),
                        ),
                        Expanded(
                          child: Text(
                              '${crmstudent['str_school_major1']}',
                              //maxLines: 1,overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          //width: 40,
                          child: const Text('备注：',
                            style: TextStyle(color: BaseColors.gray6),
                          ),
                        ),
                        Expanded(
                          child: Text(
                              '${crmstudent['remarks']}',
                              //maxLines: 1,overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '时间：',
                              style: TextStyle(color: BaseColors.gray6),
                            ),
                            Text("${crmstudent['created_at']}"),
                          ],
                        ),
                        if(ytxiangmu.isEmpty)TextButton(
                          onPressed: () async {
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context){
                                      ///return ChatPage(channel:channel,title: strS[0],linkUerkey:'',linkGroupkey:strS[1],datalist:_listmessages[strS[1]],sendMassage: (message) => sendMassage(message));
                                      return BohuiShowPage(student: crmstudent,);
                                    }
                                )
                            ).then((value) => {
                              if(value=='1') Navigator.of(context).pop()
                            });
                            //_showBasicModalBottomSheet(bohuiStudent,_handleRadioValueChanged);
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            minimumSize: MaterialStateProperty.all(const Size(50, 26)),
                            foregroundColor: MaterialStateProperty.resolveWith((states) {
                              //按下按钮时的字体颜色
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.redAccent;
                              }
                              //默认不使用字体颜色
                              return Colors.black;
                            }),
                            //背景颜色
                            backgroundColor:
                            MaterialStateProperty.all(BaseColors.orange500),
                            //水波纹颜色 不想使用 设置透明即可
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                            //设置边框
                            side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.amber)),
                            //设置形状、圆角
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4), // 设置圆角半径
                              ),
                            ),
                          ),
                          child: const Text("驳回",style: TextStyle(fontSize: 12,color: Colors.white),),
                        ),
                        if(ytxiangmu.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              _chongFuZx(1);///重复咨询
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              minimumSize: MaterialStateProperty.all(const Size(70, 26)),
                              foregroundColor: MaterialStateProperty.resolveWith((states) {
                                //按下按钮时的字体颜色
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.redAccent;
                                }
                                //默认不使用字体颜色
                                return Colors.white;
                              }),
                              //背景颜色
                              backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                              //水波纹颜色 不想使用 设置透明即可
                              overlayColor: MaterialStateProperty.all(Colors.transparent),
                              //设置边框
                              side: MaterialStateProperty.all(
                                  const BorderSide(color: Colors.blue)),
                              //设置形状、圆角
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4), // 设置圆角半径
                                ),
                              ),
                            ),
                            child: const Text("重复咨询",style: TextStyle(fontSize: 12)),
                          ),
                        if(ytxiangmu.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              _chongFuZx(2);///催联系
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              minimumSize: MaterialStateProperty.all(const Size(55, 26)),
                              foregroundColor: MaterialStateProperty.resolveWith((states) {
                                //按下按钮时的字体颜色
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.redAccent;
                                }
                                //默认不使用字体颜色
                                return Colors.white;
                              }),
                              //背景颜色
                              backgroundColor:
                              MaterialStateProperty.all(BaseColors.orange500),
                              //水波纹颜色 不想使用 设置透明即可
                              overlayColor: MaterialStateProperty.all(Colors.transparent),
                              //设置边框
                              side: MaterialStateProperty.all(
                                  const BorderSide(color: Colors.amber)),
                              //设置形状、圆角
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4), // 设置圆角半径
                                ),
                              ),
                            ),
                            child: const Text("催联系",style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              //每人一辆跑车
            ),
            isLoading?ListView.builder(
                shrinkWrap: true,//解决无限高度问题
                physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                itemCount: datas.length,
                itemBuilder: _cellForRow
            ):Center(
              child: SizedBox(
                height: 100,width: 100,
                child: Image.asset('static/images/loading3.gif',
                  width: 100,),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ifUpdate?FloatingActionButton(
        onPressed: () async {
          List upda=[];
          int pushnum=0;
          for(int ii=0;ii<datas.length;ii++){
            if(datas[ii]['yitui'].length>0) pushnum++;
            for(int jj=0;jj<datas[ii]['yitui'].length;jj++){
              if(datas[ii]['yitui'][jj]['id']==0){
                upda.add({
                  'student_id': datas[ii]['student_id'],
                  'yixiang_id': datas[ii]['id'],
                  'yixiang': datas[ii]['str_school_major'],
                  'leixing_id': datas[ii]['leixing_id'],
                  'user_id': datas[ii]['admin_id'],
                  'username': datas[ii]['admin'],
                  'yixiangtime':datas[ii]['created_at'],
                  'clash_id': widget.student['clash_id'],
                  'jigou_id': datas[ii]['yitui'][jj]['jigou_id'],
                  'jianzhang_id': datas[ii]['yitui'][jj]['jianzhang_id'],
                  'manage_id': datas[ii]['yitui'][jj]['manage_id'],
                  'manage': datas[ii]['yitui'][jj]['manage']['name'],
                });
              }
            }
          }
          if(pushnum<datas.length){
            final action = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('提示'),
                  content: const Text('部分意向未选择推送简章，确定要推送吗'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('取消',style: TextStyle(color: BaseColors.gray8),),
                      onPressed: () {
                        Navigator.pop(context, 'Cancel');
                      },
                    ),
                    TextButton(
                      child: const Text('确认',style: TextStyle(color: BaseColors.orange500)),
                      onPressed: () {
                        pushStudent(upda);
                        Navigator.pop(context, 'Ok');
                      },
                    ),
                  ],
                );
              },
            );
          }else{
            pushStudent(upda);
          }
          //Navigator.of(context).pop();
        },
        shape: CircleBorder(),
        tooltip: '保存',
        child: const Text('保存',style: TextStyle(color: Colors.white),),
      ):null
    );
  }
  ///打开推送
  void showPush(group,index){
    _inboxKey = UniqueKey();
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context){
              return StudentPushPage(key: _inboxKey,student:group,upSelect:upSelect,index:index);
            }
        )
    );
  }
  Widget _cellForRow(BuildContext context, int index) {
    return Container(

      margin: const EdgeInsets.fromLTRB(10,10,10,0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(width: 1, color: BaseColors.color4,),
      ),
      child: InkWell(
        onTap: () {
          showPush(datas[index],index);
        },
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1,color: BaseColors.gray16)
                )
              ),
              child: Row(
                children: [
                  Container(
                    //color: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 4),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.blue,
                    ),
                    child: Text(datas[index]['leixing']['name'],
                      overflow: TextOverflow.ellipsis,maxLines: 1,
                      style: const TextStyle(color: Colors.white,fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      datas[index]['str_school_major'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.0,
                          //fontStyle: FontStyle.values[1],
                          color: BaseColors.gray10
                      ),
                    ),
                  ),
                ],
              ),
            ),

            (datas[index]?['yitui']!=null && datas[index]['yitui'].length>0)?ListView.builder(
              shrinkWrap: true,//解决无限高度问题
              physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
              itemCount: datas[index]['yitui'].length,
              itemBuilder: (context, item) =>Container(
                //padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(bottom: 5,top: 15),
                      child: Text(
                        '【${datas[index]['yitui'][item]['jianzhang']['id']}】${datas[index]['yitui'][item]['jianzhang']['title']}',
                        style: const TextStyle(
                            fontSize: 16,
                            //fontWeight: FontWeight.w600,
                            height: 1.5
                        ),

                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5,color: BaseColors.gray5)
                      ),
                      child: Column(
                        children: [
                          Row(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  //padding: const EdgeInsets.only(left: 20,top: 5),
                                  child: Text(
                                    datas[index]['yitui'][item]['jigou']['name'],
                                    overflow: TextOverflow.ellipsis,maxLines: 1,
                                    style:  const TextStyle(
                                        fontSize: 14,
                                        color: BaseColors.gray11
                                    ),

                                  ),
                                ),
                              ),
                              if(datas[index]['yitui'][item]['manage']!=null && datas[index]['yitui'][item]['id']==0)const Icon(Icons.fiber_new_outlined,color: Colors.redAccent,size: 20,)
                            ],
                          ),
                          if(datas[index]['yitui'][item]['manage']!=null)Container(
                            margin: const EdgeInsets.only(top: 5,bottom: 2),
                            child: Row(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    //padding: const EdgeInsets.only(left: 20,top: 5),
                                    child:Row(
                                      children: [
                                        const Icon(Icons.group,size: 16,color: Colors.green,),
                                        SizedBox(width: 5,),
                                        Text(
                                          '${datas[index]['yitui'][item]['manage']['name']}',
                                          overflow: TextOverflow.ellipsis,maxLines: 1,
                                          style:  const TextStyle(
                                              fontSize: 14,
                                              color: BaseColors.gray11
                                          ),
                                        ),
                                      ],
                                    )

                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  //padding: const EdgeInsets.only(left: 20,top: 5),
                                  child: Text(
                                    '${datas[index]['yitui'][item]['admin']??'-'}',
                                    overflow: TextOverflow.ellipsis,maxLines: 1,
                                    style:  const TextStyle(
                                        fontSize: 14,
                                        color: BaseColors.orange500
                                    ),

                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5,bottom: 2),
                            child: Row(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      //padding: const EdgeInsets.only(left: 20,top: 5),
                                      child:Text(
                                          '${datas[index]['yitui'][item]['created_at']??'-'}',
                                          overflow: TextOverflow.ellipsis,maxLines: 1,
                                          style:  const TextStyle(
                                              fontSize: 14,
                                              color: BaseColors.gray11
                                          ),
                                      ),
                                  ),
                                ),
                                if(datas[index]['yitui'][item]['manage']!=null && datas[index]['yitui'][item]['id']==0)
                                  InkWell(
                                    onTap: () async {
                                      var ddat=datas;
                                      ddat[index]['yitui'].removeWhere((element) => element['manage_id'] == datas[index]['yitui'][item]['manage_id'] && element['jianzhang_id'] == datas[index]['yitui'][item]['jianzhang_id']);
                                      setState(() {
                                        datas=ddat;
                                      });
                                    },
                                    child: const Text("删除",style: TextStyle(color: Colors.red),),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                  ],
                ),
              ),
            ):Container(
              margin: EdgeInsets.only(top: 10),
              child: const Text('未推',style: TextStyle(color: BaseColors.gray14),)
              )
          ],
        ), //每人一辆跑车
      )

    );
  }
  void upSelect(int index,upData){
    setState(() {
      ifUpdate=true;
      datas[index]['yitui']=upData;
    });
  }
  ///重复咨询
  _chongFuZx(type) async {
    final ToastFuture toastFuture = showToastWidget(
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            //color: Colors.grey.withOpacity(0.3),
            child: Image.asset('static/mages/loading3.gif',fit: BoxFit.cover,
              width: 100,),
          ),
        ),
      ),
      duration: const Duration(seconds: 300),
      onDismiss: () {
        // The method will be called on toast dismiss.
        //debugPrint('Toast has been dismissed.');
      },
    );
    await HttpUtils.post(path:'/api/Push/chongfuzx',data:{'student_id':widget.student['id'],'ytxiangmu':ytxiangmu,'type':type}).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        //Navigator.of(context).pop();
        showToast(value['message'],duration: const Duration(seconds: 3),);
      }else{
        showToast(value['message'],duration: const Duration(seconds: 3),);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
  ///推送
  Future<void> pushStudent(data) async {
    if(isPush){
      showToast('正在处理中！请不要重复操作。',duration: const Duration(seconds: 5));
      return;
    }
    setState(() {
      ifUpdate=false;
      isPush=true;
    });
    final ToastFuture toastFuture = showToastWidget(
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            //color: Colors.grey.withOpacity(0.3),
            child: Image.asset('static/images/loading3.gif',fit: BoxFit.cover,
              width: 100,),
          ),
        ),
      ),
      duration: const Duration(seconds: 300),
      onDismiss: () {
        // The method will be called on toast dismiss.
        //debugPrint('Toast has been dismissed.');
      },
    );
    await HttpUtils.post(path:'/api/Push/save',data:{'student_id':widget.student['id'],'yitui':data}).then((value) {
      toastFuture.dismiss();
      setState(() {
        isPush=false;
      });
      if(value['code']==200){
        Navigator.of(context).pop();
      }else{
        showToast(value['message'],duration: const Duration(seconds: 3),);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
  ///获取意向数据
  Future<void> _loadStudent(int id) async {
    await HttpUtils.post(path:'/api/Push/show',data:{'id':id}).then((value) {
      if(value['code']==200){

        setState(() {
          crmstudent=value['student'];
          ytxiangmu = value['ytxiangmu'];
          datas = value['data'];
          isLoading=true;
        });
      }else{
        print('已经到底');
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
}


class BohuiShowPage extends StatefulWidget {
  const BohuiShowPage({super.key,required this.student});
  final  student;
  @override
  State<BohuiShowPage> createState() => _BohuiShowPageState();
}

class _BohuiShowPageState extends State<BohuiShowPage> with SingleTickerProviderStateMixin {

  final TextEditingController _controllerName = TextEditingController();///备注
  List<DropdownMenuItem<String>> fenleilist=[];
  late String xsstatus='264';
  @override
  void initState() {
    super.initState();
    fenleilist.add(const DropdownMenuItem(value: '264', child: Text('项目推荐不准确')));
    fenleilist.add(const DropdownMenuItem(value: '265', child: Text('项目推荐不全面')));
    fenleilist.add(const DropdownMenuItem(value: '266', child: Text('传送信息不准确')));
    fenleilist.add(const DropdownMenuItem(value: '267', child: Text('传送格式不规范')));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('驳回(${widget.student['s_name']}${widget.student['tel']})')),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              // border: Border.all(
              //   color: Colors.grey.withOpacity(0.2), //边框颜色
              //   width: 1, //边框宽度
              // ), // 边色与边宽度
              color: Colors.white, // 底色
              boxShadow: [
                BoxShadow(
                  blurRadius: 10, //阴影范围
                  spreadRadius: 0.1, //阴影浓度
                  color: Colors.grey.withOpacity(0.2), //阴影颜色
                ),
              ],
              borderRadius: BorderRadius.circular(4),
            ),
            //color: Colors.white,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
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
                      Container(
                        width:80,
                        child: const Text(
                          '状态',
                          style: TextStyle(
                              color: BaseColors.gray8,
                              fontSize:18
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          //padding: const EdgeInsets.only(bottom: 20),
                          height: 65,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none, labelText: '',
                              contentPadding: EdgeInsets.zero,
                            ),
                            // 设置默认值
                            value: '264',
                            // 选择回调
                            onChanged: (String? newPosition) {
                              setState(() {
                                xsstatus=newPosition!;
                              });
                            },
                            // 传入可选的数组
                            items:fenleilist,
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
                      Container(
                        width:80,
                        child: const Text(
                          '备注',
                          style: TextStyle(
                              color: BaseColors.gray8,
                              fontSize:18
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 2),
                          child: TextField(
                            controller: _controllerName,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: Padding(
                                  padding:  const EdgeInsets.only(top: 13,left: 20),
                                  child: _controllerName.text.isNotEmpty?GestureDetector(
                                    child:  const Text('x',style: TextStyle(color: Colors.redAccent,fontSize: 14),),
                                    onTap: (){
                                      _controllerName.text='';
                                    },
                                  ):null,
                                )
                            ),
                            minLines: 2,
                            maxLines: 5,
                          ),
                        ),

                      ),
                      ///const Icon(Icons.chevron_right),
                    ],
                  ),
                ),

                Container(
                  width: 160,
                  height: 50,
                  margin: const EdgeInsets.only(top: 20,bottom: 20),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(BaseColors.orange500),
                      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                      fixedSize: MaterialStateProperty.all(Size(160, 44)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    onPressed: bohuiStudent,
                    child: Text('保存',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w800),)
                  ),
                  // child: TextButton(
                  //   onPressed: bohuiStudent,
                  //   style: ButtonStyle(
                  //     backgroundColor: MaterialStateProperty.all(BaseColors.orange500),
                      

                  //   ),
                  //   child: const Text(
                  //     "保存",
                  //     style: TextStyle(color: Colors.white, fontSize: 17,fontWeight: FontWeight.w800),
                  //   ),
                  // ),
                )
              ],
            ),
          ),
        ),
    );
  }


  ///驳回

  Future<void> bohuiStudent() async {
    //Navigator.of(context).pop();
    //return ;
    final ToastFuture toastFuture = showToastWidget(
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            //color: Colors.grey.withOpacity(0.3),
            child: Image.asset('static/images/loading3.gif',fit: BoxFit.cover,
              width: 100,),
          ),
        ),
      ),
      duration: const Duration(seconds: 300),
      onDismiss: () {
        // The method will be called on toast dismiss.
        //debugPrint('Toast has been dismissed.');
      },
    );
    await HttpUtils.post(path:'/api/Push/bohui',data:{'student_id':widget.student['id'],'swbh_status':xsstatus,'remarks':_controllerName.text}).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        Navigator.of(context).pop('1');
      }else{
        showToast(value['message'],duration: const Duration(seconds: 3),);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
}