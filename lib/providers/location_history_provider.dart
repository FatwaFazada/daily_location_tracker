import 'package:flutter/foundation.dart';
import '../core/db_helper.dart';
import '../core/location_service.dart';
import '../models/location_entry.dart';

class LocationHistoryProvider extends ChangeNotifier {
  final _dbHelper = DBHelper();
  final _locationService = LocationService();

  List<LocationEntry> _entries = [];
  List<LocationEntry> get entries => _entries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? errorMessage;
  bool get hasError => errorMessage != null;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    _entries = await _dbHelper.getAllLocations();

    _isLoading = false;
    notifyListeners();
  }

  // =============================
  // CAPTURE LOKASI + PERMISSION
  // =============================
  Future<void> captureTodayLocation() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    /// ------ 1. CEK & MINTA PERMISSION ------
    final hasPermission = await _locationService.checkPermission();
    if (!hasPermission) {
      errorMessage = "Izin lokasi ditolak. Aktifkan lokasi agar aplikasi berfungsi.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    /// ------ 2. CEK APAKAH SUDAH ADA DATA HARI INI ------
    final today = DateTime.now();
    final existing = await _dbHelper.getLocationByDate(today);
    if (existing != null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    /// ------ 3. AMBIL POSISI SEKARANG ------
    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      errorMessage = "Gagal mengambil lokasi.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    /// ------ 4. AMBIL ALAMAT OPSIONAL ------
    final address = await _locationService.getAddressFromLatLng(
      position.latitude,
      position.longitude,
    );

    /// ------ 5. SIMPAN KE DATABASE ------
    final entry = LocationEntry(
      date: DateTime.now(),
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
    );

    await _dbHelper.insertLocation(entry);

    /// ------ 6. REFRESH LIST ------
    await loadEntries();
  }
}
