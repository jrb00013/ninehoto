# Deployment

How to ship ninehoto to the Apple App Store (iOS) and Google Play (Android).

> Nothing here is automated by CI yet. Builds are produced locally or by a future release workflow.

## iOS — App Store

### 1. Enroll in the Apple Developer Program

- Register at the [Apple Developer Enrollment page](https://developer.apple.com/programs/enroll/) with your Apple ID.
- Pay the $99/year membership. It is required to publish.
- Pick an account type: **Individual** (publish as yourself) or **Organization** (needs a legal business name and a D-U-N-S number).

### 2. Configure App Store Connect

- **App ID:** in *Certificates, Identifiers & Profiles*, register the bundle ID. ninehoto uses `com.ninehoto.app` (see `ios/project.yml`). If you change it, change it in `project.yml` too.
- **App record:** in [App Store Connect](https://appstoreconnect.apple.com), click **+** under Apps → **New App** → iOS. Enter the name, primary language, bundle ID and a SKU.
- **Metadata:**
  - Display name, subtitle and category
  - Screenshots and app previews at the required sizes
  - Age-rating questionnaire
  - Privacy details (Privacy Nutrition Label). ninehoto collects no data and uploads no media, so answer "Data Not Collected". See [SECURITY.md](../SECURITY.md).
  - Pricing and regional availability

### 3. Build and archive

1. Generate the project and open it:
   ```bash
   cd ios
   xcodegen generate
   open Ninehoto.xcodeproj
   ```
2. Set up signing: select the **Ninehoto** target → *Signing & Capabilities* → enable **Automatically manage signing** and choose your team. `project.yml` does not set `DEVELOPMENT_TEAM`; add it there to keep it across regenerations:
   ```yaml
   settings:
     base:
       DEVELOPMENT_TEAM: YOURTEAMID
   ```
3. Set the version: bump `MARKETING_VERSION` (e.g. `1.0.0`) and `CURRENT_PROJECT_VERSION` (build number, must increase on every upload) in `ios/project.yml`, then re-run `xcodegen generate`.
4. Choose **Any iOS Device (arm64)** as the destination.
5. **Product → Archive**.
6. In the Organizer window click **Distribute App** → **App Store Connect** → follow the prompts to upload.

Command-line alternative:

```bash
cd ios
xcodebuild archive -project Ninehoto.xcodeproj -scheme Ninehoto \
  -destination 'generic/platform=iOS' -archivePath build/Ninehoto.xcarchive
xcodebuild -exportArchive -archivePath build/Ninehoto.xcarchive \
  -exportOptionsPlist ExportOptions.plist -exportPath build/export
```

(`ExportOptions.plist` with `method = app-store-connect` is not committed; create one for your team.)

### 4. Submit for review

1. In App Store Connect, open the app → the version → **Build** → attach the uploaded build (it appears after processing, usually a few minutes).
2. Answer the compliance questions (encryption: the app uses only standard OS encryption).
3. Click **Add for Review** / **Submit for Review**.
4. Review typically takes 24–48 hours. The app then releases automatically or manually, depending on your setting.

Before submitting, confirm the photo-library usage strings in `ios/Ninehoto/Info.plist` clearly explain why access is needed. Reviewers check this.

## Android — Google Play

1. Create a [Google Play Console](https://play.google.com/console) developer account (one-time $25 fee).
2. Create the app record using the application ID `com.ninehoto.app` (see `android/Ninehoto.Android/Ninehoto.Android.csproj`).
3. Create a release keystore and keep it, and its passwords, out of git:
   ```bash
   keytool -genkeypair -v -keystore ninehoto-release.keystore -alias ninehoto \
     -keyalg RSA -keysize 2048 -validity 10000
   ```
4. Bump `ApplicationVersion` (must increase every upload) and `ApplicationDisplayVersion` in the csproj.
5. Build a signed Android App Bundle (requires the .NET 8 SDK and the `android` workload; see `global.json`):
   ```bash
   dotnet publish android/Ninehoto.Android/Ninehoto.Android.csproj -c Release \
     -p:AndroidPackageFormat=aab -p:AndroidKeyStore=true \
     -p:AndroidSigningKeyStore=ninehoto-release.keystore \
     -p:AndroidSigningKeyAlias=ninehoto \
     -p:AndroidSigningKeyPass=env:KEYSTORE_PASSWORD \
     -p:AndroidSigningStorePass=env:KEYSTORE_PASSWORD
   ```
6. Upload the `.aab` to a Play Console track (internal testing first), complete the store listing, Data safety form (no data collected) and content rating, then roll out to production.
7. The app uses `READ_MEDIA_*` / storage permissions. Complete Play's permissions declaration for photo and video access if prompted.

## Release checklist

- [ ] Version and build numbers bumped on both platforms
- [ ] `CHANGELOG.md` updated
- [ ] CI green on the release commit
- [ ] Tested on a physical device (iOS, and Android both below and above API 30)
- [ ] Store screenshots and metadata current
- [ ] Git tag created, e.g. `git tag v1.0.0 && git push --tags`
