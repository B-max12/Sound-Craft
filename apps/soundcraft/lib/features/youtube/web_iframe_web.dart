// Web-only official YouTube embed (visible official player; no extraction).
// dart:html is used to create the platform view; migration to package:web is
// tracked in docs/DECISIONS.md.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:ui_web' as ui_web;
// platformViewRegistry lives in dart:ui web build only

import 'package:flutter/material.dart';

/// Renders an official youtube-nocookie iframe via HtmlElementView.
class WebIframe extends StatelessWidget {
  const WebIframe({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final element = IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'encrypted-media; picture-in-picture'
      ..allowFullscreen = true;
    final viewId = 'youtube-embed-${url.hashCode}';
    // ignore: undefined_prefixed_name, avoid_dynamic_calls
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int _) => element);
    return HtmlElementView(viewType: viewId);
  }
}
