# Countify

A sleek and simple counting app built with SwiftUI. Whether you're counting inventory, tracking repetitions, or keeping score, Countify provides an elegant solution with customizable sessions and persistent storage.

## Features

- **Session-Based Counting**: Create and manage multiple counting sessions
- **Customizable Settings**: Per-session configuration for:
  - Haptic feedback
  - Negative numbers support
- **Elegant UI**:
  - Smooth animations
  - Intuitive controls
  - Clean, modern design
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
└── Views/
    ├── MainView.swift
    ├── CountSessionListView.swift
    ├── CountingStepperView.swift
    ├── NewSessionView.swift
    ├── SettingsView.swift
    └── Components/
        ├── SessionRowView.swift
        ├── CounterDisplayView.swift
        ├── CounterControlsView.swift
        └── CounterButtons.swift
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Contact

denis.ansah@yahoo.com
