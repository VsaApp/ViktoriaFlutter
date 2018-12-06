package de.lohl1kohl.viktoriaflutter;

import com.onesignal.NotificationExtenderService;
import com.onesignal.OSNotificationReceivedResult;

import org.json.JSONException;

import de.lohl1kohl.viktoriaflutterplugin.ViktoriaflutterpluginPlugin;


public class NotificationService extends NotificationExtenderService {
    @Override
    protected boolean onNotificationProcessing(OSNotificationReceivedResult receivedResult) {
        try {
            ViktoriaflutterpluginPlugin.showReplacementPlanNotification(getApplication(), receivedResult.payload.toJSONObject().getJSONObject("additionalData").toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return true;
    }
}