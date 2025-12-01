import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:background_fetch/background_fetch.dart';

// Local imports
import 'providers/location_history_provider.dart';
import 'screens/home_screen.dart';
import 'background/background_event_handler.dart';

// SQLite FFI untuk Windows/Linux
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  // SQLite FFI untuk Desktop
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Register Background Fetch Headless Task (Android)
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initBackgroundFetch();
  }

  /// 🔧 Setup Background Fetch
  void initBackgroundFetch() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
      ),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout,
    );
  }

  /// 🟢 Event yang berjalan setiap 15 menit / harian
  void _onBackgroundFetch(String taskId) async {
    BackgroundFetch.finish(taskId);
  }

  /// 🔴 Kalau timeout
  void _onBackgroundFetchTimeout(String taskId) {
    BackgroundFetch.finish(taskId);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationHistoryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
