# Apple Help Quick Start

Get your wiki converted to Apple Help in 5 minutes.

---

## 🚀 Quick Setup

### Step 1: Generate Help Files (2 minutes)

```bash
cd /Users/richardgillespie/Documents/FoTApple
./scripts/generate_help.sh
```

This will:
- ✅ Install Python dependencies
- ✅ Convert all wiki markdown to HTML
- ✅ Generate macOS Help Bundle
- ✅ Generate iOS Help Resources
- ✅ Copy images and assets

### Step 2: Add to Xcode (2 minutes)

#### For macOS Apps:

1. Open Xcode project
2. Drag `AppleHelp/FoTHelp.help` into your project
3. In each macOS app's `Info.plist`, add:

```xml
<key>CFBundleHelpBookFolder</key>
<string>FoTHelp.help</string>
<key>CFBundleHelpBookName</key>
<string>com.fortressai.fot.help</string>
```

4. Build and run
5. Press `⌘?` to open help

#### For iOS Apps:

1. Add `Sources/FoTUI/Help/HelpView.swift` to your project (if not already included)
2. Drag `AppleHelp/iOS/` contents into your app's `Help` resource folder
3. Add help button to your UI:

```swift
import FoTUI

struct SettingsView: View {
    @State private var showHelp = false
    
    var body: some View {
        Button("Help") {
            showHelp = true
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
    }
}
```

### Step 3: Test (1 minute)

**macOS:**
- Press `⌘?` → Help should open
- Try searching → Results should appear
- Click links → Pages should navigate

**iOS:**
- Tap Help button → Help screen appears
- Search for topics → Results filter
- Tap topic → Detail view opens

---

## 🎨 Customization

### Update Help Content

1. Edit files in `FoTApple.wiki/`
2. Run `./scripts/generate_help.sh`
3. Rebuild your app

### Change Styling

Edit `AppleHelp/FoTHelp.help/Contents/Resources/css/apple-help.css`

### Add Images

1. Add to `FoTApple.wiki/screenshots/`
2. Re-run generator
3. Reference in markdown: `![Image](../images/yourimage.png)`

---

## 📚 What's Included

Your help system includes:

- ✅ **60+ help pages** from your wiki
- ✅ **Categorized topics** (Getting Started, Apps, Compliance, Support)
- ✅ **Full-text search** (macOS and iOS)
- ✅ **Beautiful UI** with glass morphism
- ✅ **Light/Dark mode** support
- ✅ **Offline access** (no internet required)
- ✅ **Deep linking** to specific topics
- ✅ **Localization ready** (7 languages in wiki)

---

## 🔗 Help Topics Generated

Your help system includes these main categories:

### Getting Started
- Quick Start Guide
- Installation
- Platform Overview
- TestFlight Distribution

### Apps
- Clinician App (94.2% medical accuracy)
- Personal Health App
- Legal US App
- Education K-18 App

### Compliance
- HIPAA Compliance
- FERPA Compliance
- GCP Compliance

### Technical
- Apple Intelligence Integration
- QFOT Blockchain
- Multimodal AI
- App Intents

### Support
- FAQ (English, Spanish, French, Chinese)
- Troubleshooting
- Contact Support

---

## 🎯 User Experience

### macOS

Users can:
1. **Press `⌘?`** from anywhere in your app
2. **Search** using Apple's help viewer
3. **Navigate** between topics
4. **Find via Spotlight** - help content is automatically indexed

### iOS/iPadOS

Users can:
1. **Tap Help** button in settings or toolbar
2. **Search** inline within the help screen
3. **Browse** by category
4. **Read offline** - all content bundled with app

---

## ✅ App Store Compliance

Your help system is:
- ✅ **Fully offline** - no internet required
- ✅ **Privacy-focused** - no tracking
- ✅ **Accessible** - supports VoiceOver
- ✅ **Family-friendly** - appropriate for all ages
- ✅ **App Store ready** - meets all requirements

---

## 🚀 Advanced Features

### Contextual Help

Show help for specific screens:

```swift
HelpView(initialTopic: "drug-interaction-checker")
```

### Siri Integration

Add to App Intents:

```swift
struct ShowHelpIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Help"
    
    func perform() async throws -> some IntentResult {
        // Show help
        return .result()
    }
}
```

Users can say:
- "Hey Siri, show FoT Apple help"
- "Hey Siri, I need help with drug interactions"

### Deep Linking

Link to specific topics from your app:

```swift
// From notification
.onOpenURL { url in
    if url.scheme == "fothelp" {
        showHelp(topic: url.host)
    }
}
```

---

## 📊 Analytics (Optional)

Track help usage (privacy-friendly):

```swift
// In HelpView
.onAppear {
    Analytics.logEvent("help_opened")
}

// When topic opened
.onChange(of: viewModel.selectedTopic) { topic in
    if let topic = topic {
        Analytics.logEvent("help_topic_viewed", 
            parameters: ["topic": topic.id])
    }
}
```

---

## 🔄 Continuous Updates

### Automated Generation

Add to your CI/CD:

```yaml
# GitHub Actions example
- name: Generate Help
  run: ./scripts/generate_help.sh
  
- name: Verify Help
  run: |
    test -d AppleHelp/FoTHelp.help
    test -f AppleHelp/iOS/help-data.json
```

### Version Control

Recommended `.gitignore`:

```
# Only if regenerating help on each build
AppleHelp/

# Otherwise, commit the help bundle
# (recommended for consistency)
```

---

## 🆘 Troubleshooting

### "Help Book Not Found"

**Fix**: Check `Info.plist` has correct help book name

### "Help Pages Not Loading"

**Fix**: Ensure files are in "Copy Bundle Resources" in Xcode

### "Search Returns Nothing"

**Fix**: Verify `help-data.json` was generated with keywords

### "Images Not Displaying"

**Fix**: Check image paths are relative: `../images/filename.png`

---

## 📚 Full Documentation

For complete details, see:
- [APPLE_HELP_INTEGRATION.md](APPLE_HELP_INTEGRATION.md) - Complete integration guide
- [FoTApple.wiki/](../FoTApple.wiki/) - Source wiki content
- [Apple Help Programming Guide](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/ProvidingUserAssitAppleHelp/)

---

## ✨ That's It!

You now have a professional, Apple-compliant help system that:
- Works on macOS, iOS, and iPadOS
- Includes all your wiki content
- Is searchable and navigable
- Looks beautiful
- Works offline
- Is App Store ready

**Happy shipping! 🚀**

---

*Need help? Email support@fortressai.com*

