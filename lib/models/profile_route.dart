import 'package:app/components/app_bar.dart';
import 'package:app/components/dialog.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileRoute extends StatefulWidget {
  const ProfileRoute({Key? key}) : super(key: key);

  @override
  ProfileRouteState createState() => ProfileRouteState();
}

class ProfileRouteState extends State<ProfileRoute> {
  late final BaseAuth _authentication = Get.find<AuthenticationController>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(title: 'Profile', includeLeading: false),
        body: paddingComponent(
          widget: Column(
            children: [
              const Spacer(),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: _authentication.currentUser?.nickname,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () async {
                  try {
                    await _authentication.updateCurrentInfo(
                        nickName: _nameController.value.text);
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      dialogComponent(
                        context,
                        title: 'Name has been changed',
                        type: DialogType.oneButton,
                      );
                    }
                  } catch (e) {
                    printError(info: e.toString());
                  }
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () async {
                  try {
                    await _authentication.logout();
                    Get.offAllNamed('/MainRoute');
                  } catch (e) {
                    printError(info: e.toString());
                  }
                },
                child: const Text('Sign Out'),
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}
