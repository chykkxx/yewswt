import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


import '../../baseChat/src/util.dart';
import '../../data/colors.dart';
import '../../data/store_data.dart';
import '../../http/request.dart';
import '../../model/base_model.dart';
import '../student/student_show.dart';

class MobileShowChatLogs extends StatefulWidget {
  const MobileShowChatLogs({super.key,required this.groupKey });
  final String groupKey;
  @override
  State<MobileShowChatLogs> createState() => _ShowChatPageState();
}

class _ShowChatPageState extends State<MobileShowChatLogs> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  bool isLoading =true;
  List logsdata=[];
  int ifEdit=1;
  List userarr = [];
  List tsuserarr = [];
  int typex=0;
  late int userid=0;
  String userKey='';

  int pageNum=1;
  int total=0;
  int copyId=0;
  String keyword='';String name='';String tel='';String remarks='';String manage='';String jggroup='';

  late Map searchObj={
    'groupkey':widget.groupKey,'tel':'','startDay':'','endDay':'','keyword':'','type':0
  };
  late int searchNum=0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controllerKeyword = TextEditingController();///关键词搜索
  final TextEditingController _controllerTel = TextEditingController();///电话
  final TextEditingController _controllerStartDay = TextEditingController();///开始日期
  final TextEditingController _controllerEndDay = TextEditingController();///截止日期
  @override
  void initState() {
    super.initState();
    var user=StoreData.getUser();
    userid=user.id;
    userKey=user.keyid;
    _loadShowChatLogs(0);
    _scrollController.addListener(() {
      ///滚动到底部了
      if(isLoading ==false && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent){
        setState(() {
          isLoading=true;
          pageNum++;
          _loadShowChatLogs(pageNum);
        });
      }else if(isLoading ==false && _scrollController.position.pixels==0){ ///滚动到顶部
        setState(() {
          isLoading=true;
          pageNum=1;
          _loadShowChatLogs(pageNum);
        });
      }
    });

    _controllerKeyword.addListener(() {
      if(isLoading==false){
        searchObj['keyword']=_controllerKeyword.text;
        setState(() {
          keyword=_controllerKeyword.text;
          isLoading=true;
          pageNum=1;
          _loadShowChatLogs(pageNum);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('聊天记录'),
        ),
        body: Column(
          children: [
            Container(
              height: 52,  //搜索框高度
              padding: EdgeInsets.fromLTRB(0,10,10,10),
              alignment: Alignment.center,
              //color: Colors.white,
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   borderRadius: BorderRadius.circular(8.0),
              //   boxShadow: const [
              //     BoxShadow(
              //       color: Colors.black12,
              //       offset: Offset(0, 15.0), //阴影xy轴偏移量
              //       blurRadius: 15.0, //阴影模糊程度
              //       spreadRadius: 1.0 //阴影扩散程度
              //     )
              //   ]
              // ),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    //padding: const EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 5),
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      //布局方向，默认是（Axis.horizontal）横向
                      direction: Axis.horizontal,
                      //横向间距
                      spacing: 0,
                      //竖向间距
                      runSpacing: 0.25,
                      //横向对齐方式
                      alignment: WrapAlignment.start,
                      children: buttonWight([{'id':0,'name':'全部'},{'id':1,'name':'未处理'},{'id':2,'name':'图片'},{'id':3,'name':'文件'}],_onchange,4,'type',typex)),
                  ),

                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: _controllerKeyword,
                        style: TextStyle(fontSize: 12,height: 1.2),
                        //autofocus: true,
                        //cursorHeight: 20,
                        //readOnly: true,  //只读不可编辑，点击搜索框直接跳转搜索页
                        cursorWidth: 1,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            hintText: '电话/姓名',  //搜索提示词
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF999999)),  //搜索框文字样式
                            border: InputBorder.none,
                            suffixIcon: Padding(
                              padding:  const EdgeInsets.only(top: 0,left: 10),
                              child: GestureDetector(
                                child:   const Icon(Icons.clear,size: 14,color: BaseColors.gray6,),
                                onTap: (){
                                  _controllerKeyword.clear();
                                },
                              ),
                            )
                        ),//onTap
                      ),
                    ),
                  ),
                ],
              )

            ),
            Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: logsdata.length, //告诉ListView总共有多少个cell
                    itemBuilder: (context, index){
                      // if(logsdata[index]['senduser']['type']==4){
                      //   logsdata[index]['senduser']['imageurl']='http://jiaoyutong.ludengedu.com/static/images/zhoulaoshi.png';
                      //   logsdata[index]['senduser']['name']='周老师';
                      //   logsdata[index]['senduser']['nickname']='周老师';
                      // }
                      return Container(
                        alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white, // 底色
                            borderRadius: BorderRadius.circular(2),
                          ),
                          //color: Colors.white,
                          margin: const EdgeInsets.only(left: 10,right: 10,top: 0,bottom: 10),
                          padding: const EdgeInsets.fromLTRB(15,15,15,10),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment:CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    //超出部分，可裁剪
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color:logsdata[index]['senduser']['imageurl']!='' && logsdata[index]['senduser']['imageurl']!=null ?Colors.white:Color(0xFF0089FF)
                                    ),
                                    child: logsdata[index]['senduser']['imageurl']!='' && logsdata[index]['senduser']['imageurl']!=null ?Image.network(
                                      logsdata[index]['senduser']['imageurl'],width: 40,height: 40,
                                      fit: BoxFit.cover,
                                    ):Text(logsdata[index]['senduser']['name'].substring(0,2),style: const TextStyle(fontSize: 14,color: Colors.white),),
                                  ),
                                  const SizedBox(width: 10,),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                      margin: EdgeInsets.only(bottom: 10),
                                                      child: Text('${logsdata[index]['senduser']['name']}',style: const TextStyle(color: Color(0xFF181818),fontSize: 14,fontWeight: FontWeight.bold),)
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(bottom: 10),
                                                    child: Text(
                                                      logsdata[index]['time']>0?
                                                      getVerboseDateTimeRepresentation(DateTime.fromMillisecondsSinceEpoch(logsdata[index]['time'],isUtc: false,)):'',
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          color: BaseColors.gray7
                                                      ),maxLines: 1,overflow: TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              if(logsdata[index]['type']=='image') Image.network(
                                                logsdata[index]['data']['uri'],width: 60,height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                              if(logsdata[index]['type']=='file') TextButton(
                                                  onPressed: () async =>{
                                                    if (await canLaunch(logsdata[index]['data']['uri'])) {
                                                      await launch(logsdata[index]['data']['uri'])
                                                    } else {
                                                      throw 'Could not launch ${logsdata[index]['data']['uri']}'
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text('${logsdata[index]['text']}',style: const TextStyle(color: BaseColors.gray10,),),
                                                      const Icon(Icons.assignment_returned,color: BaseColors.gray6,),
                                                    ],
                                                  )
                                              ),
                                              if(logsdata[index]['type']=='system' || logsdata[index]['type']=='text') Text('${logsdata[index]['text']}',style: TextStyle(color: Color(0xff666666)),)
                                            ],
                                          ),
                                        ),

                                        Container(
                                          child: Column(
                                            children: [
                                              if(logsdata[index]['class']==2 && logsdata[index]['status']==3) Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                   margin: const EdgeInsets.only(top: 10),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('${logsdata[index]['user']['name']}　',style: const TextStyle(color: Color(0xFFA06711),fontSize: 12)),
                                                        Text(getVerboseDateTimeRepresentation(DateTime.fromMillisecondsSinceEpoch(logsdata[index]['usertime']!,isUtc: false,),),style: TextStyle(color: Color(0xFFA06711),fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                  if(logsdata[index]['userkey']==userKey && logsdata[index]['time'] >= 1692078318000)TextButton(
                                                      style: ButtonStyle(
                                                        maximumSize: MaterialStateProperty.all(const Size(double.infinity, 40)),
                                                        backgroundColor: MaterialStateProperty.all((copyId==logsdata[index]['id'])?BaseColors.orange600:BaseColors.orange700),
                                                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(2), // 更改圆角大小
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: (){
                                                        Clipboard.setData(ClipboardData(text: logsdata[index]['data']['tel']??'无'));
                                                        showToast('复制成功',duration: const Duration(seconds: 1));
                                                      },
                                                      child: const Text('复制电话',style: TextStyle(color: BaseColors.orange600,fontSize: 12))
                                                  ),
                                                ],
                                              ),


                                              if(logsdata[index]['class']==2 && logsdata[index]['status']==2) Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: (){
                                                      _handleMessageSd(logsdata[index]);
                                                    },
                                                    style: ButtonStyle(
                                                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                        EdgeInsets.all(5),
                                                      ),
                                                      minimumSize: MaterialStateProperty.all(Size(50, 18)),
                                                      backgroundColor: MaterialStateProperty.all(Colors.green),
                                                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(2), // 更改圆角大小
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Text('收到',style: TextStyle(color: Colors.white,fontSize: 14),),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                  )
                                ],
                              ),
                              if( logsdata[index]['data']!=null && logsdata[index]['data'].isNotEmpty && logsdata[index]['data']['yydata']!=null && logsdata[index]['data']['yydata'].isNotEmpty) Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: BaseColors.gray4
                                ),
                                child: Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      //超出部分，可裁剪
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color:logsdata[index]['data']['yydata']['senduser']['imageurl']!='' && logsdata[index]['data']['yydata']['senduser']['imageurl']!=null ?Colors.white:Color(0xFF0089FF)
                                      ),
                                      child: logsdata[index]['data']['yydata']['senduser']['imageurl']!='' && logsdata[index]['data']['yydata']['senduser']['imageurl']!=null ?Image.network(
                                        logsdata[index]['data']['yydata']['senduser']['imageurl'],width: 40,height: 40,
                                        fit: BoxFit.cover,
                                      ):Text(logsdata[index]['data']['yydata']['senduser']['name'].name.substring(0,2),style: const TextStyle(fontSize: 14,color: Colors.white),),
                                    ),
                                    const SizedBox(width: 10,),
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(bottom: 10),
                                                    child: Text('${logsdata[index]['data']['yydata']['senduser']['name']}',style: const TextStyle(color: Color(0xFF181818),fontSize: 14,fontWeight: FontWeight.bold),),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(bottom: 10),
                                                    child: Text(
                                                      logsdata[index]['time']>0?
                                                      getVerboseDateTimeRepresentation(DateTime.fromMillisecondsSinceEpoch(logsdata[index]['time'],isUtc: false,)):'',
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          color: BaseColors.gray7
                                                      ),maxLines: 1,overflow: TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              if(logsdata[index]['data']['yydata']['type']=='image') Image.network(
                                                logsdata[index]['data']['yydata']['data']['uri'],width: 60,height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                              if(logsdata[index]['data']['yydata']['type']=='file') TextButton(
                                                  onPressed: () async =>{
                                                    if (await canLaunch(logsdata[index]['data']['yydata']['data']['uri'])) {
                                                      await launch(logsdata[index]['data']['yydata']['data']['uri'])
                                                    } else {
                                                      throw 'Could not launch ${logsdata[index]['data']['yydata']['data']['uri']}'
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text('${logsdata[index]['data']['yydata']['text']}',style: const TextStyle(color: BaseColors.gray10,),),
                                                      const Icon(Icons.assignment_returned,color: BaseColors.gray6,),
                                                    ],
                                                  )
                                              ),
                                              if(logsdata[index]['data']['yydata']['type']=='system' || logsdata[index]['data']['yydata']['type']=='text') Text('${logsdata[index]['data']['yydata']['text']}',style: TextStyle(color: Color(0xff666666)),)
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )

                      );
                    } //使用_cellForRow回调返回每个cell
                )
            )
          ],
        ),
    );
  }
  ///收到
  Future<void> _handleMessageSd(metadata) async {
    ///收到
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
    await HttpUtils.post(
        path:'/api/student/shoudao',
        data: {'id':metadata?['id'],'groupid':metadata?['groupid'],'pushid':metadata?['pushid']}
    ).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        var text ="姓名：${metadata?['data']['s_name']}    电话：${metadata?['data']['tel']}    ${metadata?['data']['education']}    ${metadata?['data']['graduate']}    ${metadata?['data']['address']}    ${metadata?['data']['weixin']}    ${metadata?['data']['email']}\n 推荐：${metadata?['data']['yixiang']}\n备注：${metadata?['data']['remarks']}";
        Clipboard.setData(ClipboardData(text: text));
        var _inboxKey = UniqueKey();
        Navigator.push(context,
            MaterialPageRoute(
                builder: (context){
                  return StudentShowPage(key: _inboxKey,student:metadata,);
                }
            )
        );
      }else{
        showToast(value['message'],duration: const Duration(seconds: 3));
      }
      _loadShowChatLogs(pageNum);
      ///发送更新消息
      final sendMessage = ChatMessage(
        createdAt:DateTime.now().millisecondsSinceEpoch,
        type:'text',
        status: types.Status.sending,
        id:const Uuid().v4(),
        text:'更新消息',
        data:{'id':metadata?['id']} ,
      );
      //widget.sendData(sendMessage,'update');
    });

  }
  //获取聊天记录
  Future<void> _loadShowChatLogs(int page) async {
    searchObj['type']=typex;
    var data=searchObj;
    data['page']=page;
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
    await HttpUtils.post(path:'/api/login/chatlogs',data:data).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        if(page>1){
          var studentArr=logsdata;
          setState(() {
            logsdata = studentArr+value['data'];
            isLoading=false;
            //total=value['total'];
            pageNum=page;
          });
        }else{
          setState(() {
            logsdata = value['data'];
            isLoading=false;
            //total=value['total'];
            pageNum=page;
          });
        }
        if(value['data'].length==0){
          setState(() {
            isLoading=false;
            pageNum=page;
          });
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
  ///单选按钮
  void _onchange(feild,value){
    setState(() {
      typex=value;
      _loadShowChatLogs(1);
    });
  }
  List<Widget> buttonWight(dat,onchange,maxnum,feild,value){
    if(maxnum>dat.length) maxnum=dat.length;
    List<Widget> arr=[];
    for(var ii=0;ii<maxnum;ii++){
      arr.add(
        Container(
          child: TextButton(
            onPressed: ()=>{onchange(feild,dat[ii]['id'])},
            // style: ButtonStyle(
            //   backgroundColor: ButtonStyleButton.allOrNull<Color>(
            //     value==dat[ii]['id']?Colors.cyan:BaseColors.gray5
            //   ),
            //   shape: MaterialStateProperty.all(
            //     const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
            //   ),
            //   maximumSize: MaterialStateProperty.all(const Size(60, 35)),
            //   minimumSize: MaterialStateProperty.all(const Size(60, 35))
            // ),
            // child: Text('${dat[ii]['name'].length>6?dat[ii]['name'].substring(0,6):dat[ii]['name']}',overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(fontSize: 14,color: value==dat[ii]['id']?Colors.white:BaseColors.gray8,fontWeight: FontWeight.w400),),
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
              ),
              padding: MaterialStateProperty.all<EdgeInsets>(
                 EdgeInsets.only(left:0,right: 0,bottom:15),
              ),
              minimumSize: MaterialStateProperty.all(const Size(20, 35)),
            ),
            child: Text('${dat[ii]['name'].length>6?dat[ii]['name'].substring(0,6):dat[ii]['name']}',overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(fontSize: 14,color: value==dat[ii]['id']?Color(0xFF181818):Color(0xFF999999),fontWeight: value==dat[ii]['id']?FontWeight.bold:FontWeight.normal),),
          ),
        )
      );
    }
    if(dat.length > maxnum+1) {
      List<PopupMenuItem> arrmenu=[];
      String selmore='';
      for(var ii=maxnum;ii<dat.length;ii++){
        arrmenu.add(
            PopupMenuItem(value: dat[ii]['id'],textStyle:TextStyle(color: value==dat[ii]['id']?Colors.cyan:BaseColors.gray11), child: Text('${dat[ii]['name']}'))
        );
        if(value==dat[ii]['id']){
          selmore=dat[ii]['name'];
        }
      }
      arr.add(PopupMenuButton(
          onSelected: (va){
            onchange(feild,va);
          }, tooltip:'更多选项',
          color: Colors.amber,
          shadowColor: Colors.red,
          itemBuilder: (BuildContext context){
            return arrmenu;
          },
          child:  Container(
            color: selmore!=''?Colors.cyan:Colors.white,
            height: 26,
            padding: const EdgeInsets.only(left: 10,top: 3,right: 10),
            child: Text(selmore!=''? '${selmore} >' :'更多',),
          )
      ));
    }
    return arr;
  }
  ///日期选择
  Future<DateTime?> _showDatePickerForTheme(BuildContext context,String def) {
    late DateTime initialDate=DateTime.now();
    if(def.isNotEmpty && def!=null){ ///2023-01-02
      var year=def.substring(0,4);
      if(def.length>=10 ){
        var mouth=def.substring(5,7);
        var day=def.substring(8,10);
        initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day));
      }else if(def.length>=7){
        var mouth=def.substring(5,7);
        initialDate=DateTime(int.parse(year), int.parse(mouth));
      }else{
        initialDate=DateTime(int.parse(year), 1);
      }
    }
    return showDatePicker(
      context: context, // 上下文
      initialDate: initialDate, // 初始化选中日期
      firstDate: DateTime(1997, 5), // 开始日期
      lastDate: DateTime(2052, 7), // 结束日期
      currentDate: DateTime.now(), // 当前日期
      locale: const Locale('zh'),
      initialEntryMode: DatePickerEntryMode
          .calendarOnly, // 日历弹框样式 calendar: 默认显示日历，可切换成输入模式，input:默认显示输入模式，可切换到日历，calendarOnly:只显示日历，inputOnly:只显示输入模式
      selectableDayPredicate: (dayTime) {
        // 自定义哪些日期可选
        // if (dayTime == DateTime(2022, 5, 6) || dayTime == DateTime(2022, 6, 8)) {
        //   return false;
        // }
        return true;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,//add your + button color here
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigo, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      helpText: "请选择日期", // 左上角提示文字
      cancelText: "关闭", // 取消按钮 文案
      confirmText: "确定", // 确认按钮 文案
      initialDatePickerMode: DatePickerMode.day, // 日期选择模式 默认为天
      useRootNavigator: true, // 是否使用根导航器
      textDirection: TextDirection.ltr, // 水平方向 显示方向 默认 ltr
    );
  }
}
