//
//  iAlumniAppDelegate.h
//  iAlumni
//
//  Created by Adam on 11-10-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@class WXWNavigationController;
@class HomepageView;
@class WXWRootViewController;
@class LogUploader;
@class EventListViewController;
@class SearchAlumniViewController;
@class UserProfileViewController;
@class FeedbackViewController;
@class AppSettingViewController;
@class SurveyViewController;
@class VideoListViewController;
@class ShakeViewController;
@class BrandsViewController;
@class NearbyEntranceViewController;
@class GroupListViewController;
@class EnterpriseViewController;
@class CEIBSNewsListViewController;
@class ShakeAlumniViewController;
@class WXWWebViewController;
@class ShakeForNameCardViewController;
@class HomeContainerController;

@interface iAlumniAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAppearanceContainer, WXApiDelegate>
{
  
  NSManagedObjectContext *_moc;
  NSManagedObjectModel *_mom;
  NSPersistentStoreCoordinator *_psc;
  UINavigationController *_homeNC;
  
  id<WXApiDelegate> _wxApiDelegate;
  
@private
                            
  WXWNavigationController *_loginNav;
  
  WXWNavigationController *_premiereNav;
  
  LogUploader *_logUploader;
  
  BOOL _startup;
  
  NSString *_lastSystemLanguageCode;
  int alertType;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectContext *_moc;
@property (nonatomic, retain, readonly) NSManagedObjectModel *_mom;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *_psc;
@property (nonatomic, retain) UINavigationController *_homeNC;
@property (nonatomic, retain) id<WXApiDelegate> wxApiDelegate;

@property (nonatomic, retain) HomeContainerController *homepageContainer;

// app is running current and just back from background
@property (nonatomic, assign) BOOL toForeground;

- (void)saveContext;
- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

- (void)registerNotify;

- (void)initNecessaryResources;

- (void)openLoginNeedDisplayError:(BOOL)isNeedPrompt;
- (void)openSignInHelp;
- (void)singleLogin;
- (void)backToLoginForSessionExpired;
- (void)goHomePage;

#pragma mark - open home page
- (void)openHomePageAfterClearAllViewControllers;

#pragma mark - open shared items
- (void)openSharedEventById:(long long)eventId eventType:(int)eventType;
- (void)openSharedBrandById:(long long)brandId;
- (void)openSharedVideoById:(long long)videoId;
- (void)openSharedWelfareById:(NSString *)welfareId;

#pragma mark - open push message
- (void)prepareHomepageForOpenPushMessage;

@end
