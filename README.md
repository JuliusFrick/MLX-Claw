# MLX-Claw

An iOS application that connects to OpenClaw via WebSocket and runs MLX locally for intelligent function calling.

## Overview

MLX-Claw is an iOS app that leverages Apple's MLX framework for local machine learning inference, enabling intelligent function calling capabilities through a WebSocket connection to OpenClaw. The app provides a native iOS interface for interacting with AI-powered automation.

## Features

- **WebSocket Connection**: Real-time bidirectional communication with OpenClaw server
- **MLX Integration**: Local MLX inference for function calling and AI processing
- **SwiftUI Interface**: Modern declarative UI built with SwiftUI
- **Function Registry**: Dynamic function registration and execution system

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Apple Silicon Mac (for MLX development)

## Project Structure

```
mlx-claw/
├── Sources/
│   ├── App/
│   │   └── MLXClawApp.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── ConnectionView.swift
│   │   └── FunctionCallView.swift
│   ├── ViewModels/
│   │   ├── AppViewModel.swift
│   │   └── WebSocketViewModel.swift
│   ├── Services/
│   │   ├── WebSocketService.swift
│   │   └── MLXService.swift
│   ├── Models/
│   │   ├── FunctionCall.swift
│   │   ├── ConnectionState.swift
│   │   └── OpenClawMessage.swift
│   └── Utilities/
│       └── Constants.swift
├── Resources/
│   ├── Assets.xcassets/
│   └── Info.plist
└── mlx-claw.xcodeproj/
```

## Getting Started

1. Clone the repository
2. Open `mlx-claw.xcodeproj` in Xcode
3. Configure your OpenClaw server URL in the app
4. Build and run on device or simulator

## License

MIT License
