import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


/// WebSocket状态
enum SocketStatus {
  SocketStatusConnected, // 已连接
  SocketStatusFailed, // 失败
  SocketStatusClosed, // 连接关闭
}

class WebSocketUtility {
  /// 单例对象
  static final WebSocketUtility _socket=WebSocketUtility._internal();

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  WebSocketUtility._internal();

  /// 获取单例内部方法
  factory WebSocketUtility() {
    // 只能有一个实例
    return _socket;
  }
  late String url='ws://jiaoyutong.ludengedu.com/wss';
  late Map<String, dynamic> headers={};
  final String client = 'mobile';//移动端
  late String uidKey;
  late IOWebSocketChannel _webSocket; // WebSocket
  late SocketStatus _socketStatus=SocketStatus.SocketStatusClosed; // socket状态
  late Timer _heartBeat; // 心跳定时器
  final int _heartTimes = 55; // 心跳间隔(秒)
  int ifReconnect=0; //是否容许重新链接
  final int _reconnectCount = 43200; // 重连次数，理论无限次，使劲半天
  int _reconnectTimes = 0; // 重连计数器
  //late Timer _reconnectTimer; // 重连定时器
  late Function onError; // 连接错误回调
  late Function onOpen; // 连接开启回调
  late Function onMessage; // 接收消息回调

  /// 初始化WebSocket
  Future<void> initWebSocket({required String url,required Function onMessage, required Function onError}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uidKeyx=prefs.getString('key_loginKey');
    if(uidKeyx != null){
      uidKey=uidKeyx;
    }else{
      var nowTime = DateTime.now();
      final random = Random();
      const availableChars ='AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      final lKey = List.generate(32,(index) => availableChars[random.nextInt(availableChars.length)]).join();
      uidKey=const Uuid().v5(Uuid.NAMESPACE_DNS,'$nowTime$lKey');
      prefs.setString('key_loginKey', uidKey);
    }
    //this.onOpen = onOpen;
    this.onMessage = onMessage;
    this.onError = onError;
    this.url=url;
    ifReconnect=0;//容许自动重启
    if(_socketStatus == SocketStatus.SocketStatusConnected) {
      ///退出成功 重新链接
      //print('退出成功 重新链接');
      ifReconnect=1;// 关闭后自动重启
      _webSocket.sink.close();
      destroyHeartBeat();
      _socketStatus = SocketStatus.SocketStatusClosed;
      closeSocket();
    }else{
      openSocket();
    }
  }

  /// 开启WebSocket连接
  Future<void> openSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginKey = prefs.getString('key_loginKey')??'';
    var safekey = prefs.getString('key_safeKey')??'';
    var accessToken = prefs.getString('key_access_token')??'';
    String userobj = prefs.getString('key_userData')??'';
    var userKeyid='';
    if(userobj=='' || userobj.isEmpty){
    }else{
      var userObj=json.decode(userobj);
      if(userObj==null || userObj==''){

      }else{
        userKeyid=userObj['keyid']??'';
      }
    }
    var client ='mobile'; //设备
    headers={'loginkey':loginKey,'keyid':userKeyid,'client':client,'safekey':safekey,'accesstoken':accessToken};
    _webSocket = IOWebSocketChannel.connect(url,headers:headers);
    // 接收消息
    _webSocket.stream.listen(webSocketOnMessage,
        onError: webSocketOnError, onDone: webSocketOnDone);
  }

  /// WebSocket接收消息回调
  webSocketOnMessage(data) {
    var message = jsonDecode(data);//print(message);
    if(message['type']=='connect'){ ///连接成功
      // 连接成功，重置重连计数器
      _reconnectTimes = 0;
      // 连接成功，返回WebSocket实例
      _socketStatus = SocketStatus.SocketStatusConnected;
      ///初始化心跳线
      initHeartBeat();
    }else if(message['type']=='login'){ //需要打开登录页面
      ///ownCloseSocket();
    }
    onMessage(message);
    //print(message);
  }

  /// WebSocket关闭连接回调
  webSocketOnDone() {
    //print('WebSocket关闭连接回调');
    //print('closed');
    _socketStatus = SocketStatus.SocketStatusClosed;
    destroyHeartBeat();/// 销毁心跳
    if(ifReconnect==0){ //容许自动重启
      reconnect();
    }else if(ifReconnect==1){ //启动
      ifReconnect=0;//容许自动重启
      openSocket();
    }else{ ///不容许重启

    }
  }

  /// WebSocket连接错误回调
  webSocketOnError(e) {
    WebSocketChannelException ex = e;
    _socketStatus = SocketStatus.SocketStatusFailed;
    onError(ex.message);
    destroyHeartBeat();/// 销毁心跳
    closeSocket();
  }

  /// 初始化心跳
  void initHeartBeat() {//print('初始化心跳');
    //destroyHeartBeat();
    sentHeart();///初始化心跳
    _heartBeat =Timer.periodic(Duration(seconds: _heartTimes), (timer) {
      sentHeart();
    });
  }

  /// 心跳
  void sentHeart() {
    var massage={'type':'ping','client':client,'uidkey':uidKey,'data': {'type':'ping','text':'请求心跳'}};
    String jsonString = jsonEncode(massage);
    sendMessage(jsonString);
    //print('请求心跳');
  }

  /// 销毁心跳
  void destroyHeartBeat() {
    if (_heartBeat!=null && _heartBeat.isActive) {
      _heartBeat.cancel();
    }
  }

  /// 关闭WebSocket
  void closeSocket() {
    if (_socketStatus == SocketStatus.SocketStatusConnected) {
      //print('WebSocket连接关闭');
      _webSocket.sink.close();
      destroyHeartBeat();
      _socketStatus = SocketStatus.SocketStatusClosed;
    }
  }

  /// 发送WebSocket消息
  void sendMessage(message) {
    if (_webSocket != null) {//print('发送WebSocket消息');print(message);
      switch (_socketStatus) {
        case SocketStatus.SocketStatusConnected:

          _webSocket.sink.add(message);
          break;
        case SocketStatus.SocketStatusClosed:
        //print('连接已关闭');
          break;
        case SocketStatus.SocketStatusFailed:
        //print('发送失败');
          break;
        default:
          break;
      }
    }
  }

  ///手动断开链接 不容许自动重启
  void ownCloseSocket(){
    ifReconnect=3;
    if (_socketStatus == SocketStatus.SocketStatusConnected) {
      //print('WebSocket连接关闭');
      _webSocket.sink.close();
      destroyHeartBeat();
      _socketStatus = SocketStatus.SocketStatusClosed;
    }
  }
  /// 重连机制
  void reconnect() {
    //print('重连机制');print(_reconnectTimes);
    if(_socketStatus != SocketStatus.SocketStatusConnected){
      _reconnectTimes++;
      Timer(
          const Duration(seconds: (3)),(){
        if (_reconnectTimes < _reconnectCount) {
          //print('重连次数${_reconnectTimes}');
          openSocket();
        }else{
          //print('重连次数超过最大次数11');
        }
      }
      );
    }

  }

}