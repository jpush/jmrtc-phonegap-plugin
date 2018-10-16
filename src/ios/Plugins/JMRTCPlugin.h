#import <Cordova/CDV.h>
#import <JMessage/JMessage.h>
#import <JMRTC/JMRTC.h>

@interface NSError (JMessage)
- (NSDictionary *)errorToDictionary;
@end

@interface JMRTCSession (JMRTCRN)
- (NSDictionary *)sessionToDictionary;
@end


@interface JMRTCPlugin : CDVPlugin
+ (void)fireDocumentEvent:(NSString*)eventName jsString:(NSString*)jsString;

- (void)startJMessageSDK:(CDVInvokedUrlCommand *)command;

- (void)init:(CDVInvokedUrlCommand *)command;

- (void)initEngine:(CDVInvokedUrlCommand *)command;
- (void)releaseEngine:(CDVInvokedUrlCommand *)command;
- (void)startCallUsers:(CDVInvokedUrlCommand *)command;
- (void)accept:(CDVInvokedUrlCommand *)command;
- (void)hangup:(CDVInvokedUrlCommand *)command;
- (void)refuse:(CDVInvokedUrlCommand *)command;
- (void)inviteUsers:(CDVInvokedUrlCommand *)command;
- (void)isMuted:(CDVInvokedUrlCommand *)command;
- (void)setIsMuted:(CDVInvokedUrlCommand *)command;
- (void)isSpeakerphoneEnabled:(CDVInvokedUrlCommand *)command;
- (void)setIsSpeakerphoneEnabled:(CDVInvokedUrlCommand *)command;
@end


