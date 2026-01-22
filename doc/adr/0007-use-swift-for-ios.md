# 7. Use Swift for iOS App

Date: 2026-01-21

## Status

Accepted

## Context

Need iOS app for barcode scanning, price submission, and shop discovery. Options:
- React Native
- Flutter
- Native Swift/SwiftUI

## Decision

Use native Swift with SwiftUI for iOS app.

## Consequences

- Best integration with iOS APIs (camera, CoreML, MapKit)
- Local AI/OCR with Vision framework
- Optimal battery and performance
- SwiftData for offline storage
- No cross-platform code sharing
- Need separate Android implementation (Kotlin)
- Smaller development surface to maintain initially
