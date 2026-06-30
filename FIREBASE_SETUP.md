# Firebase Setup Guide — Digital Khata

Follow these steps exactly to connect your app to Firebase.

---

## Step 1: Create a Firebase Project

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click **"Add project"** → name it `digital-khata` (or anything you like)
3. Disable Google Analytics (optional, can enable later)
4. Click **"Create project"**

---

## Step 2: Enable Authentication

1. In the Firebase Console, go to **Build → Authentication**
2. Click **"Get started"**
3. Enable **Email/Password**:
   - Sign-in providers → Email/Password → Enable → Save
4. Enable **Phone**:
   - Sign-in providers → Phone → Enable → Save

---

## Step 3: Create Firestore Database

1. Go to **Build → Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in production mode"** (we'll add rules below)
4. Select your preferred region → Click **"Enable"**

### Firestore Security Rules

Go to **Firestore → Rules** tab and paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /customers/{customerId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;

        match /transactions/{transactionId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
  }
}
```

Click **"Publish"**.

---

## Step 4: Register Android App

1. In Firebase Console, click the **Android icon** (⊕ Add app)
2. **Android package name**: `com.example.digital_khata`
   _(Must exactly match the `applicationId` in `android/app/build.gradle`)_
3. App nickname: `Digital Khata Android`
4. Click **"Register app"**
5. **Download `google-services.json`**
6. Replace the placeholder file at:
   ```
   android/app/google-services.json
   ```
   with the real downloaded file.
7. Skip the rest of the wizard (SDK is already in pubspec.yaml)

---

## Step 5: Register iOS App

1. Click **+ Add app** → iOS icon
2. **iOS bundle ID**: `com.example.digitalKhata`
   _(Must match in Xcode: Runner → Signing & Capabilities → Bundle Identifier)_
3. App nickname: `Digital Khata iOS`
4. Click **"Register app"**
5. **Download `GoogleService-Info.plist`**
6. Replace the placeholder file at:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
   with the real downloaded file.
7. In Xcode, drag the `GoogleService-Info.plist` into the `Runner` folder in the project navigator (make sure "Copy items if needed" is checked)
8. Skip the rest of the wizard

---

## Step 6: Enable Phone Auth (SHA-1 for Android)

Phone number authentication requires a SHA-1 fingerprint for Android:

1. Run this command in your project root:
   ```bash
   cd android && ./gradlew signingReport
   ```
2. Copy the **SHA-1** from the debug keystore section
3. In Firebase Console → Project Settings → Your apps → Android app → **Add fingerprint**
4. Paste the SHA-1 → Save

---

## Step 7: Run the App

```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

---

## Firestore Data Structure

```
users/
  {uid}/
    ├── uid: string
    ├── email: string | null
    ├── phoneNumber: string | null
    ├── createdAt: timestamp
    └── lastLogin: timestamp

    customers/
      {customerId}/
        ├── name: string
        ├── phone: string | null
        ├── netBalance: number   ← positive=will get, negative=will give
        └── updatedAt: timestamp

        transactions/
          {transactionId}/
            ├── amount: number
            ├── type: 'in' | 'out'
            ├── remarks: string | null
            └── timestamp: timestamp
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `FirebaseException: No Firebase App '[DEFAULT]'` | Make sure `Firebase.initializeApp()` is called in `main()` before `runApp()` |
| Phone OTP not working on Android | Add SHA-1 fingerprint (Step 6) |
| `google-services.json` errors | Verify package name matches exactly in the file and `build.gradle` |
| iOS build fails | Ensure `GoogleService-Info.plist` is added to the Xcode project (not just the folder) |
| Firestore permission denied | Check Security Rules are published (Step 3) |
