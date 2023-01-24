import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// AppBar personalizzata
class AppBarTitle extends StatefulWidget implements PreferredSizeWidget {
  final WebViewController controller;
  const AppBarTitle({
    required this.controller,
    super.key,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize; // default is 56.0

  @override
  State<AppBarTitle> createState() => _AppBarTitleState();
}

class _AppBarTitleState extends State<AppBarTitle> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      // sovrascrivo il leading così da mettere il mio di menu icon child
      leading: Padding(
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
      title: const Text('Web view app'),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            constraints: const BoxConstraints(),
            iconSize: 24,
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              if ((widget.controller != null)
                  ? await widget.controller.canGoBack()
                  : false) {
                await widget.controller.goBack();
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
                return;
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            constraints: const BoxConstraints(),
            iconSize: 24,
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              if ((widget.controller != null)
                  ? await widget.controller.canGoForward()
                  : false) {
                await widget.controller.goForward();
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
                return;
              }
            },
          ),
        ),
      ],
    );
  }
}
