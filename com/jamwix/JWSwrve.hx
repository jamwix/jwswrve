package com.jamwix;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

import openfl.events.EventDispatcher;
import openfl.events.Event;

import haxe.Json;

#if (android && openfl)
import openfl.utils.JNI;
#end


class JWSwrve {
	
	public static function init(appId:Int, appKey:String, senderId:String, userId:String):Void 
	{
		#if android
		jwswrve_init(appId, appKey, senderId, userId);
		#end
	}
	
	public static function logEvent(eventName:String, dParams:Dynamic = null):Void
	{
		#if (android)
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
		#if (android)
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
		#if (android)
		jwswrve_purchase(item, currency, cost, quantity);
		#end
	}

	public static function currencyGiven(currency:String, amount:Float):Void
	{
		#if (android)
		jwswrve_currency_given(currency, amount);
		#end
	}

	public static function iapPlay(id:String, price:Float, currency:String, receipt:String, signature:String):Void
	{
		#if (android)
		jwswrve_iap_play(id, price, currency, receipt, signature);
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
	#end
}
