import 'dart:async';
import 'dart:io';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:oktoast/oktoast.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:yewswt/data/myIcon.dart';
import 'package:yewswt/pages/message/show_chat.dart';

import '../../baseChat/src/widgets/chat.dart';
import '../../data/colors.dart';
import '../../data/store_data.dart';
import '../../http/request.dart';

import '../../model/base_model.dart';
import '../../model/base_store.dart';
import '../picker.dart';
import '../student/student_fankui.dart';
import '../student/student_show.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
class MessagePage extends StatefulWidget {
  const MessagePage({super.key,required this.title,required this.groupKey});
  final String title;
  final String groupKey;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with WidgetsBindingObserver{
  SendDataAppLifecycle objSendDataAppLifecycle = SendDataAppLifecycle();
  List<types.Message> _messages = [];
  List<types.Message> _chatMessages = [];
  late  types.User _user = const types.User(id: '6f493d959614bda95c6902d7e204c9e4');
  //final _user = const types.User(id: StoreData.);
  int pageNum=1;int total=0;
  bool isLoading =false;
  late int readTime=0;
  late int messageTime=0;
  late int userid=0;
  late String userKey='';
  Map<String, dynamic> yydata={};//引用数据
  final AutoScrollController _scrollController=AutoScrollController();

  final controller = MultiImagePickerController(
    maxImages: 10,
    images: <ImageFile>[], // array of pre/default selected images
    picker: (bool allowMultiple) async {
      //return await pickConvertedImages(allowMultiple);
      return await pickImagesUsingImagePicker(allowMultiple);
    },
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this); //添加观察者
    var user=StoreData.getUser();
    userid=user.id;
    userKey=user.keyid;
    _user= types.User(id: user?.keyid??'',imageUrl: user.avatar,firstName: user.nickname,metadata:const {'type':0});
    _loadMessages();
    FlutterBackgroundService().on('update').listen((data) {
      // 处理从服务接收到的消息
      if(data?['data']['groupkey']==widget.groupKey){
        if(mounted) {
          ///取消重发
          List<String> sendList = objSendDataAppLifecycle.updateAppLifecycle;
          sendList.removeWhere((element) => element == data?['data']['tallkey']);
          objSendDataAppLifecycle.setUpdateAppLifecycle(sendList);
          final index =
          _chatMessages.indexWhere((element) =>
          element.id == data?['data']['tallkey']);
          if (index != -1) {
            setState(() {
              _chatMessages[index] = messageData(data?['data']);
            });
          } else {
            final index =
            _messages.indexWhere((element) =>
            element.id == data?['data']['tallkey']);
            if (index != -1) {
              setState(() {
                _messages[index] = messageData(data?['data']);
              });
            }
          }
          var baseStore = Provider.of<BaseStore>(
            context,
            listen: false,
          );
          var chatList=baseStore.chatList;
          final selectedIndex =
          chatList.indexWhere((destination) {
            return destination.keyid == widget.groupKey;
          });
          if(selectedIndex!=-1){
            chatList[selectedIndex]=ChatItem(
                id: chatList[selectedIndex].id,
                keyid: chatList[selectedIndex].keyid,
                name: chatList[selectedIndex].name,
                avatar: chatList[selectedIndex].avatar,
                message: chatList[selectedIndex].message,
                time: DateTime.now().millisecondsSinceEpoch,
                num: 0,
                nochuli: chatList[selectedIndex].nochuli,
                zhiding: chatList[selectedIndex].zhiding
            );
          }
          baseStore.chatList=chatList;
        }
      }
    });
    var tallkey='';
    FlutterBackgroundService().on('say').listen((data) {
      // 处理从服务接收到的消息
      if(data?['data']['groupkey']==widget.groupKey && tallkey!=data?['data']['tallkey']){
        if(mounted){
            if(data?['data']['time']>messageTime){
              setState(() {
                _chatMessages.insert(0,messageData(data?['data']));
                messageTime=data?['data']['time'];
              });
            }else{
              final index =
              _chatMessages.indexWhere((element) =>
              element.id == data?['data']['tallkey']);
              if (index == -1) {
                final index =
                _messages.indexWhere((element) =>
                element.id == data?['data']['tallkey']);
                if (index == -1) {
                  _chatMessages.insert(0,messageData(data?['data']));
                }
              }
            }
            _readOk();
            tallkey=data?['data']['tallkey'];
            var baseStore = Provider.of<BaseStore>(
              context,
              listen: false,
            );
            var chatList=baseStore.chatList;
            final selectedIndex =
            chatList.indexWhere((destination) {
              return destination.keyid == widget.groupKey;
            });
            if(selectedIndex!=-1){
              chatList[selectedIndex]=ChatItem(
                  id: chatList[selectedIndex].id,
                  keyid: chatList[selectedIndex].keyid,
                  name: chatList[selectedIndex].name,
                  avatar: chatList[selectedIndex].avatar,
                  message: chatList[selectedIndex].message,
                  time: DateTime.now().millisecondsSinceEpoch,
                  num: 0,
                  nochuli: chatList[selectedIndex].nochuli,
                  zhiding: chatList[selectedIndex].zhiding
              );
            }
            baseStore.chatList=chatList;
        }
      }
    });

    _scrollController.addListener(() {
      if(isLoading ==false && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent){
        setState(() {
          isLoading=true;
          pageNum++;
          _getSqflite(pageNum);
        });
        print('顶部');
      }else if(_scrollController.position.pixels==0){ ///滚动到顶部
        //print('滚动到顶部');
      }
    });

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    FlutterBackgroundService().invoke("groupKeyService",{'groupKey':''});
  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    FlutterBackgroundService().invoke("groupKeyService",{'groupKey':widget.groupKey});
    //print('didChangeDependencies');
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
        ///print('当前对话');
        FlutterBackgroundService().invoke("stateResumedService",{'stateResumed':'resumed'});
      }else{
        ///print('需要消息提醒');
        FlutterBackgroundService().invoke("stateResumedService",{'stateResumed':'inactive'});
      }
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      actions:  [
        IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>MobileShowChat(groupKey: widget.groupKey)));
            },
            icon: const Icon(Icons.more_horiz)
        ),
      ],
    ),
    body: ContextMenuOverlay(
      /// Make a custom background
      cardBuilder: (_, children) => Container(
        decoration: BoxDecoration(
            color: BaseColors.gray10,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Row(children: children),
      ),

      /// Make custom buttons
      buttonBuilder: (_, config, [__]) => TextButton(
        onPressed: config.onPressed,
        child: SizedBox(
            width: 30,
            child: Column(
              children: [
                config.label=='复制'? const Icon(Icons.file_copy_outlined,size: 20): (config.label=='引用'? const Icon(Icons.alternate_email_outlined,size: 20):(config.label=='反馈'? const Icon(Icons.chat,size: 20): const Icon(Icons.reply_all,size: 20,))),
                Text(config.label,style: const TextStyle(fontSize: 12),),
              ],
            )
        ),
      ),
      child: Chat(
        messages: _chatMessages+_messages,
        onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onMessageSd: _handleMessageSd,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        customBottomWidget: EnterMdPage(sendMessage:sendMessage,groupKey:widget.groupKey,addMessage:_addMessage,senduser:_user,yydata:yydata,cleanYydata:_handleCleanYydataPressed),
        showUserAvatars: true,
        onMessageDoubleTap:_handleMessageDoubleTap,
        //showUserNames: true,
        scrollController:_scrollController,
        user: _user,
      ),
    ),
  );

  ///发送消息
  void sendMessage(sendmessage){
    //status: types.Status.sending,
    var baseStore = Provider.of<BaseStore>(
      context,
      listen: false,
    );

    var chatList=baseStore.chatList;
    final selectedIndex =
    chatList.indexWhere((destination) {
      return destination.keyid == widget.groupKey;
    });
    if(selectedIndex!=-1){
      chatList[selectedIndex]=ChatItem(
          id: chatList[selectedIndex].id,
          keyid: chatList[selectedIndex].keyid,
          name: chatList[selectedIndex].name,
          avatar: chatList[selectedIndex].avatar,
          message: sendmessage.text,
          time: messageTime,
          num: 0,
          nochuli: chatList[selectedIndex].nochuli,
          zhiding: chatList[selectedIndex].zhiding
      );
    }
    baseStore.chatList=chatList;

    var client =StoreData.getClient(); //设备
    var massage={'type':'say','ifSendOk':true,'uidkey':StoreData.getLoginKey(),'client':client,'groupkey':widget.groupKey,'data': {'type':sendmessage.type,'tallkey':sendmessage.id,'text':sendmessage.text,'id':sendmessage.id,'createdAt':sendmessage.createdAt,'data':sendmessage.data}
    };
    FlutterBackgroundService().invoke("sendDataService",massage);
    ///两秒后重新发送
    List<String> sendList=objSendDataAppLifecycle.updateAppLifecycle;
    sendList.add(sendmessage.id);
    objSendDataAppLifecycle.setUpdateAppLifecycle(sendList);
    Timer(const Duration(seconds: (2)), () {
      List<String> sendList=objSendDataAppLifecycle.updateAppLifecycle;
      if(sendList.contains(sendmessage.id) && mounted) sendMessage(sendmessage);
    });
  }
  void _addMessage(message) {
    //widget.sendData(message,'say');
    setState(() {
      _chatMessages.insert(0, message);
    });
  }
  ///收到 收到 同步 复制 引用 删除
  Future<void> _handleMessageSd(BuildContext _, types.Message message,int leixing) async {
    if(leixing==2){ ///更新学生
      showToast('您不能点击同步！',duration: const Duration(seconds: 3),);
    }else if(leixing==3){ ///复制
      var text ='';
      message.metadata?['data'].forEach((key, value) {
        text+=value[0]+':'+value[1]+'    ';
      });
      Clipboard.setData(ClipboardData(text: text));
    }else if(leixing==4){ ///复制
      var text =message.metadata?['text'];
      Clipboard.setData(ClipboardData(text: text));
      showToast('复制成功',duration: const Duration(seconds: 1));
    }else if(leixing==5){ ///引用
      // var text =message.metadata?['text'];
      // Clipboard.setData(ClipboardData(text: text));
      //print(message.metadata?['data']);
      setState(() {
        yydata=message.metadata!;
      });
      //print(message.metadata!['senduser']);
    }else if(leixing==6){ ///撤回
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
      await HttpUtils.post(
          path:'/api/login/deletelogs',
          data: {'id':message.metadata?['id'],'groupid':message.metadata?['groupid']}
      ).then((value) {
        toastFuture.dismiss();
        if(value['code']==200){
          ///发送更新消息
          final sendMessage = ChatMessage(
            createdAt:DateTime.now().millisecondsSinceEpoch,
            type:'text',
            status: types.Status.sending,
            id:const Uuid().v4(),
            text:'更新消息',
            data:{'id':message.metadata?['id']} ,
          );
          var massage={'type':'update','ifSendOk':true,'uidkey':StoreData.getLoginKey(),'client':StoreData.getClient(),'groupkey':widget.groupKey,'data': {'type':sendMessage.type,'tallkey':sendMessage.id,'text':sendMessage.text,'id':sendMessage.id,'createdAt':sendMessage.createdAt,'data':sendMessage.data}
          };
          FlutterBackgroundService().invoke("sendDataService",massage);
        }else{
          showToast(value['message'],duration: const Duration(seconds: 3));
        }
      });
      //showToast('不可删除！',duration: const Duration(seconds: 3));
    }else if(leixing==7){ ///反馈
      var _inboxKey = UniqueKey();
      Navigator.push(context,
          MaterialPageRoute(
              builder: (context){
                return StudentFankuiPage(key: _inboxKey,student:message.metadata?['data']);
              }
          )
      );
    }else{ ///收到
      var student=message.metadata?['data'];
      student['chatgroup_id']=message.metadata?['id'];
      var _inboxKey = UniqueKey();
      Navigator.push(context,
          MaterialPageRoute(
              builder: (context){
                return StudentShowPage(key: _inboxKey,student:message.metadata?['data']);
              }
          )
      ).then((value)  async { ///需要更新一下消息
        ///发送更新消息
        final sendMessage = ChatMessage(
          createdAt:DateTime.now().millisecondsSinceEpoch,
          type:'text',
          status: types.Status.sending,
          id:const Uuid().v4(),
          text:'更新消息',
          data:{'id':message.metadata?['id']} ,
        );
        var massage={'type':'update','ifSendOk':true,'uidkey':StoreData.getLoginKey(),'client':StoreData.getClient(),'groupkey':widget.groupKey,'data': {'type':sendMessage.type,'tallkey':sendMessage.id,'text':sendMessage.text,'id':sendMessage.id,'createdAt':sendMessage.createdAt,'data':sendMessage.data}
        };
        FlutterBackgroundService().invoke("sendDataService",massage);
      });
    }
  }
  ///清除引用
  void _handleCleanYydataPressed(){
    setState(() {
      yydata={};
    });
  }
  ///发送底部默认案例
  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  ///上传文件
  Future<void> _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }
  ///上传图片
  Future<void> _handleImageSelection() async {
    var baseStore = Provider.of<BaseStore>(
      context,
      listen: false,
    );
    if(await controller.pickImages()){
      if (!mounted) return;
      controller.images.forEach((element) {
        FormData formdata = FormData.fromMap({
          'loginKey':baseStore.loginKey,
          'keyid':baseStore.userData.keyid,
          "upload":  MultipartFile.fromFileSync(element.path.toString())
        });

        HttpUtils.post(path:'/api/home/common/upload',data:formdata).then((value) async {
          if(value['code']==200){
            final bytes =  element.bytes;
            final image = await decodeImageFromList(bytes!);
            String imgUrl=value['data']['url'];
            final sendMessage = ChatMessage(
              createdAt:DateTime.now().millisecondsSinceEpoch,
              type:'image',
              status: types.Status.sending,
              id:const Uuid().v4(),
              text:'图片',
              data:{
                'uri':imgUrl,
                "name":element.name,
                "size":bytes.length,
                "height":image.height.toDouble(),
                "width":image.width.toDouble()
              } ,
            );
            _addMessage(sendMessage);
          }else{
            //showToast(value['message']);
          }
        }).catchError((error) {
          print('报错信息：$error');
        });
      });
    }
  }
  ///单击下载文件
  Future<void> _handleMessageTap(BuildContext _, types.Message message) async {


    if (message is types.FileMessage) {
      var localPath = message.uri;
      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );
          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }
  ///双击
  Future<void> _handleMessageDoubleTap(BuildContext _, types.Message message)async {
    //Toast.show(context: context, message: 'sssss');
    var _inboxKey = UniqueKey();
    if(message.metadata?['pushid']!=null && message.metadata?['pushid']!=0 && (message.metadata?['userkey']==userKey || _user.metadata?['type']>2)){
      Navigator.push(context,
          MaterialPageRoute(
              builder: (context){
                return StudentShowPage(key: _inboxKey,student:message.metadata);
              }
          )
      );
    }else if(message.metadata?['pushid']!=null && message.metadata?['pushid']!=0){
      showToast('你没有权限编辑该学生',duration: const Duration(seconds: 3));
    }
  }
  void _handlePreviewDataFetched(types.TextMessage message,types.PreviewData previewData,) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );
    setState(() {
      _messages[index] = updatedMessage;
    });
  }
  ///发送文本数据
  void _handleSendPressed(types.PartialText message) {
    final sendMessage = ChatMessage(
      createdAt:DateTime.now().millisecondsSinceEpoch,
      type:'text',
      status: types.Status.sending,
      id:const Uuid().v4(),
      text:message.text,
      data:{} ,
    );
    _addMessage(sendMessage);
  }
  ///初始获取数据
  Future<void> _loadMessages() async {
    _getSqflite(1);//print('555555555555');
  }
  ///获取本地数据
  _getSqflite(int page) async {
    var baseStore = Provider.of<BaseStore>(
      context,
      listen: false,
    );
    var nowtime=DateTime.now().millisecondsSinceEpoch;///当前时间
    await HttpUtils.post(path:'/api/login/chatlogs',data:{'userid':baseStore.userData.id,'userkey':baseStore.userData.keyid,'groupkey':widget.groupKey,'nowtime':nowtime,'page':page}).then((value) async {
      if(page==1){
        await flutterLocalNotificationsPlugin.cancel(value['group']['id']);//清楚消息提醒
        if(value['data'].length>0){
          setState(() {
            messageTime=value['data'][0]['time'];
          });
        }
        List<types.Message> messages=[];
        //widget.setMessage(messages);//清空聊天记录
        ///更新一下未处理数据
        if(value['group']!=null){

          var chatList=baseStore.chatList;
          final selectedIndex =
          chatList.indexWhere((destination) {
            return destination.keyid ==value['group']['keyid'];
          });
          if(selectedIndex!=-1){
            chatList[selectedIndex]=ChatItem(
              id: chatList[selectedIndex].id,
              keyid: chatList[selectedIndex].keyid,
              name: chatList[selectedIndex].name,
              avatar: chatList[selectedIndex].avatar,
              message: chatList[selectedIndex].message,
              time: chatList[selectedIndex].time,
              num: 0,
              nochuli: value['group']['nochuli'],
              zhiding: chatList[selectedIndex].zhiding,
            );
          }
          baseStore.chatList=chatList;
        }
      }

      if(value['code']==200){
        setState(() {
          _user= types.User(id: value['user']['keyid']??'',imageUrl: value['user']['imageurl'],firstName: value['user']['nickname'],metadata:{'type':value['user']['type']});
        });
        value['data'].forEach((data) async {
          //if(page>1){
          addChat(data,1);///加入平台显示
          // }else{
          //   addChat(data,2);///加入平台显示
          // }

        });
        if(value['data'].isNotEmpty){
          if (!mounted) return;
          setState(() {
            isLoading=false;
            pageNum=page;
          });
        }else if(page>1){
          if (!mounted) return;
          setState(() {
            isLoading=false;
            pageNum=page-1;
          });
        }
      }
    });

  }
  ///消息加入到或者更新聊天框
  ///ifsqflite =1 本地数据 ifsqflite =2 新数据 ifsqflite =3 更新数据
  addChat(data,int ifsqflite){
    types.Message chatMessage;
    var userId=data['senduser']['keyid'];
    var userimageUrl=data['senduser']['imageurl']==''?null:data['senduser']['imageurl'];
    var userFirstName=data['senduser']['nickname'] ?? data['senduser']['name'];
    // if(data['senduser']['type']==4){
    //   userId='80761a69c3a551138ffe63e81878ed75';
    //   userimageUrl='http://jiaoyutong.ludengedu.com/static/images/zhoulaoshi.png';
    //   userFirstName='周老师';
    // }
    chatMessage=messageData(data);
    //var data=v['data'];
    if(mounted){
      if(ifsqflite==1){ ///本地数据加入
        setState(() {
          _messages.add(chatMessage);
        });
      }else if(ifsqflite==2){ ///线上最新数据加入
        setState(() {
          _messages.insert(0,chatMessage);
        });
      }else{ ///更新
        final index =
        _messages.indexWhere((element) => element.id == data['tallkey']);
        if(index!=-1) {
          setState(() {
            _messages[index] = chatMessage;
          });
        }
      }
    }
  }
  ///封装数据
  messageData(data){
    var userId=data['senduser']['keyid'];
    var userimageUrl=data['senduser']['imageurl']==''?null:data['senduser']['imageurl'];
    var userFirstName=data['senduser']['nickname'] ?? data['senduser']['name'];
    // if(data['senduser']['type']==4){
    //   userId='80761a69c3a551138ffe63e81878ed75';
    //   userimageUrl='http://jiaoyutong.ludengedu.com/static/images/zhoulaoshi.png';
    //   userFirstName='周老师';
    // }
    //var data=v['data'];
    if(data['type']=='image'){
      return types.ImageMessage(
        author: types.User(id:userId,imageUrl:userimageUrl,firstName:userFirstName),
        createdAt: data['time'],
        id: data['tallkey'],
        metadata:data,
        uri: data['data']['uri']??'',
        //type: data['data']['type'],
        name: data['data']['name']??'',
        height: (data['data']['height']??0).toDouble(),
        width: (data['data']['width']??0).toDouble(),
        size: data['data']['size']??0,
        //type: types.text
      );

    }else if(data['type']=='file'){
      return types.FileMessage(
        author: types.User(id:userId,imageUrl:userimageUrl,firstName:userFirstName),
        createdAt: data['time'],
        id: data['tallkey'],
        metadata:data,
        mimeType: data['data']['mimeType']??'',
        name: data['data']['name']??'',
        size: data['data']['size']??0,
        uri: data['data']['uri']??'',
      );
    }else if(data['type']=='system'){
      return types.TextMessage(
        author: types.User(id:userId,imageUrl:userimageUrl,firstName:userFirstName),
        createdAt: data['time'],
        id: data['tallkey'],
        metadata:data,
        //status: seen,
        text: data['text'],
        //type: data['data']['type'],
        type: types.MessageType.system,
      );

    }else{
      return types.TextMessage(
        author: types.User(id:userId,imageUrl:userimageUrl,firstName:userFirstName),
        createdAt: data['time'],
        id: data['tallkey'],
        metadata:data,
        //status: types.Status.sending,
        showStatus:true,
        text: data['text'],
        //type: data['data']['type'],
        //type: types.text
      );
    }
  }
  ///发送已读请求
  Future<void> _readOk() async {
    await HttpUtils.post(path:'/api/login/chatread',data:{'userid':userid,'userkey':userKey,'groupkey':widget.groupKey},showLoading:false,showErrorMessage:false).then((value) {
      if(mounted){
        setState(() {
          readTime = value['data']??0;
        });
      }
    }).catchError((error) {
      print('报错信息：$error');
    });
  }
}

