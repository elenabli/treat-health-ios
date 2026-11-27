# Nearest Pharmacy (iOS)

A SwiftUI app that finds the pharmacy closest to you.

Tap **Find the nearest pharmacy**, allow location access, and the app shows nearby pharmacies
on a map and in a list, nearest first. Tap a pharmacy to get walking directions in Apple Maps.

## How it works

| File | What it does |
| --- | --- |
| `LocationProvider.swift` | Asks for location permission and returns the current location once, as `async` code. |
| `Pharmacy.swift` | Searches Apple Maps for points of interest in the `.pharmacy` category within 5 km and sorts them by distance. |
| `ContentView.swift` | Map with a marker per pharmacy (the nearest in green), a list, and the search button. |

No third-party dependencies and no API keys: only SwiftUI, MapKit and CoreLocation.

## Requirements

iOS 17+, Xcode 16+.

## Run it

Open `PharmacyFinder.xcodeproj` and run on a simulator or device. In the simulator, set a location
under **Features → Location** (for example a custom location in Helsinki: 60.1699, 24.9384).

## Tests

`PharmacyFinderTests` checks the nearest-first sorting. Run with ⌘U.
