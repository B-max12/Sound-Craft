import 'package:flutter/material.dart';

/// Non-web stub: YouTube embeds never exist off the web platform.
class WebIframe extends StatelessWidget {
  const WebIframe({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
