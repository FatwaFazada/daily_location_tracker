import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_history_provider.dart';
import '../core/location_service.dart';
import '../widgets/location_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LocationHistoryProvider>().loadEntries();
    });
  }

  Future<void> _capture() async {
    final hasPermission = await LocationService().checkPermission();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin lokasi ditolak")),
      );
      return;
    }

    await context.read<LocationHistoryProvider>().captureTodayLocation();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationHistoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Location History'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _capture, // ← sudah lewat runtime permission
        child: const Icon(Icons.my_location),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.entries.isEmpty
              ? const Center(
                  child: Text('Belum ada histori lokasi'),
                )
              : ListView.builder(
                  itemCount: provider.entries.length,
                  itemBuilder: (context, index) {
                    final entry = provider.entries[index];
                    return LocationTile(entry: entry);
                  },
                ),
    );
  }
}
