package de.lohl1kohl.viktoriaflutter;

import android.app.ActivityManager;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    final static String[] channelsIds = new String[]{
            "replacementplan_channel",
            "unitplan_channel",
            "cafetoria_channel",
            "calendar_channel"
    };
    final static String[] channelsInfos = new String[]{
            "Vertretungsplan-Änderungen des Vertretungsplans", // 0-4
            "Stundenplan-Stundenplanänderungen", // 5+
            "Cafetoria-Neue Menüs", // 5+
            "Kalender-Alle Termine" // 5+
    };
    private static final String CHANNEL = "viktoriaflutter";

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        NotificationService.flutterView = getFlutterView();

        NotificationManager notificationManager = (NotificationManager) getApplicationContext()
                .getSystemService(Context.NOTIFICATION_SERVICE);

        // If the android version is high enough, create the notification channels...
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            for (int i = 0; i < channelsIds.length; i++) {
                String name = channelsInfos[i].split("-")[0];
                String description = channelsInfos[i].split("-")[1];
                NotificationChannel channel = new NotificationChannel(channelsIds[i], name, i == 0 ? NotificationManager.IMPORTANCE_HIGH : NotificationManager.IMPORTANCE_DEFAULT);
                channel.setDescription(description);
                channel.setVibrationPattern(new long[]{500, 500});
                channel.enableVibration(true);
                if (i == 0) {
                    Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                    if (defaultSoundUri != null) {
                        AudioAttributes att = new AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                .build();
                        channel.setSound(defaultSoundUri, att);
                    }
                }
                // Register the channel with the system; you can't change the importance
                // or other notification behaviors after this
                if (notificationManager != null)
                    notificationManager.createNotificationChannel(channel);
            }
        }

        // Remove all notifications when app starting...
        if (notificationManager != null) {
            notificationManager.cancel(0);
            notificationManager.cancel(1);
            notificationManager.cancel(2);
            notificationManager.cancel(3);
            notificationManager.cancel(4);
        }
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler((call, result) -> {
            if (call.method.equals("clearNotifications")) {
                NotificationManager notificationManager1 = (NotificationManager) getApplicationContext()
                        .getSystemService(Context.NOTIFICATION_SERVICE);
                if (notificationManager1 != null) notificationManager1.cancelAll();
            } else if (call.method.equals("channelRegistered")) {
                String data = getIntent().getStringExtra("channel");
                new MethodChannel(getFlutterView(), CHANNEL).invokeMethod("opened", data);
                System.out.println("Data: " + data);
            } else if (call.method.equals("applyTheme")) {
                if (Build.VERSION.SDK_INT >= 21) {
                    MainActivity.this.setTaskDescription(new ActivityManager.TaskDescription(
                            "VsaApp",
                            BitmapFactory.decodeResource(getResources(), R.drawable.logo_white),
                            Color.parseColor("#" + call.argument("color"))
                    ));
                }
            }
        });
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        String data = getIntent().getStringExtra("channel");
        new MethodChannel(getFlutterView(), CHANNEL).invokeMethod("opened", data);
    }
}