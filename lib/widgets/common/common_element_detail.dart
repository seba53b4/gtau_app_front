import 'package:flutter/cupertino.dart';

Widget buildInfoRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                color: Color.fromRGBO(14, 45, 9, 1),
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          Text(value ?? "Sin Datos", style: const TextStyle(fontSize: 18)),
        ],
      ),
    ),
  );
}

Widget buildInfoMultiRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                color: Color.fromRGBO(14, 45, 9, 1),
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          Text(
            value ?? "Sin Datos",
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    ),
  );
}
