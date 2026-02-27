# MLX-Claw Specification

## 1. Project Overview

- **Project Name**: MLX-Claw
- **Bundle Identifier**: com.openclaw.mlx-claw
- **Core Functionality**: iOS app that connects to OpenClaw via WebSocket and uses MLX for local AI-powered function calling
- **Target Users**: Developers and power users who want local AI inference with remote orchestration
- **iOS Version Support**: iOS 17.0+

## 2. UI/UX Specification

### Screen Structure

1. **Main Screen (ContentView)**
   - Connection status indicator
   - Function call history list
   - Quick action buttons

2. **Connection Screen (ConnectionView)**
   - Server URL input
   - Connect/Disconnect button
   - Connection status display

3. **Function Call Screen (FunctionCallView)**
   - Function details display
   - Parameters view
   - Execute/Cancel buttons
   - Result output

### Navigation Structure
- Single NavigationStack with tab-like sections
- Modal presentations for function call details

### Visual Design

**Color Palette**
- Primary: #007AFF (iOS Blue)
- Secondary: #5856D6 (Purple)
- Accent: #34C759 (Green - connected)
- Error: #FF3B30 (Red - disconnected)
- Background: System background (adaptive)
- Surface: #F2F2F7 (light) / #1C1C1E (dark)

**Typography**
- Headings: SF Pro Display, 28pt bold
- Subheadings: SF Pro Display, 20pt semibold
- Body: SF Pro Text, 17pt regular
- Caption: SF Pro Text, 13pt regular

**Spacing System (8pt grid)**
- XS: 4pt
- S: 8pt
- M: 16pt
- L: 24pt
- XL: 32pt

### Views & Components

1. **ConnectionStatusBadge**
   - States: disconnected (red), connecting (yellow), connected (green)
   - Animated pulse when connecting

2. **FunctionCallCard**
   - Function name, timestamp, status
   - Tap to expand details

3. **ServerURLInput**
   - TextField with validation
   - Secure toggle for WebSocket URL

4. **MLXStatusIndicator**
   - Model loading state
   - Inference progress

## 3. Functionality Specification

### Core Features

**P0 - Critical**
1. WebSocket connection to OpenClaw server
2. Receive function call requests via WebSocket
3. MLX model loading and inference
4. Execute function calls locally
5. Return results to OpenClaw

**P1 - Important**
1. Connection state management
2. Function call history
3. Error handling and retry logic

**P2 - Nice to Have**
1. Offline mode with queued calls
2. Custom function registration

### User Interactions

1. **Connect to Server**
   - Enter WebSocket URL
   - Tap Connect button
   - View connection status

2. **Receive Function Call**
   - Notification on incoming call
   - View function details
   - Approve/Deny execution

3. **View Results**
   - See function output
   - Copy result to clipboard

### Data Handling

- **Local Storage**: UserDefaults for server URL and preferences
- **In-Memory**: Function call history (last 50 calls)
- **Network**: WebSocket for real-time communication

### Architecture Pattern

**MVVM (Model-View-ViewModel)**
- Models: Data structures
- Views: SwiftUI views
- ViewModels: Business logic and state management
- Services: WebSocket and MLX operations

### Edge Cases & Error Handling

1. Connection lost: Auto-reconnect with exponential backoff
2. MLX model unavailable: Graceful degradation, show error
3. Invalid function call: Return error to OpenClaw
4. Network timeout: 30 second timeout with retry option

## 4. Technical Specification

### Dependencies

**Swift Package Manager**
- Starscream (WebSocket client) - latest stable
- mlx (Apple's MLX framework - bundled with app)

### UI Framework

- **SwiftUI** for all views
- UIKit integration only if needed for specific components

### Asset Requirements

- App Icon (1024x1024 for App Store)
- SF Symbols for icons
- No custom fonts required (system fonts)

### WebSocket Protocol

**Message Format (JSON)**
```json
// Incoming function call
{
  "type": "function_call",
  "id": "uuid",
  "name": "function_name",
  "parameters": {}
}

// Outgoing response
{
  "type": "function_result",
  "id": "uuid",
  "status": "success|error",
  "result": {},
  "error": "error message if failed"
}

// Heartbeat
{
  "type": "ping"
}
{
  "type": "pong"
}
```

### MLX Configuration

- Model: Default MLX language model
- Max tokens: 512
- Temperature: 0.7
- Cache enabled for performance
