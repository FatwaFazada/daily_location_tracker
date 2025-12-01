class LocationEntry {
  final int? id;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String? address;

  LocationEntry({
    this.id,
    required this.date,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory LocationEntry.fromMap(Map<String, dynamic> map) {
    return LocationEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
    );
  }
}
