import 'package:background_fetch/background_fetch.dart';
import '../core/db_helper.dart';
import '../core/location_service.dart';
import '../models/location_entry.dart';

Future<void> handleBackgroundFetchEvent() async {
  final db = DBHelper();
  final loc = LocationService();

  final position = await loc.getCurrentPosition();
  if (position != null) {
    final addr = await loc.getAddressFromLatLng(
      position.latitude,
      position.longitude,
    );

    await db.insertLocation(
      LocationEntry(
        date: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        address: addr,
      ),
    );
  }
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  await handleBackgroundFetchEvent();
  BackgroundFetch.finish(task.taskId);
}
