import 'package:flutter/material.dart';

enum DialogMessageType {
  success,
  error,
  warning,
}

extension DialogMessageTypeExtension on DialogMessageType {
  String get value {
    switch (this) {
      case DialogMessageType.success:
        return 'Acción Satisfactoria';
      case DialogMessageType.error:
        return 'Error';
      case DialogMessageType.warning:
        return 'Advertencia!';
    }
  }
}

class MessageDialog extends StatelessWidget {
  final DialogMessageType messageType;
  final VoidCallback onAcceptPressed;

  const MessageDialog({
    required this.messageType,
    required this.onAcceptPressed,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    String textContent;

    switch (messageType) {
      case DialogMessageType.success:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        textContent = DialogMessageType.success.value;
        break;
      case DialogMessageType.error:
        iconData = Icons.error;
        iconColor = Colors.red;
        textContent = DialogMessageType.error.value;
        break;
      case DialogMessageType.warning:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        textContent = DialogMessageType.warning.value;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Ajustar el tamaño al contenido
      children: [
        Row(
          children: [
            Icon(iconData, color: iconColor),
            SizedBox(width: 10),
            Text(textContent),
          ],
        ),
        SizedBox(height: 10),
        ElevatedButton(
          child: Text('Aceptar'),
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar el diálogo
            onAcceptPressed();
          },
        ),
      ],
    );
  }
}

Future<void> showCustomMessageDialog({
  required BuildContext context,
  required DialogMessageType messageType,
  required VoidCallback onAcceptPressed,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: MessageDialog(
          messageType: messageType,
          onAcceptPressed: onAcceptPressed,
        ),
      );
    },
  );
}
