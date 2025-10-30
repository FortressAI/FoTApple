# Apple Help Integration Guide

Complete guide for integrating Apple-compliant help files into FoT Apple apps.

---

## 📚 Overview

This guide shows you how to:
1. Convert wiki markdown to Apple Help format
2. Integrate Help Books into macOS apps
3. Add in-app help to iOS/iPadOS apps
4. Configure help menu items and shortcuts

---

## 🔄 Step 1: Convert Wiki to Apple Help

### Run the Converter

```bash
cd /Users/richardgillespie/Documents/FoTApple
python3 scripts/convert_wiki_to_apple_help.py
```

### Install Required Dependencies

```bash
pip3 install markdown
```

### What Gets Generated

```
AppleHelp/
├── FoTHelp.help/              # macOS Help Bundle
│   └── Contents/
│       ├── Info.plist
│       └── Resources/
│           ├── en.lproj/
│           │   ├── index.html
│           │   ├── home.html
│           │   ├── quick-start.html
│           │   └── ... (all help pages)
│           ├── css/
│           │   └── apple-help.css
│           ├── js/
│           │   └── help-search.js
│           └── images/
│               └── FoT_core_*.png
│
└── iOS/                       # iOS Help Resources
    ├── help-data.json
    └── *.html (all help pages)
```

---

## 🖥️ Step 2: Integrate macOS Help

### Add Help Bundle to Xcode

1. **Open Xcode project**
2. **Drag `FoTHelp.help`** folder into your project
3. **Target Membership**: Add to all macOS app targets
4. **Copy Bundle Resources**: Verify it's in Build Phases

### Configure Info.plist

Add to each macOS app's `Info.plist`:

```xml
<key>CFBundleHelpBookFolder</key>
<string>FoTHelp.help</string>
<key>CFBundleHelpBookName</key>
<string>com.fortressai.fot.help</string>
```

### Add Help Menu Item

In your macOS app delegate or main app file:

```swift
import SwiftUI

@main
struct FoTClinicianMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            // Add Help menu with Search
            CommandGroup(replacing: .help) {
                Button("FoT Apple Help") {
                    if let helpBookURL = Bundle.main.url(
                        forResource: "index",
                        withExtension: "html",
                        subdirectory: "FoTHelp.help/Contents/Resources/en.lproj"
                    ) {
                        NSWorkspace.shared.open(helpBookURL)
                    }
                }
                .keyboardShortcut("?", modifiers: .command)
                
                Divider()
                
                // Apple will automatically add "Search" here if help book is configured
            }
        }
    }
}
```

### Test macOS Help

1. **Build and run** your macOS app
2. **Press `⌘?`** or select Help menu
3. **Search** should work automatically
4. **Spotlight integration**: Help content is automatically indexed

---

## 📱 Step 3: Integrate iOS Help

### Add Help Resources to Xcode

1. **Create `Help` folder** in your iOS app
2. **Add files** from `AppleHelp/iOS/`:
   - `help-data.json`
   - All `*.html` files
3. **Target Membership**: Add to all iOS app targets
4. **Copy if needed**: Ensure they're in Copy Bundle Resources

### Add HelpView Component

The `HelpView.swift` file has already been created at:
```
Sources/FoTUI/Help/HelpView.swift
```

Add it to your Xcode project if not already included.

### Add Help Button to Your App

In your main view or settings:

```swift
import SwiftUI
import FoTUI

struct SettingsView: View {
    @State private var showHelp = false
    
    var body: some View {
        List {
            Section {
                Button(action: { showHelp = true }) {
                    Label("Help & Support", systemImage: "questionmark.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
    }
}
```

### Add Help from Anywhere

You can also add a help button to your toolbar:

```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showHelp = true }) {
            Image(systemName: "questionmark.circle")
        }
    }
}
```

---

## 🔧 Step 4: Advanced Configuration

### Link to Specific Help Topics

```swift
// Open specific help topic
HelpView(initialTopic: "quick-start")

// Or programmatically:
viewModel.selectedTopic = HelpTopic(
    id: "drug-interaction",
    title: "Drug Interaction Checker",
    summary: nil,
    keywords: []
)
```

### Add Contextual Help

Show help based on current screen:

```swift
struct DrugInteractionView: View {
    @State private var showHelp = false
    
    var body: some View {
        VStack {
            // Your content
        }
        .toolbar {
            ToolbarItem {
                Button(action: { showHelp = true }) {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            HelpView(initialTopic: "drug-interaction-checker")
        }
    }
}
```

### Enable Siri Help Shortcuts

Add to your App Intents:

```swift
import AppIntents

struct ShowHelpIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Help"
    static var description = IntentDescription("Opens the FoT Apple help system")
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // Post notification to show help
        NotificationCenter.default.post(name: .showHelp, object: nil)
        return .result()
    }
}

// Add phrase support
struct FoTAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowHelpIntent(),
            phrases: [
                "Show \(.applicationName) help",
                "Open \(.applicationName) help",
                "I need help with \(.applicationName)"
            ]
        )
    }
}
```

---

## 🎨 Customization

### Update Help Styling

Edit `AppleHelp/FoTHelp.help/Contents/Resources/css/apple-help.css` to customize:

- Colors (light/dark mode)
- Typography
- Layout
- Animations

### Add Custom Images

1. **Add images** to `AppleHelp/FoTHelp.help/Contents/Resources/images/`
2. **Reference** in your markdown:
   ```markdown
   ![Screenshot](../images/screenshot.png)
   ```
3. **Re-run converter** to update

### Localization

To add localized help:

1. **Create language folder**:
   ```
   FoTHelp.help/Contents/Resources/es.lproj/
   ```

