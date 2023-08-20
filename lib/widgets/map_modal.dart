import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/map_component.dart';


void _showMapModal(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  double modalHeight = screenHeight * 0.8;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Modal",
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 12,
                ),
                onPressed: (){
                  Navigator.pop(context);
                }
            ),
            title: Text(
              "Modal",
              style: TextStyle(color: Colors.black87, fontFamily: 'Overpass', fontSize: 20),
            ),
            elevation: 0.0
        ),
       // backgroundColor: Colors.white.withOpacity(0.90),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: modalHeight,
                child: MapComponent(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          ),
        ),
      );
    },
  );
}


class MapModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          _showMapModal(context);
        },
        child: Text('Open Modal'),
      );
  }
}
