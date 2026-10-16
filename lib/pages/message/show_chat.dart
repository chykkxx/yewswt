import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:yewswt/pages/message/show_chatlogs.dart';


import '../../data/colors.dart';
import '../../http/request.dart';
import '../../model/base_model.dart';


class MobileShowChat extends StatefulWidget {
  const MobileShowChat({super.key,required this.groupKey });
  final String groupKey;
  @override
  State<MobileShowChat> createState() => _ShowChatPageState();
}

class _ShowChatPageState extends State<MobileShowChat> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  bool isLoading =true;
  Map<String,dynamic> datas = {};
  Map<String,dynamic> udata = {};
  int ifEdit=1;
  List userarr = [];
  List tsuserarr = [];
  @override
  void initState() {
    super.initState();
    _loadShowChat();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 260,
      child: Scaffold(
          appBar:  AppBar(
            title: const Text('聊天信息'),
          ),
          backgroundColor: Colors.white,
          // appBar: AppBar(title: const Text('用户'),),
          body: datas.isNotEmpty?Container(
            child: datas['type']==1?Container(
              //margin: const EdgeInsets.only(top: 65),
              //color: BaseColors.gray4,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                )
              ),
              margin: EdgeInsets.only(top:15,left: 15,right: 15),
              child: Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                //超出部分，可裁剪
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.blue
                                ),
                                child: (udata['imageurl']!=null && udata['imageurl'].isNotEmpty) ?Image.network(
                                  udata['imageurl'],
                                  fit: BoxFit.cover,
                                ):Text((udata['nickname']??udata['name']).substring(0,2),style: TextStyle(fontSize: 12,color: Colors.white),),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 10),
                                child:Text(udata['nickname']??udata['name'],style: const TextStyle(fontSize: 12,color: Color(0xFFAAABAA)),),
                              ),

                              // InkWell(
                              //   child: Container(
                              //     width: 32,
                              //     height: 32,
                              //     alignment: Alignment.center,
                              //     //超出部分，可裁剪
                              //     clipBehavior: Clip.hardEdge,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(50),
                              //       color: Colors.blue
                              //     ),
                              //     child: (udata['imageurl']!=null && udata['imageurl'].isNotEmpty) ?Image.network(
                              //       udata['imageurl'],
                              //       fit: BoxFit.cover,
                              //     ):Text(udata['name'].substring(0,2)),
                              //   ),
                              //   onTap: (){
                              //     //openGallerySystem();
                              //   },
                              // ),

                              // Container(
                              //   height: 32,
                              //   alignment: Alignment.centerLeft,
                              //   padding: const EdgeInsets.only(left: 20,right: 10),
                              //   child:Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //     children: [
                              //       Text(udata['name'],style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w800),),
                              //       Text(udata['tel']??''),
                              //       Text(udata['nickname']??'')
                              //       //Text(model.userData.name),
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ],
                      //margin: const EdgeInsets.only(top: 40),

                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 0.25,color: BaseColors.gray5),
                          bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                        )
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>MobileShowChatLogs(groupKey: widget.groupKey)));
                        },
                        hoverColor: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('聊天记录',style: TextStyle(color: Color(0xFF191919)),),
                              Icon(IconData(0xe60b,fontFamily: "myIcons",matchTextDirection: true),color: BaseColors.gray6,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ):Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Container(
                    ///color: Colors.white,
                    // height: 56,
                    child: GridView.count(
                      crossAxisCount: 5,
                      shrinkWrap: true,//解决无限高度问题
                      physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 0.8, //子元素宽高比
                      children:Boxs(),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 0.25,color: BaseColors.gray5),
                        bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                      )
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>MobileShowChatLogs(groupKey: widget.groupKey)));
                      },
                      hoverColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('聊天记录',style: TextStyle(color: Color(0xFF191919)),),
                            Icon(IconData(0xe60b,fontFamily: "myIcons",matchTextDirection: true),color: BaseColors.gray6,),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ):const SizedBox(height: 0,)
      ),
    );
  }
  /*一个渐变颜色的正方形集合*/
  List<Widget> Boxs() => List.generate(ifEdit==2?userarr.length+1:userarr.length, (index) {
    return index<userarr.length?Column(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          //margin: EdgeInsets.only(bottom: 4),
          //超出部分，可裁剪
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: userarr[index]['imageurl']!='' && userarr[index]['imageurl']!=null ?Colors.white:Color(0xFF0089FF)
          ),
          child: userarr[index]['imageurl']!='' && userarr[index]['imageurl']!=null ?Image.network(
            userarr[index]['imageurl'],width: 32,height: 32,
            fit: BoxFit.cover,
          ):Text((userarr[index]['nickname']??userarr[index]['name']).substring(0,2),style: const TextStyle(color: Colors.white,fontSize: 12),),
        ),
        Container(
          width: 50,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 8),
          child: Text(userarr[index]['nickname']??userarr[index]['name'],maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12,color: Color(0xFFAAABAA)),),
        )
      ],
    ):Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          //margin: EdgeInsets.only(bottom: 4),
          //超出部分，可裁剪
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              border: Border.all(width: 0.25,color: const Color(0xFF0089FF),style: BorderStyle.solid)
          ),
          child: const Icon(Icons.add),
        )
      ]
    );
  });
  //获取好友
  Future<void> _loadShowChat() async {
    var data={'groupkey':widget.groupKey};
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
    await HttpUtils.post(path:'/api/login/showchat',data:data).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        //print(value);
        setState(() {
          ///ifEdit=value['ifEdit']; ///暂停修改功能
          isLoading=false;
          datas=value['data'];
          if(datas['type']==1){
            udata=value['udata'];
          }else{
            userarr=value['userarr'];
            tsuserarr=value['tsuserarr'];
          }
        });
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
