package com.jamwix;


import java.lang.Runnable;
import java.util.Calendar;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.res.AssetManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.util.Log;

import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;

import org.json.JSONException;
import org.json.JSONObject;

import com.swrve.sdk.SwrveSDK;
import com.swrve.sdk.config.SwrveConfig;
import com.swrve.sdk.config.SwrveStack;
import com.swrve.sdk.gcm.ISwrvePushNotificationListener;

import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

/* 
	You can use the Android Extension class in order to hook
	into the Android activity lifecycle. This is not required
	for standard Java code, this is designed for when you need
	deeper integration.
	
	You can access additional references from the Extension class,
	depending on your needs:
	
	- Extension.assetManager (android.content.res.AssetManager)
	- Extension.callbackHandler (android.os.Handler)
	- Extension.mainActivity (android.app.Activity)
	- Extension.mainContext (android.content.Context)
	- Extension.mainView (android.view.View)
	
	You can also make references to static or instance methods
	and properties on Java classes. These classes can be included 
	as single files using <java path="to/File.java" /> within your
	project, or use the full Android Library Project format (such
	as this example) in order to include your own AndroidManifest
	data, additional dependencies, etc.
	
	These are also optional, though this example shows a static
	function for performing a single task, like returning a value
	back to Haxe from Java.
*/
public class JWSwrve extends Extension {

    private static Handler mHandler = new Handler(Looper.getMainLooper());
	
    private static final String TAG = "JWSwrve";

    private static boolean _initialized = false;
    private static String _pushData = "NULL";

	/**
	 * Called when an activity you launched exits, giving you the requestCode 
	 * you started it with, the resultCode it returned, and any additional data 
	 * from it.
	 */
	public boolean onActivityResult (int requestCode, int resultCode, Intent data) {
        Log.d(TAG, "onActivityResult");
		
		return true;
		
	}
	
	
	/**
	 * Called when the activity is starting.
	 */
	public void onCreate (Bundle savedInstanceState) {
	}

    public static void init(int appId, String apiKey, String senderId, String userId) {
        Log.i(TAG, "Initializing SWRVE");

        try {
            SwrveConfig config = SwrveConfig.withPush(senderId);
            config.setUserId(userId);
            config.setSelectedStack(SwrveStack.EU);
            SwrveSDK.createInstance(
                Extension.mainContext, appId, apiKey, config);

            SwrveSDK.setPushNotificationListener(new ISwrvePushNotificationListener() {
                @Override
                public void onPushNotification(Bundle bundle) {
                    Object rawData = bundle.get("data");
                    String data = (rawData != null) ? rawData.toString() : "NULL";
                    Log.i(TAG, "Got PUSH DATA: " + data);
                    _pushData = data;
               }
            });
 
            SwrveSDK.onCreate(Extension.mainActivity);
            _initialized = true;
        } catch (IllegalArgumentException exp) {
            Log.e(TAG, "Could not initialize the Swrve SDK", exp);
        }
    }
	
	
	/**
	 * Perform any final cleanup before an activity is destroyed.
	 */
	public void onDestroy () {
        if (_initialized) {
		    SwrveSDK.onDestroy(Extension.mainActivity);
        }
	}
	
	
	/**
	 * Called as part of the activity lifecycle when an activity is going into
	 * the background, but has not (yet) been killed.
	 */
	public void onPause () {
        if (_initialized) {
            SwrveSDK.onPause();
        }
	}
	
	
	/**
	 * Called after {@link #onStop} when the current activity is being 
	 * re-displayed to the user (the user has navigated back to it).
	 */
	public void onRestart () {
		
		
		
	}


