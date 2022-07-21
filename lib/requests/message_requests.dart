import 'package:sendbird_sdk/sendbird_sdk.dart';

Future<void> deleteMessage({
  required channel,
  required int messageId,
}) async {
  try {
    switch (channel.channelType) {
      case ChannelType.group:
        await (channel as GroupChannel).deleteMessage(messageId);
        break;
      case ChannelType.open:
        await (channel as OpenChannel).deleteMessage(messageId);
        break;
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> editUserMessage({
  required channel,
  required int messageId,
  required params,
}) async {
  try {
    switch (channel.channelType) {
      case ChannelType.group:
        await (channel as GroupChannel).updateUserMessage(messageId, params);
        break;
      case ChannelType.open:
        await (channel as OpenChannel).updateUserMessage(messageId, params);
        break;
    }
  } catch (e) {
    rethrow;
  }
}
