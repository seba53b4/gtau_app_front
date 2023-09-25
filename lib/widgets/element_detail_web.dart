import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/enums/element_type.dart';
import 'package:gtau_app_front/widgets/common/button_circle.dart';
import 'package:gtau_app_front/widgets/common/catchment_detail.dart';
import 'package:gtau_app_front/widgets/common/register_detail.dart';
import 'package:gtau_app_front/widgets/common/section_detail.dart';

class ElementDetailWeb extends StatefulWidget {
  final ElementType? elementType;
  final int? elementId;
  final VoidCallback onPressed;

  const ElementDetailWeb(
      {Key? key,
      required this.elementType,
      required this.elementId,
      required this.onPressed})
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
    return Column(
      children: [
        Container(
          color: const Color.fromRGBO(96, 166, 27, 1),
          height: 50,
          child: Row(
            children: [
              ButtonCircle(
                  icon: Icons.close,
                  onPressed: () {
                    widget.onPressed();
                  }),
              Container(
                width: 250,
                alignment: Alignment.center, // Esto centrará el contenido
                child: const Text("Detalle del Elemento",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(14, 45, 9, 1),
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
            ],
          ),
        ),
        Column(
          children: [
            DetailWidget(elementType: widget.elementType),
          ],
        )
      ],
    );
  }
}

class DetailWidget extends StatefulWidget {
  final ElementType? elementType;

  const DetailWidget({Key? key, this.elementType}) : super(key: key);

  @override
  State<DetailWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.elementType) {
      case ElementType.catchment:
        return const CatchmentDetail();
      case ElementType.register:
        return const RegisterDetail();
      case ElementType.section:
        return const SectionDetail();
      default:
        throw Exception('Invalid status string: ${widget.elementType}');
    }
  }
}
