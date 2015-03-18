//
//  iAlumniAppDelegate.m
//  iAlumni
//
//  Created by Adam on 11-10-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "iAlumniAppDelegate.h"
#import <CrashReporter/CrashReporter.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "LoginViewController.h"
#import "GlobalConstants.h"
#import "WXWRootViewController.h"
#import "WXWNavigationController.h"
#import "AppSettingViewController.h"
#import "WXWDBConnection.h"
#import "AppManager.h"
#import "CoreDataUtils.h"
#import "CommonUtils.h"
#import "LogUploader.h"
#import "TextConstants.h"
#import "EventListViewController.h"
#import "UserProfileViewController.h"
#import "FeedbackViewController.h"
#import "SearchAlumniViewController.h"
#import "SurveyViewController.h"
#import "ShakeViewController.h"
#import "VideoListViewController.h"
#import "FilterOption.h"
#import "BrandsViewController.h"
#import "NearbyEntranceViewController.h"
#import "WXWDebugLogOutput.h"
#import "GroupListViewController.h"
#import "EnterpriseViewController.h"
#import "CEIBSNewsListViewController.h"
#import "SignInHelpViewController.h"
#import "WXApi.h"
#import "ShakeAlumniViewController.h"
#import "WXWWebViewController.h"
#import "ShakeForNameCardViewController.h"
#import "VideoViewController.h"
#import "UIUtils.h"
#import "HomeContainerController.h"
#import "SplashViewController.h"
#import "UIWebViewController.h"
#import "PushNotificationHandler.h"
#import "MobClick.h"

enum {
    HOME_PAGE_TAG = 1,
    HOT_NEWS_LIST_TAG = 2,
};

typedef enum{
    LOGIN_ALERT_TYPE = 0,
    COREDATA_ERROR_TYPE,
} DELEGATE_ALERT_TYPE;

NSString *kAutoSendCrashDataKey = @"AutoSendCrashDataKey";								// preference key to check if the user allowed the application to send crash data always
NSString *kAllowBookmarkAccessKey = @"AllowBookmarkAccessKey";						// grant access to bookmarks
NSString *kCrashDataContactAllowKey = @"CrashDataContactAllowKey";				// allow to contact the user via email
NSString *kCrashDataContactEmailKey = @"CrashDataContactEmailKey";				// the users email address

NSString *kCrashReportAnalyzerStarted = @"CrashReportAnalyzerStarted";		// flags if the crashlog analyzer is started. since this may crash we need to track it
NSString *kLastRunMemoryWarningReached = @"LastRunMemoryWarningReached";	// is the last crash because of lowmemory warning?
NSString *kLastStartupFreeMemory = @"LastStartupFreeMemory";							// the amount of memory available on startup on the run of the app the crash happened
NSString *kLastShutdownFreeMemory = @"LastShutdownFreeMemory";						// the amount of memory available on shutdown on the run of the app the crash happened

@implementation UINavigationBar (UINavigationBarCategory)

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents(NAVIGATION_BAR_COLOR.CGColor));
    CGContextFillRect(context, rect);
    self.tintColor = NAVIGATION_BAR_COLOR;
}

@end

@interface iAlumniAppDelegate()

@property (nonatomic, retain) WXWNavigationController *homepageNav;
@property (nonatomic, copy) NSString *lastSystemLanguageCode;
@property (nonatomic, retain) WXWNavigationController *loginNav;
@property (nonatomic, retain) WXWNavigationController *signInhelpNav;

@property (nonatomic, retain) WXWNavigationController *homepageContainerNav;
@property (nonatomic, retain) SplashViewController *splashVC;
@property (nonatomic, retain) WXWNavigationController *splashNav;

@property (nonatomic, assign, readwrite) BOOL adjustedStatusbarForiOS7;

@end

@implementation iAlumniAppDelegate

@synthesize window = _window;
@synthesize _moc;
@synthesize _mom;
@synthesize _psc;
@synthesize _homeNC;
@synthesize homepageNav = _homepageNav;
@synthesize lastSystemLanguageCode = _lastSystemLanguageCode;
@synthesize loginNav = _loginNav;
@synthesize wxApiDelegate = _wxApiDelegate;

#pragma mark - properties

- (SplashViewController *)splashVC {
    if (nil == _splashVC) {
        _splashVC = [[SplashViewController alloc] init];
    }
    return _splashVC;
}

