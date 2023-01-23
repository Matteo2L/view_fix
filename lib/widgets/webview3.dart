/*
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWidget3 extends StatefulWidget {
  final String url;
  final WebViewController? controller;
  const WebViewWidget3({
    super.key,
    required this.url,
    this.controller,
  });

  @override
  State<WebViewWidget3> createState() => _WebViewWidget3State();
}

class _WebViewWidget3State extends State<WebViewWidget3> {
  late WebView newWebView;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: newWebView = WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              controller = controller;
            },
          ),
        ),
      ],
    );
  }
}
*/