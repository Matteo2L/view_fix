import 'dart:async';

import 'package:app_view_fix/widgets/webview3.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ipAddressController = TextEditingController();
  String _ipAddress = 'https://flutter.dev';
  final controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: appBarTitle(context),
            // sovrascrivo il leading così da mettere il mio di menu icon child
          ),
          body: _body(context),
          drawer: _drawer(context, controller),
        );
      });

  Widget appBarTitle(BuildContext context) => Builder(builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.menu),
                ),
              ),
            ),
          ],
        );
      });

  Widget _drawer(
          BuildContext context, Completer<WebViewController> completer) =>
      Drawer(
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
                  });
                },
                child: const Text('Invia'),
              ),
            ),
          ],
        ),
      );

  Widget _body(BuildContext context) => WebViewWidget3(
        url: _ipAddress,
        key: UniqueKey(),
      );
}
