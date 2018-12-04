package de.lohl1kohl.viktoriaflutter;

import android.util.Log;

import com.onesignal.OSNotificationReceivedResult;
import com.onesignal.NotificationExtenderService;

import org.json.JSONException;

public class NotificationService extends NotificationExtenderService {
    @Override
    protected boolean onNotificationProcessing(OSNotificationReceivedResult receivedResult) {
        try {
            showNotification(receivedResult.payload.toJSONObject().getJSONObject("additionalData").toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return true;
    }

    public static void showNotification(String json) {
        Log.i("payload", json);
        // TODO: Implement notification logic
    }
}