2. **Copy HTML files** and translate

3. **Update Info.plist**:
   ```xml
   <key>CFBundleDevelopmentRegion</key>
   <string>en</string>
   <key>CFBundleLocalizations</key>
   <array>
       <string>en</string>
       <string>es</string>
       <string>fr</string>
   </array>
   ```

---

## 🧪 Testing

### Test macOS Help

```bash
# Test help book structure
hiutil -Cf ~/Desktop/FoTHelp.helpindex AppleHelp/FoTHelp.help

# Validate Help Book
/usr/bin/plist -validate AppleHelp/FoTHelp.help/Contents/Info.plist
```

### Test iOS Help

1. **Run app** in simulator or device
2. **Open help** from settings or toolbar
3. **Test search** functionality
4. **Verify HTML** rendering
5. **Test deep links** to specific topics

### Automated Tests

```swift
import XCTest
@testable import FoTUI

class HelpSystemTests: XCTestCase {
    func testHelpDataLoads() async throws {
        let viewModel = HelpViewModel()
        await viewModel.loadHelpData()
        
        XCTAssertFalse(viewModel.categories.isEmpty, "Help categories should load")
    }
    
    func testSearchWorks() async throws {
        let viewModel = HelpViewModel()
        await viewModel.loadHelpData()
        
        viewModel.searchQuery = "drug interaction"
        XCTAssertFalse(viewModel.searchResults.isEmpty, "Search should return results")
    }
    
    func testHelpHTMLExists() throws {
        let bundle = Bundle.main
        let htmlURL = bundle.url(forResource: "quick-start", withExtension: "html", subdirectory: "Help")
        XCTAssertNotNil(htmlURL, "Help HTML files should exist in bundle")
    }
}
```

---

## 📝 Maintenance

### Updating Help Content

1. **Edit wiki** markdown files in `FoTApple.wiki/`
2. **Re-run converter**:
   ```bash
   python3 scripts/convert_wiki_to_apple_help.py
   ```
3. **Commit** updated help bundle
4. **Build** and test

### Version Control

Add to `.gitignore` if you want to generate help at build time:
```
AppleHelp/
```

Or commit the help bundle for consistency:
```bash
git add AppleHelp/
git commit -m "Update help documentation"
```

### Automated Generation

Add to your build script:

```bash
# generate_help.sh
#!/bin/bash

echo "🔄 Generating Apple Help..."
python3 scripts/convert_wiki_to_apple_help.py

if [ $? -eq 0 ]; then
    echo "✅ Help generation complete"
else
    echo "❌ Help generation failed"
    exit 1
fi
```

Call from Xcode build phase:
1. **Build Phases** → **New Run Script Phase**
2. **Script**: `./generate_help.sh`
3. **Run based on dependency analysis**: Unchecked

---

## 🚀 Deployment

### App Store Requirements

- ✅ Help content must be family-friendly
- ✅ No external links without user permission
- ✅ Help must be accessible offline
- ✅ Respect user privacy (no tracking in help)

### TestFlight

Help is automatically included when you build for TestFlight:

```bash
xcodebuild archive \
  -scheme "FoTClinician iOS" \
  -archivePath "build/FoTClinician.xcarchive" \
  -configuration Release \
  HELP_BOOK_ENABLED=YES
```

### Distribution

The help system is:
- ✅ Bundled with your app (no separate download)
- ✅ Works offline
- ✅ Searchable
- ✅ Integrated with Apple's Help system
- ✅ Accessible via Spotlight (macOS)

---

## 📚 Resources

### Apple Documentation

- [Apple Help Programming Guide](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/ProvidingUserAssitAppleHelp/)
- [Help Book Bundle Structure](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/ProvidingUserAssitAppleHelp/authoring_help/authoring_help_book.html)
- [App Intents](https://developer.apple.com/documentation/appintents)

### FoT Apple Documentation

- [Wiki Home](../FoTApple.wiki/Home.md)
- [Quick Start](../FoTApple.wiki/Quick-Start.md)
- [App Intents](../FoTApple.wiki/Apple-Intelligence-Integration.md)

---

## 🆘 Troubleshooting

### Help Book Not Found (macOS)

**Problem**: Help menu doesn't open help book

**Solution**:
1. Verify `Info.plist` has correct help book settings
2. Check that `.help` bundle is in app bundle
3. Clean build folder and rebuild

### HTML Not Loading (iOS)

**Problem**: Help pages show "Content Not Available"

**Solution**:
1. Verify HTML files are in `Copy Bundle Resources`
2. Check file names match `help-data.json`
3. Ensure HTML files are in `Help` subdirectory

### Search Not Working

**Problem**: Search returns no results

**Solution**:
1. Verify `help-data.json` has keywords
2. Check JavaScript console for errors (macOS)
3. Test search with simple queries first

---

## ✅ Checklist

Before shipping:

- [ ] Help converter runs without errors
- [ ] All help pages render correctly
- [ ] Search functionality works
- [ ] Images display properly
- [ ] Light and dark mode both work
- [ ] Links between help pages work
- [ ] Help opens from menu (macOS)
- [ ] Help opens from button (iOS)
- [ ] Siri shortcuts work (if implemented)
- [ ] Help content is accurate and current
- [ ] No broken links
- [ ] No external dependencies
- [ ] Works offline
- [ ] Localized content complete (if applicable)

---

**Need Help?**

- 📧 Email: support@fortressai.com
- 🌐 Wiki: [FoTApple.wiki](../FoTApple.wiki/)
- 🐛 Issues: GitHub Issues

---

*Generated for FoT Apple v1.0 - October 2025*

