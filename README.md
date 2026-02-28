# MLX-Claw

An iOS application that connects to OpenClaw via WebSocket and runs MLX locally for intelligent function calling.

## Features

- **WebSocket Connection**: Real-time bidirectional communication with OpenClaw server
- **MLX Integration**: Local MLX inference for function calling and AI processing
- **Offline Support**: Queue function calls when offline, auto-sync when reconnected
- **SwiftUI Interface**: Modern declarative UI built with SwiftUI
- **Function Registry**: Dynamic function registration and execution system

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- Apple Silicon Mac (for MLX development)

## Getting Started

1. Clone the repository
2. Open `MLXClaw.xcodeproj` in Xcode
3. Configure your OpenClaw server URL in the app
4. Build and run on device or simulator

## Configuration

### Server Connection

Enter your WebSocket server URL (e.g., `ws://localhost:8080/ws`) in the Connection screen or Settings.

### MLX Models

The app supports these MLX models:
- Llama-3.2-1B-Instruct-4bit
- Llama-3.2-3B-Instruct-4bit
- Qwen2.5-0.5B-Instruct-4bit

## Architecture

- **MVVM** pattern with SwiftUI
- **OpenClawService**: Main service for WebSocket + MLX coordination
- **QueueService**: Offline queue management
- **FunctionRegistry**: Dynamic function execution

## Available Functions

- `create_calendar_event` - Create calendar events
- `get_calendar_events` - Retrieve calendar events
- `create_task` - Create tasks
- `list_tasks` - List all tasks

## Offline Mode

When offline, function calls are automatically queued and executed when connection is restored. The app shows an offline indicator with pending queue count.

## License

MIT License
