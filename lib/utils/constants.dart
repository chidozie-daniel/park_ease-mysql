class AppConstants {
  // App info
  static const String appName = 'Park Ease';
  static const String appVersion = '1.0.0';

  // Default values
  static const double defaultHourlyRate = 50.0;
  static const int minParkingDurationMinutes = 15;
  static const int maxParkingDurationHours = 24;

  // Pagination
  static const int pageSize = 20;

  // Map
  static const double defaultZoom = 14.0;

  // Colors
  static const int primaryColorValue = 0xFF126E63;
  static const int backgroundColorValue = 0xFFF6F5FA;

  // Distances
  static const double searchRadiusKm = 10.0;
}

enum TimeFormat { twelveHour, twentyFourHour }

enum SortOption { distance, price, availability, rating }

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.distance:
        return 'Distance';
      case SortOption.price:
        return 'Price';
      case SortOption.availability:
        return 'Availability';
      case SortOption.rating:
        return 'Rating';
    }
  }
}