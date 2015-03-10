//
//  PushNotificationHandler.m
//  iAlumni
//
//  Created by Adam on 13-9-11.
//
//

#import "PushNotificationHandler.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "iAlumniAppDelegate.h"
#import "HomeContainerController.h"

@implementation PushNotificationHandler

+ (NSString *)getMessageBodyFromInfo:(NSDictionary *)info {
  NSString *message = info[@"aps"][@"alert"];
  if (message.length == 0) {
    return nil;
  } else {
    return message;
  }
}

+ (void)handlePushMessageWithInfo:(NSDictionary *)info applicationState:(UIApplicationState)applicationState {
  
  if (nil == info || info.count == 0) {
    return;
  }
  
  NSString *message = [self getMessageBodyFromInfo:info];
  
  switch (applicationState) {
    case UIApplicationStateActive:
      [CommonUtils displayMessageInStatusBar:message];
      break;
      
    case UIApplicationStateInactive:
    {
      if (((iAlumniAppDelegate*)APP_DELEGATE).toForeground == YES) {
        // app is running and just enter to foreground, then no need initialization process
        [CommonUtils displayMessageInStatusBar:message];
      } else {
        // app is closed, it triggered by user click push notification, then it needs initialization process
      }
      
      break;
    }
      
    default:
      break;
  }
}

+ (void)handleEventWithInfo:(NSDictionary *)info applicationState:(UIApplicationState)applicationState {
    
    if (nil == info || info.count == 0) {
        return;
    }
    
    switch (applicationState) {
        case UIApplicationStateActive:
            
            [CommonUtils displayEventMessage:info];
            break;
            
        case UIApplicationStateInactive:
            
            if (((iAlumniAppDelegate*)APP_DELEGATE).toForeground == YES) {
                // app is running and just enter to foreground, then no need initialization process
                [CommonUtils displayEventMessage:info];
            } else {
                // app is closed, it triggered by user click push notification, then it needs initialization process
            }
            
            break;
            
        default:
            break;
    }
}

+ (void)handleDMWithInfo:(NSDictionary *)info applicationState:(UIApplicationState)applicationState {
  
  if (nil == info || info.count == 0) {
    return;
  }
  
  switch (applicationState) {
    case UIApplicationStateActive:

      [CommonUtils displayDMMessage:info];
      break;
      
    case UIApplicationStateInactive:
      
      if (((iAlumniAppDelegate*)APP_DELEGATE).toForeground == YES) {
        // app is running and just enter to foreground, then no need initialization process
        [CommonUtils displayDMMessage:info];
      } else {
        // app is closed, it triggered by user click push notification, then it needs initialization process
      }
      
      break;
      
    default:
      break;
  }
}

+ (void)handleRemindEventPushMessageWithInfo:(NSDictionary *)info applicationState:(UIApplicationState)applicationState {
  
  [AppManager instance].pushedItemId = (NSString *)info[@"objectid"];
  
  [self handlePushMessageWithInfo:info applicationState:applicationState];
}

+ (void)handleSupplyDemandPushMessageWithInfo:(NSDictionary *)info applicationState:(UIApplicationState)applicationState {
  
  [self handlePushMessageWithInfo:info applicationState:applicationState];
}

+ (void)handleWelfarePushMessageWithInfo:(NSDictionary *)info applicationState:(UIApplicationState)applicationState {
  [self handlePushMessageWithInfo:info applicationState:applicationState];
}

+ (void)handlePushUserInfo:(NSDictionary *)userInfo applicationState:(UIApplicationState)applicationState {
  
  if (nil == userInfo || userInfo.count == 0) {
    return;
  }
  
  PushMessageType type = ((NSString *)userInfo[@"type"]).intValue;

  [AppManager instance].pushMessageType = type;

  [AppManager instance].appOpenTriggerType = PUSH_TRIGGER_TY;
  
  switch (type) {
    case DM_MSG_PUSH_TY:
      [self handleDMWithInfo:userInfo applicationState:applicationState];
      break;
      
    case NEW_EVENT_PUSH_TY:
      [self handlePushMessageWithInfo:userInfo applicationState:applicationState];
      break;
      
    case REMIND_EVENT_PUSH_TY:
      [self handleRemindEventPushMessageWithInfo:userInfo applicationState:applicationState];
      break;
      
    case NEW_SUPPLY_DEMAND_PUSH_TY:
      [self handleSupplyDemandPushMessageWithInfo:userInfo applicationState:applicationState];
      break;
      
    case NEW_WELFARE_PUSH_TY:
      [self handleWelfarePushMessageWithInfo:userInfo applicationState:applicationState];
      break;
      
    case NONE_PUSH_TY:
      [self handleEventWithInfo:userInfo applicationState:applicationState];
      break;
          
    default:
      break;
  }
}

+ (void)checkLanuchOptions:(NSDictionary *)options applicationState:(UIApplicationState)applicationState {
  if (options != nil) {
  
    NSDictionary *userInfo = options[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (userInfo != nil) {          
      
      // app opened by user click push message when app closed
      [self handlePushUserInfo:userInfo applicationState:applicationState];
    }
  }
}


@end
