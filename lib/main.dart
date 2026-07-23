import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/settings/settings_view_model.dart';
import 'services/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  setupLogging();
  final sp = await SharedPreferences.getInstance();
  appLogger.info('Viewfinder 启动');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ],
      child: const ViewfinderApp(),
    ),
  );
}