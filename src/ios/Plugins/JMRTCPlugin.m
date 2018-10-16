//              __    __                ________
//  | |    | |  \ \  / /  | |    | |   / _______|
//  | |____| |   \ \/ /   | |____| |  / /
//  | |____| |    \  /    | |____| |  | |   _____
//  | |    | |    /  \    | |    | |  | |  |____ |
//  | |    | |   / /\ \   | |    | |  \ \______| |
//  | |    | |  /_/  \_\  | |    | |   \_________|
//
//  Copyright (c) 2012年 HXHG. All rights reserved.
//  http://www.jiguang.cn
//  Created by HuminiOS
//

#import "JMRTCPlugin.h"
#import <JMessage/JMessage.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

#import "JMessageHelper.h"
#import "JMessageDefine.h"
#import "AppDelegate+JMessage.h"
#import <JMRTC/JMRTC.h>


#pragma mark - Cordova

#define ResultSuccess(method) [NSString stringWithFormat:@"success - %@",method]
#define ResultFailed(method)  [NSString stringWithFormat:@"failed  - %@",method]


typedef void (^JMSGConversationCallback)(JMSGConversation *conversation,NSError *error);


@implementation NSError (JMessage)
- (NSDictionary *)errorToDictionary {
  return @{@"code": @(self.code), @"description": [self description]};
}
@end

@implementation JMRTCSession (JMRTCRN)
- (NSDictionary *)sessionToDictionary {
  
  NSMutableDictionary *dic = @{}.mutableCopy;
  dic[@"channelId"] = @(self.channelId);
  switch (self.mediaType) {
    case JMRTCMediaVideo:
      dic[@"mediaType"] = @"video";
      break;
    case JMRTCMediaAudio:
      dic[@"mediaType"] = @"voice";
      break;
  }
  
  dic[@"inviter"] = [self userToDic:self.inviter];
  dic[@"invitingMembers"] = @[].mutableCopy;
  dic[@"joinedMembers"] = @[].mutableCopy;
  for (JMSGUser *user in self.invitingMembers) {
    [dic[@"invitingMembers"] addObject:[self userToDic:user]];
  }
  
  for (JMSGUser *user in self.joinedMembers) {
    [dic[@"joinedMembers"] addObject:[self userToDic:user]];
  }
  dic[@"startTime"] = @(self.startTime);
  return dic;
}

- (NSDictionary *)userToDic:(JMSGUser *)user {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"type"] = @"user";
  dict[@"username"] = user.username;
  dict[@"nickname"] = user.nickname;
  dict[@"birthday"] = user.birthday;
  dict[@"region"] = user.region;
  dict[@"signature"] = user.signature;
  dict[@"address"] = [user address];
  dict[@"noteName"] = user.noteName;
  dict[@"noteText"] = user.noteText;
  dict[@"appKey"] = user.appKey;
  dict[@"isNoDisturb"] = @(user.isNoDisturb);
  dict[@"isInBlackList"] = @(user.isInBlacklist);
  dict[@"isFriend"] = @(user.isFriend);
  dict[@"extras"] = user.extras;
  
  if([[NSFileManager defaultManager] fileExistsAtPath: [user thumbAvatarLocalPath] ?: @""]){
    dict[@"avatarThumbPath"] = [user thumbAvatarLocalPath];
  } else {
    dict[@"avatarThumbPath"] = @"";
  }
  
  switch (user.gender) {
    case kJMSGUserGenderUnknown:
      dict[@"gender"] = @"unknown";
      break;
    case kJMSGUserGenderFemale:
      dict[@"gender"] = @"female";
      break;
    case kJMSGUserGenderMale:
      dict[@"gender"] = @"male";
      break;
    default:
      break;
  }
  return dict.copy;
}
@end


@interface JMRTCPlugin ()<JMRTCDelegate>
@property(strong,nonatomic)CDVInvokedUrlCommand *callBack;
//@property(strong,nonatomic)NSMutableDictionary *SendMsgCallbackDic;//{@"msgid": @"", @"callbackID": @""}
@end

JMRTCPlugin *SharedJMRTCPlugin;
NSMutableDictionary *_jmrtcEventCache;

@implementation JMRTCPlugin


#ifdef __CORDOVA_4_0_0

- (void)pluginInitialize {
  NSLog(@"### pluginInitialize ");
//  [self initNotifications];
  //  TODO: add  delegate
  [JMRTCClient addDelegate: self];
  [self initPlugin];
}

#else

