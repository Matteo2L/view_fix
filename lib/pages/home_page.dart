import 'dart:async';
import 'package:app_view_fix/widgets/app_bar_title.dart';
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
  WebViewController? controller;

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        return Scaffold(
          body: _body(context),
          appBar: AppBarTitle(
            controller: controller,
          ),
          drawer: _drawer(context),
        );
      });

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
                      Navigator.pop(context);
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
                    Navigator.pop(context);
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
        key: Key(_ipAddress),
        controller: controller,
      );
}
