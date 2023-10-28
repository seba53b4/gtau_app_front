import 'package:flutter/cupertino.dart';
import 'package:gtau_app_front/widgets/common/register_detail.dart';
import 'package:gtau_app_front/widgets/common/section_detail.dart';

import '../../models/enums/element_type.dart';
import 'catchment_detail.dart';
import 'lot_detail.dart';

class DetailElementWidget extends StatefulWidget {
  final ElementType? elementType;

  const DetailElementWidget({Key? key, this.elementType}) : super(key: key);

  @override
  State<DetailElementWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailElementWidget> {
  @override
  Widget build(BuildContext context) {
    return switch (widget.elementType) {
      ElementType.catchment => const CatchmentDetail(),
      ElementType.register => const RegisterDetail(),
      ElementType.section => const SectionDetail(),
      ElementType.lot => const LotDetail(),
      _ => throw Exception('Invalid status string: ${widget.elementType}')
    };
  }
}
