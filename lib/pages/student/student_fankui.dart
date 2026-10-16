import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/colors.dart';
import '../picker.dart';
import '../../http/request.dart';
import '../../model/base_store.dart';

class StudentFankuiPage extends StatefulWidget {
  const StudentFankuiPage({super.key,required this.student});
  final Map<dynamic, dynamic>? student;
  @override
  State<StudentFankuiPage> createState() => _StudentFankuiPageState();
}

class _StudentFankuiPageState extends State<StudentFankuiPage> with SingleTickerProviderStateMixin {
  UniqueKey _inboxKey = UniqueKey();
  late  List fkzt=[];//反馈状态 57
  late int fenlei_id=260;
  late String imgUrl='';
  // final controller = MultiImagePickerController(
  //     maxImages: 1,
  //     // allowedImageTypes: ['png', 'jpg', 'jpeg'],
  //     // withData: true,
  //     // withReadStream: true,
  //     images: <ImageFile>[] // array of pre/default selected images
  // );
  final controller = MultiImagePickerController(
    maxImages: 15,
    images: <ImageFile>[], // array of pre/default selected images
    picker: (bool allowMultiple) async {
      //return await pickConvertedImages(allowMultiple);
      return await pickImagesUsingImagePicker(allowMultiple);
    },
  );

  late  List logsda=[];//反馈记录

