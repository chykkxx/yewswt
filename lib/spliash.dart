
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yewswt/data/colors.dart';
import 'package:yewswt/pages/PictureWebUrl.dart';
import 'package:yewswt/pages/PictureWebUrl.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}
class SplashScreenState extends State<SplashScreen> {
  bool ifLogin=false;
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      showUpdate(context);
    });
  }
  final String _data = "感谢您信任并使用路灯教育通App。我们非常重视用户权利及隐私政策并严格按照相关法律法规的要求，对";
  final String _data2 = "进行了更新。\n \n为了更好的保障你的个人权益，在你使用我们的产品前，请您认真阅读";
  final String _data3 = "的所有条款。\n1.为向您提供更优质的服务，你可以通过《隐私政策》了解我们如何收集、使用、存储您的个人信息，以及你拥有哪些权益等事宜；\n2.您在使用教育通App时，我们会向您申请相关权限，你未同意我们将不使用该权限；\n3.未经您同意，我们不会从第三方获取、共享或向其提供您的信息；\n4.您可以查询、更正、删除您的个人信息，我们也提供账户注销的渠道。\n \n如你同意以上协议内容，请点击“同意”，开始使用我们的产品和服务；如果你不同意将退出教育通App应用。";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image.asset('static/images/login_logo1.png'),
    );
  }

  /// 显示更新内容
  Future<void> showUpdate(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ifTongYi=prefs.getBool('key_ifTongYi')??false;
    if(ifTongYi){
      Navigator.of(context).pushReplacementNamed('login');
    }else{
      return showDialog<void>(
        context: context,
        ///barrierColor: Colors.white,
        barrierDismissible: false, //设置为false，点击空白处弹窗不关
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('温馨提示'),
            content: Container(
                margin: const EdgeInsets.only(top: 5),
                child: RichText(
                  text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: _data,
                          style:  const TextStyle(fontSize: 15,color: BaseColors.gray10),
                        ),
                        TextSpan(
                          text: '《隐私政策》',
                          style: const TextStyle(fontSize: 15,color: BaseColors.blueBase),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context){
                                        return  const PictureWebUrl(title:'隐私政策', weburl: 'https://www.ludeng.com.cn/ldysbh.html',);
                                      }
                                  )
                              );
                            },
                        ),
                        const TextSpan(
                          text: '和',
                          style: TextStyle(fontSize: 15,color: BaseColors.gray10),
                        ),
                        TextSpan(
                          text: '《用户协议》',
                          style: const TextStyle(fontSize: 15,color: BaseColors.blueBase),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context){
                                        return  const PictureWebUrl(title:'用户协议', weburl: 'https://www.ludeng.com.cn/ldfwxy.html',);
                                      }
                                  )
                              );
                            },
                        ),
                        TextSpan(
                          text: _data2,
                          style:  const TextStyle(fontSize: 15,color: BaseColors.gray10),
                        ),
                        TextSpan(
                          text: '《隐私政策》',
                          style: const TextStyle(fontSize: 15,color: BaseColors.blueBase),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context){
                                        return  const PictureWebUrl(title:'隐私政策', weburl: 'https://www.ludeng.com.cn/ldysbh.html',);
                                      }
                                  )
                              );
                            },
                        ),
                        const TextSpan(
                          text: '及',
                          style:  TextStyle(fontSize: 15,color: BaseColors.gray10),
                        ),
                        TextSpan(
                          text: '《用户协议》',
                          style: const TextStyle(fontSize: 15,color: BaseColors.blueBase),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context){
                                        return  const PictureWebUrl(title:'用户协议', weburl: 'https://www.ludeng.com.cn/ldfwxy.html',);
                                      }
                                  )
                              );
                            },
                        ),
                        TextSpan(
                          text: _data3,
                          style:  const TextStyle(fontSize: 15,color: BaseColors.gray10),
                        ),
                      ]
                  ),
                )
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  if (await FlutterBackgroundService().isRunning()) {
                    FlutterBackgroundService().invoke("stopService");
                  }
                  SystemNavigator.pop();
                },
                child: const Text('不同意',style: TextStyle(color: Colors.orange),),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  prefs.setBool('key_ifTongYi', true);
                  Navigator.of(context).pushReplacementNamed('login');
                },
                child: const Text('同意',style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        },
      );
    }

  }
}