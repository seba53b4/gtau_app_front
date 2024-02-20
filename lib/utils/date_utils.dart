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

String parseDateTimeOnFormatHourUy(DateTime? dt) {
  if (dt == null) {
    return "";
  }
  DateFormat format = DateFormat(formatDateHour);
  DateTime utcMinus3 = dt.toUtc().add(Duration(hours: -3));
  return format.format(utcMinus3);
}

String parseDateTime(DateTime? dt) {
  if (dt == null) {
    return "";
  }
  DateFormat format = DateFormat(formatDate);
  return format.format(dt);
}

String formattedDate(String dateString) {
  // Define el formato de entrada de la fecha
  DateFormat inputFormat = DateFormat(formatDate);

  // Analiza la cadena de fecha en un objeto DateTime
  DateTime date = inputFormat.parse(dateString);

  // Convierte la fecha a la zona horaria local
  DateTime localDateTime = date.toLocal();

  // Formatea la fecha en el formato deseado
  DateFormat outputFormat = DateFormat(formatDateBackendCompatible);
  String formattedDateStr = outputFormat.format(localDateTime);
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
