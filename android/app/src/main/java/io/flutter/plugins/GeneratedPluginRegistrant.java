package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.javih.add2calendar.Add2CalendarPlugin;
import com.notrait.deviceid.DeviceIdPlugin;
import io.flutter.plugins.deviceinfo.DeviceInfoPlugin;
import io.flutter.plugins.firebase.core.FirebaseCorePlugin;
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
import io.flutter.plugins.firebasemlvision.FirebaseMlVisionPlugin;
import io.github.edufolly.fluttermobilevision.FlutterMobileVisionPlugin;
import com.example.flutternativeimage.FlutterNativeImagePlugin;
import io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import io.flutter.plugins.urllauncher.UrlLauncherPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    Add2CalendarPlugin.registerWith(registry.registrarFor("com.javih.add2calendar.Add2CalendarPlugin"));
    DeviceIdPlugin.registerWith(registry.registrarFor("com.notrait.deviceid.DeviceIdPlugin"));
    DeviceInfoPlugin.registerWith(registry.registrarFor("io.flutter.plugins.deviceinfo.DeviceInfoPlugin"));
    FirebaseCorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.core.FirebaseCorePlugin"));
    FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
    FirebaseMlVisionPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemlvision.FirebaseMlVisionPlugin"));
    FlutterMobileVisionPlugin.registerWith(registry.registrarFor("io.github.edufolly.fluttermobilevision.FlutterMobileVisionPlugin"));
    FlutterNativeImagePlugin.registerWith(registry.registrarFor("com.example.flutternativeimage.FlutterNativeImagePlugin"));
    FluttertoastPlugin.registerWith(registry.registrarFor("io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin"));
    ImagePickerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
    UrlLauncherPlugin.registerWith(registry.registrarFor("io.flutter.plugins.urllauncher.UrlLauncherPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
