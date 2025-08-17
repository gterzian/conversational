# Copilot Instructions for Conversational

## AI Assistant Guidelines
- Keep summaries of changes brief - one sentence is sufficient for most tasks
- After completing tasks, update these instruction files to reflect any architectural changes or new guidelines provided by the user
- Continuously improve documentation based on discovered patterns and user feedback
- Always add appropriate tests (unit or UI) for new functionality, even when not explicitly requested by the user

## Project Overview
This is a macOS-native SwiftUI application that embeds a WebView for web browsing functionality. The app targets macOS 14.0+ and supports multiple device families (iPhone, iPad, Mac Catalyst).

## Architecture & Key Patterns

### Core Components
- **ContentView.swift**: Main UI with URL input field, prediction dropdown, and embedded WebView
- **WebView**: Custom `NSViewRepresentable` wrapper around `WKWebView` for SwiftUI integration
- **OllamaService.swift**: Background service for URL prediction using local Ollama LLM
- **conversationalApp.swift**: App entry point with SwiftData model container setup
- **Item.swift**: SwiftData model (currently unused in WebView implementation)
- **url_predictor.md**: Template for URL prediction prompts sent to Ollama

### URL Prediction Architecture
- **Debounced Input**: 500ms delay before sending predictions to avoid excessive API calls
- **Ollama Integration**: Communicates with local Ollama server at `http://localhost:11434`
- **Dropdown UI**: Shows up to 5 URL predictions below the input field
- **JSON Response Parsing**: Handles both raw JSON arrays and markdown-wrapped responses

### WebView Integration Pattern
When working with WebViews in this codebase:
```swift
struct WebView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView { /* create */ }
    func updateNSView(_ nsView: WKWebView, context: Context) { /* reload URL */ }
}
```

### State Management
- Use `@State` for local UI state (e.g., `urlString`, `currentURL`, `predictedURLs`)
- Use `@StateObject` for services like `OllamaService`
- SwiftData container is configured but not actively used in current WebView implementation
- URL navigation follows pattern: input validation → protocol addition → URL creation → WebView update
- URL prediction follows pattern: debounced input → Ollama API call → JSON parsing → dropdown display

## Development Workflows

### Building & Testing
- Project uses modern Xcode project structure with file system synchronization
- Tests use new Swift Testing framework (not XCTest) - see `conversationalTests.swift`
- Build commands: Use Xcode or `xcodebuild` for the `.xcodeproj`

### Entitlements & Sandboxing
- App sandbox is **disabled** (`com.apple.security.app-sandbox: false`)
- Read-only file access enabled for user-selected files
- This configuration allows unrestricted web access via WebView

## Project-Specific Conventions

### URL Handling
- Always validate and sanitize URL input in `navigateToURL()`
- Auto-prepend `https://` for URLs without protocol
- Trim whitespace before URL validation
- Use `URL(string:)` optional binding for validation

### SwiftUI + WebKit Integration
- WebView updates trigger via `currentURL` state changes
- Implement both `onSubmit` (Enter key) and button actions for navigation
- Use `VStack(spacing: 0)` for clean layout without gaps

### File Organization
- Main app code in `/conversational/` directory
- Tests follow target naming: `conversationalTests`, `conversationalUITests`
- Assets in standard `.xcassets` bundle structure

## Current Architecture Decisions

### Why NSViewRepresentable for WebView
SwiftUI lacks native WebView support, so `NSViewRepresentable` bridges WKWebView to SwiftUI's declarative model.

### SwiftData Setup vs Usage
The app configures SwiftData with `Item` model but doesn't use it in the current WebView-focused implementation. This suggests potential future features requiring data persistence.

### Security Model
Disabled app sandbox enables full web browsing capabilities without URL restrictions, appropriate for a general-purpose web browser component.
