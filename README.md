# PhotoPuzzle
Photo Puzzle game (SwiftUI iOS 17+)

## Quick start
1. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
2. Open `PhotoPuzzle.xcodeproj` in Xcode.
3. Run on an iPhone simulator.

## Config you must update for production
- `Resources/Config.plist`: replace AdMob test IDs with your own.
- `Info.plist`: update `GADApplicationIdentifier` to your app ID.
- `Sources/IAP/StoreManager.swift`: replace product IDs with your App Store Connect IDs.

## Daily puzzle assets
- `Resources/DailyImages/` contains 5 placeholder images.
- `Resources/daily.json` maps the daily images.
Replace with your own bundle images and edit the JSON.

## Sounds
- `Resources/Sounds/` has tiny placeholder WAV files (`move.wav`, `win.wav`).
Replace with your own `.mp3` if desired and update `SoundPlayer` accordingly.

## Localization
Included: `en`, `es`, `ca`, `fr`, `de` in `Resources/*.lproj/Localizable.strings`.

## App icon
`Resources/Assets.xcassets/AppIcon.appiconset` contains a generated placeholder icon.
Replace with your final icon before shipping.
