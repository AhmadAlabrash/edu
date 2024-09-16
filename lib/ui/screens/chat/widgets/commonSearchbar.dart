import 'package:flutter/material.dart';

class CommonSearchbar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String?)? onChanged;
  final Widget? suffixIcon;
  final String hintText;
  final bool autofocus;
  final bool enabled;
  final bool filled;
  final Color? color;
  final double? borderRadius;
  const CommonSearchbar(
      {super.key,
      this.controller,
      this.onChanged,
      this.suffixIcon,
      required this.hintText,
      this.autofocus = false,
      this.filled = true,
      this.enabled = true,
      this.color,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      enabled: enabled,
      cursorColor: color ?? const Color(0xffa2a2a2),
      style: TextStyle(color: color ?? Theme.of(context).secondaryHeaderColor),
      decoration: InputDecoration(
        fillColor: Theme.of(context).colorScheme.primary,
        filled: filled,
        suffixIcon: suffixIcon,
        prefixIcon: Icon(
          Icons.search,
          color: color ?? Theme.of(context).hintColor,
        ),
        contentPadding: EdgeInsetsDirectional.zero,
        hintText: hintText,
        hintStyle: TextStyle(
            color: color ?? Theme.of(context).hintColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14.0),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: color ?? Theme.of(context).colorScheme.surface,
              width: 1.0),
          borderRadius: BorderRadius.circular(borderRadius ?? 100),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: color ?? Theme.of(context).colorScheme.surface,
              width: 1.0),
          borderRadius: BorderRadius.circular(borderRadius ?? 100),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: color ?? Theme.of(context).colorScheme.surface,
              width: 1.0),
          borderRadius: BorderRadius.circular(borderRadius ?? 100),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 100),
        ),
      ),
    );
  }
}
