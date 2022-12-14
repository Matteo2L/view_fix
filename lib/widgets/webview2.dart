import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Classe WebViewWidget
class WebViewWidget extends StatefulWidget {
  final String url; // riceve in ingresso
  final Completer<WebViewController> controller;
  const WebViewWidget({
    super.key,
    required this.url,
    required this.controller,
  });

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  WebView newWebView = const WebView();

  @override
  void initState() {
    newWebView = WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (controller) {
        widget.controller.complete(controller);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => newWebView;

  @override
  void dispose() {
    super.dispose();
  }
}
