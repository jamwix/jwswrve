#ifndef JWSWRVE_H
#define JWSWRVE_H


namespace jwswrve {
	
    extern "C"
    {
        void jwsInit(int appId, const char *sAppKey, const char *sUserId, const char *sLaunchOptions);
        void jwsLogEvent(const char *sEventName, const char *sParams);
        void jwsUserProperties(const char *sParams);
        void jwsPurchase(const char *sItem, const char *sCurrency, int cost, int quantity);
        void jwsCurrencyGiven(const char *sCurrency, float amount);
        void jwsIapApple(const char *sOpts);
        void jwsScheduleNotification(const char *sMessage, const char *sUid, int seconds);
        void jwsRemoveNotification(const char *sUid);
        bool jwsRemoteNotificationsEnabled();
        void jwsSetDeviceToken(const char * sToken);
        void jwsReceivedNotification(const char * sUserInfo);
    }

}
#endif
