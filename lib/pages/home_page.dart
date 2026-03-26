import 'dart:async';
import 'package:view_fix/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:view_fix/services/favorites_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ipAddressController = TextEditingController(text: 'http://');
  bool wakelockEnable = true;
  String _ipAddress = 'https://flutter.dev';
  List<FavoriteUrl> _favorites = [];
  double _zoomLevel = 1.0;
  bool _showAppBar = true;
  Timer? _hideTimer;

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _startHideTimer();
    controller = WebViewController()
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
            // Inject touch/click listener so WebView can notify Flutter of taps
            controller.runJavaScript(
              '''(function(){
                try {
                  if (window._flutterTapBridgeInstalled) return;
                  window._flutterTapBridgeInstalled = true;
                  function post() { window.TouchBridge && window.TouchBridge.postMessage('tap'); }
                  document.addEventListener('touchstart', post, {passive:true});
                  document.addEventListener('click', post, {passive:true});
                } catch(e) {}
              })();''',
            );
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
WebView resource error:
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
      ..addJavaScriptChannel('TouchBridge', onMessageReceived: (message) {
        _resetHideTimer();
      })
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _ipAddressController.dispose();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showAppBar = false;
        });
      }
    });
  }

  void _resetHideTimer() {
    if (mounted) {
      setState(() {
        _showAppBar = true;
      });
      _startHideTimer();
    }
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesService.getFavoritesSimple();
    setState(() {
      _favorites = favorites;
    });
  }

  void _onFavoriteChanged() {
    _loadFavorites();
  }

  Future<void> _zoomIn() async {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 3.0);
    });
    await controller.runJavaScript(
      'document.body.style.zoom = "$_zoomLevel";',
    );
  }

  Future<void> _zoomOut() async {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 3.0);
    });
    await controller.runJavaScript(
      'document.body.style.zoom = "$_zoomLevel";',
    );
  }

  Future<void> _resetZoom() async {
    setState(() {
      _zoomLevel = 1.0;
    });
    await controller.runJavaScript(
      'document.body.style.zoom = "1.0";',
    );
  }

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) {
          return GestureDetector(
            onTap: _resetHideTimer,
            child: Scaffold(
              body: Stack(
                children: [
                  WebViewWidget(controller: controller),
                  // Thin transparent tap area at the top to reliably detect taps
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 48,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _resetHideTimer,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              ),
              appBar: _showAppBar
                  ? AppBarTitle(
                      controller: controller,
                      currentUrl: _ipAddress,
                      onFavoriteChanged: _onFavoriteChanged,
                      onZoomIn: _zoomIn,
                      onZoomOut: _zoomOut,
                      onZoomReset: _resetZoom,
                      onInteraction: _resetHideTimer,
                    )
                  : null,
              drawer: _drawer(context),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!_showAppBar)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _resetHideTimer,
                        tooltip: 'Show toolbar',
                        child: const Icon(Icons.arrow_upward, size: 20),
                      ),
                    ),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: FloatingActionButton(
                      backgroundColor: null,
                      onPressed: () {
                        setState(() {
                          wakelockEnable = !wakelockEnable;
                          WakelockPlus.toggle(enable: wakelockEnable);
                        });
                      },
                      child: Icon(
                        wakelockEnable ? Icons.wb_incandescent : Icons.wb_incandescent_outlined,
                        size: 36,
                        color: wakelockEnable ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  void updateUrl() {
    if (Uri.parse(_ipAddress).isAbsolute) {
      controller
          .loadRequest(Uri.parse(_ipAddress))
          .timeout(const Duration(seconds: 5));

      Navigator.pop(context);
    } else {
      //     Fluttertoast.showToast(msg: 'Use absolute path');
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
                  keyboardType: TextInputType.url,
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
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Preferiti',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_favorites.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep),
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear all favorites?'),
                            content:
                                const Text('This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  FavoritesService.clearAll();
                                  _loadFavorites();
                                  Navigator.pop(context);
                                },
                                child: const Text('Clear All'),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                ],
              ),
            ),
            if (_favorites.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No favorites yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ..._favorites.map((favorite) {
                return ListTile(
                  title: Text(
                    favorite.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    favorite.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      FavoritesService.removeFavorite(favorite.url);
                      _loadFavorites();
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _ipAddress = favorite.url;
                      _ipAddressController.text = _ipAddress;
                    });
                    controller.loadRequest(Uri.parse(favorite.url));
                    Navigator.pop(context);
                  },
                );
              }),
          ],
        ),
      );
}
