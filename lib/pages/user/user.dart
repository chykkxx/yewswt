
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yewswt/pages/user/setting.dart';
import '../../data/colors.dart';
import '../../data/store_data.dart';
import '../../http/request.dart';
import '../../model/base_model.dart';
import '../../model/base_store.dart';
import '../PictureWebUrl.dart';
import '../picker.dart';
import 'infor.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>  {

  final controller = MultiImagePickerController(
    maxImages: 1,
    images: <ImageFile>[], // array of pre/default selected images
    picker: (bool allowMultiple) async {
      //return await pickConvertedImages(allowMultiple);
      return await pickImagesUsingImagePicker(allowMultiple);
    },
  );
  bool ifup=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        toolbarHeight: null,
      ),
      // backgroundColor: Colors.white,
      body: Consumer<BaseStore>(
          builder: (context, model, child) {
            return Container(
              decoration:  null ,
              padding: const EdgeInsets.only(top:20,left: 10,right: 10) ,
              child: Column(
                children: [
                  Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            child: Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              //超出部分，可裁剪
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.blue
                              ),
                              child: model.userData.avatar.isNotEmpty ?Image.network(
                                model.userData.avatar,
                                fit: BoxFit.cover,
                              ):Text(model.userData.name.substring(0,2)),
                            ),
                            onTap: (){
                              openGallerySystem();
                            },
                          ),
                          const SizedBox(width: 10,),
                          Container(
                            height: 80,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 12),
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Text(model.userData.name,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w800),),
                                Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: Text(model.userData.nickname??'',style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                ),
                                Container(child: Text(model.userData.name??'',style: const TextStyle(fontSize: 14,color: Color(0xff999999)),)),
                                //Text(model.userData.tel??'',style: const TextStyle(fontSize: 14,color: Color(0xff999999)),),
                                //Text(model.userData.nickname??'',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                //Text(model.userData.name),
                              ],
                            ),
                          )
                        ],
                      )
                  ),
                  InkWell(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    child:Container(
                      padding: const EdgeInsets.only(top:22,bottom: 22,left: 20,right: 10),
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(IconData(0xe60b,fontFamily: "myIcon",matchTextDirection: true),color: BaseColors.orange500,size: 20,),
                              SizedBox(width: 15,),
                              Text('个人信息',style: TextStyle(color: Color(0xFF666666),fontSize: 16),),
                            ],
                          ),
                          Icon(IconData(0xe60b,fontFamily: "myIcons",matchTextDirection: true),color: BaseColors.gray6,)
                        ],
                      ),
                    ),
                    onTap: (){
                      showUserInfo();
                    },
                  ),
                  InkWell(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    child:Container(
                      padding: const EdgeInsets.only(top:22,bottom: 22,left: 20,right: 10),
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(IconData(0xe60f,fontFamily: "myIcon",matchTextDirection: true),color: BaseColors.orange500,size: 20,),
                              SizedBox(width: 15,),
                              Text('修改密码',style: TextStyle(color: Color(0xFF666666),fontSize: 16),),
                            ],
                          ),
                          Icon(IconData(0xe60b,fontFamily: "myIcons",matchTextDirection: true),color: BaseColors.gray6)
                        ],
                      ),
                    ),
                    onTap: (){
                      showUserSetting();
                    },
                  ),
                  InkWell(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    child:Container(
                      padding: const EdgeInsets.only(top:22,bottom: 22,left: 20,right: 10),
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.safety_check_outlined,color: BaseColors.orange500,size: 20,),
                              SizedBox(width: 15,),
                              Text('隐私政策',style: TextStyle(color: Color(0xFF666666),fontSize: 16),),
                            ],
                          ),
                          Icon(IconData(0xe60b,fontFamily: "myIcons",matchTextDirection: true),color: BaseColors.gray6)
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context){
                                return  const PictureWebUrl(title:'隐私政策', weburl: 'https://www.ludeng.com.cn/ldysbh.html',);
                              }
                          )
                      );
                    },
                  ),
                  InkWell(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    child:Container(
                      padding: const EdgeInsets.only(top:22,bottom: 22,left: 20,right: 10),
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified_user_outlined,color: BaseColors.orange500,size: 20,),
                              SizedBox(width: 15,),
                              Text('用户协议',style: TextStyle(color: Color(0xFF666666),fontSize: 16),),
                            ],
                          ),
                          Icon(IconData(0xe60b,fontFamily: "myIcons",matchTextDirection: true),color: BaseColors.gray6)
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context){
                                return  const PictureWebUrl(title:'用户协议', weburl: 'https://www.ludeng.com.cn/ldfwxy.html',);
                              }
                          )
                      );
                    },
                  ),
                  InkWell(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    child:Container(
                      padding: const EdgeInsets.only(top:22,bottom: 22,left: 20,right: 10),
                      margin: const EdgeInsets.only(bottom: 30),
                      color: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(IconData(0xe60a,fontFamily: "myIcon",matchTextDirection: true),color: BaseColors.orange500,size: 20,),
                              SizedBox(width: 15,),
                              Text('检查版本',style: TextStyle(color: Color(0xFF666666),fontSize: 16),),
                            ],
                          ),
                          Icon(IconData(0xe60b,fontFamily: "myIcons",matchTextDirection: true),color: BaseColors.gray6)
                        ],
                      ),
                    ),
                    onTap: (){
                      doCheck();
                    },
                  ),
                  //const SizedBox(height: 60,),
                  Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: null,
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () {
                          var baseStore = Provider.of<BaseStore>(
                            context,
                            listen: false,
                          );
                          baseStore.ifLogin=false;
                          StoreData.saveUser('');
                          Navigator.of(context).restorablePushNamed('login');
                          //widget.loginOut();
                          FlutterBackgroundService().invoke("stopService");
                        },
                        child: GestureDetector(
                          child: const Text('退出登录',style: TextStyle(color: Color(0xFF999999)),),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            );
          }
      ),
    );
  }
  ///打开个人信息
  void showUserInfo(){
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context){
              return const UserInfoPage();
            }
        )
    );
  }
  ///打开个人设置
  void showUserSetting(){
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context){
              return const UserSettingPage();
            }
        )
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
  //选择文件上传
  void openGallerySystem() async {
    if(ifup) {
      showToast('不可频繁更换头像,切换模块可重新上传！',duration: const Duration(seconds: 3));
      return;
    }
    var baseStore = Provider.of<BaseStore>(
      context,
      listen: false,
    );
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );
    if (result != null) {
      FormData formdata = FormData.fromMap({
        'loginKey': baseStore.loginKey,
        'keyid': baseStore.userData.keyid,
        "upload": await MultipartFile.fromFile(result.path)
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
        if(value['code']==200){
          String imgUrl=value['data']['thumbUrl'];
          HttpUtils.post(path:'/api/home/index/inforup',data:{'imageurl':imgUrl}).then((value) {
            toastFuture.dismiss();
            if(value['code']==200){
              StoreData.saveUser(value['data']);
              UserItem userItem=UserItem(id:value['data']['id'],name:value['data']['name'],nickname:value['data']['nickname'],tel:value['data']['tel'],keyid:value['data']['keyid'],avatar:imgUrl,created_at:value['data']['created_at'],zhiwu: value['data']['zhiwu']??'');
              baseStore.userData=userItem;
              setState(() {
                ifup=true;
              });
            }else{
              showToast(value['message']);
            }
          });
        }else{
          showToast(value['message']);
        }
      }).catchError((error) {
        print('报错信息：$error');
      });
    }
  }

  /// 检查更新
  String progress = "";
  late ProgressDialog pr;

  Future<void> doCheck() async {
    final packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String deviceType = "";
    if (Platform.isAndroid) {
      deviceType = "Android";
    } else {
      deviceType = "ios";
    }
    var params = <String, dynamic>{
      'packageName': packageName,
      'system': deviceType,
      'version':version,
      'leixing':'guanli'
    };
    try {
      await HttpUtils.post(path:'/api/login/version',data:params).then((value) async {
        if(value['code']==200){
          switch (value['code']) {
            case 200:
              if (value['data']['ifup']==2) {
                if (Platform.isAndroid) {
                  // ignore: use_build_context_synchronously
                  showUpdate(
                      context,
                      deviceType,
                      value['data']['versionCode'].toString(),
                      value['data']['fileUrl'],
                      value['data']['description'],
                      value['data']['ifmust']??1
                  );
                } else {
                  //const url = "https://itunes.apple.com/cn/app/id6451302186"; // id 后面的数字换成自己的应用 id 就行了
                  var url =value['data']['fileUrl'];
                  if (await canLaunch(url)) {
                    await launch(url, forceSafariVC: false);
                  } else {
                    throw 'Could not launch $url';
                  }
                }
              }else{
                showToast('已是最新版本！');
              }
              break;
            default:
              showToast(value['message']);
              break;
          }

        }
      });

    } catch (e) {
      // MyToastUtils.showToastBottom("网络异常");
    }
  }

  /// 显示更新内容
  Future<void> showUpdate(
      BuildContext context, String deviceType, String version, String url, String info, int ifmust) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //设置为false，点击空白处弹窗不关
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('检测到新版本 v$version'),
          content: Container(
            margin: const EdgeInsets.only(top: 5),
            child: Text(
              info,
              style:  const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          actions: <Widget>[
            if(ifmust!=2)TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('下次再说',style: TextStyle(color: BaseColors.orange500),),
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                doUpdate(context, version, url);
              },
              child: const Text('立即更新',style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  ///3.执行更新操作
  doUpdate(BuildContext context, String version, String url) async {
    //关闭更新内容提示框
    Navigator.pop(context);
    // downloadAndroid(url);
    _updateVersion(url);
  }

  /// android app更新
  void _updateVersion(String url) async {
    pr = ProgressDialog(
      context,
      showLogs: true,
      type: ProgressDialogType.download, //下载类型带下载进度
      isDismissible: false, //点击外层不消失
    );
    if (!pr.isShowing()) {
      pr.show();
    }
    try {
      // destinationFilename 是对下载的apk进行重命名
      OtaUpdate().execute(url, destinationFilename: 'ld_jiaoyutong.apk').listen(
            (OtaEvent event) {
          //print('status:${event.status},value:${event.value}');
          switch (event.status) {
            case OtaStatus.DOWNLOADING: // 下载中
              setState(() {
                progress = event.value!;
                double d = double.parse(progress);
                pr.update(
                  progress: d,
                  message: "下载中，请稍后…",
                );
              });
              break;
            case OtaStatus.INSTALLING: //安装中
              if (pr.isShowing()) {
                pr.hide();
              }
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR: // 权限错误
              print('更新失败，请稍后再试');
              if (pr.isShowing()) {
                pr.hide();
              }
              break;
            default: // 其他问题
              break;
          }
        },
      );
    } catch (e) {
      print('更新失败，请稍后再试');
    }
  }
}
