package de.lohl1kohl.viktoriaflutter;

import android.graphics.Color;
import android.support.v4.app.NotificationCompat;

import com.onesignal.NotificationExtenderService;
import com.onesignal.OSNotificationReceivedResult;

import org.json.JSONException;

public class NotificationService extends NotificationExtenderService {
    @Override
    protected boolean onNotificationProcessing(final OSNotificationReceivedResult receivedResult) {
        try {
            if (!receivedResult.payload.additionalData.getString("type").equals("silent")) {
                OverrideSettings overrideSettings = new OverrideSettings();
                if (receivedResult.payload.additionalData.getString("type").equals("replacementplan")) {
                    overrideSettings.extender = builder -> builder.setSmallIcon(R.mipmap.ic_launcher)
                            .setContentTitle(receivedResult.payload.title)
                            .setContentText(String.valueOf(receivedResult.payload.body.length() - receivedResult.payload.body.replace("\n", "").length() + 1) + " Änderungen")
                            .setColor(Color.parseColor("#ff5bc638"))
                            .setStyle(new NotificationCompat.BigTextStyle().bigText(receivedResult.payload.body))
                            .setVibrate(new long[]{100, 100});
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
