package de.lohl1kohl.viktoriaflutter;

import android.os.Bundle;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static de.lohl1kohl.viktoriaflutter.NotificationService.showNotification;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "viktoriaflutter";

  @Override
  public void onCreate(Bundle savedInstanceState) {

    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
        new MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, Result result) {
                try {
                    if(new JSONObject(call.method).getString("type").equals("replacementplan")){
                        showNotification(call.method);
                        result.success(0);
                    }else{
                        result.notImplemented();
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
    });
  }
}