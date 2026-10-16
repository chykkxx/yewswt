import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/colors.dart';

import '../../http/request.dart';

class StudentRemarksPage extends StatefulWidget {
  const StudentRemarksPage({super.key,required this.id,required this.s_name,required this.tel,required this.status});
  final int id;
  final String? s_name;
  final String? tel;
  final int? status;
  @override
  State<StudentRemarksPage> createState() => _StudentRemarksPagePageState();
}

class _StudentRemarksPagePageState extends State<StudentRemarksPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();

  late  List<DropdownMenuItem<String>> fenlei;
  late  List<DropdownMenuItem<String>> manage;
  late String xsstatus=widget.status.toString();
  late String manage_id;
  late List remarksData=[];
  bool isLoading =false;
  int page=1;
  int total=0;
  final TextEditingController _controllerStartDay = TextEditingController();///下次跟进时间
  final TextEditingController _controllerRemarks = TextEditingController();///备注

  final ScrollController _scrollController = ScrollController();///整体滚动，输入框点击时防止底部按钮挡住输入框

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ///防止底部按钮挡住输入框
  void _clickDelayedScroll(int topScroll) {
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
    _loadStudent(widget.id);
  }
  Future<void> _saveStudent() async {
    if(_controllerRemarks.text=='') return;
    Map upData={
      'pushid':widget.id,
      'status':xsstatus,
      'nexttime':_controllerStartDay.text,
      'remarks':_controllerRemarks.text,
    };
    await HttpUtils.post(path:'/api/Student/createremarks',data:upData).then((value) {
      if(value['code']==200){
        Navigator.pop(context);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: InkWell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${widget.s_name}(${widget.tel})'),
              SizedBox(width:5),
              const Image(image: AssetImage('static/images/tel.png'),width: 18,)
            ],
          ),
          onTap: () async {
            final Uri launchUri = Uri(
              scheme: 'tel',
              path: widget.tel,
            );
            await launchUrl(launchUri);
          },
        ),
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
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                  shrinkWrap: true,//解决无限高度问题
                  physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                  itemCount: remarksData.length, //告诉ListView总共有多少个cell
                  itemBuilder: (context, index){
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // 底色
                        borderRadius: BorderRadius.circular(4),
                        border: const Border(
                          bottom: BorderSide(width: 0.5,color: BaseColors.gray5),
                        )
                      ),
                      //color: Colors.white,
                      // margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      // padding: const EdgeInsets.fromLTRB(10,0,10,10),
                      child: Column(
                        children: <Widget>[

                          Container(
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  //width: 40,
                                  child: const Text('备注信息：',
                                    style: TextStyle(color: BaseColors.gray6),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${remarksData[index]['remarks']}',
                                    //maxLines: 1,overflow: TextOverflow.ellipsis
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      '回访状态：',
                                      style: TextStyle(color: BaseColors.gray6),
                                    ),
                                    Text('${remarksData[index]['statusname']['name']}',maxLines: 1,overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Text(
                                      '下次跟进：',
                                      style: TextStyle(color: BaseColors.gray6),
                                    ),
                                    Text(remarksData[index]['nexttime'] ?? '',maxLines: 1,overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Text(
                                      '添加时间：',
                                      style: TextStyle(color: BaseColors.gray6),
                                    ),
                                    Text(remarksData[index]['created_at'] ?? '',maxLines: 1,overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } //使用_cellForRow回调返回每个cell
              )
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // 底色
                borderRadius: BorderRadius.circular(2),
              ),
              //color: Colors.white,
              margin: const EdgeInsets.only(left: 10,right: 10),
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
                              '回访状态',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 10),
                              height: 44,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none, labelText: '',
                                  isCollapsed: true,
                                ),
                                // 设置默认值
                                value:widget.status.toString(),
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
                              '下次跟进',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(top: 10),
                                height: 44,
                                // width: (MediaQuery.of(context).size.width-120),
                                child: TextField(
                                  controller: _controllerStartDay,
                                  cursorWidth: 1,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                    suffixIcon: GestureDetector(
                                      child: const Padding(
                                        padding: EdgeInsets.only(bottom: 8,left: 20),
                                        child: Icon(Icons.close,size: 14,color: BaseColors.gray6,),
                                      ),
                                      onTap: (){
                                        _controllerStartDay.text='';
                                      },
                                    ),
                                    // suffixIcon: Padding(
                                    //   padding: const EdgeInsets.only(bottom: 8,left: 20),
                                    //   child: GestureDetector(
                                    //     child: const Icon(Icons.close,size: 14,color: BaseColors.gray6,),
                                    //     onTap: (){
                                    //       _controllerStartDay.text='';
                                    //     },
                                    //   ),
                                    // )
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    var ss=_showDatePickerForTheme(context,_controllerStartDay.text);
                                    ss.then((value) {
                                      var day ='';
                                      if(value!=null){
                                        //print(formatDate(value, [yyyy, '-', mm, '-', dd,HH, ':', nn, ':', s]));
                                        //day =value.toString().substring(0,11);
                                        day =formatDate(value, [yyyy, '-', mm, '-', dd]);
                                        var his=_selectTime(context,_controllerStartDay.text);
                                        his.then((values) {
                                          _controllerStartDay.text='$day $values';
                                        });
                                      }
                                      //widget.setSearch('startDay',day);
                                    });
                                  },
                                  onChanged: (text){
                                    //widget.setSearch('startDay',text);
                                  },
                                ),
                              )
                          ),
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
                              '备注信息',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:16
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 12,bottom: 12),
                              //height: 40,
                              child: TextField(
                                controller: _controllerRemarks,
                                style: TextStyle(fontSize: 16),
                                cursorWidth: 1,
                                maxLines: 5,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                ),
                                onTap: (){
                                  _clickDelayedScroll(0);
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
    await HttpUtils.post(path:'/api/Student/getremarks',data:{'pushid':id}).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){

        List<DropdownMenuItem<String>> fenleilist=[];
        value['fenlei'].forEach((item){
          fenleilist.add(DropdownMenuItem(value: item['id'].toString(), child: Text(item['name'])));
        });

        setState(() {
          remarksData = value['data'];
          fenlei=fenleilist.toList();
          isLoading=true;
        });
      }else{
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
  Future<DateTime?> _showDatePickerForTheme(BuildContext context,String def) {
    late DateTime initialDate=DateTime.now();
    if(def.isNotEmpty && def!=null){ ///2023-01-02
      var year=def.substring(0,4);
      if(def.length>=10 ){
        var arr=def.split(' ');
        var mouth=def.substring(5,7);
        var day=def.substring(8,10);
        if(arr.length==2){
          var sfm=arr[1].split(':');
          if(sfm.length==3){
            initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day), int.parse(sfm[0]), int.parse(sfm[1]), int.parse(sfm[2]));
          }else if(sfm.length==2){
            initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day), int.parse(sfm[0]), int.parse(sfm[1]));
          }else{
            initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day), int.parse(sfm[0]));
          }
        }else{
          initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day));
        }
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
      cancelText: '取消',
      confirmText: '确定',
      initialDatePickerMode: DatePickerMode.day, // 日期选择模式 默认为天
      useRootNavigator: true, // 是否使用根导航器
      textDirection: TextDirection.ltr, // 水平方向 显示方向 默认 ltr
    );
  }
  Future<String> _selectTime(BuildContext context,String def) async {
    late DateTime initialDate=DateTime.now();
    if(def.isNotEmpty && def!=null){ ///2023-01-02
      var year=def.substring(0,4);
      if(def.length>=10 ){
        var arr=def.split(' ');
        var mouth=def.substring(5,7);
        var day=def.substring(8,10);
        if(arr.length==2){
          var sfm=arr[1].split(':');
          if(sfm.length==3){
            initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day), int.parse(sfm[0]), int.parse(sfm[1]), int.parse(sfm[2]));
          }else if(sfm.length==2){
            initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day), int.parse(sfm[0]), int.parse(sfm[1]));
          }else{
            initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day), int.parse(sfm[0]));
          }
        }else{
          initialDate=DateTime(int.parse(year), int.parse(mouth), int.parse(day));
        }
      }else if(def.length>=7){
        var mouth=def.substring(5,7);
        initialDate=DateTime(int.parse(year), int.parse(mouth));
      }else{
        initialDate=DateTime(int.parse(year), 1);
      }
    }
    var ss=formatDate(initialDate, [s]);
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(initialDate);
    final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        //initialEntryMode: TimePickerEntryMode.input,
        builder: (context,child){
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
              child: child!
          );
        },
        helpText: '选择时间',
        cancelText: '取消',
        confirmText: '确定'
    );
    return time.toString().substring(10,15)+':'+ss;
    //return time;
  }
}