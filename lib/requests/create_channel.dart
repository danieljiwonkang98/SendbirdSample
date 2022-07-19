import 'package:sendbird_sdk/sendbird_sdk.dart';

Future<BaseChannel> createChannel(
    {required ChannelType channelType, required dynamic channelParams}) async {
  try {
    switch (channelType) {
      case ChannelType.group:
        final params = channelParams as GroupChannelParams;
        return await GroupChannel.createChannel(params);
      case ChannelType.open:
        final params = channelParams as OpenChannelParams;
        return await OpenChannel.createChannel(params);
    }
  } catch (e) {
    rethrow;
  }
}
