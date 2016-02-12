package com.jamwix;

import openfl.events.Event;

class JWSwrveEvent extends Event 
{
	public static inline var PUSH_REGISTERED = "PUSH_REGISTERED"; 
	public static inline var PUSH_RECEIVED = "PUSH_RECEIVED"; 
	
	public var data:Dynamic;

	public function new (type:String, data:Dynamic = null) 
	{
		super(type);
		
		this.data = data;
	}
}