- (CDVPlugin*)initWithWebView:(UIWebView*)theWebView {
  NSLog(@"### initWithWebView ");
  if (self=[super initWithWebView:theWebView]) {
    [self initNotifications];
  }
  [self initPlugin];
  return self;
}

#endif

-(void)initPlugin{
  if (!SharedJMRTCPlugin) {
    SharedJMRTCPlugin = self;
  }
}

- (void)onAppTerminate {
  NSLog(@"### onAppTerminate ");
}

- (void)onReset {
  NSLog(@"### onReset ");
}

- (void)dispose {
  NSLog(@"### dispose ");
}

#pragma mark - JMessagePlugin

-(void)startJMessageSDK:(CDVInvokedUrlCommand *)command{
  [(AppDelegate*)[UIApplication sharedApplication].delegate startJMessageSDK];
}

#pragma mark IM - Private

- (void)init:(CDVInvokedUrlCommand *)command {
  self.callBack = command;
  [self dispatchJMessageCacheEvent];
}

- (void)dispatchJMessageCacheEvent {
  if (!_jmrtcEventCache) {
    return;
  }
  
  for (NSString* key in _jmrtcEventCache) {
    NSArray *evenList = _jmrtcEventCache[key];
    for (NSString *event in evenList) {
      [JMRTCPlugin fireDocumentEvent:key jsString:event];
    }
  }
}

+(void)fireDocumentEvent:(NSString*)eventName jsString:(NSString*)jsString{
  
  if (SharedJMRTCPlugin) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [SharedJMRTCPlugin.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('jmessage.%@',%@)", eventName, jsString]];
    });
    return;
  }
  
  if (!_jmrtcEventCache) {
    _jmrtcEventCache = @{}.mutableCopy;
  }
  
  if (!_jmrtcEventCache[eventName]) {
    _jmrtcEventCache[eventName] = @[].mutableCopy;
  }
  
  [_jmrtcEventCache[eventName] addObject: jsString];
}


- (void)initEngine:(CDVInvokedUrlCommand *)command {
  [JMRTCClient initializeEngine:^(id resultObject, NSError *error) {
    CDVPluginResult *result = nil;
    if (error) {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                             messageAsDictionary:@{@"code": @(error.code), @"description": [error description]}];
    } else {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }];
}

- (void)startCallUsers:(CDVInvokedUrlCommand *)command {
  NSDictionary * params = [command argumentAtIndex:0];
  
  if (params[@"usernames"] == nil) {
    [self returnParamError:command];
    return;
  }
  
  NSArray *usernames = params[@"usernames"];
  [JMSGUser userInfoArrayWithUsernameArray:usernames completionHandler:^(id resultObject, NSError *error) {
    
    if (error) {
      [self handleResultWithDictionary: nil command: command error: error];
      return;
    }
    
    NSArray *users = resultObject;
    [JMRTCClient startCallUsers:users
                      mediaType:JMRTCMediaAudio
                        handler:^(id resultObject, NSError *error) {
                          JMRTCSession *session = resultObject;
                          [self handleResultWithDictionary: [session sessionToDictionary] command: command error: error];
                          return;
                        }];
  }];
}

- (void)accept:(CDVInvokedUrlCommand *)command {
  if (![JMRTCClient currentCallSession]) {
    
    [self returnErrorWithLog:@"无法获取当前通话 session" command:command];
    return;
  }
  
  [[JMRTCClient currentCallSession] accept:^(id resultObject, NSError *error) {
    [self handleResultWithDictionary:@{} command:command error:error];
  }];
}

- (void)hangup:(CDVInvokedUrlCommand *)command {
  [[JMRTCClient currentCallSession] hangup:^(id resultObject, NSError *error) {
    [self handleResultWithDictionary:@{} command:command error:error];
  }];
  

}

- (void)refuse:(CDVInvokedUrlCommand *)command {
  [[JMRTCClient currentCallSession] refuse:^(id resultObject, NSError *error) {
    [self handleResultWithDictionary:@{} command:command error:error];
  }];
}

- (void)inviteUsers:(CDVInvokedUrlCommand *)command {
  NSDictionary * params = [command argumentAtIndex:0];
  
  [JMSGUser userInfoArrayWithUsernameArray:params[@"usernames"] completionHandler:^(id resultObject, NSError *error) {
    
    NSArray *users = resultObject;
    [[JMRTCClient currentCallSession] inviteUsers:users handler:^(id resultObject, NSError *error) {
      [self handleResultWithDictionary:@{} command:command error:error];
    }];
  }];
}

- (void)isMuted:(CDVInvokedUrlCommand *)command {
  
  CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsBool: [JMRTCClient currentCallSession].isMuted];
  [self.commandDelegate sendPluginResult: result callbackId:command.callbackId];
  
}

