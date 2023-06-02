import 'package:flutter/material.dart';
import 'package:invoice_app/src/utils/custom_media_query.dart';

import 'colors.dart';

class CustomLoading {
  // making it singleton

  // ignore: unused_field
  static final CustomLoading _instance = CustomLoading._init();

  static OverlayEntry? _overlayEntry;

  CustomLoading._init();

  static void showLoading(BuildContext context) {
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
              top: CustomMediaQuery.makeHeight(context, .5),
              left: CustomMediaQuery.makeWidth(context, .45),
              child: CircularProgressIndicator(
                strokeWidth: 3.4,
                color: purple,
              )));

      Overlay.of(context)!.insert(_overlayEntry!);
    }
  }

  static void dismiss() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}
