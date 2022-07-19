import 'package:app/components/padding.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

Widget messageField(TextEditingController controller,
    {required GroupChannel channel, required VoidCallback onSend}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 40, left: 20),
    child: Row(
      children: [
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
                    }));
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
