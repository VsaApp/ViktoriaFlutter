package de.lohl1kohl.viktoriaflutter;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.AudioManager;
import android.os.Vibrator;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Arrays;
import java.util.Map;
import java.util.Random;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterView;

public class NotificationService extends FirebaseMessagingService {
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
                        remoteMessage.getData().get("notificationTitle") + " " + remoteMessage.getData().get("notificationBody"),
                        remoteMessage.getData()
                );
                System.out.println("notify");
            } else {
                showNotification(
                        remoteMessage.getData().get("notificationTitle"),
                        remoteMessage.getData().get("notificationBody"),
                        remoteMessage.getData().get("notificationBody"),
                        remoteMessage.getData().get("type") + "_channel",
                        (new Random().nextInt() * 10000 + 5),
                        remoteMessage.getData().get("notificationTitle"),
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

    public void showNotification(String title, String body, String bodyLong, String channelId, int notificationId, String ticker, Map<String, String> data) {

        AudioManager am = (AudioManager) getApplicationContext().getSystemService(Context.AUDIO_SERVICE);

        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra("channel", channelId);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        int uniqueInt = (int) (System.currentTimeMillis() & 0xfffffff);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, uniqueInt, intent, PendingIntent.FLAG_CANCEL_CURRENT);

        NotificationCompat.Builder notification = new NotificationCompat.Builder(getApplicationContext(), channelId)
                .setContentTitle(title)
                .setContentText(body)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setStyle(new NotificationCompat.BigTextStyle().bigText(bodyLong))
                .setContentIntent(pendingIntent)
                .setTicker(ticker)
                .setColor(Color.parseColor("#ff5bc638"))
                .setGroup("group" + Integer.toString(notificationId))
                .setAutoCancel(true)
                .setColorized(true);

        if (am != null && am.getRingerMode() != AudioManager.RINGER_MODE_SILENT) {
            System.out.println("Vibrate");
            Vibrator v = (Vibrator) getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
            if (v != null) {
                v.vibrate(300);
            } else {
                notification.setVibrate(new long[]{300, 300});
            }
        } else {
            System.out.println("Silent");
            notification.setVibrate(new long[]{0});
        }

        NotificationManagerCompat manager = NotificationManagerCompat.from(getApplicationContext());
        manager.notify(notificationId, notification.build());
    }
}