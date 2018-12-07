package de.lohl1kohl.viktoriaflutterplugin;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.os.Build;
import android.support.v4.app.NotificationCompat;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * ViktoriaflutterpluginPlugin
 */
public class ViktoriaflutterpluginPlugin implements MethodCallHandler {
    Activity activity;

    public ViktoriaflutterpluginPlugin(Activity activity) {
        this.activity = activity;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "viktoriaflutterplugin");
        channel.setMethodCallHandler(new ViktoriaflutterpluginPlugin(registrar.activity()));
    }

    public static void showReplacementPlanNotification(Context context, String json) throws JSONException {
        createNotificationChannel(context);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, "replacementplan")
                .setSmallIcon(R.drawable.logo)
                .setContentTitle(new JSONObject(json).getString("weekday"))
                .setContentText("Ein neuer Vertretungsplan ist erschienen")
                .setVibrate(new long[]{250, 250, 250, 250})
                .setContentIntent(PendingIntent.getActivity(context, 0, context.getPackageManager().getLaunchIntentForPackage("de.lohl1kohl.viktoriaflutter"), PendingIntent.FLAG_UPDATE_CURRENT));
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.notify(new JSONObject(json).getString("day").equals("today") ? 0 : 1, builder.build());
    }


    private static void createNotificationChannel(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "replacementplan";
            String description = name.toString();
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(description, name, importance);
            channel.setDescription(description);
            NotificationManager notificationManager = context.getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }


    @Override
    public void onMethodCall(MethodCall call, Result result) {
        try {
            if (new JSONObject(call.method).getString("type").equals("replacementplan")) {
                showReplacementPlanNotification(activity, call.method);
                result.success(0);
            } else if (new JSONObject(call.method).getString("type").equals("clear")) {
                NotificationManager notificationManager = (NotificationManager) activity.getSystemService(Context.NOTIFICATION_SERVICE);
                notificationManager.cancelAll();
                result.success(0);
            } else {
                result.notImplemented();
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
