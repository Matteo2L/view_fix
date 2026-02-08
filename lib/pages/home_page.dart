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
          // Update the address bar when page finishes loading
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
  void initState() {
    super.initState();
    _loadFavorites();
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

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        return Scaffold(
          body: WebViewWidget(controller: controller),
          appBar: AppBarTitle(
            controller: controller,
            currentUrl: _ipAddress,
            onFavoriteChanged: _onFavoriteChanged,
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
                  WakelockPlus.toggle(enable: wakelockEnable);
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
              }).toList(),
          ],
        ),
      );
}
