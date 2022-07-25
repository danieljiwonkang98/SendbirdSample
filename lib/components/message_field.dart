import 'dart:io';

import 'package:app/components/dialog.dart';
import 'package:app/components/padding.dart';
import 'package:app/requests/message_requests.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

Widget messageField(
  TextEditingController controller, {
  required BaseChannel channel,
  required VoidCallback onSend,
  required BuildContext context,
}) {
  final ImagePicker picker = ImagePicker();

  return Padding(
    padding: const EdgeInsets.only(bottom: 40, left: 20),
    child: Row(
      children: [
        IconButton(
          onPressed: () => dialogComponent(
            context,
            title: 'File Upload',
            content: 'Choose type to uplaod',
            buttonText1: 'Image',
            onTap1: () async {
              try {
                final _file =
                    await picker.pickImage(source: ImageSource.gallery);
                if (_file == null) {
                  throw Exception('File not chosen');
                }
                File _imageFile = File(_file.path);
                Get.back();
                // ignore: use_build_context_synchronously
                dialogComponent(
                  context,
                  title: 'Send Image?',
                  buttonText1: 'Send',
                  buttonText2: 'Cancel',
                  onTap1: () async {
                    await sendFileMessage(
                      channel: channel,
                      params: FileMessageParams.withFile(_imageFile),
                    );
                    onSend();
                  },
                );
              } catch (e) {
                rethrow;
              }
            },
            buttonText2: 'Video',
            onTap2: () async {
              try {
                final _file =
                    await picker.pickVideo(source: ImageSource.gallery);
                if (_file == null) {
                  throw Exception('File not chosen');
                }
                File _videoFile = File(_file.path);
                Get.back();
                // ignore: use_build_context_synchronously
                dialogComponent(
                  context,
                  title: 'Send Video?',
                  buttonText1: 'Send',
                  buttonText2: 'Cancel',
                  onTap1: () async {
                    await sendFileMessage(
                      channel: channel,
                      params: FileMessageParams.withFile(_videoFile),
                    );
                    onSend();
                  },
                );
              } catch (e) {
                rethrow;
              }
            },
          ),
          icon: const Icon(Icons.add),
        ),
        Expanded(
          child: TextField(
            minLines: 1,
            maxLines: 3,
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            channel.sendUserMessage(
              UserMessageParams(message: controller.value.text),
              onCompleted: ((message, error) => {
                    controller.clear(),
                    onSend(),
                  }),
            );
          },
          child: paddingComponent(
            widget: const SizedBox.square(
              dimension: 20,
              child: Icon(Icons.send),
            ),
          ),
        )
      ],
    ),
  );
}
