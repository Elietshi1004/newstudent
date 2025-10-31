import 'package:flutter/material.dart';
import '../../utils/const/colors/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ??
        (isOutlined ? Colors.transparent : AppColors.primary);
    final effectiveTextColor =
        textColor ?? (isOutlined ? AppColors.primary : Colors.white);

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isOutlined ? Colors.transparent : effectiveBackgroundColor,
        foregroundColor: effectiveTextColor,
        side:
            isOutlined ? BorderSide(color: AppColors.primary, width: 2) : null,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isOutlined ? 0 : 2,
      ),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );

    return button;
  }
}