- (WXWNavigationController *)splashNav {
    if (nil == _splashNav) {
        _splashNav = [[WXWNavigationController alloc] initWithRootViewController:self.splashVC];
    }
    return _splashNav;
}

- (HomeContainerController *)homepageContainer {
    if (nil == _homepageContainer) {
        _homepageContainer = [[HomeContainerController alloc] initWithMOC:self._moc];
    }
    return _homepageContainer;
}

- (WXWNavigationController *)homepageContainerNav {
    if (nil == _homepageContainerNav) {
        _homepageContainerNav = [[WXWNavigationController alloc] initWithRootViewController:self.homepageContainer];
    }
    return _homepageContainerNav;
}

#pragma mark - view navigation

- (void)backToHomepage:(id)sender {
    [self goHomePage];
}

- (void)switchViews:(WXWNavigationController *)toBeDisplayedNav {
    
    CATransition *viewFadein = [CATransition animation];
    viewFadein.duration = 0.3f;
    viewFadein.type = kCATransitionFade;
    
    [self.window.layer addAnimation:viewFadein forKey:nil];
    
    if (_premiereNav) {
        _premiereNav.view.hidden = YES;
        [_premiereNav.view removeFromSuperview];
    }
    
    toBeDisplayedNav.view.hidden = NO;
    
    [self.window addSubview:toBeDisplayedNav.view];
    
    _premiereNav = toBeDisplayedNav;
}

- (void)clearHomepageViewController {
    
    [self.homepageContainer cancelConnectionAndImageLoading];
    self.homepageContainer = nil;
    self.homepageContainerNav = nil;
}

- (void)clearSubLayerViewControllers {
    
    self.splashVC = nil;
    self.splashNav = nil;
    
}

#pragma mark - logic view

- (void)doLogin {
    
    [CommonUtils deleteAllObjects:_moc];
    
    [self clearHomepageViewController];
    
    [self clearSplashViewIfNeeded];
    
    _premiereNav = nil;
    
    LoginViewController *loginVC = [[[LoginViewController alloc] initWithMOC:_moc] autorelease];
    self.loginNav = [[[WXWNavigationController alloc] initWithRootViewController:loginVC] autorelease];
    //self.loginNav.navigationBarHidden = YES;
    [self.window makeKeyAndVisible];
    [self.window addSubview:self.loginNav.view];
    
}

- (void)openLoginNeedDisplayError:(BOOL)needDisplayError {
    if (needDisplayError) {
        alertType = LOGIN_ALERT_TYPE;
        
        ShowAlertWithOneButton(nil, LocaleStringForKey(NSNoteTitle, nil), [AppManager instance].errDesc, LocaleStringForKey(NSOKTitle, nil));
    }
    
    if (IS_NEED_3RD_LOGIN == 1) {
        [self singleLogin];
    } else {
        [self doLogin];
    }
}

- (void)clearCurrentViewStacks {
    if (_premiereNav) {
        _premiereNav.view.hidden = YES;
        [_premiereNav.view removeFromSuperview];
        
        _premiereNav = nil;
    }
}

- (void)openSignInHelp {
    [CommonUtils deleteAllObjects:_moc];
    
    [self clearHomepageViewController];
    
    [self clearSplashViewIfNeeded];
    
    _premiereNav = nil;
    
    SignInHelpViewController *helpVC = [[[SignInHelpViewController alloc] init] autorelease];
    self.signInhelpNav = [[[WXWNavigationController alloc] initWithRootViewController:helpVC] autorelease];
    [self.window makeKeyAndVisible];
    [self.window addSubview:self.signInhelpNav.view];
}

- (void)backToLoginForSessionExpired {
    alertType = LOGIN_ALERT_TYPE;
    
    ShowAlertWithOneButton(nil, LocaleStringForKey(NSNoteTitle, nil), [AppManager instance].errDesc, LocaleStringForKey(NSOKTitle, nil));
    
    BOOL currentInHomepage = NO;
    if (self.homepageNav == _premiereNav) {
        currentInHomepage = YES;
    }
    
    [self clearCurrentViewStacks];
    
    if (IS_NEED_3RD_LOGIN == 1) {
        [self singleLogin];
    } else {
        [self doLogin];
    }
    
    if (currentInHomepage) {
        [self clearHomepageViewController];
    } else {
        [self clearSubLayerViewControllers];
    }
}

