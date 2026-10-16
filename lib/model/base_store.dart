import 'package:flutter/cupertino.dart';


import '../data/store_data.dart';
import 'base_model.dart';
import 'menu_model.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class BaseStore with ChangeNotifier {
  String _modelId = 'chatPush';

  String get selectedModelId => _modelId;

  set selectedModelId(String value) {
    _modelId = value;
    notifyListeners();
  }

  MenuType _selectedMenuPage = MenuType.chatPush;

  MenuType get selectedMenuPage => _selectedMenuPage;

  set selectedMenuPage(MenuType mailboxPage) {
    _selectedMenuPage = mailboxPage;
    notifyListeners();
  }

  //用户是否登录 StoreData.isLogined()
  bool _ifLogin = StoreData.isAgreeForget()?StoreData.isLogined():false;

  bool get ifLogin => _ifLogin;

  set ifLogin(bool value) {
    _ifLogin = value;
    notifyListeners();
  }
  //用户登录KEY
  String _loginKey = StoreData.getLoginKey()??'';
  String get loginKey => _loginKey;
  set loginKey(String value) {
    _loginKey = value;
    notifyListeners();
  }
  //用户
  UserItem _userData = StoreData.getUser();
  UserItem get userData => _userData;
  set userData(UserItem value) {
    _userData = value;
    notifyListeners();
  }

  //用户ID
  int _selectedUserId = -1;

  int get selectedUserId => _selectedUserId;

  set selectedUserId(int value) {
    _selectedUserId = value;
    notifyListeners();
  }

  //用户key
  String _userKey = '6f493d959614bda95c6902d7e204c9e4';
  String get selectedUserKey => _userKey;
  set selectedUserKey(String value) {
    _userKey = value;
    notifyListeners();
  }
  //对话列表
  List<ChatItem> _chatList=StoreData.chatList();
  List<ChatItem> get chatList => _chatList;
  set chatList(List<ChatItem>  value){
    _chatList=value;
    notifyListeners();
  }
  //当前对话Key
  String _chatKey = StoreData.getChatKey();
  String get selectedChatKey => _chatKey;
  set selectedChatKey(String value) {
    _chatKey = value;
    notifyListeners();
  }
  //消息列表
  List<Message> _allMessage=[];
  List<Message> get allMessage => _allMessage;
  set allMessage(List<Message>  value){
    _allMessage=value;
    notifyListeners();
  }

  bool get onUserView => _selectedUserId > -1;

  bool _onSearchPage = false;

  bool get onSearchPage => _onSearchPage;

  set onSearchPage(bool value) {
    _onSearchPage = value;
    notifyListeners();
  }
  ///发送消息零时存储
  Map _onEnterText = {};
  Map get onEnterText => _onEnterText;
  set setEnterText(Map value) {
    _onEnterText=value;
    notifyListeners();
  }
}

class ChatMessages extends ChangeNotifier{//查看对话详情KEY
  List<types.Message> _chatMessages = [];


  List<types.Message> get chatMessages => _chatMessages;

  setChatMessages(message){
    _chatMessages=message;
    notifyListeners();
  }
}

class ShowChatKey extends ChangeNotifier{//查看对话详情KEY
  String _chatKey = '';//查看对话详情KEY

  String get chatKey => _chatKey;

  setChatKey(selectedChatKey){
    _chatKey=selectedChatKey;
    notifyListeners();
  }
}

class IfShowChat extends ChangeNotifier{//查看对话详情KEY
  int _ifChat = 0;//查看对话详情KEY
  int get ifChat => _ifChat;
  setIfChat(){
    _ifChat++;
    notifyListeners();
  }
}
///修改消息内容
class UpdateMessage extends ChangeNotifier{//查看对话详情KEY
  late types.Message _updateMessage ;//查看对话详情KEY
  types.Message get updateMessage => _updateMessage;
  setUpdateMessage(types.Message message){
    _updateMessage=message;
    notifyListeners();
  }
}

///修改app状态
class UpdateAppLifecycle extends ChangeNotifier{//查看对话详情KEY
  late String _appLifecycle ;//查看对话详情KEY
  String get updateAppLifecycle => _appLifecycle;
  setUpdateAppLifecycle(String message){
    _appLifecycle=message;
    notifyListeners();
  }
}


///记录未发生成功数据
class SendDataAppLifecycle extends ChangeNotifier{//查看对话详情KEY
  late List<String> _appSendData=[] ;//查看对话详情KEY
  List<String> get updateAppLifecycle => _appSendData;
  setUpdateAppLifecycle(List<String> message){
    _appSendData=message;
    notifyListeners();
  }
}