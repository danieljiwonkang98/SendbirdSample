import 'package:app/components/app_bar.dart';
import 'package:app/components/message_field.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
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
  GroupChannel? _groupchannel;

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
      _groupchannel ??= await GroupChannel.getChannel(_channelUrl!);

      return await PreviousMessageListQuery(
              channelType: _channelType, channelUrl: _channelUrl!)
          .loadNext();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    setState(() {});
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
            appBar: appBarComponent(title: 'Chat Room', includeLeading: false),
            bottomNavigationBar: messageField(_messageController,
                channel: _groupchannel!, onSend: refresh),
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
                      subtitle: Text(
                        messages.data?[index].message ?? 'Empty Text',
                        textAlign: messages.data?[index].sender?.userId ==
                                _authentication.currentUser?.userId
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
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