  bool isLoading =false;
  int page=1;
  int total=0;
  final TextEditingController _controllerRemarks = TextEditingController();///备注
  @override
  void initState() {
    super.initState();
    _loadLogs();

  }
  Future<void> _saveStudent() async {
      if(fenlei_id==262 && imgUrl.isEmpty){
        showToast('请上传依据！',duration: const Duration(seconds: 3));
        return;
      }
      if(_controllerRemarks.text.isEmpty){
        showToast('请输入反馈内容！',duration: const Duration(seconds: 3));
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
      Map upData={
        'id':widget.student?['id'],
        'jggroup_id':widget.student?['jggroup_id'],
        'student_id':widget.student?['student_id'],
        'fenlei_id':fenlei_id,
        'image':imgUrl,
        'remarks':_controllerRemarks.text,
      };
      await HttpUtils.post(path:'/api/Student/createfankui',data:upData).then((value) {
        toastFuture.dismiss();
        if(value['code']==200){
          Navigator.of(context).pop();
          setState(() {
            imgUrl='';
          });
          _controllerRemarks.text='';
          _loadLogs();
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
        ),
      ),

      body: isLoading?SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1, color: Color(0xFFDFDFE0)),
            ),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  // border: Border.all(
                  //   color: Colors.grey.withOpacity(0.2), //边框颜色
                  //   width: 1, //边框宽度
                  // ), // 边色与边宽度
                  // color: Colors.white, // 底色
                  // boxShadow: [
                  //   BoxShadow(
                  //     blurRadius: 10, //阴影范围
                  //     spreadRadius: 0.1, //阴影浓度
                  //     color: Colors.grey.withOpacity(0.2), //阴影颜色
                  //   ),
                  // ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
                //color: Colors.white,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 10,left: 5),
                      // decoration: const BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                      //     )
                      // ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width:50,
                            margin: EdgeInsets.only(top: 8),
                            child: Text(
                              '状态：',
                              // '状　　态：',
                              style: TextStyle(
                                  color: BaseColors.gray6,
                                  fontSize:14
                              ),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              //布局方向，默认是（Axis.horizontal）横向
                                direction: Axis.horizontal,
                                //横向间距
                                spacing: 5,
                                //竖向间距
                                runSpacing: -8,
                                //横向对齐方式
                                alignment: WrapAlignment.start,
                                children: buttonWight(fkzt,_onchange,fkzt.length,'education',fenlei_id)
                              ),
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(bottom: 15,left: 5),
                      // decoration: const BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                      //     )
                      // ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: const SizedBox(
                              width:50,
                              child: Text(
                                '依据：',
                                style: TextStyle(
                                    color: BaseColors.gray6,
                                    fontSize:14
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            child: Container(
                              width: 120,
                              height: 120,
                              alignment: Alignment.center,
                              //超出部分，可裁剪
                              //clipBehavior: Clip.hardEdge,
                              decoration:  BoxDecoration(
                                //borderRadius: BorderRadius.circular(50),
                                  color: Color(0xFFF8F8F8),
                              ),
                              child: imgUrl.isNotEmpty ?Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                              ):const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Icon(Icons.add,color: Color(0xFFD8D8D8),size: 32,),
                                  ),
                                  Text('点击上传',style: TextStyle(color: Color(0xFF666666)),),
                                ],
                              ),
                            ),
                            onTap: (){
                              openGallerySystem();
                            },
                          ),
                          ///const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(left: 5),
                      // decoration: const BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(width: 0.25,color: BaseColors.gray5),
                      //     )
                      // ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: const SizedBox(
                              width:50,
                              child: Text(
                                '内容：',
                                style: TextStyle(
                                    color: BaseColors.gray6,
                                    fontSize:14
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                // padding: const EdgeInsets.only(top: 10,bottom: 10),
                                //height: 60,
                                child: TextField(
                                  controller: _controllerRemarks,
                                  cursorWidth: 1,
                                  maxLines: 5,
                                  minLines: 1,
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: BaseColors.gray6,width: 0.25)
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: BaseColors.blue3,width: 0.25)
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  ),
                                ),
                              )
                          ),
                          //const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Container(
                      //color: Colors.white,
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(10),
                      child: logsda.length>0?ListView.builder(
                        shrinkWrap: true,//解决无限高度问题
                        physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                        itemCount: logsda.length,
                        itemBuilder: (context, index) =>Container(
                          padding: const EdgeInsets.only(top: 10,bottom: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:BorderSide(color: BaseColors.gray5,width: 0.5)
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                margin: EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                //超出部分，可裁剪
                                //clipBehavior: Clip.hardEdge,
                                decoration:  BoxDecoration(
                                  //borderRadius: BorderRadius.circular(50),
                                    color: Colors.blue.shade50
                                ),
                                child: logsda[index]['image'].isNotEmpty ?Image.network(
                                  logsda[index]['image'],
                                  fit: BoxFit.cover,
                                ):const Text('无'),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(logsda[index]['fenlei']['name'],style: TextStyle(color: BaseColors.orange500),),
                                    SizedBox(height: 5,),
                                    Text(logsda[index]['remarks'],textAlign: TextAlign.right,),
                                    SizedBox(height: 5,),
                                    Text(logsda[index]['created_at'],style: TextStyle(color: Color(0xff999999)),),
                                  ],
                                ),
                              ),
                            ],
                          )
              
                        )
                      ):Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: const Text('暂无反馈',style: TextStyle(color: Color(0xFF999999)),),
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ):Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1, color: Color(0xFFDFDFE0)),
          ),
        ),
        child: Center(
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
                onPressed: (){
                  _saveStudent();
                },
                child: const Text('保存')
              ),
            ]
        ),
      ),

    );
  }
  void _onchange(feild,value){
    setState(() {
      fenlei_id=value;
    });
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
          duration: const Duration(seconds: 3),
          onDismiss: () {
            // The method will be called on toast dismiss.
            //debugPrint('Toast has been dismissed.');
          },
        );
        HttpUtils.post(path:'/api/home/common/upload',data:formdata).then((value) async {
          toastFuture.dismiss();
          if(value['code']==200){
            setState(() {
              imgUrl=value['data']['thumbUrl'];
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
  List<DropdownMenuItem<int>> selectWight(dat){
    List<DropdownMenuItem<int>> arr=[];
    for(var ii=0;ii<dat.length;ii++){
      arr.add(DropdownMenuItem(value: dat[ii]['id'], child: Text(dat[ii]['name'])));
    }
    return arr;
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
                  value==dat[ii]['id']?BaseColors.blue7:Colors.white
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3), // 设置圆角半径
                  ),
                ),
                side: MaterialStateProperty.resolveWith((states) {
                  if (value==dat[ii]['id']) {
                    return BorderSide.none;
                  } else {
                    return BorderSide(
                      color: Color(0xFFDFDFE0),
                      width: 1.0,
                    );
                  }
                }),
                minimumSize: MaterialStateProperty.all(const Size(75, 34))
            ),
            child: Text('${dat[ii]['name']}',style:  TextStyle(fontSize: 14,color: value==dat[ii]['id']?BaseColors.white50:Color(0xFF666666),fontWeight: FontWeight.w400),),
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
  Future<void> _loadLogs() async {
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
    await HttpUtils.post(path:'/api/Student/getfankui',data:{'jggroup_id':widget.student?['jggroup_id'],'student_id':widget.student?['student_id']}).then((value) {
      toastFuture.dismiss();
      if(value['code']==200){
        setState(() {
          logsda = value['data'];
          fkzt=value['fenlei'];
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