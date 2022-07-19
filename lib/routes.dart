import 'package:app/features_example.dart/features_example_route.dart';
import 'package:app/main_example.dart/groupChannel/group_channel_route.dart';
import 'package:app/main_example.dart/main_example_route.dart';
import 'package:app/main_example.dart/openChannel/open_channel_route.dart';
import 'package:app/main_route.dart';
import 'package:app/models/chat_room_route.dart';
import 'package:app/root.dart';
import 'package:get/get.dart';

final List<GetPage> routes = [
  GetPage(name: "/MainRoute", page: () => const MainRoute()),
  GetPage(name: "/RootRoute", page: () => const RootRoute()),
  GetPage(name: "/MainExampleRoute", page: () => const MainExampleRoute()),
  GetPage(
      name: "/FeaturesExampleRoute", page: () => const FeaturesExampleRoute()),
  GetPage(name: "/GroupChannelRoute", page: () => const GroupChannelRoute()),
  GetPage(name: "/OpenChannelRoute", page: () => const OpenChannelRoute()),
  GetPage(name: "/ChatRoomRoute", page: () => const ChatRoomRoute()),
];
