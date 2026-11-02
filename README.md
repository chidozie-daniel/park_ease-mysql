# park_ease_application

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Nearby parking search

With location permission enabled, the app searches for parking around the
device's current location using the Park Ease API. Results combine parking
lots registered in Park Ease with nearby OpenStreetMap parking listings.
OpenStreetMap results are community-maintained and do not provide verified
availability, rates, or in-app booking; those listings are marked in the app.
The search uses OpenStreetMap data and displays its required attribution.

Run the API from the `server` directory with `npm start` while using the app.
Android emulators connect to the host API at `http://10.0.2.2:3000`.