- (void)setIsMuted:(CDVInvokedUrlCommand *)command {
  NSDictionary * params = [command argumentAtIndex:0];
  
  if (!params[@"muted"]) {
    return;
  }
  
  NSNumber *isMuted = params[@"muted"];
  [[JMRTCClient currentCallSession] setMuted: isMuted.boolValue];
}

- (void)isSpeakerphoneEnabled:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsBool: [JMRTCClient currentCallSession].isSpeakerphoneEnabled];
  [self.commandDelegate sendPluginResult: result callbackId:command.callbackId];
}

- (void)setIsSpeakerphoneEnabled:(CDVInvokedUrlCommand *)command {
  NSDictionary * params = [command argumentAtIndex:0];
  
  if (!params[@"speakerphoneEnabled"]) {
    return;
  }
  
  NSNumber *isSpeakerphoneEnabled = params[@"speakerphoneEnabled"];
  [[JMRTCClient currentCallSession] setSpeakerEnabled: isSpeakerphoneEnabled.boolValue];
}



// Helper

-(void)handleResultNilWithCommand:(CDVInvokedUrlCommand*)command error:(NSError*)error{
  CDVPluginResult *result = nil;
  
  if (error == nil) {
    CDVCommandStatus status = CDVCommandStatus_OK;
    result = [CDVPluginResult resultWithStatus: status];
    
  } else {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                           messageAsDictionary:@{@"code": @(error.code), @"description": [error description]}];
  }
  
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)returnParamError:(CDVInvokedUrlCommand *)command {
  NSError *error = [NSError errorWithDomain:@"param error" code: 1 userInfo: nil];
  [self handleResultWithDictionary:nil command:command error: error];
}

- (void)returnErrorWithLog:(NSString *)log command:(CDVInvokedUrlCommand *)command {
  NSError *error = [NSError errorWithDomain:log code: 1 userInfo: nil];
  [self handleResultWithDictionary:nil command:command error: error];
}

-(void)handleResultWithDictionary:(NSDictionary *)value command:(CDVInvokedUrlCommand*)command error:(NSError*)error{
  CDVPluginResult *result = nil;
  
  if (error == nil) {
    CDVCommandStatus status = CDVCommandStatus_OK;
    result = [CDVPluginResult resultWithStatus:status messageAsDictionary:value];
  } else {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                           messageAsDictionary:@{@"code": @(error.code), @"description": [error description]}];
  }
  
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

-(void)handleResultWithArray:(NSArray *)value command:(CDVInvokedUrlCommand*)command error:(NSError*)error{
  CDVPluginResult *result = nil;
  
  if (error == nil) {
    CDVCommandStatus status = CDVCommandStatus_OK;
    result = [CDVPluginResult resultWithStatus:status messageAsArray: value];
  } else {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"code": @(error.code), @"description": [error description]}];
  }
  
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

-(void)handleResultWithString:(NSString *)value command:(CDVInvokedUrlCommand*)command error:(NSError*)error{
  CDVPluginResult *result = nil;
  
  if (error == nil) {
    CDVCommandStatus status = CDVCommandStatus_OK;
    result = [CDVPluginResult resultWithStatus:status messageAsString:value];
  } else {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                           messageAsDictionary:@{@"code": @(error.code), @"description": [error description]}];
  }
  
  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (NSDictionary *)userToDic:(JMSGUser *)user {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"type"] = @"user";
  dict[@"username"] = user.username;
  dict[@"nickname"] = user.nickname;
  dict[@"birthday"] = user.birthday;
  dict[@"region"] = user.region;
  dict[@"signature"] = user.signature;
  dict[@"address"] = [user address];
  dict[@"noteName"] = user.noteName;
  dict[@"noteText"] = user.noteText;
  dict[@"appKey"] = user.appKey;
  dict[@"isNoDisturb"] = @(user.isNoDisturb);
  dict[@"isInBlackList"] = @(user.isInBlacklist);
  dict[@"isFriend"] = @(user.isFriend);
  dict[@"extras"] = user.extras;
  
  if([[NSFileManager defaultManager] fileExistsAtPath: [user thumbAvatarLocalPath] ?: @""]){
    dict[@"avatarThumbPath"] = [user thumbAvatarLocalPath];
  } else {
    dict[@"avatarThumbPath"] = @"";
  }
  
  switch (user.gender) {
    case kJMSGUserGenderUnknown:
      dict[@"gender"] = @"unknown";
      break;
    case kJMSGUserGenderFemale:
      dict[@"gender"] = @"female";
      break;
    case kJMSGUserGenderMale:
      dict[@"gender"] = @"male";
      break;
    default:
      break;
  }
  return dict.copy;
}

