# App Store Connect Requirements Checklist

## ✅ Screenshots (Required for iOS apps)

### Required Sizes:
- **iPhone 6.5"** (iPhone 14 Pro Max): 1284 x 2778 pixels
- **iPad 13"** (iPad Pro 12.9"): 2048 x 2732 pixels

### To Generate:
```bash
./scripts/generate_app_store_screenshots.sh
```

Screenshots will be saved to: `app_store_screenshots/`

### Upload to App Store Connect:
1. Go to App Store Connect → Your App
2. Click "App Store" tab
3. Scroll to "Screenshots"
4. Upload required sizes for each app

---

## 📋 App Metadata Requirements

### 1. Primary Category (Required for ALL apps)

**Recommended for Field of Truth apps:**
- **PersonalHealthApp**: Medical
- **ClinicianApp**: Medical
- **EducationApp**: Education
- **ParentApp**: Education
- **LegalApp**: Reference

---

### 2. Privacy Policy URL (Required)

Create a privacy policy page and add URL:

**Recommended Structure:**
```
https://yourdomain.com/privacy-policy
```

**Or use placeholder:**
```
https://fieldoftruth.com/privacy-policy
```

For each app in App Store Connect:
1. Go to **App Privacy** section
2. Click "Edit" on Privacy Policy URL
3. Enter your privacy policy URL

---

### 3. Age Rating (Required)

All apps need age rating with content descriptions.

**Recommended settings for Field of Truth apps:**

#### Medical Apps (PersonalHealthApp, ClinicianApp):
- **Medical/Treatment Information**: Frequent/Intense
- **Unrestricted Web Access**: None
- **Cartoon or Fantasy Violence**: None
- **Realistic Violence**: None
- **Profanity or Crude Humor**: None
- **Sexual Content or Nudity**: None
- **Alcohol, Tobacco, or Drug Use or References**: None
- **Gambling and Contests**: None
- **Horror/Fear Themes**: None
- **Mature/Suggestive Themes**: None
- **Simulated Gambling**: None
- **Contests**: None

**Age Rating Result**: 4+ (or appropriate for medical apps)

#### Education Apps (EducationApp, ParentApp):
- All content: None/Frequent as appropriate
- **Age Rating Result**: 4+ or 9+ depending on content

#### Legal App:
- **Unrestricted Web Access**: None
- Other content: None
- **Age Rating Result**: 4+

---

## 📝 Quick Setup Guide

### For Each App in App Store Connect:

1. **Screenshots**:
   - Upload from `app_store_screenshots/` folder
   - iPhone 6.5" and iPad 13" required

2. **Primary Category**:
   - Go to App Information → Primary Category
   - Select: Medical, Education, or Reference as appropriate

3. **Privacy Policy**:
   - Go to App Privacy → Privacy Policy URL
   - Enter: `https://fieldoftruth.com/privacy-policy` (or your URL)

4. **Age Rating**:
   - Go to App Information → Age Rating
   - Answer content questions
   - Save rating

---

## 🚀 After Completing Requirements

Once all requirements are met:
1. Builds will be eligible for App Store Review
2. Submit each app for review
3. Apps will appear in App Store after approval

