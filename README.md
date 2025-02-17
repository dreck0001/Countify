# Countify

A sleek and simple counting app built with SwiftUI. Whether you're counting inventory, tracking repetitions, or keeping score, Countify provides an elegant solution with customizable sessions and persistent storage.

## Features

- **Session-Based Counting**: Create and manage multiple counting sessions
- **Flexible Counting Options**:
  - Custom step sizes for increment/decrement
  - Upper and lower limits support
  - Reset functionality with smart default values
- **Customizable Settings**: Per-session configuration for:
  - Haptic feedback with distinct patterns
  - Negative numbers support
  - Step size (1-100)
  - Optional upper and lower limits
- **Accessibility**:
  - VoiceOver support
  - Distinct haptic patterns for different actions
  - Clear visual feedback for limits
- **Elegant UI**:
  - Smooth animations
  - Intuitive controls
  - Clean, modern design
  - Smart text scaling for large numbers
- **Data Persistence**: All sessions are automatically saved
- **Dark Mode Support**: Seamless integration with system appearance

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/dreck0001/Countify.git
```

2. Open `Countify.xcodeproj` in Xcode

3. Build and run the project

## Architecture

Countify follows the MVVM (Model-View-ViewModel) architecture pattern and is organized into the following components:

```
Countify/
├── App/
│   └── CountifyApp.swift
├── Models/
│   └── CountSession.swift
├── ViewModels/
│   └── CountSessionManager.swift
├── Views/
│   ├── MainView.swift
│   ├── CountSessionListView.swift
│   ├── CountingStepperView.swift
│   ├── NewSessionView.swift
│   ├── SettingsView.swift
│   └── Components/
│       ├── SessionRowView.swift
│       ├── CounterDisplayView.swift
│       ├── CounterControlsView.swift
│       └── CounterButtons.swift
└── Utilities/
    └── HapticManager.swift
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Contact

denis.ansah@yahoo.com
