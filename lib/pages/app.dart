
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yewswt/pages/student/index.dart';
import 'package:yewswt/pages/student/xuesheng.dart';
import 'package:yewswt/pages/user/user.dart';
import 'package:flutter/material.dart';

import '../data/colors.dart';
import '../data/store_data.dart';
import '../http/request.dart';
import '../model/base_model.dart';
import '../model/base_store.dart';
import 'friends/index.dart';
import 'message/index.dart';
import 'message/message.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
StreamController<ReceivedNotification>.broadcast();
class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
const String darwinNotificationCategoryText = 'textCategory';
const String darwinNotificationCategoryPlain = 'plainCategory';
const String navigationActionId = 'id_3';
class AppPage extends StatefulWidget {
  const AppPage({super.key, });
  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with WidgetsBindingObserver{
  int currentPageIndex=0;
  var statusClose;
  void onTabTapped(int index){
    setState((){
      currentPageIndex=index;
    });
  }
  static const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');
  final List<DarwinNotificationCategory> darwinNotificationCategories =
  <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];
  @override
  void initState() {
    super.initState();
    startRunning();///检测是否启动
    doCheck();///检测更新
    WidgetsBinding.instance?.addObserver(this); //添加观察者
    if(statusClose!=null) statusClose.cancel(); /// 取消定时器
    statusClose=Timer.periodic( const Duration(milliseconds: 500), (timer) { ///用于判断APP是否关闭
      FlutterBackgroundService().invoke("statusCloseService",{'statusClose':DateTime.now().millisecondsSinceEpoch});
    });
    getGroupMessage();///获取聊天记录列表
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      notificationCategories: darwinNotificationCategories,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('static/images/favicon.png'),
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:(NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            _openChat(notificationResponse!.payload??'');
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              _openChat(notificationResponse!.payload??'');
            }
            break;
        }
      },
    );
    FlutterBackgroundService().on('message').listen((dataobj) async {
      // 处理从服务接收到的消息
      if(dataobj?['device']=='login'){
        StoreData.saveUser('');
        var baseStore = Provider.of<BaseStore>(
          context,
          listen: false,
        );
        baseStore.ifLogin=false;
        FlutterBackgroundService().invoke("stopService");
        Navigator.of(context).pushReplacementNamed('login');
        return;
      }
      var data=dataobj?['data'];
      if(data['class']==2) return;///无效提醒
      String ticker=json.encode({'keyid':data?['groupkey'],'name':data?['data']['group']['name'],'device':dataobj?['device']});
      int idNotification=data?['data']['groupid'];
      String title = data?['data']['group']['name'];
      String body = data?['data']['text'];
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('your channel id', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
      const NotificationDetails notificationDetails =
      NotificationDetails(
          android: androidNotificationDetails,
          iOS: DarwinNotificationDetails(
            presentAlert:true,
            presentBadge:true,
            presentSound:true,
            categoryIdentifier: 'plainCategory',
          )
      );
      await flutterLocalNotificationsPlugin.show(
          idNotification, title, body, notificationDetails,
          payload: ticker);

    });
    FlutterBackgroundService().on('logs').listen((dataobj) async {
      var baseStore = Provider.of<BaseStore>(
        context,
        listen: false,
      );
      var message=dataobj?['data'];
      var chatList = baseStore.chatList;
      for(var litem in message['data']){
        var selectedIndex =
        chatList.indexWhere((destination) {
          return destination.keyid == litem['keyid'];
        });
        var upgroup = ChatItem(
            id: litem['id'],
            keyid: litem['keyid'],
            name: litem['name'],
            avatar: litem['imageurl']??'',
            message: litem['text'] ?? '',
            time: litem['time'],
            num: litem['num'],
            nochuli: litem['nochuli'],
            zhiding: litem['zhiding']??0
        );
        if (selectedIndex != -1) {
          chatList[selectedIndex] = upgroup;
        } else {
          chatList.add(upgroup);
        }
      }
      chatList.sort(((a, b){
        return (b.time+(b.zhiding*10000000000)).compareTo(a.time+(a.zhiding*10000000000));
      }));
      baseStore.chatList = chatList;

      var ctLists=[];
      for (var itemc in chatList) {
        ctLists.add(
            {
              'id': itemc.id,
              'keyid': itemc.keyid,
              'name': itemc.name,
              'avatar': itemc.avatar,
              'message': itemc.message,
              'time': itemc.time,
              'num': itemc.num,
              'nochuli': itemc.nochuli,
              'zhiding': itemc.zhiding,
            }
        );
      }
      await StoreData.setChatList(ctLists);//本地存储

    });
  }
  ///启动stopService
  Future<void> startRunning() async {
    if (await FlutterBackgroundService().isRunning()==false) {
      ///启动后台运行
      FlutterBackgroundService().startService();
    }
  }
  //  生命周期变化时回调
  //  resumed:应用可见并可响应用户操作
  //  inactive:用户可见，但不可响应用户操作
  //  paused:已经暂停了，用户不可见、不可操作
  //  suspending：应用被挂起，此状态IOS永远不会回调
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(mounted){
      if(state==AppLifecycleState.resumed){
        getGroupMessage();
      }
    }
  }
  void _openChat(data)  {
    var dat=json.decode(data);
    if(dat['keyid']!=dat['device']){
      Navigator.push(context,
          MaterialPageRoute(
              builder: (context){
                ///return ChatPage(channel:channel,title: strS[0],linkUerkey:'',linkGroupkey:strS[1],datalist:_listmessages[strS[1]],sendMassage: (message) => sendMassage(message));
                return MessagePage(groupKey: dat['keyid'],title:dat['name']);
              }
          )
      );
    }
  }
  Future<void> getGroupMessage() async {
    await HttpUtils.post(path:'/api/login/getchatllist').then((value) {
      if(value['code']==200){
        var baseStore = Provider.of<BaseStore>(
          context,
          listen: false,
        );
        ///获取聊天记录
        List<ChatItem> chatList  = [];
        var message =value['data'];
        message['data']['data'].forEach((v) {
          var ungroup = ChatItem(
            id: v['id'],
            keyid: v['keyid'],
            name: v['name'],
            avatar: v['imageurl']??'',
            message: v['text'] ?? '',
            time: v['time'],
            num: v['num'],
            nochuli: v['nochuli'],
            zhiding: v['zhiding']??0,
          );
          chatList.add(ungroup);
        });
        chatList.sort(((a, b){
          return (b.time+(b.zhiding*10000000000)).compareTo(a.time+(a.zhiding*10000000000));
        }));
        baseStore.chatList = chatList;
        var ctLists=[];
        for (var itemc in chatList) {
          ctLists.add(
              {
                'id': itemc.id,
                'keyid': itemc.keyid,
                'name': itemc.name,
                'avatar': itemc.avatar,
                'message': itemc.message,
                'time': itemc.time,
                'num': itemc.num,
                'nochuli': itemc.nochuli,
                'zhiding': itemc.zhiding
              }
          );
        }
        StoreData.setChatList(ctLists);//本地存储
      }else{
        Navigator.of(context).pushReplacementNamed('login');
        showToast(value['message']);
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: false,//是否透明
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: BaseColors.blue6,
          unselectedLabelStyle:const TextStyle(color: BaseColors.blue6),
          selectedLabelStyle:const TextStyle(color:BaseColors.blue6),
          iconSize: 18,
          selectedFontSize: 12.0,
          onTap: onTabTapped,
          currentIndex: currentPageIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.all(4),child: Icon(IconData(0xe602,fontFamily: "myIcon",matchTextDirection: true)),),
              activeIcon: Padding(padding: EdgeInsets.all(4),child: Icon(IconData(0xe609,fontFamily: "myIcon",matchTextDirection: true)),),
              label: "消息",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.all(4),child: Icon(IconData(0xe608,fontFamily: "myIcon",matchTextDirection: true)),),
              activeIcon: Padding(padding: EdgeInsets.all(4),child: Icon(IconData(0xe606,fontFamily: "myIcon",matchTextDirection: true)),),
              label: "通讯录",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.all(4),child: Icon(IconData(0xe603,fontFamily: "myIcon",matchTextDirection: true)),),
              activeIcon: Padding(padding: EdgeInsets.all(4),child: Icon(IconData(0xe600,fontFamily: "myIcon",matchTextDirection: true)),),
              label: "学生",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.all(4),child: Icon(IconData(0xe60b,fontFamily: "myIcon",matchTextDirection: true)),),
              activeIcon: Padding(padding: EdgeInsets.all(4),child: Icon(IconData(0xe60d,fontFamily: "myIcon",matchTextDirection: true)),),
              label: "我",
            )
          ],
        ),
        body: <Widget>[
          const IndexMessagePage(),
          const IndexFriendsPage(),
          StoreData.gtLoginType() == -1?const XueShengPage():const IndexStudentPage(),
          const UserPage()
        ][currentPageIndex],

    );
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
                //showToast('已是最新版本！');
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

