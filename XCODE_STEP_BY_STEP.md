# Xcode TestFlight Upload - Step by Step

## Apps to Upload (in order):

1. ✅ **PersonalHealthApp** (OPEN NOW - follow steps below)
2. ⏳ **ClinicianApp** (I'll open after #1 done)
3. ⏳ **ParentApp** (I'll open after #2 done)
4. ⏳ **EducationApp** (I'll open after #3 done)
5. ⏳ **LegalApp** (I'll open after #4 done)

---

## Steps for Each App (Same Process):

### Step 1: Select Device
- **Top left** of Xcode window
- Click the device/simulator selector
- Choose **"Any iOS Device (arm64)"**

### Step 2: Archive
- **Menu**: Product → Archive
- **Or press**: Cmd + Shift + B (⌘⇧B)
- **Status bar shows**: "Archiving PersonalHealthApp..."
- **Wait**: ~2 minutes

### Step 3: Organizer Opens
- Automatically appears when archive completes
- Your archive is listed with date/time
- Click **"Distribute App"** button (right side)

### Step 4: Choose Distribution Method
- Select **"TestFlight & App Store"**
- Click **"Next"**

### Step 5: Upload Option
- Select **"Upload"** (not Export)
- Click **"Next"**

### Step 6: Signing
- Check **"Automatically manage signing"** ✓
- Click **"Next"**
- Xcode creates certificates & profiles automatically

### Step 7: Review
- Review the app info
- Click **"Upload"**
- Progress bar shows upload status
- **Wait**: ~2-3 minutes

### Step 8: Success!
- You'll see **"Upload Successful"** ✓
- Click **"Done"**
- Come back here and type **"done"** in terminal

---

## After All 5 Apps Uploaded

### Verify in App Store Connect:
```bash
open https://appstoreconnect.apple.com/apps
```

You should see all 5 apps with:
- Status: "Prepare for Submission"
- TestFlight tab: Build processing (5-15 min)

### Add Yourself as Tester:
1. Click app → TestFlight tab
2. Internal Testing → Click "+"
3. Add your email
4. Accept invite on your iPhone
5. Install and test!

---

## Troubleshooting

### "No code signing identities found"
- Xcode → Settings → Accounts
- Click your Apple ID
- Click "Download Manual Profiles"

### "Archive option grayed out"
- Make sure "Any iOS Device" is selected (not simulator)
- Try: Product → Clean Build Folder (Cmd+Shift+K)

### "Upload failed"
- Check internet connection
- Try again (sometimes Apple servers are busy)

---

## Time Estimate

- Per app: 5 minutes (2 min archive + 3 min upload)
- All 5 apps: 25 minutes total
- Processing: Additional 5-15 min per app (happens in background)

---

**Current App**: PersonalHealthApp (Xcode is open)  
**Next Step**: Follow steps 1-8 above  
**When Done**: Type "done" in terminal

