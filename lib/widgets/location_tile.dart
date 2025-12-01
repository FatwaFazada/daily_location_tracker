import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/location_entry.dart';

class LocationTile extends StatelessWidget {
  final LocationEntry entry;
  const LocationTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final dateStr = dateFormat.format(entry.date);

    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(dateStr),
      subtitle: Text(
        entry.address ??
            'Lat: ${entry.latitude.toStringAsFixed(5)}, '
            'Lng: ${entry.longitude.toStringAsFixed(5)}',
      ),
    );
  }
}