class EnterMdPage extends StatefulWidget{
  const EnterMdPage({super.key,required this.sendMessage,required this.groupKey,required this.addMessage,required this.senduser,required this.yydata,required this.cleanYydata});
  final void Function(ChatMessage) sendMessage;
  final void Function(types.Message) addMessage;
  final String groupKey;
  final types.User senduser;
  final Map<String, dynamic> yydata;
  final void Function() cleanYydata;
  @override
  State<EnterMdPage> createState() => EnterMdPageState();
}
class EnterMdPageState extends State<EnterMdPage>{
  late  TextEditingController enterController = TextEditingController();
  FocusNode focusNode = FocusNode();
  late String textFieldText ='';
  late bool showUpload=false;
  // final controller = MultiImagePickerController(
  //     maxImages: 1,
  //     allowedImageTypes: ['png', 'jpg', 'jpeg'],
  //     withData: true,
  //     withReadStream: true,
  //     images: <ImageFile>[] // array of pre/default selected images
  // );
  final controller = MultiImagePickerController(
    maxImages: 1,
    images: <ImageFile>[], // array of pre/default selected images
    picker: (bool allowMultiple) async {
      //return await pickConvertedImages(allowMultiple);
      return await pickImagesUsingImagePicker(allowMultiple);
    },
  );
  late bool ifBiaoQin=true;
  late List bqbao=[
    ['😀','😄','😁','😆','😅','🤣','😂','🙂'],
    ['😉','😊','😇','😬','😍','😦','😘','😗'],
    ['☺','😚','😙','😏','😋','😛','😜','😫'],
    ['😝','😏','🙄','😬','🤥','😔','🤤','😴'],
    ['😎','🤓','😩','😕','😟','🙁','☹','😮'],
    ['🌹','🍎','💰','🌙','🌷','💎','🔪','👍'],
    ['👋','🤚','🖐️','👌','✌','🤞','👈','🖕'],
    ['✊','👊','🤛','🤝','🙏','💪','🙌','🤟'],
    ['🍇','🍉','🍭','🍷','🍸','🍺','🍻','🥂'],
  ];
  List<Widget> _getData(datas) {
    List<Widget> list = [];
    for (var ite = 0; ite < datas.length; ite++) {
      List<Widget> rowList = [];
      for (var item = 0; item < datas[ite].length; item++) {
        rowList.add(
            InkWell(
              onTap: (){
                enterController.text=enterController.text+datas[ite][item];
                setState(() {
                  textFieldText=enterController.text;
                });
              },
              child: Text(datas[ite][item],style: TextStyle(fontSize: 30),),
            )
        );
      }
      list.add(
        Row(
          mainAxisSize:MainAxisSize.max,
          crossAxisAlignment:CrossAxisAlignment.center,
          mainAxisAlignment:MainAxisAlignment.spaceAround,
          children: rowList,
        ),
      );
      list.add(const SizedBox(height: 10));//保留间距10
    }
    //删除按
    list.add(
        InkWell(
          onTap: (){
            String text=enterController.text;
            String entext='';
            if(text.isNotEmpty){
              List<int> runes = text.runes.toList();
              runes.removeLast();
              runes.forEach((rune) {
                var character = String.fromCharCode(rune);
                entext += character;
              });
            }
            enterController.text=entext;
            setState(() {
              textFieldText=enterController.text;
            });
          },
          child: Container(
            alignment: Alignment.centerRight,
            child: Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4)
              ),
              child: Icon(Icons.keyboard_backspace,size: 32,color: BaseColors.gray8,),
            ),
          ),
        )
    );
    return list;
  }
  @override
  void initState() {
    var baseStore = Provider.of<BaseStore>(
      context,
      listen: false,
    );
    var oldEnter=baseStore.onEnterText;
    enterController.text=oldEnter[widget.groupKey]??'';
    textFieldText=oldEnter[widget.groupKey]??'';
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          ifBiaoQin=true;
        });
      }else{
        setState(() {
          ifBiaoQin=true;
        });

      }
    });
    enterController.addListener(() {
      oldEnter[widget.groupKey]=enterController.text;
      baseStore.setEnterText=oldEnter;
    });
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context){


    return Container(
        padding: const EdgeInsets.all(8),
        margin: EdgeInsets.only(bottom: (Platform.isAndroid || Platform.isWindows)?0:40.0),
        decoration: const BoxDecoration(
            color:  BaseColors.gray4
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5.0,bottom:2),
                    height: 35.0,
                    width: 30.0,
                    child: IconButton(
                      padding: const EdgeInsets.all(0.0),
                      //color: themeData.primaryColor,
                      icon:  const Icon(myIcon.huaTong),
                      onPressed: (){
                        showToast('暂未开通',duration: const Duration(seconds: 2));
                      },
                    )
                ),
                Expanded(
                    child:Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          constraints: const BoxConstraints(
                            maxHeight: 130.0,
                            minHeight: 40.0,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          ),
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 10.0, bottom: 8.0),
                          child: TextField(
                            controller: enterController,
                            focusNode: focusNode,
                            maxLines: null,
                            cursorWidth: 1,
                            textInputAction: TextInputAction.next,
                            restorationId: 'username_text_field',
                            style: const TextStyle(fontSize: 16),
                            decoration: const InputDecoration.collapsed(
                              hintText:'',
                            ),
                            onChanged: (text){
                              setState(() {
                                textFieldText=text;
                                showUpload=false;
                              });
                            },
                            onSubmitted: (text){
                              if(textFieldText!=''){
                                sendMessage(textFieldText);
                                setState(() {
                                  textFieldText='';
                                  enterController.text='';
                                });
                              }
                            },
                          ),
                        ),
                        widget.yydata['id']!=null?Container(
                            margin: const EdgeInsets.only(right: 8,top: 5),
                            padding: const EdgeInsets.only(left: 10.0, right: 4.0, top: 5.0, bottom: 5.0),
                            decoration: BoxDecoration(
                                color: BaseColors.gray5,
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: textFieldText!=''?MediaQuery.of(context).size.width-160:MediaQuery.of(context).size.width-125,//160
                                  child: Text('${widget.yydata['senduser']['name']}：${widget.yydata['text']}',style: TextStyle(color: BaseColors.gray8,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                ),
                                InkWell(
                                  onTap: (){
                                    widget.cleanYydata();
                                  },
                                  child: const Icon(Icons.clear,size: 14,),
                                )
                              ],
                            )
                        ):const SizedBox(height: 0)
                      ],
                    )
                ),
                Container(
                    margin: const EdgeInsets.only(right: 10.0,bottom:2),
                    height: 35.0,
                    width: 30.0,
                    child: IconButton(
                      padding: const EdgeInsets.all(0.0),
                      //color: themeData.primaryColor,
                      icon: ifBiaoQin==false?const Icon(myIcon.keybord):const Icon(myIcon.biaoqing),
                      onPressed: (){
                        if(ifBiaoQin){
                          FocusScope.of(context).unfocus();
                          //FocusScope.of(context).
                          Future.delayed(const Duration(milliseconds: 100), () {
                            setState(() {
                              ifBiaoQin=!ifBiaoQin;
                              showUpload=false;
                            });
                          });
                        }else{
                          FocusScope.of(context).requestFocus();
                          setState(() {
                            ifBiaoQin=!ifBiaoQin;
                            showUpload=false;
                          });
                        }
                      },
                    )
                ),
                Container(
                  margin: const EdgeInsets.only(bottom:2),
                  child:textFieldText!=''? SizedBox(
                      width: 64,
                      height: 36,
                      child: MaterialButton(
                        splashColor: Colors.pink,
                        color: BaseColors.blueBase,
                        textColor: Colors.white,
                        minWidth: MediaQuery.of(context).size.width / 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        child: const Text('发送',style: TextStyle(fontSize: 14),),
                        onPressed: () {
                          if(textFieldText!=''){
                            sendMessage(textFieldText);
                            setState(() {
                              textFieldText='';
                              enterController.text='';
                              ifBiaoQin=true;
                            });
                            widget.cleanYydata();
                          }
                        },
                      )
                  ):SizedBox(
                      height: 35.0,
                      width: 30.0,
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        //color: themeData.primaryColor,
                        icon: const Icon(myIcon.qita),
                        onPressed: (){
                          setState(() {
                            showUpload=!showUpload;
                            ifBiaoQin=true;
                          });
                        },
                      )
                  ),
                ),

              ],
            ),

            Offstage(
              offstage: ifBiaoQin,
              child: Container(
                height: 260.0,
                width: double.infinity,
                //color: Colors.greenAccent,
                padding: const EdgeInsets.all(8),
                //margin: const EdgeInsets.all(8),
                // child: Column(
                //   mainAxisSize: MainAxisSize.max,
                //   crossAxisAlignment : CrossAxisAlignment.center,
                //   children: _getData(bqbao),
                // )
                child: ListView.builder(
                  reverse: false,
                  itemCount: bqbao.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisSize:MainAxisSize.max,
                        crossAxisAlignment:CrossAxisAlignment.center,
                        mainAxisAlignment:MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: (){
                              enterController.text=enterController.text+bqbao[index][0];
                              setState(() {
                                textFieldText=enterController.text;
                              });
                            },
                            child: Text(bqbao[index][0],style: TextStyle(fontSize: 24),),
                          ),
                          InkWell(
                            onTap: (){
                              enterController.text=enterController.text+bqbao[index][1];
                              setState(() {
                                textFieldText=enterController.text;
                              });
                            },
                            child: Text(bqbao[index][1],style: TextStyle(fontSize: 24),),
                          ),
                          InkWell(
                            onTap: (){
                              enterController.text=enterController.text+bqbao[index][2];
                              setState(() {
                                textFieldText=enterController.text;
                              });
                            },
                            child: Text(bqbao[index][2],style: TextStyle(fontSize: 24),),
                          ),
                          InkWell(
                            onTap: (){
                              enterController.text=enterController.text+bqbao[index][3];
                              setState(() {
                                textFieldText=enterController.text;
                              });
                            },
                            child: Text(bqbao[index][3],style: TextStyle(fontSize: 24),),
                          ),
                          InkWell(
                            onTap: (){
                              enterController.text=enterController.text+bqbao[index][4];
                              setState(() {
                                textFieldText=enterController.text;
                              });
                            },
                            child: Text(bqbao[index][4],style: TextStyle(fontSize: 24),),
                          ),
                          InkWell(
                            onTap: (){
                              enterController.text=enterController.text+bqbao[index][5];
                              setState(() {
                                textFieldText=enterController.text;
                              });
                            },
                            child: Text(bqbao[index][5],style: TextStyle(fontSize: 24),),
                          ),
                          InkWell(
                            onTap: (){
                              enterController.text=enterController.text+bqbao[index][6];
                              setState(() {
                                textFieldText=enterController.text;
                              });
                            },
                            child: Text(bqbao[index][6],style: TextStyle(fontSize: 24),),
                          ),
                          InkWell(
                            onTap: (){
                              enterController.text=enterController.text+bqbao[index][7];
                              setState(() {
                                textFieldText=enterController.text;
                              });
                            },
                            child: Text(bqbao[index][7],style: TextStyle(fontSize: 24),),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if(ifBiaoQin==false)SizedBox(
                height: 30.0,
                width: 30.0,
                child:FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.keyboard_backspace,color: BaseColors.gray5,),
                  onPressed: () {
                    String text=enterController.text;
                    String entext='';
                    if(text.isNotEmpty){
                      List<int> runes = text.runes.toList();
                      runes.removeLast();
                      runes.forEach((rune) {
                        var character = String.fromCharCode(rune);
                        entext += character;
                      });
                    }
                    enterController.text=entext;
                    setState(() {
                      textFieldText=enterController.text;
                    });
                  },
                )
            ),
            if(showUpload) Row(
              children: [
                Container(
                    height: 60.0,
                    width: 60.0,
                    //color: Colors.greenAccent,
                    //padding: EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.only(right: 4),
                      //color: themeData.primaryColor,
                      icon: const Icon(myIcon.tupian),
                      onPressed: (){
                          MobileImageSelection('gallery');
                      },
                    )
                ),

                Container(
                      height: 60.0,
                      width: 60.0,
                      //color: Colors.greenAccent,
                      //padding: EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        //color: themeData.primaryColor,
                        icon: const Icon(myIcon.xiangji),
                        onPressed: (){
                            MobileImageSelection('camera');
                        },
                      )
                  ),
                Container(
                    height: 60.0,
                    width: 60.0,
                    //color: Colors.greenAccent,
                    //padding: EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.only(right: 4),
                      //color: themeData.primaryColor,
                      icon: const Icon(myIcon.wenjian),
                      onPressed: (){
                        setState(() {
                          MobileFileSelection();
                        });
                      },
                    )
                ),
              ],
            ),

          ],
        )
    );
  }
  ///普通文本消息
  void sendMessage(String message){
    var mid=const Uuid().v4();
    var time=DateTime.now().millisecondsSinceEpoch;
    final sendMessage = ChatMessage(
      createdAt:time,
      type:'text',
      status: types.Status.sending,
      id:mid,
      text:message,
      data:{'yydata':widget.yydata} ,
    );
    final mess = types.TextMessage(
      author: widget.senduser,
      createdAt: time,
      id: mid,
      metadata:{'time':time,'yydata':widget.yydata},
      status: types.Status.sending,
      text: message,
      //type: data['data']['type'],
      //type: types.MessageType.system,
    );
    widget.addMessage(mess);
    widget.sendMessage(sendMessage);
  }
  ///发送图片
  Future<void> MobileImageSelection(fangshi) async {
    if (!mounted) return;
    var baseStore = Provider.of<BaseStore>(
      context,
      listen: false,
    );
    final result;
    if(fangshi=='camera'){
      result = await ImagePicker().pickImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.camera,
      );
    }else{
      result = await ImagePicker().pickImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.gallery,
      );
    }
    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      var mid=const Uuid().v4();
      var time=DateTime.now().millisecondsSinceEpoch;
      final message = types.ImageMessage(
        author: widget.senduser,
        createdAt: time,
        height: image.height.toDouble(),
        id: mid,
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );
      widget.addMessage(message);
      FormData formdata = FormData.fromMap({
        'loginKey': baseStore.loginKey,
        'keyid': baseStore.userData.keyid,
        "upload": await MultipartFile.fromFile(result.path)
      });
      HttpUtils.post(path: '/api/home/common/upload',
          data: formdata).then((value) async {
        if (value['code'] == 200) {
          String imgUrl = value['data']['url'];
          final sendMessage = ChatMessage(
            createdAt: time,
            type: 'image',
            status: types.Status.sending,
            id: mid,
            text: '图片',
            data: {
              'uri': imgUrl,
              'name': result.name,
              'size': bytes.length,
              'width': image.width.toDouble(),
              'time':time
            },
          );
          widget.sendMessage(sendMessage);
          setState(() {
            showUpload=false;
          });
          //controller.dispose();
        } else {
          //showToast(value['message']);
        }
      }).catchError((error) {
        print('报错信息：$error');
      });

    }

  }
  ///发送文件
  Future<void> MobileFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null && result.files.single.path != null) {
      var mid=const Uuid().v4();
      var time=DateTime.now().millisecondsSinceEpoch;
      final message = types.FileMessage(
        author: widget.senduser,
        createdAt: time,
        id: mid,
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );
      widget.addMessage(message);
      FormData formdata = FormData.fromMap({
        "upload": await MultipartFile.fromFile(result.files.single.path!, filename:result.files.single.name)
      });
      await HttpUtils.post(path:'/api/home/common/uploadfile',data:formdata).then((value) async {
        if(value['code']==200){
          String fileUrl=value['data']['url'];
          final sendMessage = ChatMessage(
            createdAt:time,
            type:'file',
            status: types.Status.sending,
            id:mid,
            text:'文件',
            data:{
              'uri':fileUrl,
              'name':result.files.single.name,
              'size':result.files.single.size,
              'mimeType': lookupMimeType(result.files.single.path!),
              'time':time
            } ,
          );
          widget.sendMessage(sendMessage);
          setState(() {
            showUpload=false;
          });
        }else{
          //print('报错信息：$error');
        }
      }).catchError((error) {
        print('报错信息：$error');
      });
    }
  }

}


//通过 Overlay 实现 Toast
class Toast {
  static void show({required BuildContext context, required String message}) {
    //1、创建 overlayEntry
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery
              .of(context)
              .size
              .height * 0.8,
          child: Material(
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              alignment: Alignment.center,
              child: Center(
                child: Card(
                  color: Colors.grey.withOpacity(0.6),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child:  Text(message),
                  ),
                ),
              ),
            ),
          ));
    });
    //插入到 Overlay中显示 OverlayEntry
    Overlay.of(context).insert(overlayEntry);
    //延时两秒，移除 OverlayEntry
    Future.delayed(const Duration(seconds: 10)).then((value) {
      overlayEntry.remove();
    }
    );
  }
}