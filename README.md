# Minute Repeater

<p align="center">
  <img src="MinuteRepeater/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" alt="MinuteRepeater Icon" width="128" height="128">
</p>

A elegant macOS menu bar application that chimes the current time using traditional watch minute repeater sounds. Inspired by luxury mechanical watches, this app announces the hours, quarter-hours, and minutes through beautiful audio chimes.

## Features

- 🔔 **Minute Repeater Chiming** - Audibly announces the current time using three distinct chime sounds:
  - Low tone for hours
  - Double tone for quarter-hours (15 minutes)
  - High tone for additional minutes
  
- ⌨️ **Keyboard Shortcut** - Set a custom keyboard shortcut to trigger the chiming on demand

- 🚀 **Launch at Login** - Automatically start the app when you log in to macOS

- 🌐 **Bilingual Support** - Full localization in English and Simplified Chinese (简体中文)

- 🎯 **Menu Bar Integration** - Lightweight menu bar application that stays out of your way

- 🔒 **Single Instance** - Prevents multiple instances from running simultaneously

## How It Works

The minute repeater follows the traditional watch complication pattern:

1. **Hours**: Chimes a low tone for each hour (12-hour format)
2. **Quarters**: Chimes a double tone for each 15-minute interval past the hour
3. **Minutes**: Chimes a high tone for each minute past the last quarter

### Example
For **3:47**:
- 3 low-tone chimes (3 hours)
- 3 double-tone chimes (45 minutes = 3 quarters)
- 2 high-tone chimes (2 additional minutes)

## Requirements

- macOS 10.15 (Catalina) or later
- Xcode 15.0+ (for building from source)

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/huangcheng/SwiftMinuteRepeater.git
cd MinuteRepeater
```

2. Open the project in Xcode:
```bash
open MinuteRepeater.xcodeproj
```

3. Build and run the project (⌘R)

## Usage

### Triggering the Chime

1. **Via Menu Bar**: Click the menu bar icon and select "About" (or use ⌘A)
2. **Via Keyboard Shortcut**: Configure a custom shortcut in Settings and use it anytime

### Settings

Click the menu bar icon and select "Settings" (or press ⌘,) to access:

- **Launch at Login**: Toggle automatic startup
- **Chiming Shortcut**: Set your preferred keyboard shortcut for triggering chimes

### Keyboard Shortcuts

- **⌘,** - Open Settings
- **⌘A** - Trigger chiming (also mapped to About menu)
- **⌘Q** - Quit application

## Localization

MinuteRepeater supports the following languages:

- 🇺🇸 English
- 🇨🇳 简体中文 (Simplified Chinese)

The language automatically follows your system preferences, but can be customized through the app's localization settings.

## Technical Details

### Architecture

- **SwiftUI** - Modern declarative UI framework
- **AVFoundation** - Audio playback engine
- **ServiceManagement** - Launch at login functionality
- **KeyboardShortcuts** - Custom keyboard shortcut support (via [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) library)

### Audio Processing

The app uses a custom `WaveRider` class to:
1. Parse individual WAV audio files (hour, quarter, minute chimes)
2. Concatenate multiple audio samples dynamically
3. Generate a single composite WAV file for playback

This approach ensures seamless chiming without gaps or delays between sounds.

## Project Structure

```
MinuteRepeater/
├── MinuteRepeater/
│   ├── MinuteRepeaterApp.swift    # Main app entry point
│   ├── WaveRider.swift             # Audio concatenation engine
│   ├── Constants.swift             # Keyboard shortcut definitions
│   ├── Localizable.xcstrings       # Localization strings
│   ├── Views/
│   │   └── SettingsView.swift     # Settings UI
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset/    # App icons
│       ├── TrayIcon.imageset/     # Menu bar icon
│       └── Audio/                 # Chime sound files
│           ├── hour.wav
│           ├── quarter.wav
│           └── minute.wav
└── README.md
```

## Dependencies

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - macOS library for recording and using keyboard shortcuts

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

The MIT License (MIT)

## Acknowledgments

- Inspired by the mechanical minute repeater complication found in luxury timepieces
- Audio chimes designed to replicate traditional watch striking mechanisms

## Author

Cheng Huang ([@huangcheng](https://github.com/huangcheng))

---

Made with ❤️ for horology enthusiasts
