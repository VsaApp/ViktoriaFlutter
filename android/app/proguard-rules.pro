#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

-keepattributes Signature -keep class com.firebase.** { *; }
-dontwarn android.support.v4.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**