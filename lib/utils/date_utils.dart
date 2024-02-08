import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/theme_constants.dart';

const formatDate = 'dd-MM-yyyy';
const formatDateHour = 'dd-MM-yyyy HH:mm:ss';
const formatDateBackendCompatible = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

String parseDateTimeOnFormat(DateTime dt) {
  return DateFormat(formatDate).format(dt);
}

String formatDateTime(DateTime dt, String formatDate) {
  // Formatea el DateTime en la cadena de fecha y hora deseada
  DateFormat format = DateFormat(formatDate);
  return format.format(dt);
}

String parseDateTimeOnFormatHour(DateTime? dt) {
  if (dt == null) {
    return "";
  }
  DateFormat format = DateFormat(formatDateHour);
  return format.format(dt);
}

String parseDateTime(DateTime? dt) {
  if (dt == null) {
    return "";
  }
  DateFormat format = DateFormat(formatDate);
  return format.format(dt);
}

// String formattedDate(String dateString) {
//   DateFormat inputFormat = DateFormat(formatDate);
//   DateTime date = inputFormat.parse(dateString);
//
//   String formattedDate = date.toLocal().toIso8601String();
//   return formattedDate;
// }

String formattedDate(String dateString) {
  print('dateString: ' + dateString);
  // Define el formato de entrada de la fecha
  DateFormat inputFormat = DateFormat(formatDate);

  // Analiza la cadena de fecha en un objeto DateTime
  DateTime date = inputFormat.parse(dateString);

  // Crea un objeto de zona horaria para Uruguay (UTC-3)
  final uruguayTimeZone = DateTime.now().timeZoneOffset;
  final uruguayOffset = Duration(hours: uruguayTimeZone.inHours);

  // Ajusta la zona horaria a Uruguay (UTC-3)
  DateTime uruguayDateTime = date.add(uruguayOffset);

  // Formatea la fecha en el formato deseado
  DateFormat outputFormat = DateFormat(formatDateBackendCompatible);
  String formattedDateStr = outputFormat.format(uruguayDateTime);
  print('date parseada:' + formattedDateStr);
  return formattedDateStr;
}

String getCurrentHour() {
  DateTime now = DateTime.now();
  String formattedDateHour =
      DateFormat(formatDateBackendCompatible).format(now);
  return formattedDateHour;
}

Future<DateTime?> showCustomDatePicker(
    BuildContext context, DateTime startDate) async {
  return await showDatePicker(
    context: context,
    initialDate: startDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: primarySwatch,
          colorScheme: ColorScheme.light(
            primary: primarySwatch[200]!,
          ),
          buttonTheme: const ButtonThemeData(
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        child: child!,
      );
    },
  );
}
