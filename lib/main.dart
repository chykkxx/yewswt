import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:yewswt/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
///import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/colors.dart';
import 'data/letter_spacing.dart';
import 'data/store_data.dart';
import 'http/web_sockt.dart';
import 'model/base_store.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  await StoreData.init().then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      // 2-A: wrap your app with OKToast
        backgroundColor: Colors.black.withOpacity(.6),
        radius: 4,
        textPadding: const EdgeInsets.fromLTRB(15,10,15,10),
        animationCurve: Curves.easeIn,
        //animationBuilder: const Miui10AnimBuilder(),
        animationDuration: const Duration(milliseconds: 200),
        duration: const Duration(seconds: 3),
        child:const AppPage()
    );
  }
}
class AppPage extends StatefulWidget {
  const AppPage({super.key, });
  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage>  with RestorationMixin{
  final _RestorableState _appState = _RestorableState();
  @override
  String get restorationId => 'replyState';
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_appState, 'state');
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BaseStore>.value(
          value: _appState.value,
        ),
      ],
      child:MaterialApp(
        title: '路灯教育通',
        debugShowCheckedModeBanner: false,
        theme: _buildReplyLightTheme(context),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,//指定本地化的字符串和一些其他的值
          GlobalWidgetsLocalizations.delegate,//定义 widget 默认的文本方向，从左到右或从右到左。
          GlobalCupertinoLocalizations.delegate,//对应的 Cupertino 风格（Cupertino
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        //home: const MyHomePage(title: 'Flutter Demo Home Page'),
        onGenerateRoute: RouteConfiguration.onGenerateRoute,
        initialRoute: _appState.value.ifLogin?'home':'/',
      )
    );
  }
}
class _RestorableState extends RestorableListenable<BaseStore> {
  @override
  BaseStore createDefaultValue() {
    return BaseStore();
  }

  @override
  BaseStore fromPrimitives(Object? data) {
    final appState = BaseStore();
    final appData = Map<String, dynamic>.from(data as Map);
    appState.selectedUserId = appData['selectedUserId'] as int;
    appState.loginKey =  appData['loginKey']??'';
    appState.ifLogin =  appData['ifLogin']??false;
    appState.userData =  appData['userData'];
    appState.chatList = appData['chatList'];
    // appState.selectedUserKey = appData['selectedUserKey'];
    // appState.chatList = appData['chatList'];
    // appState.selectedChatKey = appData['selectedChatKey'];
    // appState.allMessage = appData['allMessage'];
    return appState;
  }

