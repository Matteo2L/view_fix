import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  // Getter che invia l'url in maniera ritardata di un secondo
  static Future<String> get _url async {
    await Future.delayed(Duration(seconds: 1));
    return 'https://flutter.dev/';
  }

  // Il FutureBuilder crea, quando future (_url) è pronto, un WebViewWidget
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: FutureBuilder(
              future: _url,
              builder: (BuildContext context, AsyncSnapshot snapshot) =>
                  snapshot.hasData
                      ? WebViewWidget(
                          url: snapshot.data,
                        )
                      : const CircularProgressIndicator()),
        ),
      );
}

class WebViewWidget extends StatefulWidget {
  final String url;
  const WebViewWidget({required this.url});

  @override
  _WebViewWidget createState() => _WebViewWidget();
}

class _WebViewWidget extends State<WebViewWidget> {
  WebView _webView = const WebView();
  @override
  void initState() {
    super.initState();
    _webView = WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  @override
  void dispose() {
    super.dispose();
//    _webView = null;
  }

  @override
  Widget build(BuildContext context) => _webView;
}
