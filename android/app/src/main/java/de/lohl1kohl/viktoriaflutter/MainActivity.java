package de.lohl1kohl.viktoriaflutter;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "viktoriaflutter";

    final static String[] channelsIds = new String[] {
        "replacementplan_channel",
        "messageboard_channel",
        "unitplan_channel",
        "cafetoria_channel",
        "calendar_channel"
    };

    final static String[] channelsInfos = new String[] {
        "Vertretungsplan-Änderungen des Vertretungsplans",
        "Schwarzes Brett-Alle neuen Nachrichten",
        "Stundenplan-Stundenplanänderungen",
        "Cafetoria-Neue Menüs",
        "Kalender-Alle Termiene"
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        NotificationService.flutterView = getFlutterView();

        String data = (String) getIntent().getStringExtra("channel");
        new MethodChannel(getFlutterView(), CHANNEL).invokeMethod("opened", data);
        System.out.println("Data: " + data);

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
                if (notificationManager != null) notificationManager.createNotificationChannel(channel);
            }
        }

        // Remove all notifications when app starting...
        NotificationManager notificationManager = (NotificationManager) getApplicationContext()
                .getSystemService(Context.NOTIFICATION_SERVICE);
        if (notificationManager != null) notificationManager.cancelAll();
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if (call.method.equals("clearNotifications")) {
                    NotificationManager notificationManager = (NotificationManager) getApplicationContext()
                            .getSystemService(Context.NOTIFICATION_SERVICE);
                    if (notificationManager != null) notificationManager.cancelAll();
                }
            }
        });
    }
}