import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  final double height;

  CustomBottomSheet({
    required this.child,
    this.height = 300.0, // Altura predeterminada
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          // Barra de título del modal si es necesario
          // Agrega aquí una barra de título si deseas

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context,
      {required Widget child, double height = 300.0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Esto permite que el contenido sea más alto que la pantalla
      builder: (BuildContext context) {
        return CustomBottomSheet(child: child, height: height);
      },
    );
  }
}
