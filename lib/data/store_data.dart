import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/base_model.dart';

class StoreData {
  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  StoreData._internal();

  static SharedPreferences? _spf;

  static Future<SharedPreferences> init() async {
    _spf ??= await SharedPreferences.getInstance();
    return _spf!;
  }
  ///设备类型 mobile  desktop
  static Future<bool> saveClient(String client) {
    return _spf!.setString('key_client', client);
  }

  static String getClient() {
    //return 'mobile';
    return _spf!.getString('key_client')??'mobile';
  }

  ///主题
  static Future<bool> saveThemeIndex(int value) {
    return _spf!.setInt('key_theme_color', value);
  }

  static int getThemeIndex() {
    if (_spf!.containsKey('key_theme_color')) {
      return _spf!.getInt('key_theme_color')??0;
    }
    return 0;
  }

  ///语言
  static Future<bool> saveLocale(String locale) {
    return _spf!.setString('key_locale', locale);
  }

  static String getLocale() {
    return _spf!.getString('key_locale')??'';
  }


  ///是否同意隐私协议
  static Future<bool> saveIsAgreePrivacy(bool isAgree) {
    return _spf!.setBool('key_agree_privacy', isAgree);
  }

  static bool isAgreePrivacy() {
    return false;
    if (!_spf!.containsKey('key_agree_privacy')) {
      return false;
    }
    return _spf!.getBool('key_agree_privacy')??false;
  }
  ///登录关键ID
  static String? getLoginKey(){
    return _spf!.getString('key_loginKey');
  }
  static Future<bool> setLoginKey(String value){
    return _spf!.setString('key_loginKey',value);
  }
  static String? getSafeKey(){
    return _spf!.getString('key_safeKey');
  }
  static Future<bool> setSafeKey(String value){
    return _spf!.setString('key_safeKey',value);
  }
  static String? getToken(){
    return _spf!.getString('key_access_token');
  }
  static Future<bool> setToken(String value){
    return _spf!.setString('key_access_token',value);
  }
  ///是否记住密码
  static bool isAgreeForget() {
    return _spf!.getBool('key_isAgreeForget')??false;
  }
  static Future<bool> setAgreeForget(bool value) {
    return _spf!.setBool('key_isAgreeForget', value);
  }
  ///登录类型状态  1、商务、-1咨询师
  static int gtLoginType() {
    return _spf!.getInt('key_loginType')??1;
  }
  static Future<bool> setLoginType(int value) {
    return _spf!.setInt('key_loginType', value);
  }
  ///是否已登陆
  static bool isLogined() {
    String userObj = _spf!.getString('key_userData')??'';
    //return false;
    if(userObj != ''){
      return true;
    }else{
      return false;
    }
    //return false;
    //return userObj != null && userObj.isNotEmpty;
  }
  ///用户数据
  static Future<bool> saveUser(value) {
    return _spf!.setString('key_userData', value==''?'':json.encode(value));
  }
  static UserItem getUser() {
    String userobj = _spf!.getString('key_userData')??'';
    if(userobj=='' || userobj.isEmpty){
      return UserItem(id: 0,keyid: '',name: '');
    }else{
      var userObj=json.decode(userobj);
      if(userObj==null || userObj==''){
        return UserItem(id: 0,keyid: '',name: '');
      }else{
        return UserItem(id:userObj['id']??0,name:userObj['name']??'',nickname:userObj['nickname']??'',tel:userObj['tel']??'',keyid:userObj['keyid']??'',avatar:userObj['imageurl']??'',created_at:userObj['time']??'');
      }
    }
  }
  ///当前回话关键ID
  static String getChatKey(){
    return _spf!.getString('key_chatKey')??'';
  }
  static Future<bool> setChatKey(String value){
    return _spf!.setString('key_chatKey',value);
  }
  ///聊天对话列表
  static List<ChatItem> chatList() {
    String chartList = _spf!.getString('key_chartList')??'';//chartList='';
    if(chartList!.isNotEmpty && chartList!=''){
      var listCh=json.decode(chartList);
      if(listCh.length>0){
        final messages = (listCh as List)
            .map((e) => ChatItem(id: e['id']??0,name: e['name']??'',keyid: e['keyid']??'',avatar: e['avatar']??'',time: e['time']??0,num: e['num']??0,message:e['message']??'')
        ).toList();
        return messages;
      }
    }
    String userobj = _spf!.getString('key_userData')??'';
    if(userobj.isEmpty==false && userobj!.isNotEmpty && userobj != ''){
      var userObj = json.decode(userobj);
      return [
        ChatItem(id: userObj['id'] ?? 0,
            name: userObj['nickname'] ?? '',
            keyid: userObj['keyid'] ?? '',
            avatar: userObj['avatar'] ?? '')
      ];
    }else{
      return [ChatItem(id: 0,name: '',keyid: '')];
    }

  }
  static Future<bool> setChatList(value) {
    return _spf!.setString('key_chartList', json.encode(value));
  }
  static  dynamic getChatList() {
    String chartList = _spf!.getString('key_chartList')??'';
    if(chartList!.isNotEmpty && chartList !=''){
      var listCh=json.decode(chartList);
      if(listCh.length>0){
        return listCh;
      }
    }
    return [];
  }
}
