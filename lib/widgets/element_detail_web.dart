import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/element_type.dart';
import 'package:gtau_app_front/widgets/common/button_circle.dart';

import '../constants/theme_constants.dart';
import 'common/detail_element_widget.dart';

class ElementDetailWeb extends StatefulWidget {
  final ElementType? elementType;
  final VoidCallback onPressed;

  const ElementDetailWeb(
      {Key? key, required this.elementType, required this.onPressed})
      : super(key: key);

  @override
  State<ElementDetailWeb> createState() => _ElementDetailWebState();
}

class _ElementDetailWebState extends State<ElementDetailWeb> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          color: primarySwatch[400],
          height: 50,
          child: Row(
            children: [
              ButtonCircle(
                  icon: Icons.close,
                  size: 50,
                  onPressed: () {
                    widget.onPressed();
                  }),
              Container(
                width: 250,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: Text(
                    AppLocalizations.of(context)!.component_detail_title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: lightBackground,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w300,
                        fontSize: 18)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
          width: double.infinity,
          height: screenHeight * 0.94,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DetailElementWidget(elementType: widget.elementType),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
