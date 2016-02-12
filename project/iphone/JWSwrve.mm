#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import "Swrve.h"
#include "JWSwrve.h"

extern "C" void send_swrve_event(const char* type, const char* data);

@interface JWSwrve: NSObject
{
    ReceivedNotificationHandler _receivedNotificationCb;
}
- (void) initWithId: (int) appId 
           appKey: (NSString*) appKey 
           userId: (NSString*) userId 
    launchOptions: (NSDictionary*) launchOptions;
- (void) logEvent: (NSString*) eventName 
       withParams: (NSDictionary*) params;
- (void) userProperties: (NSDictionary*) params;
- (void) purchase: (NSString*) item 
         currency: (NSString*) currency 
             cost: (int) cost 
         quantity: (int) quantity;
- (void) currencyGiven: (NSString*) currency 
                amount: (float) amount;
- (void) iapWithCurrency: (NSString*) currency 
                    cost: (float) cost
               productId: (NSString*) productId
                 transId: (NSString*) transId
                 receipt: (NSString*) receipt
              rewardType: (NSString*) rewardType
             rewardCount: (int) rewardCount;
- (void) scheduleNotification: (NSString*) message 
                          uid: (NSString*) uid 
                      seconds: (int) seconds;
- (void) removeNotification: (NSString*) uid;
- (void) setDeviceToken: (NSData*) token;
- (void) receivedNotification: (NSDictionary*) userInfo;
+ (id) sharedInstance;
@end

@implementation JWSwrve

+ (JWSwrve*) sharedInstance
{
    static JWSwrve *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void) initWithId: (int) appId appKey: (NSString*) appKey userId: (NSString*) userId launchOptions: (NSDictionary*) launchOptions
{
    _receivedNotificationCb = ^(NSDictionary* userInfo){
        
        NSString *retStr = @"{}";

        if (!userInfo)
        {
            NSLog(@"no userInfo received");
            return;
        }

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: userInfo
                                                           options: 0
                                                             error: &error];

        if (!jsonData) 
        {
            NSLog(@"userInfo parse error: %@", error.localizedDescription);
            return;
        } 
        else 
        {
            send_swrve_event("PUSH_RECEIVED", [[[NSString alloc] initWithData: jsonData encoding:NSUTF8StringEncoding] UTF8String]);
        } 
    };

    SwrveConfig* config = [[SwrveConfig alloc] init];
    config.selectedStack = SWRVE_STACK_EU;
    config.userId = userId;
    config.pushEnabled = YES;
    //config.autoCollectDeviceToken = NO;
    config.pushNotificationEvents = [[NSSet alloc] initWithArray:@[@"push_permission_request"]];

    [Swrve sharedInstanceWithAppID: appId apiKey: appKey config:config launchOptions: launchOptions];

    Swrve *mySwrve = [Swrve sharedInstance];
    //mySwrve.receivedNotificationCb = _receivedNotificationCb;
/*
    mySwrve.receivedNotificationCb = ^(NSDictionary* userInfo){
        
        NSString *retStr = @"{}";

        if (!userInfo)
        {
            NSLog(@"no userInfo received");
            return;
        }

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: userInfo
                                                           options: 0
                                                             error: &error];

        if (!jsonData) 
        {
            NSLog(@"userInfo parse error: %@", error.localizedDescription);
            return;
        } 
        else 
        {
            send_swrve_event("PUSH_RECEIVED", [[[NSString alloc] initWithData: jsonData encoding:NSUTF8StringEncoding] UTF8String]);
        } 
    };*/
}

- (void) logEvent: (NSString*) eventName withParams: (NSDictionary*) params
{
    [[Swrve sharedInstance] event: eventName payload: params];
}

- (void) userProperties: (NSDictionary*) params
{
    [[Swrve sharedInstance] userUpdate: params];
}

- (void) purchase: (NSString*) item currency: (NSString*) currency cost: (int) cost quantity: (int) quantity
{
    [[Swrve sharedInstance] purchaseItem: item currency: currency cost: cost quantity: quantity];
}

- (void) currencyGiven: (NSString*) currency amount: (float) amount
{
    [[Swrve sharedInstance] currencyGiven: currency givenAmount: amount];
}

- (void) iapWithCurrency: (NSString*) currency 
                    cost: (float) cost
               productId: (NSString*) productId
                 transId: (NSString*) transId
                 receipt: (NSString*) receipt
              rewardType: (NSString*) rewardType
             rewardCount: (int) rewardCount
{

    SwrveIAPRewards* rewards = [[SwrveIAPRewards alloc] init];
    [rewards addCurrency: rewardType withAmount: rewardCount];

    [[Swrve sharedInstance] iapWithCurrency: currency
                                       cost: cost
                                  productId: productId
                                    transId: transId
                                    receipt: receipt
                                    rewards: rewards];
/*
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setValue: @"apple" forKey:@"app_store"];
    [json setValue: currency forKey:@"local_currency"];
    [json setValue: [NSNumber numberWithDouble: cost] forKey:@"cost"];
    [json setValue: [rewards rewards] forKey:@"rewards"];
    [json setValue: receipt forKey:@"receipt"];

    NSMutableDictionary* eventPayload = [[NSMutableDictionary alloc] init];
    [eventPayload setValue: productId forKey:@"product_id"];
    [json setValue:eventPayload forKey:@"payload"];
    [json setValue: transId forKey:@"transaction_id"];

    [[Swrve sharedInstance] queueEvent:@"iap" data:json triggerCallback:true];
*/
}

- (void) scheduleNotification: (NSString*) message uid: (NSString*) uid seconds: (int) seconds
{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init]; 
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow: seconds];
    localNotification.alertBody = message;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = [NSDictionary dictionaryWithObject: uid forKey: @"uid"];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification]; 
}