- (NSString *)reasonToString: (JMRTCDisconnectReason)reason {
  switch (reason) {
    case JMRTCDisconnectReasonRefuse:
      return @"refuse";
      break;
    case JMRTCDisconnectReasonHangup:
      return @"hangup";
      break;
    case JMRTCDisconnectReasonCancel:
      return @"cancel";
      break;
    case JMRTCDisconnectReasonBusy:
      return @"busy";
      break;
    case JMRTCDisconnectReasonNetworkError:
      return @"networkError";
      break;
  }
}


// JMRTC delegate

- (void)onCallOutgoing:(JMRTCSession *)callSession {

  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
                                                                                                        @"eventName": @"onCallOutgoing",
                                                                                                        @"value": [callSession sessionToDictionary]}];
  [result setKeepCallback:@(true)];
  
  [self.commandDelegate sendPluginResult:result callbackId:self.callBack.callbackId];
  
}

- (void)onCallReceiveInvite:(JMRTCSession *)callSession {
  
  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
                                                                                                        @"eventName": @"onCallReceiveInvite",
                                                                                                        @"value": [callSession sessionToDictionary]}];
  [result setKeepCallback:@(true)];
  
  [self.commandDelegate sendPluginResult:result callbackId:self.callBack.callbackId];
}

- (void)onCallConnecting:(JMRTCSession *)callSession {

  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
                                                                                                        @"eventName": @"onCallConnecting",
                                                                                                        @"value": [callSession sessionToDictionary]}];
  [result setKeepCallback:@(true)];
  
  [self.commandDelegate sendPluginResult:result callbackId:self.callBack.callbackId];
}

- (void)onCallConnected:(JMRTCSession *)callSession {
  
  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
                                                                                                        @"eventName": @"onCallConnected",
                                                                                                        @"value": [callSession sessionToDictionary]}];
  [result setKeepCallback:@(true)];
  
  [self.commandDelegate sendPluginResult:result callbackId:self.callBack.callbackId];
}

- (void)onCallMemberJoin:(JMSGUser *)joinUser {
  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
                                                                                                        @"eventName": @"onCallMemberJoin",
                                                                                                        @"value": [self userToDic:joinUser]}];
  [result setKeepCallback:@(true)];
  
  [self.commandDelegate sendPluginResult:result callbackId:self.callBack.callbackId];
}

- (void)onCallDisconnect:(JMRTCSession *)callSession disconnectReason:(JMRTCDisconnectReason)reason {
  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
                                                                                                        @"eventName": @"onCallDisconnect",
                                                                                                        @"value": [callSession sessionToDictionary]}];
  [result setKeepCallback:@(true)];
  
  [self.commandDelegate sendPluginResult:result callbackId:self.callBack.callbackId];
}

- (void)onCallMemberLeave:(JMSGUser *)leaveUser reason:(JMRTCDisconnectReason)reason {
  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
                                                                                                        @"eventName": @"onCallMemberLeave",
                                                                                                        @"value": @{
                                                                                                            @"user": [self userToDic:leaveUser],
                                                                                                            @"reason": [self reasonToString:reason]
                                                                                                            }
                                                                                                        }];
  [result setKeepCallback:@(true)];
  
  [self.commandDelegate sendPluginResult:result callbackId:self.callBack.callbackId];
}

- (void)onCallOtherUserInvited:(NSArray <__kindof JMSGUser *>*)invitedUsers fromUser:(JMSGUser *)fromUser {

    NSMutableArray *userDics = @[].mutableCopy;
    for (JMSGUser *user in invitedUsers) {
      [userDics addObject:[self userToDic:user]];
    }
  CDVPluginResult *result = [CDVPluginResult resultWithStatus:
                             CDVCommandStatus_OK messageAsDictionary:@{
                                                                       @"eventName": @"onCallOtherUserInvited",
                                                                       @"value": @{@"invitedUsers": userDics, @"fromUser": [self userToDic:fromUser]}}];
  [result setKeepCallback:@(true)];
  
  [self.commandDelegate sendPluginResult:result callbackId:self.callBack.callbackId];
}

- (void)onCallError:(NSError *)error {
  
  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
                                                                                                        @"eventName": @"onCallError",
                                                                                                        @"value": [error errorToDictionary]}];
  [result setKeepCallback:@(true)];
  
  [self.commandDelegate sendPluginResult:result callbackId:self.callBack.callbackId];
}
@end
