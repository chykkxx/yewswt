// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:yewswt/data/colors.dart';
import 'package:yewswt/data/store_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';

import '../../data/image_placeholder.dart';
import '../../http/request.dart';
import '../../model/base_model.dart';
import '../../model/base_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with RestorationMixin {
  final RestorableTextEditingController _usernameController =
      RestorableTextEditingController();
  final RestorableTextEditingController _passwordController =
      RestorableTextEditingController();
  @override
  String get restorationId => 'login_page';
  late bool _ifAgreeFuwu = false;
  _setIsAgreeFuwu(bool value){
    setState(() {
      _ifAgreeFuwu=value;
    });
  }
  @override
  void initState()   {
    super.initState();
    stopRunning();///停止stopService
  }
  ///停止stopService
  Future<void> stopRunning() async {
    if (await FlutterBackgroundService().isRunning()) {
    FlutterBackgroundService().invoke("stopService");
    }
  }
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_usernameController, restorationId);
    registerForRestoration(_passwordController, restorationId);
  }
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        resizeToAvoidBottomInset: false,
        // backgroundColor: BaseColors.blueBase,//这里是你期望的颜色
        body: Stack(
          children: [
            // 背景图片
            Image.asset(
              'static/images/login_bg.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            SafeArea(
              child: _MainView(
                usernameController: _usernameController.value,
                passwordController: _passwordController.value,
                ifAgreeFuwu:_ifAgreeFuwu,
                setIsAgreeFuwu:_setIsAgreeFuwu,
              ),
            ),
          ],
        ),
      );
  }
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _MainView extends StatelessWidget {
  const _MainView({
    this.usernameController,
    this.passwordController,
    required this.ifAgreeFuwu,
    required this.setIsAgreeFuwu,
  });

  final TextEditingController? usernameController;
  final TextEditingController? passwordController;
  final bool ifAgreeFuwu;
  final void Function(bool) setIsAgreeFuwu;

  Future<void> _login(BuildContext context) async {
    if(ifAgreeFuwu==false){
      showToast('请先同意服务协议！');
      return;
    }
    String? name=usernameController?.text;
    if(name==null || name==''){
      showToast('请输入电话号码！');
      return;
    }
    String? password=passwordController?.text;
    if(password==null || password==''){
      showToast('请输入登录密码！');
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
      duration: const Duration(seconds: 300),
      onDismiss: () {
      },
    );
    var data={
      'name':usernameController?.text,
      'password':passwordController?.text,
      'class':'push',
      'device':Platform.isIOS?'ios':(Platform.isWindows?'windows':'android')
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginKey=StoreData.getLoginKey();
    if(loginKey == null){
      loginKey=prefs.getString('key_loginKey');
      if(loginKey == null){
        var nowTime = DateTime.now();
        final random = Random();
        const availableChars ='AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
        final lKey = List.generate(32,(index) => availableChars[random.nextInt(availableChars.length)]).join();
        loginKey=const Uuid().v5(Uuid.NAMESPACE_DNS,'$nowTime$lKey');
        prefs.setString('key_loginKey', loginKey);
        StoreData.setLoginKey(loginKey);
      }
    }
    await HttpUtils.post(path:'/api/login/login',data:data).then((value) async {
      toastFuture.dismiss();
      if(value['code']==200){
        StoreData.setLoginType(value['data']['type']??1);///登录类型状态  1、商务、-1咨询师
        StoreData.setAgreeForget(true);///记住密码
        StoreData.saveClient('mobile');///标记手机端
        StoreData.setToken(value['data']['access_token']);///保存用户登录
        StoreData.setSafeKey(value['data']['safekey']);///保存用户登录安全码
        StoreData.setChatList([]);///清空本地会话记录
        UserItem userItem=UserItem(id:value['data']['id'],name:value['data']['name'],nickname:value['data']['nickname'],tel:value['data']['tel']??'',keyid:value['data']['keyid'],avatar:value['data']['imageurl']??'',created_at:value['data']['time'],zhiwu: value['data']['zhiwu']??'');

        StoreData.saveUser(value['data']);
        var baseStore = Provider.of<BaseStore>(
          context,
          listen: false,
        );
        prefs.setString('key_safeKey', value['data']['safekey']);
        prefs.setString('key_access_token', value['data']['access_token']);
        prefs.setString('key_userData', json.encode(value['data']));
        baseStore.loginKey=loginKey!;
        baseStore.ifLogin=true;
        baseStore.userData=userItem;
        Navigator.of(context).pushReplacementNamed('home');
        ///启动后台运行
        FlutterBackgroundService().startService();
      }else if(value['code']==403){
        showToast(value['message']);
      }else{
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });

  }
  @override
  Widget build(BuildContext context) {
    List<Widget> listViewChildren;

    listViewChildren = [
      const SizedBox(height: 50),
      const _TopBar(),
      const SizedBox(height: 30),
      _UsernameInput(
        maxWidth: 300,
        usernameController: usernameController,
      ),
      const SizedBox(height: 12),
      _PasswordInput(
        maxWidth: 300,
        passwordController: passwordController,
      ),
      _LoginButton(
        onTap: () {
          _login(context);
        },
      ),
      Align(
          alignment: Alignment.center,
          child: Container(
            width: 300,
            child: Row(
              children:<Widget>[
                // 选中框
                Checkbox(
                  value:ifAgreeFuwu,
                  shape: const CircleBorder(),
                  // 改变后的事件
                  onChanged:(value){
                    setIsAgreeFuwu(value!);
                  },
                  // 选中后的颜色
                  activeColor: BaseColors.color8,
                  // 选中后对号的颜色
                  checkColor: Colors.white,
                ),
                const Text('我已阅读并同意',style: TextStyle(color: Color(0xFF999999),fontSize: 12),),
                TextButton(
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero
                  ),
                  onPressed: () async{
                    final Uri url = Uri.parse('https://www.125keji.com/fwxy.html');
                    if (!await launchUrl(url,mode:LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  child: const Text("服务协议、隐私策略",style: TextStyle(color: BaseColors.color6,fontSize: 12),),
                )
              ],
            ),
          )
      ),
      const SizedBox(height: 30),
    ];
    return Stack(
      children: [
        Column(
          children: [
            //const _TopBar(),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView(
                  restorationId: 'login_list_view',
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: listViewChildren,
                ),
              ),
            ),
          ],
        ),
        const Positioned(
          bottom: 20.0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "技术支持：北京一二五科技有限公司",
              style: TextStyle(color: BaseColors.gray6,fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}


class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {

    //final localizations = GalleryLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      //margin: const EdgeInsets.only(top: 0),
      //padding: const EdgeInsets.symmetric(horizontal: 30),
      alignment: Alignment.center,
      child: Wrap(
        //alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ExcludeSemantics(
                child: SizedBox(
                  height: 130,
                  child: FadeInImagePlaceholder(
                    image:
                    const AssetImage('static/images/login_logo1.png'),
                    placeholder: LayoutBuilder(builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxHeight,
                        height: constraints.maxHeight,
                      );
                    }),
                  ),
                ),
              ),
              // spacing,
              // Text(
              //   '登录',
              //   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              //     fontSize: 35 / reducedTextScale(context),
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
            ],
          ),

        ],
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput({
    this.maxWidth,
    this.usernameController,
  });

  final double? maxWidth;
  final TextEditingController? usernameController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            height: 52,
            constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
            padding: const EdgeInsets.only(left: 20,right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextField(
              textInputAction: TextInputAction.next,
              controller: usernameController,
              decoration: const InputDecoration(
                hintText: '请输入手机号',
                hintStyle: TextStyle(fontSize: 16, color: Color(0xFF999999)),
                border: InputBorder.none,
                fillColor: BaseColors.gray8,
              ),

            ),
          ),
          const Positioned(
            right: 0,
            child: Image(image:AssetImage('static/images/login_tag.png'),width: 50,),
          )
        ],
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({
    this.maxWidth,
    this.passwordController,
  });

  final double? maxWidth;
  final TextEditingController? passwordController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextField(
          textInputAction: TextInputAction.next,
          controller: passwordController,
          decoration: const InputDecoration(
            hintText: '请输入密码',
            hintStyle: TextStyle(fontSize: 16, color: Color(0xFF999999)),
            border: InputBorder.none,
            fillColor: BaseColors.gray8,
          ),
          obscureText: true,
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onTap,
    this.maxWidth,
  });

  final double? maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        //padding: const EdgeInsets.symmetric(vertical: 30),
        width: 300,
        child: Container(
          margin: const EdgeInsets.only(top: 30),
          //color: Colors.green,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                foregroundColor: BaseColors.orange500,
                side: const BorderSide(color: BaseColors.white50),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: BaseColors.blue6,
                textStyle: const TextStyle(fontSize: 16,)
            ),
            onPressed: () {
              onTap();
            },
            child: const Text('登 录',style: TextStyle(color: Colors.white),),
          ),
        ),
      ),
    );
  }
}