  @override
  Object toPrimitives() {
    return <String, dynamic>{
      //'selectedEmailId': value.selectedUserId,

    };
  }
}
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  //}

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      // auto start service
      autoStart: true,
      isForegroundMode: false,
      // notificationChannelId: 'my_foreground',
      // initialNotificationTitle: 'AWESOME SERVICE',
      // initialNotificationContent: 'Initializing',
      // foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.setString("hello", "world");
  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  var groupKey='';var stateResumed='resumed';var statusClose=DateTime.now().millisecondsSinceEpoch;
  service.on('statusCloseService').listen((mdata) {
    statusClose=mdata?['statusClose'];
  });
  service.on('groupKeyService').listen((mdata) {
    groupKey=mdata?['groupKey'];
  });
  service.on('stateResumedService').listen((mdata) {
    stateResumed=mdata?['stateResumed'];
  });
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  service.on('sendDataService').listen((massage) {
    String jsonString = jsonEncode(massage);
    WebSocketUtility().sendMessage(jsonString);
  });
  var messageTime=preferences.getInt('messageTime')??0;
  service.on('messageTimeService').listen((mdata) {
    messageTime=mdata?['messageTime'];
  });
  int BadgerNumb=0;
  service.on('badgerNumbService').listen((mdata) {
    BadgerNumb=mdata?['BadgerNumb']??0;
    if(BadgerNumb>0){
      FlutterAppBadger.updateBadgeCount(BadgerNumb);
    }else{
      FlutterAppBadger.removeBadge();
    }
  });
  var client=preferences.getString('key_loginKey');
  String tallkey ='';
  WebSocketUtility().initWebSocket(
      url:'wss://jiaoyutong.ludengedu.com/wss',
      onMessage:(data) {
        if(data['type']=='update' || data['type']=='say'){ ///发会收到  用于重发
          var massagex={'type':'shoudao','client':client,'groupkey':data['groupkey'],'loginkey': data['loginkey'],'tallkey': data['data']['tallkey']};
          String jsonString = jsonEncode(massagex);
          WebSocketUtility().sendMessage(jsonString);
        }
        if(data['type']=='login'){ //需要登录
          service.invoke(
            'message',
            {
              "data":data['data'],
              "current_date": DateTime.now().toIso8601String(),
              "device": 'login',
            },
          );
        }else if(data['type']=='update'){//消息更新
          //print(data['type']);
          service.invoke(
            'update',
            {
              "data":data['data'],
              "current_date": DateTime.now().toIso8601String(),
              "device": '消息更新',
            },
          );
        }else if(data['type']=='say' && data?['data']['time'] > messageTime){
          if(tallkey==data['data']['tallkey']) return;
          service.invoke( ///列表，内容显示
            'say',
            {
              "data":data['data'],
              "current_date": DateTime.now().toIso8601String(),
              "device": groupKey,
            },
          );
          if(data?['data']['class']!=2 && DateTime.now().millisecondsSinceEpoch-statusClose>600){ ///已经关闭程序
            flutterLocalNotificationsPlugin.show(
              data?['data']['group']['id'],
              data?['data']['group']['name'],
              '${data?['data']['text']}',
              const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'your channel id', 'your channel name',
                    channelDescription: 'your channel description',
                    importance: Importance.max,
                    priority: Priority.high,
                    ticker: 'ticker',
                    //ongoing: false,
                  ),
                  iOS: DarwinNotificationDetails(
                    presentAlert:true,
                    presentBadge:true,
                    presentSound:true,
                    categoryIdentifier: 'plainCategory',
                  )
              ),
            );
            BadgerNumb++;
            FlutterAppBadger.updateBadgeCount(BadgerNumb);
          }else if(groupKey!=data?['groupkey'] || stateResumed!='resumed'){ ///消息提醒
            service.invoke(
              'message',
              {
                "data":data,
                "current_date": DateTime.now().toIso8601String(),
                "device": groupKey,
              },
            );
            BadgerNumb++;
            FlutterAppBadger.updateBadgeCount(BadgerNumb);
          }else{
            BadgerNumb=0;
            FlutterAppBadger.removeBadge();
          }
          tallkey=data['data']['tallkey'];
          messageTime=data['data']['time'];
          preferences.setInt("messageTime", messageTime);
        }else if(data['type']=='logs'){
          service.invoke(
            'logs',
            {
              "data":data['data'],
              "current_date": DateTime.now().toIso8601String(),
              "device": '我上线了！',
            },
          );
        }else{  //收到消息
          service.invoke(
            'ping',
            {
              "data":data['data'],
              "current_date": DateTime.now().toIso8601String(),
              "device": '我还在线...',
            },
          );

        }
      },
      onError:(err){
        print(err);
      }
  );

}

