import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';

import '../../models/enums/message_type.dart';

class CustomToast {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    required MessageType type,
  }) {
    final scaffold = ScaffoldMessenger.of(context);
    double screenWidth = MediaQuery.of(context).size.width;

    Icon icon;

    switch (type) {
      case MessageType.error:
        icon = const Icon(Icons.error, color: Colors.white);
        backgroundColor = bucketDelete;
        break;
      case MessageType.warning:
        icon = const Icon(Icons.warning, color: Colors.white);
        backgroundColor = Colors.orange;
        break;
      case MessageType.success:
        icon = const Icon(Icons.check, color: Colors.white);
        backgroundColor = Colors.lightGreen;
        break;
    }

    scaffold.showSnackBar(
      SnackBar(
        width: kIsWeb ? 400 : screenWidth * 0.8,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        backgroundColor: backgroundColor ?? Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) // Agregar el icono si está definido
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                // Espacio entre el icono y el texto
                child: icon,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        color: textColor ?? Colors.white,
                      ),
                    ),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: duration,
      ),
    );
  }
}
