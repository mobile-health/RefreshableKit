# RefreshableKit

Lightweight pull-to-refresh and infinite-scrolling helpers for UIScrollView on iOS.

## Installation

### Swift Package Manager

Add this repository to your iOS project using Xcode's Swift Packages UI (File → Add Packages) or in your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/mobile-health/RefreshableKit.git", from: "0.0.1")
```

Then add `RefreshableKit` to your target's dependencies and import it:

```swift
import RefreshableKit
```

**Note:** The package includes a fallback shim for `SWActivityIndicatorView` so it builds without external SPM dependencies. For CocoaPods users, the real `SWActivityIndicatorView` will be used automatically when available.

### CocoaPods

```ruby
pod 'RefreshableKit', '~> 0.0.1'
```

## Usage

Use the provided `UIScrollView` extensions to add pull-to-refresh and infinite scrolling:

```swift
import RefreshableKit

// Add pull-to-refresh
scrollView.addPullToRefresh {
    // Your refresh logic
}

// Add infinite scrolling
scrollView.addInfinityScrolling {
    // Your load more logic
}
```