ThemeData _buildReplyLightTheme(BuildContext context) {
  final base = ThemeData.light();
  return base.copyWith(
    appBarTheme: const AppBarTheme(centerTitle: true,toolbarHeight:40,titleTextStyle:TextStyle(fontSize: 16,color: BaseColors.gray11,fontWeight:FontWeight.w800),elevation: 0.25,),
    bottomAppBarTheme: const BottomAppBarTheme(color: BaseColors.blueBase),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: BaseColors.blueBase,
      modalBackgroundColor: Colors.white.withOpacity(0.7),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: BaseColors.color6,
      selectionColor: Color(0xff68b6d9),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: BaseColors.blueBase,
      selectedIconTheme: const IconThemeData(color: BaseColors.blueBase),
      // selectedLabelTextStyle:
      // GoogleFonts.workSansTextTheme().headlineSmall!.copyWith(
      //   color: BaseColors.blueBase,
      // ),
      unselectedIconTheme: const IconThemeData(color: BaseColors.blueBase),
      // unselectedLabelTextStyle:
      // GoogleFonts.workSansTextTheme().headlineSmall!.copyWith(
      //   color: BaseColors.blueBase,
      // ),
    ),
    canvasColor: BaseColors.gray3, //底部导航颜色
    cardColor: BaseColors.blueBase,
    chipTheme: _buildChipTheme(
      BaseColors.blueBase,
      BaseColors.lightChipBackground,
      Brightness.light,
    ),
    colorScheme: const ColorScheme.light(
      primary: BaseColors.gray3,//主题色
      primaryContainer: BaseColors.blueBase,
      secondary: BaseColors.blueBase,
      secondaryContainer: BaseColors.blueBase,
      surface: BaseColors.gray4,
      error: BaseColors.blueBase,
      onPrimary: BaseColors.gray11,  //头部颜色
      onSecondary: BaseColors.blueBase,
      onBackground: BaseColors.blueBase,
      //onSurface: BaseColors.orange500,//返回箭头等颜色
      onError: BaseColors.blueBase,
      background: BaseColors.blueBase,
    ),
    textTheme: _buildReplyLightTextTheme(base.textTheme),
    scaffoldBackgroundColor: BaseColors.gray3, //背景颜色
  );
}
TextTheme _buildReplyLightTextTheme(TextTheme base) {
  return base.copyWith(
    // headlineMedium: GoogleFonts.workSans(
    //   fontWeight: FontWeight.w600,
    //   fontSize: 34,
    //   //letterSpacing: letterSpacingOrNone(0.4),
    //   height: 0.9,
    //   color: BaseColors.black900,
    // ),
    // headlineSmall: GoogleFonts.workSans(
    //   fontWeight: FontWeight.bold,
    //   fontSize: 24,
    //   letterSpacing: letterSpacingOrNone(0.27),
    //   color: BaseColors.black900,
    // ),
    // titleLarge: GoogleFonts.workSans(
    //   fontWeight: FontWeight.w600,
    //   fontSize: 20,
    //   letterSpacing: letterSpacingOrNone(0.18),
    //   color: BaseColors.black900,
    // ),
    // titleSmall: GoogleFonts.workSans(
    //   fontWeight: FontWeight.w600,
    //   fontSize: 14,
    //   letterSpacing: letterSpacingOrNone(-0.04),
    //   color: BaseColors.black900,
    // ),
    // bodyLarge: GoogleFonts.workSans(
    //   fontWeight: FontWeight.normal,
    //   fontSize: 18,
    //   letterSpacing: letterSpacingOrNone(0.2),
    //   color: BaseColors.black900,
    // ),
    // bodyMedium: GoogleFonts.workSans(
    //   fontWeight: FontWeight.normal,
    //   fontSize: 14,
    //   letterSpacing: letterSpacingOrNone(-0.05),
    //   color: BaseColors.black900,
    // ),
    // bodySmall: GoogleFonts.workSans(
    //   fontWeight: FontWeight.normal,
    //   fontSize: 12,
    //   letterSpacing: letterSpacingOrNone(0.2),
    //   color: BaseColors.black900,
    // ),
  );
}
ChipThemeData _buildChipTheme(
    Color primaryColor,
    Color chipBackground,
    Brightness brightness,
    ) {
  return ChipThemeData(
    backgroundColor: primaryColor.withOpacity(0.12),
    disabledColor: primaryColor.withOpacity(0.87),
    selectedColor: primaryColor.withOpacity(0.05),
    secondarySelectedColor: chipBackground,
    padding: const EdgeInsets.all(4),
    shape: const StadiumBorder(),
    // labelStyle: GoogleFonts.workSansTextTheme().bodyMedium!.copyWith(
    //   color: brightness == Brightness.dark
    //       ? BaseColors.white50
    //       : BaseColors.black900,
    // ),
    // secondaryLabelStyle: GoogleFonts.workSansTextTheme().bodyMedium,
    brightness: brightness,
  );
}
