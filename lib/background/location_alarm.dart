import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../core/location_service.dart';
import '../core/db_helper.dart';
import '../models/location_entry.dart';

void alarmCallback() async {
  final locationService = LocationService();
  final db = DBHelper();

  final position = await locationService.getCurrentPosition();
  if (position == null) return;

  final address = await locationService.getAddressFromLatLng(
    position.latitude,
    position.longitude,
  );

  db.insertLocation(LocationEntry(
    date: DateTime.now(),
    latitude: position.latitude,
    longitude: position.longitude,
    address: address,
  ));
}
