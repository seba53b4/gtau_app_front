import 'package:flutter/material.dart';
import 'package:gtau_app_front/assets/font/gtauicons.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomElevatedIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final MessageType? messageType;
  final double? width;
  final double? height;
  final int loadingDuration;
  final bool showLoading;

  const CustomElevatedIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.textColor,
    this.messageType,
    this.width,
    this.height,
    this.loadingDuration = 0,
    this.showLoading = false,
  }) : super(key: key);

  @override
  _CustomElevatedIconButton createState() => _CustomElevatedIconButton();
}

class _CustomElevatedIconButton extends State<CustomElevatedIconButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [primarySwatch[300]!, primarySwatch[100]!];
    if (widget.backgroundColor == null) {
      switch (widget.messageType) {
        case MessageType.success:
          colors = [primarySwatch[300]!, primarySwatch[100]!];
          break;
        case MessageType.error:
          colors = [Colors.red[400]!, Colors.red[300]!];
          break;
        case MessageType.warning:
          colors = [Colors.orange, Colors.orangeAccent];
          break;
        case null:
          colors = [primarySwatch[300]!, primarySwatch[100]!];
      }
    } else {
      colors = [Colors.grey, Colors.grey[400]!];
    }

    return ElevatedButton(
      onPressed:
          _isLoading || widget.showLoading ? null : () => _handleButtonPress(),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Container(
          constraints: BoxConstraints(
              minHeight: widget.height ?? 32,
              minWidth: widget.width ?? 78,
              maxWidth: 96,
              maxHeight: 42),
          padding: const EdgeInsets.all(4),
          child: _isLoading || widget.showLoading
              ? Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: lightBackground,
                    size: 32,
                  ),
                )
              : Center(
                  child: Icon(widget.icon, color: widget.textColor ?? Colors.white)
                ),
        ),
      ),
    );
  }

  void _handleButtonPress() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    widget.onPressed();

    if (widget.loadingDuration > 0) {
      await Future.delayed(Duration(milliseconds: widget.loadingDuration));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
