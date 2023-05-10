import 'package:app_view_fix/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ipAddressController = TextEditingController(text: 'http://');
  bool wakelockEnable = true;
  String _ipAddress = 'https://flutter.dev';
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            debugPrint('blocking navigation to ${request.url}');
            return NavigationDecision.prevent;
          }
          debugPrint('allowing navigation to ${request.url}');
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://flutter.dev'));

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        return Scaffold(
          body: WebViewWidget(controller: controller),
          appBar: AppBarTitle(
            controller: controller,
          ),
          drawer: _drawer(context),
          floatingActionButton: SizedBox(
            width: 68,
            height: 68,
            child: FloatingActionButton(
              child: Icon(
                Icons.wb_incandescent_outlined,
                size: 48,
                color: wakelockEnable ? Colors.black : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  wakelockEnable = !wakelockEnable;
                  Wakelock.toggle(enable: wakelockEnable);
                });
              },
            ),
          ),
        );
      });

  updateUrl() {
    if (Uri.parse(_ipAddress).isAbsolute) {
      controller
          .loadRequest(Uri.parse(_ipAddress))
          .timeout(const Duration(seconds: 5));

      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: 'Use absolute path');
      _ipAddress.trim();
      _ipAddress = 'http://$_ipAddress';
      controller
          .loadRequest(Uri.parse(_ipAddress))
          .timeout(const Duration(seconds: 5));
      Navigator.pop(context);
    }
  }

  Widget _drawer(BuildContext context) => Drawer(
        child: ListView(
          children: [
            Form(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Indirizzo IP',
                  ),
                  controller: _ipAddressController,
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (value) {
                    setState(() {
                      _ipAddress = _ipAddressController.text;
                      updateUrl();
                      _ipAddressController.text = _ipAddress;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _ipAddress = _ipAddressController.text;
                    updateUrl();
                    _ipAddressController.text = _ipAddress;
                  });
                },
                child: const Text('Invia'),
              ),
            ),
          ],
        ),
      );
}
