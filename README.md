# sim_mis_app

SIM MIS App built with Flutter.

## Release Setup

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill the keystore values and point `storeFile` to your release keystore.
3. Place the `.jks` file in the path you choose.
4. Build release artifacts with:
   - `flutter build appbundle`
   - `flutter build apk --release`

If you want iOS release builds, open the iOS project in Xcode and set signing for the `Runner` target.