- (void)clearLoginViewIfNeeded {
    if (self.loginNav) {
        
        [self.loginNav.view removeFromSuperview];
        self.loginNav = nil;
    }
}

- (void)clearSplashViewIfNeeded {
    if (self.splashNav) {
        [self.splashNav.view removeFromSuperview];
        self.splashNav = nil;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
}

- (void)goHomePage {
    
    self.adjustedStatusbarForiOS7 = NO;
    
    [self clearLoginViewIfNeeded];
    
    [self clearSplashViewIfNeeded];
    
    [self switchViews:self.homepageContainerNav];
    
    [self clearSubLayerViewControllers];
}

#pragma mark - handle notifications
- (void)handleSessionExpiredNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo.count > 0) {
        
        NSNumber *type = (NSNumber *)userInfo[SESSION_EXPIRED_TYPE_KEY];
        
        [[AppManager instance] refreshSessionForView:userInfo[SESSION_EXPIRED_VIEW_KEY]
                                          actionType:type.intValue];
    }
}

#pragma mark - single sign on

- (void)singleLogin {
    NSString *paraStr = [NSString stringWithFormat:@"%@://loginreturn?user=&token=&resultmsg=", APP_NAME];
    
    NSString *encodeStr = [CommonUtils stringByURLEncodingStringParameter:paraStr];
    
    NSString *transUrl = [NSString stringWithFormat:@"%@://login?returnurl=%@", SINGLE_LOGIN_APP_NAME, encodeStr];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:transUrl]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:transUrl]];
        
    } else {
        //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/ceibs-icampus/id486623316?mt=8"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/ceibs-icampus-for-iphone/id565005535?mt=8"]];
    }
}

#pragma mark - lifecycle methods
- (void)dealloc
{
    self.lastSystemLanguageCode = nil;
    
    [self clearSubLayerViewControllers];
    [self clearHomepageViewController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REFRESH_SESSION_NOTIFY
                                                  object:nil];
    
    [_window release];
    [_moc release];
    [_mom release];
    [_psc release];
    [super dealloc];
}

- (void)applyCurrentLanguage {
    [WXWSystemInfoManager instance].currentLanguageCode = [CommonUtils fetchIntegerValueFromLocal:SYSTEM_LANGUAGE_LOCAL_KEY];
    
    if ([WXWSystemInfoManager instance].currentLanguageCode == NO_TY) {
        [WXWCommonUtils getLocalLanguage];
    }else {
        [WXWCommonUtils getDBLanguage];
    }
}

- (void)prepareCache {
    [AppManager instance].userId = NULL_PARAM_VALUE;
    [AppManager instance].MOC = [self managedObjectContext];
    
    [WXWDBConnection prepareBizDB];
}

- (void)prepareCrashReporter {
    
    // Enable the Crash Reporter
    NSError *error;
	if (![[PLCrashReporter sharedReporter] enableCrashReporterAndReturnError: &error]) {
		debugLog(@"Warning: Could not enable crash reporter: %@", error);
    }
}

- (void)generateConnectionIdentifier {
    NSString *seed = [NSString stringWithFormat:@"%@_%@_%@", [NSDate date], [WXWCommonUtils deviceModel], [[AppManager instance] getUserIdFromLocal]];
    [AppManager instance].deviceConnectionIdentifier = [WXWCommonUtils hashStringAsMD5:seed];
}

- (void)addSessionExpiredNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSessionExpiredNotification:)
                                                 name:REFRESH_SESSION_NOTIFY
                                               object:nil];
}

- (void)prepareApp {
    [self prepareCrashReporter];
    
    [self generateConnectionIdentifier];
    
    [self addSessionExpiredNotification];
    
    _startup = YES;
    
    [[AppManager instance] initParam];
    [[AppManager instance] getCurrentLocationInfo];
    if (![IPHONE_SIMULATOR isEqualToString:[CommonUtils deviceModel]]) {
        [self registerNotify];
    }
    
    [self applyCurrentLanguage];
    
    // register call back method for MOC save notification
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self._moc];
    
    [self prepareCache];
    
    // register app to WeChat
    [WXApi registerApp:WX_API_KEY];
    
    // get Device System
    [CommonUtils getDeviceSystemInfo];
}

