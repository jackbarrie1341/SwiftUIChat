# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ExyteChat is a SwiftUI Chat UI framework (Swift Package) that provides fully customizable message cells and a built-in media picker. It is a **library**, not an app. The package name is `Chat`, and the library product is `ExyteChat`. iOS 17+ only.

## Build & Test Commands

```bash
# Build the library
swift build

# Run all tests
swift test

# Run a single test
swift test --filter ExyteChatTests.ExampleChatTests/testName

# Format code (required before committing)
swift-format format -i --configuration .swift-format Sources/ExyteChat/path/to/File.swift
```

Example projects live in `ChatExample/` and `ChatFirestoreExample/` — open their `.xcodeproj` files in Xcode to build and run.

## Code Style

- 4-space indentation (configured in `.swift-format`)
- No spaces on empty lines
- Comments: `// start with small letter`
- Declarations: `var users: [User]` (space after colon)
- Run `swift-format` before committing

## Architecture

### Core Types (Sources/ExyteChat/Model/)

- **`Message`** — The primary data model. Contains `User`, `Attachment`s, `Recording`, `ReplyMessage`, `Reaction`s, `Status`, and optional Giphy media. Messages must have unique IDs (enforced with a fatal error).
- **`DraftMessage`** — Returned to consumers via `didSendMessage` closure when the user taps send. The library does **not** handle networking — the consumer maps `DraftMessage` to their API.
- **`User`** — Identifies message authors. `isCurrentUser` determines bubble alignment (right for current user in conversation mode).
- **`Attachment`** — Supports image, video, and document types with optional upload status tracking (`UploadStatus`: inProgress, complete, cancelled, error).
- **`MessagesSection`** / **`MessageRow`** — Internal grouping types. Messages are sectioned by day and wrapped with position metadata (`PositionInUserGroup`, `PositionInMessagesSection`, `CommentsPosition`).

### View Layer (Sources/ExyteChat/Views/)

- **`ChatView`** — The main public API. Generic over `<MessageContent, InputViewContent, MenuAction>`. Consumers pass `[Message]` and a `didSendMessage` closure. Customization is via SwiftUI-style modifier methods (e.g., `.avatarSize()`, `.setAvailableInputs()`, `.showDateHeaders()`).
- **`PartialTemplateSpecifications.swift`** — Contains multiple `ChatView` init overloads using `EmptyView` and `DefaultMessageMenuAction` to make generic parameters optional. This is how the simple `ChatView(messages:didSendMessage:)` init works.
- **`UIList`** — A `UIViewRepresentable` wrapping `UITableView` for the message list. Handles scroll behavior, pagination, and keyboard dismiss modes.
- **`InputView` / `InputViewModel`** — The text input area with support for text, media picker, audio recording, and Giphy sticker keyboard.
- **`MessageMenu`** — Fullscreen context menu shown on long press. Supports custom actions via `MessageMenuAction` protocol and reactions via `ReactionDelegate`.
- **`WrappingMessages`** — Static methods on `ChatView` that transform flat `[Message]` arrays into `[MessagesSection]` with position metadata. Handles both `.quote` and `.answer` reply modes.

### Theming (Sources/ExyteChat/Theme/)

- **`ChatTheme`** — Passed via SwiftUI environment (`.chatTheme()` modifier). Contains `Colors`, `Images`, and `Style` sub-structs. Default colors load from asset catalog in the bundle.
- **`ChatTheme+Auto`** — iOS 18+ auto-theming based on accent color.

### Key Patterns

- **Modifier-style API**: `ChatView` customization uses methods that return modified copies (e.g., `func avatarSize(avatarSize:) -> ChatView`), not SwiftUI `ViewModifier`s.
- **Strict Concurrency**: Enabled via `StrictConcurrency` experimental feature flag in Package.swift. Core model types conform to `Sendable`.
- **`ChatType`**: `.conversation` (newest at bottom) vs `.comments` (newest at top) — affects scroll direction and new message animation.
- **`ReplyMode`**: `.quote` (reply appears as newest message quoting original) vs `.answer` (reply appears directly below original message).

### Dependencies

- **ExyteMediaPicker** — Photo/video library and camera picker
- **ActivityIndicatorView** — Loading indicators
- **GiphyUISDK** — Sticker/GIF keyboard integration
- **Kingfisher** — Image caching (used via `CachedAsyncImage`)
