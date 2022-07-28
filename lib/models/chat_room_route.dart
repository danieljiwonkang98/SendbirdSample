import 'package:app/components/app_bar.dart';
import 'package:app/components/dialog.dart';
import 'package:app/components/message_field.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/handlers/channel_event_handlers.dart';
import 'package:app/models/edit_message_route.dart';
import 'package:app/requests/message_requests.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ChatRoomRoute extends StatefulWidget {
  const ChatRoomRoute({Key? key}) : super(key: key);

  @override
  ChatRoomRouteState createState() => ChatRoomRouteState();
}

class ChatRoomRouteState extends State<ChatRoomRoute> {
  final BaseAuth _authentication = Get.find<AuthenticationController>();
  final String? _channelUrl = Get.parameters['channelUrl'];
  final ChannelType _channelType = Get.arguments[0];
  late final ScrollController _scrollController;
  late final TextEditingController _messageController;
  BaseChannel? _channel;
  List<BaseMessage> messageList = [];
  late Future<List<BaseMessage>>? _futureMessageList;
  late PreviousMessageListQuery _futureMessageListQuery;
  late final ChannelEventHandlers _channelHandler;

  @override
  void initState() {
    _scrollController = ScrollController();
    _messageController = TextEditingController();
    _channelHandler = ChannelEventHandlers(
      refresh: _refreshMessages,
      channelUrl: _channelUrl!,
      channelType: _channelType,
    );

    _futureMessageListQuery = PreviousMessageListQuery(
        channelType: _channelType, channelUrl: _channelUrl!)
      ..limit = 2;
    _futureMessageList = _loadPreviousMessage();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _channelHandler.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<List<BaseMessage>> _loadPreviousMessage() async {
    try {
      if (_channelUrl == null) throw Exception('ChannelUrl is Null');

      List<BaseMessage> messageList = await _futureMessageListQuery.loadNext();
      for (int i = messageList.length - 1; i >= 0; i--) {
        this.messageList.add(messageList[i]);
      }
      switch (_channelType) {
        case ChannelType.group:
          _channel ??= await GroupChannel.getChannel(_channelUrl!);
          (_channel as GroupChannel).markAsRead();
          break;
        case ChannelType.open:
          _channel ??= await OpenChannel.getChannel(_channelUrl!);
          break;
      }
      return messageList;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _refreshMessages() async {
    try {
      if (_channelUrl == null) throw Exception('ChannelUrl is Null');

      messageList = await (PreviousMessageListQuery(
              channelType: _channelType, channelUrl: _channelUrl!)
            ..limit = 2)
          .loadNext();

      switch (_channelType) {
        case ChannelType.group:
          _channel ??= await GroupChannel.getChannel(_channelUrl!);
          (_channel as GroupChannel).markAsRead();
          break;
        case ChannelType.open:
          _channel ??= await OpenChannel.getChannel(_channelUrl!);
          break;
      }
    } catch (e) {
      rethrow;
    }
    setState(() {});
    return;
  }

  Future<void> refresh({bool loadPrevious = false}) async {
    setState(() {
      if (loadPrevious) {
        _futureMessageList = _loadPreviousMessage();
      } else {
        _refreshMessages();
      }
    });
  }

  Widget _infoButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () {
          Get.toNamed('/ChatDetailRoute', arguments: [_channel])?.then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.info),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureMessageList,
      builder:
          (BuildContext context, AsyncSnapshot<List<BaseMessage>> messages) {
        if (messages.hasData) {
          _scrollToBottom();
          return Scaffold(
            appBar: appBarComponent(
                title: 'Chat Room',
                includeLeading: false,
                actions: [_infoButton()]),
            bottomNavigationBar: MessageField(
              controller: _messageController,
              channel: _channel!,
              onSend: refresh,
            ),
            body: LiquidPullToRefresh(
              onRefresh: () => refresh(loadPrevious: true), // refresh callback
              child: ListView(
                children: [
                  SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    controller: _scrollController,
                    child: paddingComponent(
                      widget: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: messageList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Widget? titleWidget;
                          if (messageList[index] is UserMessage) {
                            titleWidget = Text(
                              messageList[index].message,
                              textAlign: messageList[index].sender?.userId ==
                                      _authentication.currentUser?.userId
                                  ? TextAlign.right
                                  : TextAlign.left,
                            );
                          } else if (messageList[index] is FileMessage) {
                            titleWidget = Row(
                              mainAxisAlignment:
                                  messageList[index].sender?.userId ==
                                          _authentication.currentUser?.userId
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  height: 120,
                                  width: 180,
                                  fit: BoxFit.cover,
                                  imageUrl: (messageList[index] as FileMessage)
                                          .secureUrl ??
                                      (messageList[index] as FileMessage).url,
                                  placeholder: (context, url) => const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ],
                            );
                          } else {
                            printError(info: 'Unknown Message Type');
                          }
                          return ListTile(
                            isThreeLine: true,
                            leading: messageList[index].sender?.userId ==
                                    _authentication.currentUser?.userId
                                ? null
                                : const Icon(Icons.person),
                            trailing: messageList[index].sender?.userId ==
                                    _authentication.currentUser?.userId
                                ? const Icon(Icons.person)
                                : null,
                            title: titleWidget,
                            subtitle: _channel!.channelType == ChannelType.group
                                ? Text(
                                    'Unread ${(_channel as GroupChannel).getUnreadMembers(messageList[index]).length}',
                                    textAlign: messageList[index]
                                                .sender
                                                ?.userId ==
                                            _authentication.currentUser?.userId
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  )
                                : null,
                            onLongPress: () {
                              if (messageList[index] is UserMessage) {
                                dialogComponent(
                                  context,
                                  buttonText1: 'Edit',
                                  onTap1: () async {
                                    await Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: ((context) => EditMessageRoute(
                                              message: messageList[index]
                                                  as UserMessage,
                                              channel: _channel,
                                            )),
                                      ),
                                    )
                                        .then((value) async {
                                      refresh();
                                    });
                                  },
                                  buttonText2: 'Delete',
                                  onTap2: () async {
                                    await deleteMessage(
                                      channel: _channel,
                                      messageId: messageList[index].messageId,
                                    );
                                    refresh();
                                  },
                                );
                              } else if (messageList[index] is FileMessage) {
                                dialogComponent(
                                  context,
                                  type: DialogType.oneButton,
                                  buttonText1: 'Delete',
                                  onTap1: () async {
                                    await deleteMessage(
                                      channel: _channel,
                                      messageId: messageList[index].messageId,
                                    );
                                    refresh();
                                  },
                                );
                              } else {
                                printError(info: 'Unknown message type');
                              }
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (messages.hasError) {
          return const Center(
            child: Text('Error retrieving Messages'),
          );
        } else {
          return Scaffold(
            appBar: appBarComponent(title: 'Chat Room', includeLeading: false),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