- (void)arrangeSolidColorNavigationBar {
    if([UINavigationBar respondsToSelector:@selector(appearance)]){
        UIImage *image = [UIImage imageNamed:@"navigationBarBackground.png"];
        [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    if (CURRENT_OS_VERSION >= IOS7) {
        NSDictionary *textTitleOptions = @{UITextAttributeTextColor : [UIColor whiteColor],
                                           UITextAttributeTextShadowColor : TRANSPARENT_COLOR};
        [UINavigationBar appearance].titleTextAttributes = textTitleOptions;
    }
}

- (void)initNecessaryResources {
    // prepare meta data and cache
    [self prepareApp];
    
//    if (IS_NEED_3RD_LOGIN == 1) {
//        [self singleLogin];
//    } else {
//        [self doLogin];
//    }
    
    // prepare UI homepage
    [self arrangeSolidColorNavigationBar];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window makeKeyAndVisible];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.window addSubview:self.splashNav.view];
    
}

- (void)run
{
    [self initNecessaryResources];
    
    [AppManager instance].hostUrl = @"http://alumniapp.ceibs.edu:8080/ceibs";
    
    if ([[AppManager instance] userAlreadySignedIn]) {
        [[AppManager instance] beginInitializationProcess];
    } else {
        [self openLoginNeedDisplayError:NO];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AppManager instance] initUser];
    
    // step 1 check status
    [PushNotificationHandler checkLanuchOptions:launchOptions
                               applicationState:application.applicationState];
    
    // step 2 normal initial process
    [self run];
    
    // Analysis
    [MobClick startWithAppkey:UMENG_ANALYS_APP_KEY reportPolicy:SEND_INTERVAL channelId:nil];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [MobClick setLogEnabled:YES];
    
    // modify user agent
    @autoreleasepool {
        UIWebView* tempWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString* userAgent = [tempWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString *ua = [NSString stringWithFormat:@"%@\\%@/%@",
                        userAgent,
                        @"JIT", VERSION];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent" : ua}];
#if !__has_feature(objc_arc)
        [tempWebView release];
#endif
    }
    
    return YES;
}

#pragma mark - handle OpenURL

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([[url scheme] isEqualToString:APP_NAME]) {
        NSString *resultMsg = [NSString stringWithFormat:@"%@", url];
        
        NSString *paraStr = [NSString stringWithFormat:@"%@://loginreturn?user=&token=&", APP_NAME];
        if ([resultMsg isEqualToString:paraStr]) {
            
            [self openSignInHelp];
            
        } else {
            
            [self clearLoginViewIfNeeded];
            
            [UIApplication sharedApplication].statusBarHidden = YES;
            [self.window addSubview:self.splashNav.view];
            
            NSArray *resultArray = [resultMsg componentsSeparatedByString:@"?"];
            NSArray *pramArray = [resultArray[1] componentsSeparatedByString:@"&"];
            
            [AppManager instance].userId = [pramArray[0] componentsSeparatedByString:@"="][1];
            NSString *sessionId = [pramArray[1] componentsSeparatedByString:@"="][1];
            
            NSString *decryptSessionId = [sessionId stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [AppManager instance].sessionId = [EncryptUtil TripleDES:decryptSessionId encryptOrDecrypt:kCCDecrypt];
            
            [[AppManager instance] beginSSOInitialicationProcess];
        }
        
        return YES;
    } else {
        if (self.wxApiDelegate) {
            return [WXApi handleOpenURL:url delegate:self.wxApiDelegate];
        } else {
            return [WXApi handleOpenURL:url delegate:self];
        }
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    self.toForeground = NO;
    _startup = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    self.toForeground = YES;
    
    [[AppManager instance] relocationForAppActivate];
    
}

- (void)updateUnreadDMCount {
    
    [AppManager instance].msgNumber = STR_FORMAT(@"%d", [UIApplication sharedApplication].applicationIconBadgeNumber);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DM_REFRESH_IN_PERSONAL_VIEW_KEY
                                                        object:nil
                                                      userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DM_REFRESH_IN_CHAT_ALUMNUS_KEY
                                                        object:nil
                                                      userInfo:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // update
    [self updateUnreadDMCount];
    
    // upload log
    _logUploader = [[[LogUploader alloc] init] autorelease];
    [NSThread detachNewThreadSelector:@selector(triggerUpload)
                             toTarget:_logUploader
                           withObject:nil];
    
    // close loading activity during become active
    if ([CommonUtils fetchBoolValueFromLocal:LOADING_NOTIFY_LOCAL_KEY]) {
        [UIUtils closeActivityView];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    // clear UIWebView cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // clear image cache
    [[WXWImageManager instance] clearImageCacheForHandleMemoryWarning];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    [[WXWImageManager instance].imageCache clearAllCachedAndLocalImages];
    
    [WXWDBConnection closeDB];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:self._moc];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *moc = self._moc;
    if (moc != nil)
    {
        if ([moc hasChanges] && ![moc save:&error])
        {
        }
    }
}

- (void)handleSaveNotification:(NSNotification *)aNotification {
    [self._moc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                withObject:aNotification
                             waitUntilDone:YES];
}

#pragma mark - notify
- (void)registerNotify
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    [AppManager instance].deviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    [AppManager instance].deviceToken = [[AppManager instance].deviceToken stringByReplacingOccurrencesOfString:@"<" withString:NULL_PARAM_VALUE];
    [AppManager instance].deviceToken = [[AppManager instance].deviceToken stringByReplacingOccurrencesOfString:@">" withString:NULL_PARAM_VALUE];
    [AppManager instance].deviceToken = [[AppManager instance].deviceToken stringByReplacingOccurrencesOfString:@" " withString:NULL_PARAM_VALUE];
    
    /*
     UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil
     message:[AppManager instance].deviceToken
     delegate:nil
     cancelButtonTitle:@"Cancel"
     otherButtonTitles:@"OK", nil] autorelease];
     [alertView show];
     */
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

//接收到push消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [AppManager instance].appOpenTriggerType = PUSH_TRIGGER_TY;
    
    [PushNotificationHandler handlePushUserInfo:userInfo applicationState:application.applicationState];
}

