import 'package:app/components/app_bar.dart';
import 'package:app/components/dialog.dart';
import 'package:app/components/message_field.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/requests/message_requests.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

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

  @override
  void initState() {
    _scrollController = ScrollController();
    _messageController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<List<BaseMessage>> _initialize() async {
    try {
      if (_channelUrl == null) throw Exception('ChannelUrl is Null');
      List<BaseMessage> messageList = await PreviousMessageListQuery(
              channelType: _channelType, channelUrl: _channelUrl!)
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

      return messageList;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    setState(() {});
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
      future: _initialize(),
      builder:
          (BuildContext context, AsyncSnapshot<List<BaseMessage>> messages) {
        if (messages.hasData) {
          _scrollToBottom();
          return Scaffold(
            appBar: appBarComponent(
                title: 'Chat Room',
                includeLeading: false,
                actions: [_infoButton()]),
            bottomNavigationBar: messageField(
              _messageController,
              context: context,
              channel: _channel!,
              onSend: refresh,
            ),
            body: SingleChildScrollView(
              physics: const ScrollPhysics(),
              controller: _scrollController,
              child: paddingComponent(
                widget: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: messages.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      isThreeLine: true,
                      leading: messages.data?[index].sender?.userId ==
                              _authentication.currentUser?.userId
                          ? null
                          : const Icon(Icons.person),
                      trailing: messages.data?[index].sender?.userId ==
                              _authentication.currentUser?.userId
                          ? const Icon(Icons.person)
                          : null,
                      title: Text(
                        messages.data?[index].message ?? 'Empty Text',
                        textAlign: messages.data?[index].sender?.userId ==
                                _authentication.currentUser?.userId
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                      subtitle: _channel!.channelType == ChannelType.group
                          ? Text(
                              'Unread ${(_channel as GroupChannel).getUnreadMembers(messages.data![index]).length}',
                              textAlign: messages.data?[index].sender?.userId ==
                                      _authentication.currentUser?.userId
                                  ? TextAlign.right
                                  : TextAlign.left,
                            )
                          : null,
                      onLongPress: () {
                        dialogComponent(
                          context,
                          buttonText1: 'Edit',
                          onTap1: () {},
                          buttonText2: 'Delete',
                          onTap2: () async {
                            await deleteMessage(
                              channel: _channel,
                              messageId: messages.data![index].messageId,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
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
