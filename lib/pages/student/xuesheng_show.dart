import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yewswt/data/colors.dart';
import 'package:yewswt/http/request.dart';
import '../picker.dart';
import 'yiliaoduihua.dart';
import 'package:yewswt/model/base_store.dart';

class MobileXueShengShowPage extends StatefulWidget {
  const MobileXueShengShowPage({super.key,required this.student});
  final Map? student;
  @override
  State<MobileXueShengShowPage> createState() => _XueShengShowPageState();
}

class _XueShengShowPageState extends State<MobileXueShengShowPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  late Map students={'modulesel':[],'filess':[]};
  late  List<DropdownMenuItem<String>> fenlei;
  late  List<DropdownMenuItem<String>> manage;
  late  List yiliaodh=[];
  late  List areacrm=[];
  late  List areaarr=[];
  late  List lypt=[];//来源平台 57
  late  List ptlx=[];//平台类型 276
  late  List zxfs=[];//咨询方式 296
  late  List fslx=[];//方式类型 308
  late  List xueli=[];//当前学历 27
  late  List zhuangtai=[];//学生状态 243
  late  List call_status=[];//回访状态 220
  late  List leixing=[];//dc_leixing
  late Map modulearr={};
  late String xsstatus;
  late String manage_id;
  bool isLoading =true;
  bool telMore =false;
  int page=1;
  int total=0;
  final TextEditingController _controllerName = TextEditingController();///姓名
  final TextEditingController _controllerTel = TextEditingController();///电话
  final TextEditingController _controllerWeixin = TextEditingController();///微信
  final TextEditingController _controllerSeekmessage = TextEditingController();///其他
  final TextEditingController _controllerSchool = TextEditingController();///学校
  final TextEditingController _controllerEducation = TextEditingController();///学历
  final TextEditingController _controllerGraduate = TextEditingController();///毕业时间
  final TextEditingController _controllerAddress = TextEditingController();///所在城市
  final TextEditingController _controllerBmRemark = TextEditingController();///报名专业
  final TextEditingController _controllerRemarks = TextEditingController();///备注
  final TextEditingController _controllerStartDay = TextEditingController();///咨询时间
  final TextEditingController _controllerCallRemarks = TextEditingController();///回访备注
  final TextEditingController _controllerNexttime = TextEditingController();///下次回访时间
  final controller = MultiImagePickerController(
    maxImages: 1,
    images: <ImageFile>[], // array of pre/default selected images
    picker: (bool allowMultiple) async {
      //return await pickConvertedImages(allowMultiple);
      return await pickImagesUsingImagePicker(allowMultiple);
    },
  );
  @override
  void initState() {
    super.initState();
    _loadStudent(widget.student?['id']);
  }
  late Map searchObj={
    'name':'','jigou_id':'','jigou':'',
  };
  void setSearch(field,value){
    setState(() {
      searchObj[field]=value;
    });
  }
  Future<void> _saveStudent() async {
    var modulearrx={};
    for(var ii in modulearr.keys){
      modulearrx[ii.toString()]=modulearr[ii];
    }
    Map upData={
      'id':widget.student?['id'],
      's_name':_controllerName.text,
      'sex':students['sex'],
      'tel':_controllerTel.text.replaceAll('\n', '|'),
      'weixin':_controllerWeixin.text,
      'seekmessage':_controllerSeekmessage.text,
      'school':_controllerSchool.text,
      'education':students['education'],
      'graduate':_controllerGraduate.text,
      'status':students['status'],
      'province':students['province'],
      'city':students['city'],
      'address':_controllerAddress.text,
      'modulesel':students['modulesel'],
      'modulearr':modulearrx,
      'call_status':students['call_status'],
      'call_remarks':_controllerCallRemarks.text,
      'nexttime':_controllerNexttime.text,
      'remarks':_controllerRemarks.text,
      'filess':jsonEncode(students['filess'])
    };
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
      duration: const Duration(seconds: 30),
      onDismiss: () {
        // The method will be called on toast dismiss.
        //debugPrint('Toast has been dismissed.');
      },
    );
    await HttpUtils.post(path:'/api/Xuesheng/save',data:upData).then((value) {
      toastFuture.dismiss();
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
                Text('${widget.student?['s_name']}(${widget.student?['tel']})'),
                SizedBox(width:5),
                const Image(image: AssetImage('static/images/tel.png'),width: 18,)
              ],
            ),
            onTap: () async {
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: widget.student?['tel'],
              );
              await launchUrl(launchUri);
            },
          )
      ),
      body: isLoading?SingleChildScrollView(
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
                borderRadius: BorderRadius.circular(10),
              ),
              //color: Colors.white,
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.only(top: 10,bottom: 10),
                      child: TextField(
                        controller: _controllerSeekmessage,
                        cursorColor: BaseColors.orange500,
                        maxLines: 5,
                        minLines: 2,
                        decoration: const InputDecoration(
                          hintText: '其他信息',
                          hintStyle: TextStyle(fontSize: 16, color: Color(0xFF999999)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                          ),

                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment : MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:MaterialStateProperty.all(Colors.blue),
                          ),
                          onPressed: () {
                            _shibie();///识别信息
                          },
                          child: const Text("识别",style: TextStyle(color: Colors.white),)
                      ),
                      const SizedBox(width: 10,),
                      if(yiliaodh.isNotEmpty)ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:MaterialStateProperty.all(Colors.orangeAccent),
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context){
                                      return YiliaoDuihua(data: yiliaodh,);
                                    }
                                )
                            );
                          },
                          child: const Text("对话",style: TextStyle(color: Colors.white),)
                      ),
                    ],
                  )
                ],
              ),
              //每人一辆跑车
            ),
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
                borderRadius: BorderRadius.circular(10),
              ),
              //color: Colors.white,
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        const Text(
                          '姓　　名：',
                          style: TextStyle(color: BaseColors.gray8),
                        ),
                        Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                              height: 40,
                              child: TextField(
                                controller: _controllerName,
                                cursorColor: BaseColors.orange500,
                                decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                                    ),
                                    contentPadding: const EdgeInsets.only(left: 10),
                                    suffixIcon: Padding(
                                      padding:  const EdgeInsets.only(top: 0,left: 10),
                                      child: GestureDetector(
                                        child:   const SizedBox(width: 0,),
                                        onTap: (){
                                          _controllerTel.clear();
                                        },
                                      ),
                                    )
                                ),
                              ),
                            )

                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        const Text(
                          '性　　别：',
                          style: TextStyle(color: BaseColors.gray8),
                        ),
                        Container(
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: (){
                                  setState(() {
                                    students['sex']=1;
                                  });
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                                  ),
                                  backgroundColor: ButtonStyleButton.allOrNull<Color>(
                                      students['sex']==1?Colors.cyan:BaseColors.gray5
                                  ),
                                ),
                                child: Text('男'),
                              ),
                              TextButton(
                                  onPressed: (){
                                    setState(() {
                                      students['sex']=2;
                                    });
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                        const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                                    ),
                                    backgroundColor: ButtonStyleButton.allOrNull<Color>(
                                        students['sex']==2?Colors.cyan:BaseColors.gray5
                                    ),
                                  ),
                                  child: Text('女')
                              ),
                              TextButton(
                                  onPressed: (){
                                    setState(() {
                                      students['sex']=3;
                                    });
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                        const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                                    ),
                                    backgroundColor: ButtonStyleButton.allOrNull<Color>(
                                        students['sex']==3?Colors.cyan:BaseColors.gray5
                                    ),
                                  ),
                                  child: Text('其他')
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '电　　话：',
                          style: TextStyle(color: BaseColors.gray8),
                        ),
                        Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                              height: telMore==true?80:40,
                              child: TextField(
                                controller: _controllerTel,
                                cursorColor: BaseColors.orange500,
                                maxLines: 5,
                                minLines: 1,
                                decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                                    ),
                                    contentPadding: const EdgeInsets.only(left: 10),
                                    suffixIcon: Padding(
                                      padding:  const EdgeInsets.only(top: 0,left: 10),
                                      child: GestureDetector(
                                        child:   const SizedBox(width: 0,),
                                        onTap: (){
                                          _controllerTel.clear();
                                        },
                                      ),
                                    )
                                ),
                                onChanged: (value){
                                  setState(() {
                                    telMore=_controllerTel.text.contains("\n");
                                  });
                                },
                              ),
                            )

                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        const Text(
                          '微　　信：',
                          style: TextStyle(color: BaseColors.gray8),
                        ),
                        Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                              height: 40,
                              child: TextField(
                                controller: _controllerWeixin,
                                cursorColor: BaseColors.orange500,
                                decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                                    ),
                                    contentPadding: const EdgeInsets.only(left: 10),
                                    suffixIcon: Padding(
                                      padding:  const EdgeInsets.only(top: 0,left: 10),
                                      child: GestureDetector(
                                        child:   const SizedBox(width: 0,),
                                        onTap: (){
                                          _controllerWeixin.clear();
                                        },
                                      ),
                                    )
                                ),
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        const Text(
                          '毕业时间：',
                          style: TextStyle(color: BaseColors.gray8),
                        ),
                        Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                              height: 40,
                              child: TextField(
                                controller: _controllerGraduate,
                                cursorColor: BaseColors.orange500,
                                decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                                    ),
                                    contentPadding: const EdgeInsets.only(left: 10),
                                    suffixIcon: Padding(
                                      padding:  const EdgeInsets.only(top: 0,left: 10),
                                      child: GestureDetector(
                                        child:   const SizedBox(width: 0,),
                                        onTap: (){
                                          _controllerGraduate.clear();
                                        },
                                      ),
                                    )
                                ),
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        const Text(
                          '所在城市：',
                          style: TextStyle(color: BaseColors.gray8),
                        ),
                        Expanded(
                            child: Container(
                                padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                                alignment: Alignment.center,
                                height: 40,
                                child: Builder(
                                    builder: (cxt){
                                      return TextField(
                                          controller: _controllerAddress,
                                          cursorColor: BaseColors.orange500,
                                          decoration:  InputDecoration(
                                              enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                                              ),
                                              contentPadding: EdgeInsets.only(left: 10),
                                              suffixIcon: Padding(
                                                  padding:  const EdgeInsets.only(left: 10),
                                                  child:IconButton(onPressed: (){Scaffold.of(cxt).openEndDrawer();}, icon: const Icon(Icons.area_chart,size: 20,color: Colors.blue,))
                                              )
                                          ),
                                          readOnly:true,
                                          onTap:(){
                                            Scaffold.of(cxt).openEndDrawer();
                                          }
                                      );
                                    })

                            )
                        )
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.centerLeft,
                    child:Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children: [
                        const Text('学　　历：',
                          style: TextStyle(color: BaseColors.gray8),
                        ),
                        Row(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Wrap(
                                //布局方向，默认是（Axis.horizontal）横向
                                  direction: Axis.horizontal,
                                  //横向间距
                                  spacing: 0,
                                  //竖向间距
                                  runSpacing: 0.25,
                                  //横向对齐方式
                                  alignment: WrapAlignment.start,
                                  children: buttonWight(xueli,_onchange,xueli.length,'education',students['education'])),
                            ),
                          ],
                        ),
                      ],
                    )

                  ),
                ],
              ),
              //每人一辆跑车
            ),
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
                borderRadius: BorderRadius.circular(10),
              ),
              //color: Colors.white,
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment : CrossAxisAlignment.start,
                children: [
                  const Text('学生状态：',
                    style: TextStyle(color: BaseColors.gray8),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Wrap(
                            //布局方向，默认是（Axis.horizontal）横向
                              direction: Axis.horizontal,
                              //横向间距
                              spacing: 0,
                              //竖向间距
                              runSpacing: 0.25,
                              //横向对齐方式
                              alignment: WrapAlignment.start,
                              children: buttonWight(zhuangtai,_onchange,zhuangtai.length,'status',students['status'])),
                        ),
                      ],
                    ),
                  ),
                  students['status']==244?Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children: [
                      const Text('回访类型：',
                        style: TextStyle(color: BaseColors.gray8),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Wrap(
                                //布局方向，默认是（Axis.horizontal）横向
                                  direction: Axis.horizontal,
                                  //横向间距
                                  spacing: 0,
                                  //竖向间距
                                  runSpacing: 0.25,
                                  //横向对齐方式
                                  alignment: WrapAlignment.start,
                                  children: buttonWight(call_status,_onchange,call_status.length,'call_status',students['call_status'])),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text('回访备注：',
                              style: TextStyle(color: BaseColors.gray8),
                            ),
                            Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(top: 10,bottom: 10),
                                  child: TextField(
                                    controller: _controllerCallRemarks,
                                    cursorColor: BaseColors.orange500,
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                                      ),
                                      contentPadding: EdgeInsets.only(left: 10),
                                    ),
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Text(
                              '下次回访：',
                              style: TextStyle(color: BaseColors.gray8),
                            ),
                            Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  height: 40,
                                  child: TextField(
                                    controller: _controllerNexttime,
                                    cursorColor: BaseColors.orange500,
                                    decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                                        ),
                                        contentPadding: const EdgeInsets.only(left: 10),
                                        suffixIcon: Padding(
                                          padding:  const EdgeInsets.only(top: 0,left: 10),
                                          child: _controllerNexttime.text.isNotEmpty?GestureDetector(
                                            child:  const SizedBox(width: 0,),
                                            onTap: (){
                                              _controllerNexttime.text='';
                                            },
                                          ):null,
                                        )
                                    ),
                                    readOnly: true,
                                    onTap: () {
                                      var ss=_showDatePickerForTheme(context,_controllerNexttime.text);
                                      ss.then((value) {
                                        var day ='';
                                        if(value!=null){
                                          //print(formatDate(value, [yyyy, '-', mm, '-', dd,HH, ':', nn, ':', s]));
                                          //day =value.toString().substring(0,11);
                                          day =formatDate(value, [yyyy, '-', mm, '-', dd]);
                                        }
                                        var his=_selectTime(context,_controllerNexttime.text);
                                        his.then((value) {
                                          _controllerNexttime.text='$day $value';
                                        });
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
                    ],
                  ):Column(
                    children: [
                      students['status']==245?Column(
                        crossAxisAlignment : CrossAxisAlignment.start,
                        children: [
                          const Text('推送类型：',
                            style: TextStyle(color: BaseColors.gray8),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [

                                Expanded(
                                  child: Wrap(
                                    //布局方向，默认是（Axis.horizontal）横向
                                      direction: Axis.horizontal,
                                      //横向间距
                                      spacing: 0,
                                      //竖向间距
                                      runSpacing: 0.25,
                                      //横向对齐方式
                                      alignment: WrapAlignment.start,
                                      children: leixingWight(leixing,_onchangeLeixing,leixing.length,'modulesel',students['modulesel'])),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                              shrinkWrap: true,//解决无限高度问题
                              physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                              itemCount: students['modulesel'].length,
                              itemBuilder: _cellForRow
                          )
                        ],
                      ):const SizedBox(height: 0,),
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text('附件图片：',
                              style: TextStyle(color: BaseColors.gray8),
                            ),
                            TextButton(
                              onPressed: (){
                                openGallerySystem();
                              },
                              style: ButtonStyle(
                                  backgroundColor:MaterialStateProperty.all(Colors.blue[600])
                              ),
                              child: const Text('上传'),
                            ),

                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if(students['filess'].length>0)
                            InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 10,bottom: 10),
                                child: Container(
                                  width: 200.0,
                                  height: 200.0,
                                  color: Colors.white,
                                  child: Image.network(
                                    students['filess'][0]['url'],
                                  ),
                                ),
                              ),
                              onTap: (){
                                openGallerySystem();
                              },
                            ),
                          if(students['filess'].length>1)
                            InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 10,bottom: 10),
                                child: Container(
                                  width: 200.0,
                                  height: 200.0,
                                  color: Colors.white,
                                  child: Image.network(
                                    students['filess'][1]['url'],
                                  ),
                                ),
                              ),
                              onTap: (){
                                openGallerySystem();
                              },
                            ),
                          if(students['filess'].length>2)
                            InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 10,bottom: 10),
                                child: Container(
                                  width: 200.0,
                                  height: 200.0,
                                  color: Colors.white,
                                  child: Image.network(
                                    students['filess'][2]['url'],
                                  ),
                                ),
                              ),
                              onTap: (){
                                openGallerySystem();
                              },
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text('学生备注：',
                              style: TextStyle(color: BaseColors.gray8),
                            ),
                            Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(top: 10,bottom: 10),
                                  child: TextField(
                                    controller: _controllerRemarks,
                                    cursorColor: BaseColors.orange500,
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                                      ),
                                      contentPadding: EdgeInsets.only(left: 10),
                                    ),
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  )

                ],
              ),
              //每人一辆跑车
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
      floatingActionButton: FloatingActionButton(
        backgroundColor:Colors.green,
        child: const Text('保存',style: TextStyle(color: Colors.white),),
        onPressed: (){
          _saveStudent();
        },

      ),
      endDrawer: AppDrawer(areacrm:areacrm,selArea:_selArea,field: 'city',student:students),
      onEndDrawerChanged: (ifShou){
        if(ifShou==false){

        }
      },
    );
  }
  Widget _cellForRow(BuildContext context, int index) {
    var lxobj=leixing.firstWhere((v) => v['id'] == students['modulesel'][index]);
    return Container(

        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(width: 1, color: BaseColors.orange500,),
        ),

        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.only(bottom: 10),
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1,color: BaseColors.gray11)
                  )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    //color: Colors.blue,
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.blue,
                    ),
                    child: Text('${lxobj['name']}',
                      overflow: TextOverflow.ellipsis,maxLines: 1,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                      onPressed: (){
                        setState(() {
                          modulearr[students['modulesel'][index]].add({'id':0,'str_school_major':['','','','']});
                        });
                      },
                      child:  const Text(
                        '新增意向',
                        style: TextStyle(
                            //fontWeight: FontWeight.w800,
                            fontSize: 12.0,
                            color: Colors.green
                        ),
                      ),
                  )
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,//解决无限高度问题
              physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
              itemCount: modulearr[students['modulesel'][index]].length,
              itemBuilder: (context, item) =>Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.5,color: Colors.blue)
                  )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                      height: 40,
                      child: TextField(
                        controller:TextEditingController.fromValue(TextEditingValue(text: modulearr[students['modulesel'][index]][item]['str_school_major'][0])),
                        cursorColor: BaseColors.orange500,
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                            hintText: '学校',
                            hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF999999)),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                            ),
                            contentPadding: const EdgeInsets.only(left: 10),
                            suffixIcon: Padding(
                              padding:  const EdgeInsets.only(top: 0,left: 10),
                              child: GestureDetector(
                                child:   const SizedBox(width: 0,),
                                onTap: (){
                                  _controllerTel.clear();
                                },
                              ),
                            )
                        ),
                        onChanged: (value){
                          modulearr[students['modulesel'][index]][item]['str_school_major'][0]=value;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                      height: 40,
                      child: TextField(
                        controller:TextEditingController.fromValue(TextEditingValue(text: modulearr[students['modulesel'][index]][item]['str_school_major'].length>1?modulearr[students['modulesel'][index]][item]['str_school_major'][1]:'')),
                        cursorColor: BaseColors.orange500,
                        decoration: InputDecoration(
                            hintText: '学院',
                            hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF999999)),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                            ),
                            contentPadding: const EdgeInsets.only(left: 10),
                            suffixIcon: Padding(
                              padding:  const EdgeInsets.only(top: 0,left: 10),
                              child: GestureDetector(
                                child:   const SizedBox(width: 0,),
                                onTap: (){
                                  modulearr[students['modulesel'][index]][item]['str_school_major'][1]='';
                                },
                              ),
                            )
                        ),
                        onChanged: (value){
                          modulearr[students['modulesel'][index]][item]['str_school_major'][1]=value;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                      height: 40,
                      child: TextField(
                        controller:TextEditingController.fromValue(TextEditingValue(text: modulearr[students['modulesel'][index]][item]['str_school_major'].length>2?modulearr[students['modulesel'][index]][item]['str_school_major'][2]:'')),
                        cursorColor: BaseColors.orange500,
                        decoration: InputDecoration(
                            hintText: '专业',
                            hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF999999)),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                            ),
                            contentPadding: const EdgeInsets.only(left: 10),
                            suffixIcon: Padding(
                              padding:  const EdgeInsets.only(top: 0,left: 10),
                              child: GestureDetector(
                                child:   const SizedBox(width: 0,),
                                onTap: (){
                                  modulearr[students['modulesel'][index]][item]['str_school_major'][2]='';
                                },
                              ),
                            )
                        ),
                        onChanged: (value){
                          modulearr[students['modulesel'][index]][item]['str_school_major'][2]=value;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                      height: 40,
                      child: TextField(
                        controller:TextEditingController.fromValue(TextEditingValue(text: modulearr[students['modulesel'][index]][item]['str_school_major'].length>3?modulearr[students['modulesel'][index]][item]['str_school_major'][3]:'')),
                        cursorColor: BaseColors.orange500,
                        decoration: InputDecoration(
                            hintText: '班型',
                            hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF999999)),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                            ),
                            contentPadding: const EdgeInsets.only(left: 10),
                            suffixIcon: Padding(
                              padding:  const EdgeInsets.only(top: 0,left: 10),
                              child: GestureDetector(
                                child:   const SizedBox(width: 0,),
                                onTap: (){
                                  modulearr[students['modulesel'][index]][item]['str_school_major'][3]='';
                                },
                              ),
                            )
                        ),
                        onChanged: (value){
                          modulearr[students['modulesel'][index]][item]['str_school_major'][3]=value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ), //每人一辆跑车


    );
  }
  ///获取学生信息
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
      duration: const Duration(seconds: 30),
      onDismiss: () {
        // The method will be called on toast dismiss.
        //debugPrint('Toast has been dismissed.');
      },
    );
    await HttpUtils.post(path:'/api/Xuesheng/show',data:{'id':id}).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        if(value['data']['files']!=null && value['data']['files']!='') {
          value['data']['filess'] = jsonDecode(value['data']['files']);
        }else{
          value['data']['filess'] =[];
        }
        _controllerName.text=value['data']['s_name'];
        _controllerTel.text=value['data']['tel'].replaceAll('|', '\n');
        _controllerWeixin.text = value['data']['weixin']??'';///微信
        _controllerSeekmessage.text = value['data']['seekmessage']??'';///其他信息
        _controllerGraduate.text = value['data']['graduate']??'';///毕业时间
        _controllerRemarks.text = value['data']['remarks']??'';///备注
        _controllerAddress.text = value['data']['citytext']??'';///所在城市
        _controllerNexttime.text = value['data']['nexttime']??'';///下次回访时间
        _controllerCallRemarks.text = value['data']['call_remarks']??'';///回访备注
        setState(() {
          //if(value['ylduihua']!=null) yiliaodh=jsonDecode(value['ylduihua']['currentChatJsonDetail']);
          yiliaodh=value['ylduihua']['duihua'];
          telMore=_controllerTel.text.contains("\n");
          if(value['data']['modulearr']!=null) {
            value['data']['modulearr'].forEach( (key, value){
              modulearr[int.parse(key)]=value;
            } );
          }else{
            value['data']['modulearr']={};
          }
          if(value['data']['modulesel']==null) value['data']['modulesel']=[];
          students = value['data'];
          areacrm = value['areacrm'];
          areaarr = value['areacrm'];
          //fenlei=fenleilist.toList();
          //manage=managelist.toList();
          lypt=value['lypt'];//来源平台 57
          ptlx=value['ptlx'];//平台类型 276
          zxfs=value['zxfs'];//咨询方式 296
          fslx=value['fslx'];//方式类型 308
          xueli=value['xueli'];//当前学历 27
          zhuangtai=value['zhuangtai'];//学生状态 243
          leixing=value['leixing'];//dc_leixing
          call_status=value['call_status'];//回访状态 220

          isLoading=true;
        });
      }else{
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
  ///识别信息
  void _shibie(){
    if(widget.student?['status']==333){
      setState(() {
        students['modulesel']=[];
        modulearr={};
      });
    }
    //print(_controllerSeekmessage.text);
    ///Map leixingarr0={1:'1',2:'2',3:'3',4:'4',5:'5',6:'6',7:'7',8:'13',9:'8',10:'9',11:'11',12:'10',13:'14',14:'12'};
    Map leixingarr={14:'12',13:'14',12:'10',11:'11',10:'9',9:'8',8:'13',7:'7',6:'6',5:'5',4:'4',3:'3',2:'2',1:'1'};
    Map leixingarr1={1:'同等',2:'专硕',3:'国硕',4:'中外',5:'高级',6:'高管',7:'博士',8:'辅导',9:'调剂',10:'专本科',11:'建造师',12:'国际学校',13:'国博',14:'资格证书'};
    Map leixingarr2={1:'同力',2:'专硕',3:'国硕',4:'合办',5:'研修',6:'培训',7:'国博',8:'考辅',9:'调剂',10:'专本',14:'证书'};
    Map leixingarr3={1:'同等学历',2:'专业硕士',3:'国际硕士',4:'中外合办',5:'高级研修',6:'高管培训',7:'在职博士',8:'考研辅导',9:'考研调剂',10:'专科本科',11:'建造师',12:'国际学校',13:'国际博士',14:'资格证书'};
    Map xueliarr={28:'大专以下',29:'公立大专',35:'民办大专',30:'成人大专',36:'民办本科',321:'无学位',31:'学位',37:'成人本科',38:'大专在读',34:'本科在读',32:'硕士',33:'博士'};
    Map xueliarr2={29:'大专',31:'有学位',321:'本科无学位'};
    Map xueliarr3={31:'学士',29:'专科'};
    Map xueliarr4={29:'专升本'};
    DateTime currentTime = DateTime.now();
    var year=currentTime.year;
    var arr=[];
    if(_controllerSeekmessage.text.contains('+')){
      arr=_controllerSeekmessage.text.split('+');
    }else{
      arr=_controllerSeekmessage.text.split("\n");
    }
    var ifxueli=false;
    for(var ii=0;ii<arr.length;ii++){
      var text=arr[ii].trim();
      //检测学历
      if(ifxueli==false){
        for(var jj in xueliarr.keys){
          if(text.contains(xueliarr[jj])){
            setState(() {
              students['education']=jj;
              ifxueli=true;
            });
            break;
          }
        }
        //检测学历2
        for(var jj in xueliarr2.keys){
          if(text.contains(xueliarr2[jj])){
            setState(() {
              students['education']=jj;
              ifxueli=true;
            });
            break;
          }
        }
        //检测学历3
        for(var jj in xueliarr3.keys){
          if(text.contains(xueliarr3[jj])){
            setState(() {
              students['education']=jj;
              ifxueli=true;
            });
            break;
          }
        }
        //检测学历4
        for(var jj in xueliarr4.keys){
          if(text.contains(xueliarr4[jj])){
            setState(() {
              students['education']=jj;
              ifxueli=true;
            });
            break;
          }
        }
      }
      var leixingif=true;//是否需要判断类型
      //检测类型
      for(var jjx in leixingarr.keys){
        var jjxx=jjx.toString();
        if(text.contains('$jjxx,') || text.contains('$jjxx，') || text.contains('$jjxx：')){
          String textx = text.replaceFirst('$jjxx：', '');
          textx = textx.replaceFirst('$jjxx,', '');
          textx = textx.replaceFirst('$jjxx，', '');
          var lxarr=textx.split(" ");
          var jj=int.parse(leixingarr[jjx]);
          leixingif=false;
          setState(() {
            students['status']=245;
            if(students['modulesel'].contains(jj)){
              // if(modulearr[jj].every((v) => v['id'] == 0)){
              //   students['modulesel'].remove(jj);
              //   modulearr.remove(jj);
              // }
              modulearr[jj].add({'id':0,'str_school_major':[lxarr[0]??'',lxarr.length>3?lxarr[3]:'',lxarr.length>1?lxarr[1]:'',lxarr.length>2?lxarr[2]:'']});
            }else{
              if(modulearr[jj]!=null){
                modulearr[jj].add({'id':0,'str_school_major':[lxarr[0]??'',lxarr.length>3?lxarr[3]:'',lxarr.length>1?lxarr[1]:'',lxarr.length>2?lxarr[2]:'']});
              }else{
                modulearr[jj]=[{'id':0,'str_school_major':[lxarr[0]??'',lxarr.length>3?lxarr[3]:'',lxarr.length>1?lxarr[1]:'',lxarr.length>2?lxarr[2]:'']}];
              }
              students['modulesel'].add(jj);
            }
          });
          break;
        }
      }
      //检测类型1
      if(leixingif) {
        for (var jj in leixingarr1.keys) {
          if (text.contains(leixingarr1[jj]+',') || text.contains(leixingarr1[jj]+'，') || text.contains(leixingarr1[jj]+'：')) {

            String textx = text.replaceFirst(leixingarr1[jj] + '：', '');
            textx = textx.replaceFirst(leixingarr1[jj] + ',', '');
            textx = textx.replaceFirst(leixingarr1[jj] + '，', '');
            var lxarr = textx.split(" ");
            leixingif = false;
            setState(() {
              students['status'] = 245;
              if (students['modulesel'].contains(jj)) {
                // if(modulearr[jj].every((v) => v['id'] == 0)){
                //   students['modulesel'].remove(jj);
                //   modulearr.remove(jj);
                // }
                modulearr[jj].add({
                  'id': 0,
                  'str_school_major': [
                    lxarr[0] ?? '',
                    lxarr.length > 3 ? lxarr[3] : '',
                    lxarr.length>1?lxarr[1]:'',
                    lxarr.length > 2 ? lxarr[2] : ''
                  ]
                });
              } else {
                if (modulearr[jj] != null) {
                  modulearr[jj].add({
                    'id': 0,
                    'str_school_major': [
                      lxarr[0] ?? '',
                      lxarr.length > 3 ? lxarr[3] : '',
                      lxarr.length>1?lxarr[1]:'',
                      lxarr.length > 2 ? lxarr[2] : ''
                    ]
                  });
                } else {
                  modulearr[jj] = [
                    {
                      'id': 0,
                      'str_school_major': [
                        lxarr[0] ?? '',
                        lxarr.length > 3 ? lxarr[3] : '',
                        lxarr.length>1?lxarr[1]:'',
                        lxarr.length > 2 ? lxarr[2] : ''
                      ]
                    }
                  ];
                }
                students['modulesel'].add(jj);
              }
            });
            break;
          }
        }
      }
      //检测类型2
      if(leixingif) {
        for (var jj in leixingarr2.keys) {
          if (text.contains(leixingarr2[jj]+',') || text.contains(leixingarr2[jj]+'，') || text.contains(leixingarr2[jj]+'：')) {
            String textx = text.replaceFirst(leixingarr2[jj] + '：', '');
            textx = textx.replaceFirst(leixingarr2[jj] + ',', '');
            textx = textx.replaceFirst(leixingarr2[jj] + '，', '');
            var lxarr = textx.split(" ");
            leixingif = false;
            setState(() {
              students['status'] = 245;
              if (students['modulesel'].contains(jj)) {
                // if(modulearr[jj].every((v) => v['id'] == 0)){
                //   students['modulesel'].remove(jj);
                //   modulearr.remove(jj);
                // }
                modulearr[jj].add({
                  'id': 0,
                  'str_school_major': [
                    lxarr[0] ?? '',
                    lxarr.length > 3 ? lxarr[3] : '',
                    lxarr.length>1?lxarr[1]:'',
                    lxarr.length > 2 ? lxarr[2] : ''
                  ]
                });
              } else {
                if (modulearr[jj] != null) {
                  modulearr[jj].add({
                    'id': 0,
                    'str_school_major': [
                      lxarr[0] ?? '',
                      lxarr.length > 3 ? lxarr[3] : '',
                      lxarr.length>1?lxarr[1]:'',
                      lxarr.length > 2 ? lxarr[2] : ''
                    ]
                  });
                } else {
                  modulearr[jj] = [
                    {
                      'id': 0,
                      'str_school_major': [
                        lxarr[0] ?? '',
                        lxarr.length > 3 ? lxarr[3] : '',
                        lxarr.length>1?lxarr[1]:'',
                        lxarr.length > 2 ? lxarr[2] : ''
                      ]
                    }
                  ];
                }
                students['modulesel'].add(jj);
              }
            });
            break;
          }
        }
      }
      //检测类型3
      if(leixingif) {
        for (var jj in leixingarr3.keys) {
          if (text.contains(leixingarr3[jj]+',') || text.contains(leixingarr3[jj]+'，') || text.contains(leixingarr3[jj]+'：')) {
            String textx = text.replaceFirst(leixingarr3[jj] + '：', '');
            textx = textx.replaceFirst(leixingarr3[jj] + ',', '');
            textx = textx.replaceFirst(leixingarr3[jj] + '，', '');
            var lxarr = textx.split(" ");
            leixingif = false;
            setState(() {
              students['status'] = 245;
              if (students['modulesel'].contains(jj)) {
                // if(modulearr[jj].every((v) => v['id'] == 0)){
                //   students['modulesel'].remove(jj);
                //   modulearr.remove(jj);
                // }
                modulearr[jj].add({
                  'id': 0,
                  'str_school_major': [
                    lxarr[0] ?? '',
                    lxarr.length > 3 ? lxarr[3] : '',
                    lxarr.length>1?lxarr[1]:'',
                    lxarr.length > 2 ? lxarr[2] : ''
                  ]
                });
              } else {
                if (modulearr[jj] != null) {
                  modulearr[jj].add({
                    'id': 0,
                    'str_school_major': [
                      lxarr[0] ?? '',
                      lxarr.length > 3 ? lxarr[3] : '',
                      lxarr.length>1?lxarr[1]:'',
                      lxarr.length > 2 ? lxarr[2] : ''
                    ]
                  });
                } else {
                  modulearr[jj] = [
                    {
                      'id': 0,
                      'str_school_major': [
                        lxarr[0] ?? '',
                        lxarr.length > 3 ? lxarr[3] : '',
                        lxarr.length>1?lxarr[1]:'',
                        lxarr.length > 2 ? lxarr[2] : ''
                      ]
                    }
                  ];
                }
                students['modulesel'].add(jj);
              }
            });
            break;
          }
        }
      }
      //毕业时间
      RegExp reg=RegExp(r'\d{4}年');
      var byyear=reg.stringMatch(text);
      if(byyear!=null){
        String textx = byyear.replaceFirst('年', '');
        _controllerGraduate.text=textx;
      }else{
        for(var ib=0;ib<20;ib++){
          var ibtxt='';
          if(ib==0){
            ibtxt='今年';
          }else{
            ibtxt='$ib年';
          }
          if(text.contains(ibtxt)){
            _controllerGraduate.text= '${year - ib}';
          }
        }
      }
      //微信识别
      if(text.contains('微信:') || text.contains('微信,') || text.contains('微信，')){
        String textx = text.replaceFirst('微信：', '');
        textx = textx.replaceFirst('微信,', '');
        textx = textx.replaceFirst('微信，', '');
        _controllerWeixin.text= textx;
      }
      //备注识别
      if(text.contains('备注')){
        String textx = text.replaceFirst('备注：', '');
        textx = textx.replaceFirst('备注,', '');
        textx = textx.replaceFirst('备注，', '');
        _controllerRemarks.text= textx;
      }
      //城市识别
      if(text.contains('城市') || text.contains('0：') || text.contains('0,') || text.contains('0，')){
        String textx = text.replaceFirst('城市：', '');
        textx = textx.replaceFirst('城市,', '');
        textx = textx.replaceFirst('城市，', '');
        textx = textx.replaceFirst('0：', '');
        textx = textx.replaceFirst('0,', '');
        textx = textx.replaceFirst('0，', '');
        var ararr=textx.split(" ");
        for(var ia=0;ia<areacrm.length;ia++){
          if(ararr.length>1){
            if(areacrm[ia]['namepath'].contains(ararr[0]) && areacrm[ia]['namepath'].contains(ararr[1])){
              _selArea('city',areacrm[ia]);
              break;
            }
          }else{
            if(areacrm[ia]['namepath'].contains(ararr[0])){
              _selArea('city',areacrm[ia]);
              break;
            }
          }
        }
      }
    }
  }
  void _onchange(feild,value){
    setState(() {
      students[feild]=value;
    });
  }
  void _onchangeLeixing(feild,value){
    setState(() {
      if(students[feild].contains(value)){
        if(modulearr[value].every((v) => v['id'] == 0)){
          students[feild].remove(value);
          modulearr.remove(value);
        }
      }else{
        modulearr[value]=[{'id':0,'str_school_major':['','','','']}];
        students[feild].add(value);
      }
    });
  }
  void _selArea(feild,value){
    setState(() {
      students['province']=value['parent_id'];
      students[feild]=value['id'];
      students[feild+'text']=value['namepath'];
      _controllerAddress.text=value['namepath'];
    });
  }
  ///单选按钮
  List<Widget> buttonWight(dat,onchange,maxnum,feild,value){
    if(maxnum>dat.length) maxnum=dat.length;
    List<Widget> arr=[];
    for(var ii=0;ii<maxnum;ii++){
      arr.add(
        TextButton(
          onPressed: ()=>{onchange(feild,dat[ii]['id'])},
          style: ButtonStyle(
            backgroundColor: ButtonStyleButton.allOrNull<Color>(
                value==dat[ii]['id']?Colors.cyan:BaseColors.gray5
            ),
            shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
            ),
            maximumSize: MaterialStateProperty.all(Size((MediaQuery.of(context).size.width-40)/4, 35)),
            minimumSize: MaterialStateProperty.all(Size((MediaQuery.of(context).size.width-40)/4, 35))
          ),
          child: Text('${dat[ii]['name']}',overflow: TextOverflow.ellipsis,maxLines: 1,style:  TextStyle(fontSize: 14,color: value==dat[ii]['id']?Colors.white:BaseColors.gray8,fontWeight: FontWeight.w400),),
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
  ///类型选择
  List<Widget> leixingWight(dat,onchange,maxnum,feild,value){
    if(maxnum>dat.length) maxnum=dat.length;
    List<Widget> arr=[];
    for(var ii=0;ii<maxnum;ii++){
      arr.add(
          TextButton(
            onPressed: ()=>{onchange(feild,dat[ii]['id'])},
            style: ButtonStyle(
                backgroundColor: ButtonStyleButton.allOrNull<Color>(
                    value.contains(dat[ii]['id'])?Colors.cyan:BaseColors.gray5
                ),
                shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                ),
                maximumSize: MaterialStateProperty.all(Size((MediaQuery.of(context).size.width-40)/4, 35)),
                minimumSize: MaterialStateProperty.all(Size((MediaQuery.of(context).size.width-40)/4, 35))
            ),
            child: Text('${ii+1}${dat[ii]['name']}',overflow: TextOverflow.ellipsis,maxLines: 1,style:  TextStyle(fontSize: 14,color: value.contains(dat[ii]['id'])?Colors.white:BaseColors.gray8,fontWeight: FontWeight.w400),),
          )
      );
    }
    if(dat.length > maxnum+1) {
      List<PopupMenuItem> arrmenu=[];
      String selmore='';
      for(var ii=maxnum;ii<dat.length;ii++){
        arrmenu.add(
            PopupMenuItem(value: dat[ii]['id'],textStyle:TextStyle(color: value.contains(dat[ii]['id'])?Colors.cyan:BaseColors.gray11), child: Text('${dat[ii]['name']}'))
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
  //选择文件上传
  void openGallerySystem() async {
    var baseStore = Provider.of<BaseStore>(
      context,
      listen: false,
    );
    //List resultList = [];
    if(await controller.pickImages()){
      if (!mounted) return;
      controller.images.forEach((element) {
        FormData formdata = FormData.fromMap({
          'loginKey':baseStore.loginKey,
          'keyid':baseStore.userData.keyid,
          "upload":  MultipartFile.fromFileSync(element.path.toString())
        });
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
          duration: const Duration(seconds: 30),
          onDismiss: () {
            // The method will be called on toast dismiss.
            //debugPrint('Toast has been dismissed.');
          },
        );
        HttpUtils.post(path:'/api/home/common/upload',data:formdata).then((value) async {
          toastFuture.dismiss();
          if(value['code']==200){
            //String imgUrl=value['data']['thumbUrl'];
            setState(() {
              students['filess'].add(value['data']);
            });
          }else{
            showToast(value['message']);
          }
        }).catchError((error) {
          print('报错信息：$error');
        });
      });
    }
    // controller.addListener(() {
    //   print(controller.images);
    //   ///controller.clearImages();
    // });
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key,required this.areacrm,required this.selArea,required this.field,required this.student});
  final void Function(String,Map) selArea;
  final Map student;
  final List areacrm;
  final String field;
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>{

  final TextEditingController _controllerJigou = TextEditingController();///机构
  late List datas=[];
  int pageNum=1;
  bool isLoading=false;
  @override
  void initState(){
    datas=widget.areacrm;
    // _controllerJigou.addListener(() {
    //   setState(() {
    //     datas=widget.areacrm.where((elem)=>elem['namepath'].contains(_controllerJigou.text)==true).toList();
    //   });
    // });
    _controllerJigou.text=widget.student['${widget.field}text']??'';
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child:SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 10,left: 10,right: 10,bottom: 5),
                height: 70,
                decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                    ),
                    color: Colors.white
                ),
                child: TextField(
                  controller: _controllerJigou,
                  cursorColor: BaseColors.orange500,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 14
                  ),
                  decoration: InputDecoration(
                      labelText: '名称搜索',
                      labelStyle: const TextStyle(
                          color: BaseColors.gray8,
                          fontSize: 14
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        //borderSide: const BorderSide(color: Colors.red, width: 3.0, style: BorderStyle.solid)
                      ),
                      enabledBorder:OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.green, width: 1.0, style: BorderStyle.solid)
                      ),
                      focusedBorder:OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: BaseColors.orange500, width: 1.0, style: BorderStyle.solid)
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(top: 15,left: 20),
                        child: _controllerJigou.text.isNotEmpty?GestureDetector(
                          child: const Text('x',style: TextStyle(color: Colors.redAccent,fontSize: 14),),
                          onTap: (){
                            _controllerJigou.clear();
                          },
                        ):null,
                      )
                  ),
                  onChanged: (val){
                    setState(() {
                      datas=widget.areacrm.where((elem)=>elem['namepath'].contains(_controllerJigou.text)==true).toList();
                    });
                  },
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,//解决无限高度问题
                  physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                  itemCount: datas.length>100?100:datas.length, //告诉ListView总共有多少个cell
                  itemBuilder: (context, index) =>Container(
                      color: Colors.white,
                      //margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.only(bottom: 2,right: 5,left: 15),
                      child: InkWell(
                        onTap: () {
                          widget.selArea(widget.field,datas[index]);
                          Navigator.of(context).pop();
                        },
                        child:Container(
                          height: 46,
                          padding: const EdgeInsets.only(left: 5,right: 5),
                          alignment: Alignment.centerLeft,
                          decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                              )
                          ),
                          child:Text(datas[index]['namepath'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                            maxLines: 1,overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ) //每人一辆跑车
                  ) //使用_cellForRow回调返回每个cell
              ),
            ],
          ),
        )

    );
  }
}
