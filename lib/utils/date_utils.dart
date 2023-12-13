import 'package:intl/intl.dart';

const formatDate = 'dd-MM-yyyy';
const formatDateHour = 'dd-MM-yyyy HH:mm:ss';
const formatDateBackendCompatible = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

String parseDateTimeOnFormat(DateTime dt) {
  return DateFormat(formatDate).format(dt);
}

String parseDateTimeOnFormatHour(DateTime? dt) {
  if (dt == null) {
    return "";
  }
  DateFormat format = DateFormat(formatDateHour);
  return format.format(dt);
}

String formattedDateToUpdate(String dateString) {
  DateFormat inputFormat = DateFormat(formatDate);
  DateTime date = inputFormat.parse(dateString);

  String formattedDate = date.toUtc().toIso8601String();
  return formattedDate;
}

String getCurrentHour() {
  DateTime now = DateTime.now();
  String formattedDateHour =
      DateFormat(formatDateBackendCompatible).format(now);
  return formattedDateHour;
}
