import 'package:app/controllers/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChannelEventHandlers with ChannelEventHandler {
  final BaseAuth _authentication = Get.find<AuthenticationController>();
  late VoidCallback? callback;
  List<BaseMessage> messages = RxList.empty(growable: true);
  String channelUrl;
  late BaseChannel channel;
  late PreviousMessageListQuery _messageListQuery;

  ChannelEventHandlers({
    VoidCallback? refresh,
    required this.channelUrl,
    required ChannelType channelType,
  }) {
    _messageListQuery = PreviousMessageListQuery(
        channelType: channelType, channelUrl: channelUrl);
    callback = refresh;
    _authentication.sendbirdSdk
        .addChannelEventHandler('ChannelEventHandler', this);
    getChannel(channelUrl, channelType: channelType);
  }

  void getChannel(String channelUrl, {required ChannelType channelType}) async {
    switch (channelType) {
      case ChannelType.group:
        channel = await GroupChannel.getChannel(channelUrl);
        (channel as GroupChannel).markAsRead();
        break;
      case ChannelType.open:
        channel = await OpenChannel.getChannel(channelUrl);
        break;
    }
  }

  void dispose() {
    _authentication.sendbirdSdk
        .removeChannelEventHandler('ChannelEventHandler');
  }

  @override
  void onReadReceiptUpdated(GroupChannel channel) {
    print('on Read');
    if (callback != null) {
      callback!();
    }
  }

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    print('on Recieve');
    if (callback != null) {
      callback!();
    }
  }

  @override
  void onMessageUpdated(BaseChannel channel, BaseMessage message) {
    print('on Update');
    if (callback != null) {
      callback!();
    }
  }

  @override
  void onMessageDeleted(BaseChannel channel, int messageId) {
    print('on Delete');
    if (callback != null) {
      callback!();
    }
  }

  Future<List<BaseMessage>> loadMessages() async {
    List<BaseMessage> messageList = await _messageListQuery.loadNext();
    for (int i = messageList.length - 1; i >= 0; i--) {
      messages.add(messageList[i]);
    }

    return messages;
  }
}
