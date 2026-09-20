# Firebase Push Notification Setup

The Flutter application now contains the Firebase Cloud Messaging integration layer. The app remains usable when Firebase is not configured; push registration is skipped and the failure is logged in debug output.

## Android

1. Create/select the Church of Uganda Youth Platform project in Firebase.
2. Register the Android application with this production application ID:
   `org.churchofuganda.youth`
3. Download `google-services.json` and place it at:
   `android/app/google-services.json`
4. Do not commit that file. It is ignored by `.gitignore`.

The Google Services Gradle plugin is already configured in `android/settings.gradle.kts` and applied in `android/app/build.gradle.kts`.

## iOS

1. Use the same organisational identifier where possible: `org.churchofuganda.youth`.
2. The Xcode Runner target still needs its `PRODUCT_BUNDLE_IDENTIFIER` changed from the generated Flutter placeholder to the final Church of Uganda identifier before Firebase/App Store registration.
3. Download `GoogleService-Info.plist`.
4. Add it to the Runner target in Xcode at `ios/Runner/GoogleService-Info.plist`.
5. Enable Push Notifications and Background Modes > Remote notifications in the Runner target.
6. Upload the APNs authentication key/certificate in Firebase Console.
7. Do not commit the plist file. It is ignored by `.gitignore`.

## Flutter dependencies

Run:

```bash
flutter pub get
```

This updates `pubspec.lock` for:

- `firebase_core`
- `firebase_messaging`

Commit the regenerated `pubspec.lock` after confirming the build succeeds.

## Application flow

When an authenticated session is restored or a user signs in:

1. Firebase is initialized.
2. Notification permission is requested.
3. The FCM/APNs token is retrieved.
4. The token is registered with `POST /api/v1/devices`.
5. Token refreshes are automatically re-registered.
6. On sign-out, the current token is removed through `DELETE /api/v1/devices`.

The Laravel API therefore never needs Firebase client configuration files and the Flutter app does not contain backend secrets.
