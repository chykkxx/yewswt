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
import 'package:yewswt/model/base_store.dart';

import '../picker.dart';

class MobileXueShengNotelPage extends StatefulWidget {
  const MobileXueShengNotelPage({super.key,required this.id});
  final int id;
  @override
  State<MobileXueShengNotelPage> createState() => _XueShengNotelPageState();
}

class _XueShengNotelPageState extends State<MobileXueShengNotelPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  late Map students={
    'modulesel':[],'filess':[]
  };
  late  List<DropdownMenuItem<String>> fenlei;
  late  List<DropdownMenuItem<String>> manage;
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
    _loadStudent(widget.id);
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
    if(students['seekcom']==null || students['seekcom']==0 || students['seekcom']==''){
      showToast(
        '请选择来源平台',duration: const Duration(seconds: 3),
      );
      return;
    }
    if(students['seekfrom']==null || students['seekfrom']==0 || students['seekfrom']=='' ){
      showToast('请选择来源渠道',duration: const Duration(seconds: 3),);
      return;
    }
    if(students['laiyuanlx']==null || students['laiyuanlx']==0 || students['laiyuanlx']==''){
      showToast('请选择咨询方式',duration: const Duration(seconds: 3),);
      return;
    }
    Map upData={
      'id':widget.id,
      'seekcom':students['seekcom'],
      'seekfrom':students['seekfrom'],
      'laiyuanlx':students['laiyuanlx'],
      'seektime':_controllerStartDay.text,
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
      'remarks':_controllerRemarks.text,
      'filess':jsonEncode(students['filess'])
    };
    if((upData['tel']==null || upData['tel']=='') && (upData['weixin']==null || upData['weixin']=='') && (upData['filess']==null || upData['filess']=='')){
      showToast('请输入电话/微信/附件',duration: const Duration(seconds: 3),);
      return;
    }
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
      duration: const Duration(seconds: 30),
      onDismiss: () {
        // The method will be called on toast dismiss.
        //debugPrint('Toast has been dismissed.');
      },
    );
    await HttpUtils.post(path:'/api/Xuesheng/createnotel',data:upData).then((value) {
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
          title: const Text('无电话学生'),
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
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text('来源平台：',
                                style: TextStyle(color: BaseColors.gray8),
                              ),
                              SizedBox(
                                width: (MediaQuery.of(context).size.width-120),
                                height: 40.0,
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.only(left: 10, right: 0),
                                  ),
                                  // 设置默认值
                                  value: students['seekcom'],
                                  // 选择回调
                                  onChanged: (int? newPosition) {
                                    setState(() {
                                      students['seekcom']=newPosition;
                                    });
                                  },
                                  // 传入可选的数组
                                  items: selectWight(lypt),
                                ),
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
                              const Text('来源渠道：',
                                style: TextStyle(color: BaseColors.gray8),
                              ),
                              SizedBox(
                                width: (MediaQuery.of(context).size.width-120),
                                height: 40.0,
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.only(left: 10, right: 0),
                                  ),
                                  // 设置默认值
                                  value: students['seekfrom'],
                                  // 选择回调
                                  onChanged: (int? newPosition) {
                                    setState(() {
                                      students['seekfrom']=newPosition;
                                      if((newPosition! >= 285 && newPosition < 295) || newPosition==319 || (newPosition >= 379 && newPosition <= 384)){
                                        students['laiyuanlx']=301;
                                      }
                                    });
                                  },
                                  // 传入可选的数组
                                  items: selectWight(ptlx),
                                ),
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
                              const Text('咨询方式：',
                                style: TextStyle(color: BaseColors.gray8),
                              ),
                              SizedBox(
                                width: (MediaQuery.of(context).size.width-120),
                                height: 40.0,
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.only(left: 10, right: 0),
                                  ),
                                  // 设置默认值
                                  value: students['laiyuanlx'],
                                  // 选择回调
                                  onChanged: (int? newPosition) {
                                    setState(() {
                                      students['laiyuanlx']=newPosition;
                                      if(newPosition==299 || newPosition==302 || newPosition==303){
                                        students['seekfrom']=295;
                                      }
                                    });
                                  },
                                  // 传入可选的数组
                                  items: selectWight(zxfs),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(

                          child: Row(
                            children: [
                              const Text(
                                '咨询时间：',
                                style: TextStyle(color: BaseColors.gray8),
                              ),
                              Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: (MediaQuery.of(context).size.width-120),
                                    height: 40,
                                    child: TextField(
                                      controller: _controllerStartDay,
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
                                            child: _controllerStartDay.text.isNotEmpty?GestureDetector(
                                              child:  const SizedBox(width: 0,),
                                              onTap: (){
                                                _controllerStartDay.text='';
                                              },
                                            ):null,
                                          )
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
                                          }
                                          var his=_selectTime(context,_controllerStartDay.text);
                                          his.then((value) {
                                            _controllerStartDay.text='$day $value';
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
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(

                          child: Row(
                            children: [
                              const Text(
                                '姓　　名：',
                                style: TextStyle(color: BaseColors.gray8),
                              ),
                              Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                                    width: (MediaQuery.of(context).size.width-120),
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
                        SizedBox(
                          child: Row(
                            children: [
                              const Text(
                                '性　　别：',
                                style: TextStyle(color: BaseColors.gray8),
                              ),
                              Container(
                                width: (MediaQuery.of(context).size.width-120),
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
                        SizedBox(
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
                                    width: (MediaQuery.of(context).size.width-120),
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
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              const Text(
                                '微　　信：',
                                style: TextStyle(color: BaseColors.gray8),
                              ),
                              Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                                    width: (MediaQuery.of(context).size.width-120),
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
                        SizedBox(

                          child: Row(
                            children: [
                              const Text(
                                '毕业时间：',
                                style: TextStyle(color: BaseColors.gray8),
                              ),
                              Expanded(
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width-120),
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
                        // SizedBox(
                        //   child: Row(
                        //     children: [
                        //       const Text(
                        //         '所在城市：',
                        //         style: TextStyle(color: BaseColors.gray8),
                        //       ),
                        //       Expanded(
                        //           child: Container(
                        //             width: (MediaQuery.of(context).size.width-120),
                        //             padding: const EdgeInsets.only(top: 4,bottom: 4,right: 10),
                        //             alignment: Alignment.center,
                        //             height: 40,
                        //             child: TextField(
                        //               controller: _controllerAddress,
                        //               cursorColor: BaseColors.orange500,
                        //               decoration:  InputDecoration(
                        //                   enabledBorder: const OutlineInputBorder(
                        //                       borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                        //                   ),
                        //                   focusedBorder: const OutlineInputBorder(
                        //                       borderSide: BorderSide(color: BaseColors.orange500,width: 0.25)
                        //                   ),
                        //                   contentPadding: EdgeInsets.only(left: 10),
                        //                   suffixIcon: Padding(
                        //                     padding:  const EdgeInsets.only(left: 10),
                        //                     child: Builder(
                        //                       builder: (cxt){
                        //                         return IconButton(onPressed: (){Scaffold.of(cxt).openEndDrawer();}, icon: const Icon(Icons.area_chart,size: 20,color: Colors.blue,));
                        //                       },
                        //                     ),
                        //                   )
                        //               ),
                        //               readOnly:true,
                        //             ),
                        //           )
                        //       )
                        //     ],
                        //   ),
                        // ),
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
                        const Text('学　　历：',
                          style: TextStyle(color: BaseColors.gray8),
                        ),
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
                  ),
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
                  Container(
                    child: Column(
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
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text('其他信息：',
                          style: TextStyle(color: BaseColors.gray8),
                        ),
                        Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 10,bottom: 10),
                              child: TextField(
                                controller: _controllerSeekmessage,
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
    await HttpUtils.post(path:'/api/Xuesheng/show',data:{'id':id,'notel':2}).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        if(value['data']['files']!=null && value['data']['files']!='') {
          value['data']['filess'] = jsonDecode(value['data']['files']);
        }else{
          value['data']['filess'] =[];
        }
        if(id>0){
          _controllerName.text=value['data']['s_name'];
          if(value['data']['tel']!=null) _controllerTel.text=value['data']['tel'].replaceAll('|', '\n');
          _controllerWeixin.text = value['data']['weixin']??'';///微信
          _controllerSeekmessage.text = value['data']['seekmessage']??'';///其他信息
          _controllerGraduate.text = value['data']['graduate']??'';///毕业时间
          _controllerRemarks.text = value['data']['remarks']??'';///备注
          _controllerAddress.text = value['data']['citytext']??'';///所在城市

        }
        setState(() {
          if(id>0){
            if(_controllerTel.text.isNotEmpty)telMore=_controllerTel.text.contains("\n");
            _controllerStartDay.text=value['data']['seektime'];
          }

          areacrm = value['areacrm'];
          areaarr = value['areacrm'];
          //fenlei=fenleilist.toList();
          //manage=managelist.toList();
          lypt=value['lypt'];//来源平台 57
          ptlx=value['ptlx'].where((item) => (item['id']>=285 && item['id']<=295) || item['id']==319 || (item['id']>=379 && item['id']<=384)).toList();//平台类型 276
          zxfs=value['zxfs'].where((item) => item['id'] == 299 || item['id']==301 || item['id']==302 || item['id']==303).toList();//咨询方式 296
          fslx=value['fslx'];//方式类型 308
          xueli=value['xueli'];//当前学历 27
          zhuangtai=value['zhuangtai'];//学生状态 243
          leixing=value['leixing'];//dc_leixing
          call_status=value['call_status'];//回访状态 220
          students = value['data'];
          isLoading=true;
        });
      }else{
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
  void _onchange(feild,value){
    setState(() {
      students[feild]=value;
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
            maximumSize: MaterialStateProperty.all(const Size(120, 35)),
            minimumSize: MaterialStateProperty.all(const Size(120, 35))
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
  List<DropdownMenuItem<int>> selectWight(dat){
    List<DropdownMenuItem<int>> arr=[];
    for(var ii=0;ii<dat.length;ii++){
      arr.add(DropdownMenuItem(value: dat[ii]['id'], child: Text(dat[ii]['name'])));
    }
    return arr;
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
