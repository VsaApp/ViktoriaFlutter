# Build our app like usual
flutter build apk --release

### BEGIN MODIFICATIONS

# Copy mergeJniLibs to debugSymbols
cp -R ./build/app/intermediates/transforms/mergeJniLibs/release/0/lib debugSymbols

# The libflutter.so here is the same as in the artifacts.zip found with symbols.zip
cd debugSymbols/armeabi-v7a

# Download the corresponding libflutter.so with debug symbols
ENGINE_VERSION=`cat $HOME/flutter/bin/internal/engine.version`
gsutil cp gs://flutter_infra/flutter/${ENGINE_VERSION}/android-arm-release/symbols.zip .

# Replace libflutter.so
unzip -o symbols.zip
rm -rf symbols.zip

# Upload symbols to Crashlytics
cd ../../android
./gradlew crashlyticsUploadSymbolsRelease

### END MODIFICATIONS

cd ..
flutter install
adb shell am start -n de.lohl1kohl.viktoriaflutter/de.lohl1kohl.viktoriaflutter.MainActivity
adb logcat -c
adb logcat