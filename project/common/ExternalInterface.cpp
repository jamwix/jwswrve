#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include <stdio.h>
#include "JWSwrve.h"


using namespace jwswrve;

AutoGCRoot* swrve_event_handle = 0;

static value jwswrve_set_event_handle(value onEvent)
{
	swrve_event_handle = new AutoGCRoot(onEvent);
	return alloc_null();
}
DEFINE_PRIM(jwswrve_set_event_handle, 1);

static value jwswrve_init (value appId, value appKey, value userId, value launchOptions) {
    jwsInit(val_int(appId), val_string(appKey), val_string(userId), val_string(launchOptions));
	return alloc_null();
}
DEFINE_PRIM (jwswrve_init, 4);

static value jwswrve_log_event (value eventName, value sParams) {
    jwsLogEvent(val_string(eventName), val_string(sParams));
	return alloc_null();
}
DEFINE_PRIM (jwswrve_log_event, 2);

static value jwswrve_user_properties (value sParams) {
    jwsUserProperties(val_string(sParams));
	return alloc_null();
}
DEFINE_PRIM (jwswrve_user_properties, 1);

static value jwswrve_purchase (value item, value currency, value cost, value quantity) {
    jwsPurchase(val_string(item), val_string(currency), val_int(cost), val_int(quantity));
	return alloc_null();
}
DEFINE_PRIM (jwswrve_purchase, 4);

static value jwswrve_currency_given (value currency, value amount) {
    jwsCurrencyGiven(val_string(currency), val_float(amount));
	return alloc_null();
}
DEFINE_PRIM (jwswrve_currency_given, 2);

static value jwswrve_iap_apple (value opts) {
    jwsIapApple(val_string(opts));
	return alloc_null();
}
DEFINE_PRIM (jwswrve_iap_apple, 1);

static value jwswrve_schedule_notification (value message, value uid, value seconds) {
    jwsScheduleNotification(val_string(message), val_string(uid), val_int(seconds));
	return alloc_null();
}
DEFINE_PRIM (jwswrve_schedule_notification, 3);

static value jwswrve_remove_notification (value uid) {
    jwsRemoveNotification(val_string(uid));
	return alloc_null();
}
DEFINE_PRIM (jwswrve_remove_notification, 1);

static value jwswrve_remote_notifications_enabled () {
	return alloc_bool(jwsRemoteNotificationsEnabled());
}
DEFINE_PRIM (jwswrve_remote_notifications_enabled, 0);

static value jwswrve_set_device_token (value token) {
    jwsSetDeviceToken(val_string(token));
    return alloc_null();
}
DEFINE_PRIM (jwswrve_set_device_token, 1);

static value jwswrve_received_notification (value userInfo) {
    jwsReceivedNotification(val_string(userInfo));
    return alloc_null();
}
DEFINE_PRIM (jwswrve_received_notification, 1);

extern "C" void jwswrve_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (jwswrve_main);



extern "C" int jwswrve_register_prims () { return 0; }

extern "C" void send_swrve_event(const char* type, const char* data)
{
    value o = alloc_empty_object();
    alloc_field(o,val_id("type"),alloc_string(type));
	
    if (data != NULL) alloc_field(o,val_id("data"),alloc_string(data));
	
    val_call1(swrve_event_handle->get(), o);
}
