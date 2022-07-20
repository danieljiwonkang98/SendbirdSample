import 'package:flutter/material.dart';

enum DialogType {
  oneButton,
  twoButton,
}

Future<void> dialogComponent(
  BuildContext context, {
  DialogType type = DialogType.twoButton,
  String? title,
  String? content,
  Function? onTap1,
  String? buttonText1,
  Function? onTap2,
  String? buttonText2,
}) async {
  switch (type) {
    case DialogType.oneButton:
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title == null ? null : Text(title),
            content: content == null ? null : Text(content),
            actions: <Widget>[
              TextButton(
                child: Text(buttonText1 ?? 'Approve'),
                onPressed: () => onTap1,
              ),
            ],
          );
        },
      );
    case DialogType.twoButton:
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title == null ? null : Text(title),
            content: content == null ? null : Text(content),
            actions: <Widget>[
              TextButton(
                child: Text(buttonText1 ?? 'Approve'),
                onPressed: () => onTap1,
              ),
              TextButton(
                child: Text(buttonText2 ?? 'Cancel'),
                onPressed: () => onTap2,
              ),
            ],
          );
        },
      );
  }
}
