import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomText extends StatelessWidget {
  const CustomText(this.text,
      {super.key,
      this.color,
      this.showLineThrough,
      this.fontWeight,
      this.fontStyle,
      this.fontSize,
      this.textAlign,
      this.maxLines,
      this.height,
      this.showUnderline,
      this.underlineOrLineColor});

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? fontSize;
  final double? height;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool? showLineThrough;
  final bool? showUnderline;
  final Color? underlineOrLineColor;

  TextStyle textStyle(BuildContext context) {
    return TextStyle(
        color: color ?? Theme.of(context).colorScheme.blackColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        fontSize: fontSize,
        decoration: showLineThrough ?? false
            ? TextDecoration.lineThrough
            : showUnderline ?? false
                ? TextDecoration.underline
                : null,
        decorationColor: underlineOrLineColor,
        height: height);
  }

  @override
  Widget build(BuildContext context) {
    return maxLines != null
        ? Text(
            text,
            maxLines: maxLines,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: textStyle(context),
            textAlign: textAlign,
          )
        : Text(
            text,
            style: textStyle(context),
            textAlign: textAlign,
          );
  }
}