	/**
	 * Called after {@link #onRestart}, or {@link #onPause}, for your activity 
	 * to start interacting with the user.
	 */
	public void onResume () {
        if (_initialized) {
		    SwrveSDK.onResume(Extension.mainActivity);
        }
	}
	
	
	/**
	 * Called after {@link #onCreate} &mdash; or after {@link #onRestart} when  
	 * the activity had been stopped, but is now again being displayed to the 
	 * user.
	 */
	public void onStart () {
		
		
		
	}
	
	
	/**
	 * Called when the activity is no longer visible to the user, because 
	 * another activity has been resumed and is covering this one. 
	 */
	public void onStop () {
		
		
		
	}

    public void onLowMemory() {
        if (_initialized) {
            SwrveSDK.onLowMemory();
        }
    }
	
    public static void logEvent(String title, String sParams) {
        if (!_initialized) {
            return;
        }
        JSONObject options;

        try {
            options = new JSONObject(sParams);
        } catch (JSONException e) {
            Log.e(TAG, "Unable to parse swrve event params");
            return;
        }

        Map<String, String> datamap = new HashMap<String, String>();
        Iterator<String> keysItr = options.keys();
        while (keysItr.hasNext()) {
            String key = keysItr.next();
            try {
                Object value = options.get(key);
                datamap.put(key, value.toString());
            } catch (JSONException e) {
                Log.e(TAG, "Unable to get value for key: " + key);
                return;
            }
        }

        if (datamap.isEmpty()) {
            SwrveSDK.event(title);
        } else {
            SwrveSDK.event(title, datamap);
        }
    }

    public static void userProperties(String sParams) {
        if (!_initialized) {
            return;
        }

        JSONObject options;

        try {
            options = new JSONObject(sParams);
        } catch (JSONException e) {
            Log.e(TAG, "Unable to parse swrve user params");
            return;
        }

        Map<String, String> datamap = new HashMap<String, String>();
        Iterator<String> keysItr = options.keys();
        while (keysItr.hasNext()) {
            String key = keysItr.next();
            try {
                Object value = options.get(key);
                datamap.put(key, value.toString());
            } catch (JSONException e) {
                Log.e(TAG, "Unable to get value for key: " + key);
                return;
            }
        }

        if (datamap.isEmpty()) {
            return;
        } else {
            SwrveSDK.userUpdate(datamap);
        }
    }

    public static void purchase(String item, String currency, int cost, int quantity) {
        if (!_initialized) {
            return;
        }
        SwrveSDK.purchase(item, currency, cost, quantity);
    }

    public static void currencyGiven(String givenCurrency, double givenAmount) {
        if (!_initialized) {
            return;
        }
        SwrveSDK.currencyGiven(givenCurrency, givenAmount);
    }

    public static void iapPlay(String productId, double productPrice, 
                               String currency, String receipt, 
                               String receiptSignature) {
        if (!_initialized) {
            return;
        }
        SwrveSDK.iapPlay(productId, productPrice, currency, receipt, 
                         receiptSignature);
    }

    public static String getPushData() {
        String data = _pushData;
        _pushData = "NULL";
        Log.i(TAG, "Returning push data: " + data);
        return data;
    }

    public static void scheduleNotification(int seconds) {
        AlarmManager alarmManager = (AlarmManager) Extension.mainActivity.getSystemService(Context.ALARM_SERVICE);

        Intent notificationIntent = new Intent("android.media.action.DISPLAY_NOTIFICATION");
        notificationIntent.addCategory("android.intent.category.DEFAULT");

        PendingIntent broadcast = PendingIntent.getBroadcast(Extension.mainActivity, 112980, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.SECOND, seconds);
        alarmManager.setExact(AlarmManager.RTC_WAKEUP, cal.getTimeInMillis(), broadcast);
    }

    public static void removeNotification() {
        AlarmManager alarmManager = (AlarmManager) Extension.mainActivity.getSystemService(Context.ALARM_SERVICE);

        Intent notificationIntent = new Intent("android.media.action.DISPLAY_NOTIFICATION");
        notificationIntent.addCategory("android.intent.category.DEFAULT");

        PendingIntent broadcast = PendingIntent.getBroadcast(Extension.mainActivity, 112980, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        alarmManager.cancel(broadcast);
    }
}
