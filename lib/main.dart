import 'package:view_fix/app.dart';
import 'package:view_fix/services/favorites_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoritesService.init();

  runApp(const App());
}
