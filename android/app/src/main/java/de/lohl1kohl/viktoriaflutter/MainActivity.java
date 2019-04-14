package de.lohl1kohl.viktoriaflutter;

import android.app.ActivityManager;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Color;
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
            "Vertretungsplan-Änderungen des Vertretungsplans",
            "Stundenplan-Stundenplanänderungen",
            "Cafetoria-Neue Menüs",
            "Kalender-Alle Termine"
    };
    private static final String CHANNEL = "viktoriaflutter";

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        NotificationService.flutterView = getFlutterView();

        // If the android version is high enough, create the notification channels...
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            for (int i = 0; i < channelsIds.length; i++) {
                String name = channelsInfos[i].split("-")[0];
                String description = channelsInfos[i].split("-")[1];
                NotificationChannel channel = new NotificationChannel(channelsIds[i], name, importance);
                channel.setDescription(description);
                channel.setVibrationPattern(new long[]{500, 500});
                channel.enableVibration(true);
                // Register the channel with the system; you can't change the importance
                // or other notification behaviors after this
                NotificationManager notificationManager = getSystemService(NotificationManager.class);
                if (notificationManager != null)
                    notificationManager.createNotificationChannel(channel);
            }
        }

        // Remove all notifications when app starting...
        NotificationManager notificationManager = (NotificationManager) getApplicationContext()
                .getSystemService(Context.NOTIFICATION_SERVICE);
        if (notificationManager != null) notificationManager.cancelAll();
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