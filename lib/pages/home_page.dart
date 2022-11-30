import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) => Scaffold(
          body: _body(context),
          drawer: _drawer(context),
        ),
      );

  Widget _body(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SafeArea(
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.menu),
              ),
            ),
          ),
        ],
      );

  Widget _drawer(BuildContext context) => Drawer(
        child: ListView(
          children: [Text('testo')],
        ),
      );
}
