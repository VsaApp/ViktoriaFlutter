//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <add_2_calendar/Add2CalendarPlugin.h>
#import <device_id/DeviceIdPlugin.h>
#import <device_info/DeviceInfoPlugin.h>
#import <firebase_core/FirebaseCorePlugin.h>
#import <firebase_messaging/FirebaseMessagingPlugin.h>
#import <flutter_mobile_vision/FlutterMobileVisionPlugin.h>
#import <shared_preferences/SharedPreferencesPlugin.h>
#import <url_launcher/UrlLauncherPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [Add2CalendarPlugin registerWithRegistrar:[registry registrarForPlugin:@"Add2CalendarPlugin"]];
  [DeviceIdPlugin registerWithRegistrar:[registry registrarForPlugin:@"DeviceIdPlugin"]];
  [FLTDeviceInfoPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTDeviceInfoPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FLTFirebaseMessagingPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseMessagingPlugin"]];
  [FlutterMobileVisionPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterMobileVisionPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
  [FLTUrlLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTUrlLauncherPlugin"]];
}

@end
