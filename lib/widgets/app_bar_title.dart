import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:view_fix/services/favorites_service.dart';

// AppBar personalizzata
class AppBarTitle extends StatefulWidget implements PreferredSizeWidget {
  final WebViewController controller;
  final String currentUrl;
  final VoidCallback onFavoriteChanged;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomReset;

  const AppBarTitle({
    required this.controller,
    required this.currentUrl,
    required this.onFavoriteChanged,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onZoomReset,
    super.key,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize; // default is 56.0

  @override
  State<AppBarTitle> createState() => _AppBarTitleState();
}

class _AppBarTitleState extends State<AppBarTitle> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  @override
  void didUpdateWidget(AppBarTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUrl != widget.currentUrl) {
      _checkIfFavorite();
    }
  }

  Future<void> _checkIfFavorite() async {
    final isFav = await FavoritesService.isFavorite(widget.currentUrl);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoritesService.removeFavorite(widget.currentUrl);
    } else {
      await FavoritesService.addFavorite(widget.currentUrl, widget.currentUrl);
    }
    widget.onFavoriteChanged();
    await _checkIfFavorite();
  }

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
      title: const Text('Wiev fix'),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_outline,
              color: _isFavorite ? Colors.amber : null,
            ),
            constraints: const BoxConstraints(),
            iconSize: 24,
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.replay),
            constraints: const BoxConstraints(),
            iconSize: 24,
            onPressed: () async {
              await widget.controller.reload();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            constraints: const BoxConstraints(),
            iconSize: 24,
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              if (await widget.controller.canGoBack()) {
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
              if (await widget.controller.canGoForward()) {
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
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'zoom_in') {
              widget.onZoomIn();
            } else if (value == 'zoom_out') {
              widget.onZoomOut();
            } else if (value == 'zoom_reset') {
              widget.onZoomReset();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'zoom_in',
              child: Row(
                children: [
                  Icon(Icons.zoom_in, size: 20),
                  SizedBox(width: 12),
                  Text('Zoom In'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'zoom_out',
              child: Row(
                children: [
                  Icon(Icons.zoom_out, size: 20),
                  SizedBox(width: 12),
                  Text('Zoom Out'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'zoom_reset',
              child: Row(
                children: [
                  Icon(Icons.restore, size: 20),
                  SizedBox(width: 12),
                  Text('Reset Zoom'),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
