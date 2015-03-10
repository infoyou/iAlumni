//
//  PushNotificationHandler.h
//  iAlumni
//
//  Created by Adam on 13-9-11.
//
//

#import <Foundation/Foundation.h>

@interface PushNotificationHandler : NSObject {
  
}

+ (void)handlePushUserInfo:(NSDictionary *)userInfo applicationState:(UIApplicationState)applicationState;
+ (void)checkLanuchOptions:(NSDictionary *)options applicationState:(UIApplicationState)applicationState;

@end
