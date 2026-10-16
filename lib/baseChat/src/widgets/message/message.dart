import 'package:context_menus/context_menus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:oktoast/oktoast.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:yewswt/baseChat/src/widgets/message/system_message.dart';
import 'package:yewswt/baseChat/src/widgets/message/user_name.dart';
import 'package:yewswt/data/colors.dart';

import '../../../../pages/student/student_show.dart';
import '../../conditional/conditional.dart';
import '../../models/bubble_rtl_alignment.dart';
import '../../models/emoji_enlargement_behavior.dart';
import '../../util.dart';
import '../state/inherited_chat_theme.dart';
import '../state/inherited_user.dart';
import 'chatMobile_message.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'message_status.dart';
import 'text_message.dart';
import 'user_avatar.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type.
  const Message({
    super.key,
    this.audioMessageBuilder,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.bubbleRtlAlignment,
    this.customMessageBuilder,
    this.customStatusBuilder,
    required this.emojiEnlargementBehavior,
    this.fileMessageBuilder,
    required this.hideBackgroundOnEmojiMessages,
    this.imageHeaders,
    this.imageMessageBuilder,
    this.imageProviderBuilder,
    required this.message,
    required this.messageWidth,
    this.nameBuilder,
    this.onAvatarTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageSd,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.isLeftStatus,
    required this.showUserAvatars,
    this.textMessageBuilder,
    required this.textMessageOptions,
    required this.usePreviewData,
    this.userAgent,
    this.videoMessageBuilder,
  });

  /// Build an audio message inside predefined bubble.
  final Widget Function(types.AudioMessage, {required int messageWidth})?
      audioMessageBuilder;

  /// This is to allow custom user avatar builder
  /// By using this we can fetch newest user info based on id.
  final Widget Function(types.User author)? avatarBuilder;

  /// Customize the default bubble using this function. `child` is a content
  /// you should render inside your bubble, `message` is a current message
  /// (contains `author` inside) and `nextMessageInGroup` allows you to see
  /// if the message is a part of a group (messages are grouped when written
  /// in quick succession by the same author).
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Determine the alignment of the bubble for RTL languages. Has no effect
  /// for the LTR languages.
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// Build a custom message inside predefined bubble.
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// Build a custom status widgets.
  final Widget Function(types.Message message, {required BuildContext context})?
      customStatusBuilder;

  /// Controls the enlargement behavior of the emojis in the
  /// [types.TextMessage].
  /// Defaults to [EmojiEnlargementBehavior.multi].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Build a file message inside predefined bubble.
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Hide background for messages containing only emojis.
  final bool hideBackgroundOnEmojiMessages;

  /// See [Chat.imageHeaders].
  final Map<String, String>? imageHeaders;

  /// Build an image message inside predefined bubble.
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// See [Chat.imageProviderBuilder].
  final ImageProvider Function({
    required String uri,
    required Map<String, String>? imageHeaders,
    required Conditional conditional,
  })? imageProviderBuilder;

  /// Any message type.
  final types.Message message;

  /// Maximum message width.
  final int messageWidth;

  /// See [TextMessage.nameBuilder].
  final Widget Function(types.User)? nameBuilder;

  /// See [UserAvatar.onAvatarTap].
  final void Function(types.User)? onAvatarTap;

  /// Called when user double taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;
  final void Function(BuildContext context, types.Message,int)? onMessageSd;

  /// Called when user makes a long press on any message.
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// Called when user makes a long press on status icon in any message.
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// Called when user taps on status icon in any message.
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// Called when user taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageTap;

  /// Called when the message's visibility changes.
  final void Function(types.Message, bool visible)? onMessageVisibilityChanged;

  /// See [TextMessage.onPreviewDataFetched].
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  /// See [TextMessage.showName].
  final bool showName;

  /// Show message's status.
  final bool showStatus;

  /// This is used to determine if the status icon should be on the left or
  /// right side of the message.
  /// This is only used when [showStatus] is true.
  /// Defaults to false.
  final bool isLeftStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  /// Build a text message inside predefined bubble.
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [TextMessage.options].
  final TextMessageOptions textMessageOptions;

  /// See [TextMessage.usePreviewData].
  final bool usePreviewData;

  /// See [TextMessage.userAgent].
  final String? userAgent;

  /// Build an audio message inside predefined bubble.
  final Widget Function(types.VideoMessage, {required int messageWidth})?
      videoMessageBuilder;

  Widget _avatarBuilder() =>
       avatarBuilder?.call(message.author) ??
          UserAvatar(
            author: message.author,
            bubbleRtlAlignment: bubbleRtlAlignment,
            imageHeaders: imageHeaders,
            onAvatarTap: onAvatarTap,
          )
      ;

  Widget _bubbleBuilder(
    BuildContext context,
    BorderRadius borderRadius,
    bool currentUserIsAuthor,
    bool enlargeEmojis,
  ) =>ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            "复制",
            icon: const Icon(Icons.file_copy_outlined),
            onPressed: () => onMessageSd!(context, message,4),
          ),
          ContextMenuButtonConfig(
            "引用",
            icon: const Icon(Icons.alternate_email_outlined),
            onPressed: () => onMessageSd!(context, message,5),
          ),
          if(message.metadata?['userkey']==InheritedUser.of(context).user.id && message.metadata?['class']==2 && message.metadata?['status']==3)ContextMenuButtonConfig(
            "反馈",
            icon: const Icon(Icons.chat),
            onPressed: () => onMessageSd!(context, message,7),
          ), //DateTime.now().millisecondsSinceEpoch
          if(message.metadata?['time']!=null && DateTime.now().millisecondsSinceEpoch-message.metadata?['time']<300000 && message.author.id==InheritedUser.of(context).user.id && message.metadata?['status']!=null && message.metadata?['status']<2)ContextMenuButtonConfig(
            "撤回",
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => onMessageSd!(context, message,6),
          ),

        ],
      ),
      child:
      bubbleBuilder != null
          ? bubbleBuilder!(
        _messageBuilder(context),
        message: message,
        nextMessageInGroup: roundBorder,
      )
          : enlargeEmojis && hideBackgroundOnEmojiMessages
          ? _messageBuilder(context)
          : Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          //color: Colors.white,
          // color: !currentUserIsAuthor ||
          //         message.type == types.MessageType.image
          //     ? InheritedChatTheme.of(context).theme.secondaryColor
          //     : InheritedChatTheme.of(context).theme.primaryColor,
          color: !currentUserIsAuthor ||
              message.type == types.MessageType.image
              ? Colors.white
              : BaseColors.blue2,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: _messageBuilder(context),
        ),
      )
  );

  Widget _messageBuilder(BuildContext context) {
    switch (message.type) {
      case types.MessageType.audio:
        final audioMessage = message as types.AudioMessage;
        return audioMessageBuilder != null
            ? audioMessageBuilder!(audioMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.custom:
        final customMessage = message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.file:
        final fileMessage = message as types.FileMessage;
        return fileMessageBuilder != null
            ? fileMessageBuilder!(fileMessage, messageWidth: messageWidth)
            : FileMessage(message: fileMessage);
      case types.MessageType.image:
        final imageMessage = message as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: messageWidth)
            : ImageMessage(
                imageHeaders: imageHeaders,
                imageProviderBuilder: imageProviderBuilder,
                message: imageMessage,
                messageWidth: messageWidth,
              );
      case types.MessageType.text:
        final textMessage = message as types.TextMessage;
        return textMessageBuilder != null
            ? textMessageBuilder!(
                textMessage,
                messageWidth: messageWidth,
                showName: showName,
              )
            : TextMessage(
                emojiEnlargementBehavior: emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
                message: textMessage,
                nameBuilder: nameBuilder,
                onPreviewDataFetched: onPreviewDataFetched,
                options: textMessageOptions,
                showName: showName,
                usePreviewData: usePreviewData,
                userAgent: userAgent,
              );
      case types.MessageType.system:
        //final user = InheritedUser.of(context).user;
        final textMessage = message as types.TextMessage;
        final shiCha=getVerboseDateTimeCha(message.metadata?['time'],message.metadata?['time']);
        var logs=[];
        if(message.metadata?['time']!=null && message.metadata?['time'] >= 1692078318000 && message.metadata?['data']['sendtype']!=null) {
          logs = message.metadata?['data']['logs']??[];
        }
        return textMessageBuilder != null
            ? textMessageBuilder!(
          textMessage,
          messageWidth: messageWidth,
          showName: showName,
        )
            : ChatMobileMessage(message:message,messageWidth: messageWidth,showName: showName,onMessageSd:onMessageSd);

      case types.MessageType.video:
        final videoMessage = message as types.VideoMessage;
        return videoMessageBuilder != null
            ? videoMessageBuilder!(videoMessage, messageWidth: messageWidth)
            : const SizedBox();
      default:
        return const SizedBox();
    }
  }

  Widget _statusIcon(
    BuildContext context,
  ) {
    if (!showStatus) return const SizedBox.shrink();

    return Padding(
      padding: InheritedChatTheme.of(context).theme.statusIconPadding,
      child: GestureDetector(
        onLongPress: () => onMessageStatusLongPress?.call(context, message),
        onTap: () => onMessageStatusTap?.call(context, message),
        child: customStatusBuilder != null
            ? customStatusBuilder!(message, context: context)
            : MessageStatus(status: message.status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final user = InheritedUser.of(context).user;
    final currentUserIsAuthor = user.id == message.author.id;
    final enlargeEmojis =
        emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            message is types.TextMessage &&
            isConsistsOfEmojis(
              emojiEnlargementBehavior,
              message as types.TextMessage,
            );
    final messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    final borderRadius = bubbleRtlAlignment == BubbleRtlAlignment.left
        ? BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(
              !currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
            ),
            bottomStart: Radius.circular(
              currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
            ),
            topEnd: Radius.circular(messageBorderRadius),
            topStart: Radius.circular(messageBorderRadius),
          )
        : BorderRadius.only(
            // bottomLeft: Radius.circular(
            //   currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
            // ),
            // bottomRight: Radius.circular(
            //   !currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
            // ),
            // topLeft: Radius.circular(messageBorderRadius),
            // topRight: Radius.circular(messageBorderRadius),
            topLeft: Radius.circular(
              currentUserIsAuthor  ? messageBorderRadius : 0,
            ),
            topRight: Radius.circular(
              !currentUserIsAuthor  ? messageBorderRadius : 0,
            ),
            bottomLeft: Radius.circular(messageBorderRadius),
            bottomRight: Radius.circular(messageBorderRadius),
          );

    return message.metadata?['status']==4?Container(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
              color: Colors.black12
          ),
          child: Text( '${message.author.firstName} 撤回一条消息',style: const TextStyle(fontSize: 12,color: Colors.black45),),
        )
    ):Container(
      alignment: bubbleRtlAlignment == BubbleRtlAlignment.left
          ? currentUserIsAuthor
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart
          : currentUserIsAuthor
          ? Alignment.centerRight
          : Alignment.centerLeft,
      margin: bubbleRtlAlignment == BubbleRtlAlignment.left
          ? EdgeInsetsDirectional.only(
        bottom: 4,
        end: isMobile ? query.padding.right : 0,
        start: 10 + (isMobile ? query.padding.left : 0),
      )
          : EdgeInsets.only(
        bottom: 4,
        left: 10 + (isMobile ? query.padding.left : 0),
        right: isMobile ? query.padding.right : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        textDirection: bubbleRtlAlignment == BubbleRtlAlignment.left
            ? null
            : TextDirection.ltr,
        children: [
          if (!currentUserIsAuthor && showUserAvatars) _avatarBuilder(),
          const SizedBox(width: 5,),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: messageWidth.toDouble(),
            ),
            child: Column(
              crossAxisAlignment: currentUserIsAuthor?CrossAxisAlignment.end:CrossAxisAlignment.start,
              children: [
                UserName(author: message.author),
                GestureDetector(
                  onDoubleTap: () => onMessageDoubleTap?.call(context, message),
                  onLongPress: () => onMessageLongPress?.call(context, message),
                  onTap: () => {
                    if(message.metadata?['userkey']==InheritedUser.of(context).user.id && message.metadata?['class']==2 && message.metadata?['status']==3){
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context){
                                  return StudentShowPage(key: UniqueKey(),student:message.metadata);
                              }
                          )
                      )
                    }else{
                      onMessageTap?.call(context, message)
                    }
                  },
                  child: onMessageVisibilityChanged != null
                      ? VisibilityDetector(
                    key: Key(message.id),
                    onVisibilityChanged: (visibilityInfo) =>
                        onMessageVisibilityChanged!(
                          message,
                          visibilityInfo.visibleFraction > 0.1,
                        ),
                    child: _bubbleBuilder(
                      context,
                      borderRadius.resolve(Directionality.of(context)),
                      currentUserIsAuthor,
                      enlargeEmojis,
                    ),
                  )
                      : _bubbleBuilder(
                    context,
                    borderRadius.resolve(Directionality.of(context)),
                    currentUserIsAuthor,
                    enlargeEmojis,
                  ),
                ),
                message.metadata?['data']!=null && message.metadata?['data'].isNotEmpty && message.metadata?['data']['yydata']!=null && message.metadata?['data']['yydata'].isNotEmpty?
                (message.metadata?['data']['yydata']['type']=='image' || message.metadata?['data']['yydata']['type']=='file')?Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        //width: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xffE8E8E8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          //mainAxisAlignment : MainAxisAlignment.end,
                          children: [
                            Text('${message.metadata?['data']['yydata']['senduser']['name']}：'),
                            _yymessageBuilder(context,message.metadata?['data']['yydata'])
                          ],
                        )

                    )
                  ],
                ):Container(
                    //color: Colors.white,
                    padding: const EdgeInsets.all(10),
                    //width: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xffE8E8E8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:Column(
                      children: [
                        Text('${message.metadata?['data']['yydata']['senduser']['type']==4?'张老师':message.metadata?['data']['yydata']['senduser']['name']}：${message.metadata?['data']['yydata']['text']}',style: const TextStyle(color: Color(0xff555555)),),
                        if(message.metadata?['data']['yydata']['class']==2)TextButton(
                            onPressed: (){
                              if(user.metadata?['type']>=4 || message.metadata?['data']['yydata']['sendkey']==user.id) {
                                Clipboard.setData(ClipboardData(text: message.metadata?['data']['yydata']['data']['tel']??'无'));
                                showToast('复制成功',duration: const Duration(seconds: 1));
                              }else{
                                showToast('不是你的学生不能复制！',duration: const Duration(seconds: 1));
                              }
                            },
                            child:  const Text('复制电话',style: TextStyle(color: Colors.blue,fontSize: 14))
                        ),
                      ],
                    )
                ):const SizedBox(height: 0,),
              ],
            ),
          ),
          if (currentUserIsAuthor)
            Padding(
              padding: InheritedChatTheme.of(context).theme.statusIconPadding,
              child: showStatus
                  ? GestureDetector(
                onLongPress: () =>
                    onMessageStatusLongPress?.call(context, message),
                onTap: () => onMessageStatusTap?.call(context, message),
                child: customStatusBuilder != null
                    ? customStatusBuilder!(message, context: context)
                    : MessageStatus(status: message.status),
              )
                  : null,
            ),
          if (currentUserIsAuthor && showUserAvatars) _avatarBuilder(),
        ],
      ),
    );
  }
  ///引用数据
  Widget _yymessageBuilder(context,data) {
    switch (data['type']) {
      case 'audio':
        final audioMessage = message as types.AudioMessage;
        return audioMessageBuilder != null
            ? audioMessageBuilder!(audioMessage, messageWidth: messageWidth)
            : const SizedBox();
      case 'custom':
        final customMessage = message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage, messageWidth: messageWidth)
            : const SizedBox();
      case 'file':
        final fileMessage=types.FileMessage(
          author: message.author,
          createdAt: data['time'],
          id: data['tallkey'],
          metadata:data,
          mimeType: data['data']['mimeType']??'',
          name: data['data']['name']??'',
          size: data['data']['size']??0,
          uri: data['data']['uri']??'',
        );
        return fileMessageBuilder != null
            ? fileMessageBuilder!(fileMessage, messageWidth: messageWidth)
            : FileMessage(message: fileMessage);
      case 'image':
        final imageMessage = types.ImageMessage(
          author: message.author,
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
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: 40)
            : ImageMessage(
          imageHeaders: imageHeaders,
          message: imageMessage,
          messageWidth: 40,
        );
      case 'text':
        final textMessage = types.TextMessage(
          author: message.author,
          createdAt: data['time'],
          id: data['tallkey'],
          metadata:data,
          //status: types.Status.sending,
          showStatus:true,
          text: data['text'],
          //type: data['data']['type'],
          //type: types.text
        );
        return textMessageBuilder != null
            ? textMessageBuilder!(
          textMessage,
          messageWidth: messageWidth,
          showName: showName,
        )
            : TextMessage(
          emojiEnlargementBehavior: emojiEnlargementBehavior,
          hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
          message: textMessage,
          nameBuilder: nameBuilder,
          onPreviewDataFetched: onPreviewDataFetched,
          options: textMessageOptions,
          showName: showName,
          usePreviewData: usePreviewData,
          userAgent: userAgent,
        );
      case 'system':
        final textMessage=types.TextMessage(
          author: message.author,
          createdAt: data['time'],
          id: data['tallkey'],
          metadata:data,
          //status: seen,
          text: data['text'],
          //type: data['data']['type'],
          type: types.MessageType.system,
        );
        return textMessageBuilder != null
            ? textMessageBuilder!(
          textMessage,
          messageWidth: messageWidth,
          showName: showName,
        )
            : SystemMessage(
          message: textMessage.text,
        );
      case 'video':
        final videoMessage = message as types.VideoMessage;
        return videoMessageBuilder != null
            ? videoMessageBuilder!(videoMessage, messageWidth: messageWidth)
            : const SizedBox();
      default:
        return const SizedBox();
    }
  }
}
