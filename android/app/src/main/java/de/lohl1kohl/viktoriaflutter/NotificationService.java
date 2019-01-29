package de.lohl1kohl.viktoriaflutter;

import android.graphics.Color;
import android.support.v4.app.NotificationCompat;
import android.content.Intent;

import com.onesignal.NotificationExtenderService;
import com.onesignal.OSNotificationReceivedResult;

import org.json.JSONException;

import java.util.Arrays;

public class NotificationService extends NotificationExtenderService {

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }

    @Override
    protected boolean onNotificationProcessing(final OSNotificationReceivedResult receivedResult) {
        try {
            if (!receivedResult.payload.additionalData.getString("type").equals("silent")) {
                OverrideSettings overrideSettings = new OverrideSettings();
                if (receivedResult.payload.additionalData.getString("type").equals("replacementplan")) {
                    int changes = receivedResult.payload.body.length() - receivedResult.payload.body.replace("\n", "").length() + 1;
                    overrideSettings.extender = builder -> builder.setSmallIcon(R.mipmap.ic_launcher)
                            .setContentTitle(receivedResult.payload.title)
                            .setContentText(changes > 1 ? String.valueOf(changes) + " Änderungen" : receivedResult.payload.body)
                            .setColor(Color.parseColor("#ff5bc638"))
                            .setStyle(new NotificationCompat.BigTextStyle().bigText(receivedResult.payload.body))
                            .setVibrate(new long[]{100, 100});
                    overrideSettings.androidNotificationId = Arrays.asList(new String[]{"Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"}).indexOf(receivedResult.payload.title);
                } else {
                    overrideSettings.extender = builder -> builder.setSmallIcon(R.mipmap.ic_launcher)
                            .setContentTitle(receivedResult.payload.title)
                            .setContentText(receivedResult.payload.body)
                            .setColor(Color.parseColor("#ff5bc638"))
                            .setStyle(new NotificationCompat.BigTextStyle().bigText(receivedResult.payload.body))
                            .setVibrate(new long[]{250, 250});

                }
                displayNotification(overrideSettings);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return true;
    }
}
