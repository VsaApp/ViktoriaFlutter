package de.lohl1kohl.viktoriaflutter;

import android.app.PendingIntent;
import android.app.TaskStackBuilder;
import android.content.Context;
import android.os.Build;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.graphics.Color;
import android.os.Vibrator;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;
import android.content.Intent;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;


import org.json.JSONException;

import java.util.HashMap;
import java.util.Map;
import java.util.Arrays;
import java.util.Random;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterView;

public class NotificationService extends FirebaseMessagingService  {
    private static final String CHANNEL = "viktoriaflutter";
    static public FlutterView flutterView;

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);

        System.out.println("Start service");
        System.out.println(remoteMessage.getNotification());
        System.out.println(remoteMessage.getData());

        if (remoteMessage.getNotification() == null && remoteMessage.getData().get("notificationTitle") != null) {            
            if (remoteMessage.getData().get("type").equals("replacementplan")) {
                int changes = remoteMessage.getData().get("notificationBody").length() - remoteMessage.getData().get("notificationBody").replace("\n", "").length() + 1;
                showNotification(
                        remoteMessage.getData().get("notificationTitle"),
                        changes > 1 ? String.valueOf(changes) + " Änderungen" : remoteMessage.getData().get("notificationBody"),
                        remoteMessage.getData().get("notificationBody"),
                        "replacementplan_channel",
                        Arrays.asList(new String[]{"Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"}).indexOf(remoteMessage.getData().get("notificationTitle")),
                        remoteMessage.getData()
                );
                System.out.println("notify");
            } else {
                showNotification(
                    remoteMessage.getData().get("notificationTitle"),
                    remoteMessage.getData().get("notificationBody"),
                    remoteMessage.getData().get("notificationBody"),
                    remoteMessage.getData().get("type") +  "_channel",
                    (new Random().nextInt() * 10000 + 5),
                    remoteMessage.getData()
                );
            }
        } else if (remoteMessage.getNotification() == null) {
            System.out.println("Launch listener...");
            informGui(remoteMessage.getData().get("type"), remoteMessage.getData());
        }
    }

    public void informGui(String type, Map<String, String> data) {
        new MethodChannel(flutterView, CHANNEL).invokeMethod(type, data);
    }

    public void showNotification(String title, String body, String bodyLong, String channelId, int notificationId, Map<String, String> data) {

        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra("channel", channelId);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);

        Vibrator v = (Vibrator) getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
        // Vibrate for 500 milliseconds
        v.vibrate(500);

        NotificationCompat.Builder notification = new NotificationCompat.Builder(getApplicationContext(), channelId)
                .setContentTitle(title)
                .setContentText(body)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setStyle(new NotificationCompat.BigTextStyle().bigText(bodyLong))
                .setContentIntent(pendingIntent)
                //.setSound()
                .setVibrate(new long[]{500, 500})
                .setColor(Color.parseColor("#ff5bc638"))
                .setGroup("group" + Integer.toString(notificationId))
                .setAutoCancel(true)
                .setColorized(true);

        NotificationManagerCompat manager = NotificationManagerCompat.from(getApplicationContext());
        manager.notify(notificationId, notification.build());
    }
}