#pragma mark - Core Data stack
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (_moc != nil)
    {
        return _moc;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _moc = [[NSManagedObjectContext alloc] init];
        [_moc setPersistentStoreCoordinator:coordinator];
    }
    return _moc;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_mom != nil)
    {
        return _mom;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _mom;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_psc != nil)
    {
        return _psc;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:DBFile];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:storeURL error:nil];
    
    NSError *error = nil;
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _psc;
}

#pragma mark - Application's Documents directory
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - WXApiDelegate methods

- (void)onReq:(BaseReq*)req {
    if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        ShowMessageFromWXReq *wxReq = (ShowMessageFromWXReq *)req;
        
        [AppManager instance].appOpenTriggerType = SHARE_ITEM_TRIGGER_TY;
        
        //handle open shared event
        [[AppManager instance] openAppFromWeChatByMessage:wxReq.message];
    }
}

#pragma mark - open shared items

- (void)clearAllCurrentViewControllers {
    _premiereNav = nil;
    
    [self clearHomepageViewController];
}

- (void)openHomePageAfterClearAllViewControllers {
    // step 1: clear all view controller stack
    [self clearAllCurrentViewControllers];
    
    // step 2: re-initialize home page container view controller
    [self goHomePage];
}

- (void)openSharedEventById:(long long)eventId eventType:(int)eventType {
    // step 1: open home page
    [self openHomePageAfterClearAllViewControllers];
    
    // step 2: select event tab and open shared event automatically
    [self.homepageContainer setAutoSelectEventTabFlagWithId:eventId eventType:eventType];
}

- (void)openSharedBrandById:(long long)brandId {
    // step 1: open home page
    [self openHomePageAfterClearAllViewControllers];
    
    // step 2: open shared brand
    [self.homepageContainer setAutoSelectBrandId:brandId];
}

- (void)openSharedVideoById:(long long)videoId {
    // step 1: open home page
    [self openHomePageAfterClearAllViewControllers];
    
    // step 2: open shared video
    [self.homepageContainer setAutoSelectVideoId:videoId];
}

- (void)openSharedWelfareById:(NSString *)welfareId {
    
    // step 1: open home page
    [self openHomePageAfterClearAllViewControllers];
    
    // step 2: open shared welfare
    [self.homepageContainer setAutoSelectWelfareId:welfareId];
}

#pragma mark - open push message
- (void)prepareHomepageForOpenPushMessage {
    [self openHomePageAfterClearAllViewControllers];
    
}
@end