- (void) removeNotification: (NSString*) uid
{
    for (UILocalNotification *notification in [[[UIApplication sharedApplication] scheduledLocalNotifications] copy]){
        NSDictionary *userInfo = notification.userInfo;
        if ([uid isEqualToString: [userInfo objectForKey: @"uid"]]){
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (bool) remoteNotificationsEnabled
{ 
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {

        BOOL isRegisteredForRemoteNotifications = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];

        if (isRegisteredForRemoteNotifications) { 
            return true;
        }

        return false;

    } else {

        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];

        if (types == UIRemoteNotificationTypeNone) {
            return false;
        }

        return true;
    }
}

- (void) setDeviceToken: (NSData*) token
{
    if ([Swrve sharedInstance].talk != nil) {
        [[Swrve sharedInstance].talk setDeviceToken: token];
    }
}

- (void) receivedNotification: (NSDictionary*) userInfo
{
    if ([Swrve sharedInstance].talk != nil) {
        [[Swrve sharedInstance].talk pushNotificationReceived: userInfo];
    }
}

@end

extern "C"
{
    NSDictionary* jwsParseParams(const char *sParams)
    {
        if (!sParams || strlen(sParams) <= 0 || strcmp(sParams, "{}") == 0) return nil;

        NSString *params = [ [NSString alloc] initWithUTF8String: sParams ];
        NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];

        NSError *error;
        NSDictionary *parameters = 
            [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
        if (error)
        {
            NSLog(@"Unable to parse params %@", params);
            return nil;
        }

        return parameters;
    }

    void jwsInit(int appId, const char *sAppKey, const char *sUserId, const char *sLaunchOptions)
    {
		NSString *appKey = [ [NSString alloc] initWithUTF8String: sAppKey ];
		NSString *userId = [ [NSString alloc] initWithUTF8String: sUserId ];

        [[JWSwrve sharedInstance] initWithId: appId appKey: appKey userId: userId launchOptions: jwsParseParams(sLaunchOptions)];
    }
    
    void jwsLogEvent(const char *sEventName, const char *sParams)
    {
		NSString *eventName = [ [NSString alloc] initWithUTF8String: sEventName ];
		NSDictionary *params = jwsParseParams(sParams);

        [[JWSwrve sharedInstance] logEvent: eventName withParams: params];
    }

    void jwsUserProperties(const char *sParams)
    {
        NSDictionary *params = jwsParseParams(sParams);

        [[JWSwrve sharedInstance] userProperties: params];
    }

    void jwsPurchase(const char *sItem, const char *sCurrency, int cost, int quantity)
    {
		NSString *item = [ [NSString alloc] initWithUTF8String: sItem ];
		NSString *currency = [ [NSString alloc] initWithUTF8String: sCurrency ];
        
        [[JWSwrve sharedInstance] purchase: item currency: currency cost: cost quantity: quantity];
    }

    void jwsCurrencyGiven(const char *sCurrency, float amount)
    {
		NSString *currency = [ [NSString alloc] initWithUTF8String: sCurrency ];

        [[JWSwrve sharedInstance] currencyGiven: currency amount: amount];
    }

    void jwsIapApple(const char *sOpts)
    {
        NSDictionary *params = jwsParseParams(sOpts);
        if (params == nil)
        {
            return;
        }

        if ([params objectForKey: @"currency"] == nil) { return; }
        if ([params objectForKey: @"cost"] == nil) { return; }
        if ([params objectForKey: @"productId"] == nil) { return; }
        if ([params objectForKey: @"transId"] == nil) { return; }
        if ([params objectForKey: @"receipt"] == nil) { return; }
        if ([params objectForKey: @"rewardType"] == nil) { return; }
        if ([params objectForKey: @"rewardCount"] == nil) { return; }

		NSString *currency = [params valueForKey: @"currency"];
		float cost = [[params objectForKey: @"cost"] floatValue];
		NSString *productId = [params valueForKey: @"productId"];
		NSString *transId = [params valueForKey: @"transId"];
		NSString *receipt = [params valueForKey: @"receipt"];
		NSString *rewardType = [params valueForKey: @"rewardType"];
		int rewardCount = [[params objectForKey: @"rewardCount"] intValue];

        [[JWSwrve sharedInstance] iapWithCurrency: currency cost: cost productId: productId transId: transId receipt: receipt rewardType: rewardType rewardCount: rewardCount];
    }

    void jwsScheduleNotification(const char *sMessage, const char *sUid, int seconds)
    {
		NSString *message = [ [NSString alloc] initWithUTF8String: sMessage ];
		NSString *uid = [ [NSString alloc] initWithUTF8String: sUid ];
        [[JWSwrve sharedInstance] scheduleNotification: message uid: uid seconds: seconds];
    }

    void jwsRemoveNotification(const char *sUid)
    {
		NSString *uid = [ [NSString alloc] initWithUTF8String: sUid ];
        [[JWSwrve sharedInstance] removeNotification: uid];
    }

    bool jwsRemoteNotificationsEnabled()
    {
        return [[JWSwrve sharedInstance] remoteNotificationsEnabled];
    }

    void jwsSetDeviceToken(const char * sToken)
    {
		NSString *token = [ [NSString alloc] initWithUTF8String: sToken ];
        NSData *dToken = [token dataUsingEncoding:NSUTF8StringEncoding];

        [[JWSwrve sharedInstance] setDeviceToken: dToken];
    }

    void jwsReceivedNotification(const char * sUserInfo)
    {
        [[JWSwrve sharedInstance] receivedNotification: jwsParseParams(sUserInfo)];
    }
}
