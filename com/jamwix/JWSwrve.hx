package com.jamwix;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

import com.jamwix.JWSwrveEvent;

import openfl.events.EventDispatcher;
import openfl.events.Event;

import haxe.Json;

#if (android && openfl)
import openfl.utils.JNI;
#end


class JWSwrve {
	
	private static var dispatcher = new EventDispatcher ();

	public static function init(appId:Int, appKey:String, userId:String, senderId:String = null, launchOptions:String = "{}"):Void 
	{
		#if android
		jwswrve_init(appId, appKey, senderId, userId);
		#elseif ios
		set_event_handle(notifyListeners);
		jwswrve_init(appId, appKey, userId, launchOptions);
		#end
	}
	
	public static function logEvent(eventName:String, dParams:Dynamic = null):Void
	{
		#if (android || ios)
		var sParams = "{}";
		try 
		{
			if (dParams != null)
			{
				sParams = Json.stringify(dParams);
			}
		}
		catch (err:String)
		{
			trace("Unable to stringify swrve params");
			return;
		}

		jwswrve_log_event(eventName, sParams);
		#end
	}

	public static function userProperties(dParams:Dynamic):Void 
	{
		#if (android || ios)
		var sParams = "{}";
		try 
		{
			if (dParams != null)
			{
				sParams = Json.stringify(dParams);
			}
		}
		catch (err:String)
		{
			trace("Unable to stringify swrve params");
			return;
		}

		jwswrve_user_properties(sParams);
		#end
	}

	public static function purchase(item:String, currency:String, cost:Int, quantity:Int):Void
	{
		#if (android || ios)
		jwswrve_purchase(item, currency, cost, quantity);
		#end
	}

	public static function currencyGiven(currency:String, amount:Float):Void
	{
		#if (android || ios)
		jwswrve_currency_given(currency, amount);
		#end
	}

	public static function iapPlay(id:String, price:Float, currency:String, receipt:String, signature:String):Void
	{
		#if (android)
		jwswrve_iap_play(id, price, currency, receipt, signature);
		#end
	}

	public static function iapApple(currency:String, cost:Float, productId:String, transId:String, receipt:String, rewardType:String, rewardCount:Int):Void
	{
		#if ios
		var opts:Dynamic =
		{
			currency: currency,
			cost: cost,
			productId: productId,
			transId: transId,
			receipt: receipt,
			rewardType: rewardType,
			rewardCount: rewardCount
		};

		var sOpts = null;
		try 
		{
			sOpts = Json.stringify(opts);
		}
		catch (err:String)
		{
			trace("unable ot stringify iapApple opts");
			return;
		}

		jwswrve_iap_apple(sOpts);
		#end
	}

	public static function scheduleNotification(message:String, uid:String, seconds:Int):Void
	{
		#if ios
		jwswrve_schedule_notification(message, uid, seconds);
		#end
	}

	public static function removeNotification(uid:String):Void
	{
		#if ios
		jwswrve_remove_notification(uid); 
		#end
	}

	public static function getPushData():String
	{
		#if (android)
		return jwswrve_get_push_data();
		#else
		return null;
		#end
	}

	public static function remoteNotificationsEnabled():Bool
	{
		#if ios
		return jwswrve_remote_notifications_enabled();
		#end

		return true;
	}

	public static function setDeviceToken(token:String):Void
	{
		#if ios
		jwswrve_set_device_token(token);
		#end
	}

	public static function receivedNotification(userInfo:String):Void
	{
		#if ios
		jwswrve_received_notification(userInfo);
		#end
	}

	public static function dispatchEvent (event:Event):Bool 
	{
		return dispatcher.dispatchEvent (event);
	}

	public static function addEventListener (type:String, listener:Dynamic):Void 
	{
		dispatcher.addEventListener(type, listener);
	}

	public static function removeEventListener (type:String, listener:Dynamic):Void 
	{
		dispatcher.removeEventListener(type, listener);
	}

	private static function notifyListeners(inEvent:Dynamic):Void
	{
		
		#if ios
		
		var type = Std.string (Reflect.field (inEvent, "type"));
		var data = Std.string (Reflect.field (inEvent, "data"));
		
		switch (type) {
			
			case "PUSH_REGISTERED":
				
				dispatchEvent(new JWSwrveEvent(JWSwrveEvent.PUSH_REGISTERED, data));

			case "PUSH_RECEIVED":
				
				dispatchEvent(new JWSwrveEvent(JWSwrveEvent.PUSH_RECEIVED, data));

			default:
			
		}

		#end
	}

	#if android
	private static var jwswrve_init = JNI.createStaticMethod(
		"com.jamwix.JWSwrve",
		"init",
		"(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	private static var jwswrve_log_event = JNI.createStaticMethod(
		"com.jamwix.JWSwrve",
		"logEvent",
		"(Ljava/lang/String;Ljava/lang/String;)V"
	);
	private static var jwswrve_user_properties = JNI.createStaticMethod(
		"com.jamwix.JWSwrve",
		"userProperties",
		"(Ljava/lang/String;)V"
	);
	private static var jwswrve_purchase = JNI.createStaticMethod(
		"com.jamwix.JWSwrve",
		"purchase",
		"(Ljava/lang/String;Ljava/lang/String;II)V"
	);
	private static var jwswrve_currency_given = JNI.createStaticMethod(
		"com.jamwix.JWSwrve",
		"currencyGiven",
		"(Ljava/lang/String;D)V"	
	);
	private static var jwswrve_iap_play = JNI.createStaticMethod(
		"com.jamwix.JWSwrve",
		"iapPlay",
		"(Ljava/lang/String;DLjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
	);
	private static var jwswrve_get_push_data = JNI.createStaticMethod(
		"com.jamwix.JWSwrve",
		"getPushData",
		"()Ljava/lang/String;"
	);
	#elseif ios
	private static var set_event_handle = Lib.load("jwswrve", "jwswrve_set_event_handle", 1);
	private static var jwswrve_init = Lib.load("jwswrve", "jwswrve_init", 4);
	private static var jwswrve_log_event = Lib.load("jwswrve", "jwswrve_log_event", 2);
	private static var jwswrve_user_properties = Lib.load("jwswrve", "jwswrve_user_properties", 1);
	private static var jwswrve_purchase = Lib.load("jwswrve", "jwswrve_purchase", 4);
	private static var jwswrve_currency_given = Lib.load("jwswrve", "jwswrve_currency_given", 2);
	private static var jwswrve_iap_apple = Lib.load("jwswrve", "jwswrve_iap_apple", 1);
	private static var jwswrve_schedule_notification = Lib.load("jwswrve", "jwswrve_schedule_notification", 3);
	private static var jwswrve_remove_notification = Lib.load("jwswrve", "jwswrve_remove_notification", 1);
	private static var jwswrve_remote_notifications_enabled = Lib.load("jwswrve", "jwswrve_remote_notifications_enabled", 0);
	private static var jwswrve_set_device_token = Lib.load("jwswrve", "jwswrve_set_device_token", 1);
	private static var jwswrve_received_notification = Lib.load("jwswrve", "jwswrve_received_notification", 1);
	#end
}
