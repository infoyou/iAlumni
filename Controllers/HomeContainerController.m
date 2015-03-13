//
//  HomepageContainerController.m
//  iAlumni
//
//  Created by Adam on 13-1-8.
//
//

#import "HomeContainerController.h"
#import "HomepageEntranceViewController.h"
#import "EventListViewController.h"
#import "WXWLabel.h"
#import "XMLParser.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "EventEntranceViewController.h"
#import "AlumniEntranceViewController.h"
#import "BizEntranceViewController.h"
#import "BizOppViewController.h"
#import "GroupEventMainViewController.h"
#import "UserProfileViewController.h"
#import "PersonalInfoViewController.h"
#import "MyInfoViewController.h"
#import "Event.h"
#import "TabBarView.h"
#import "WXWSystemInfoManager.h"
#import "UIWebViewController.h"

#import "SupplyDemandListViewController.h"
#import "NaviButton.h"

#import "LoginViewController.h"
#import "EventWebViewController.h"
#import "WXWBarItemButton.h"

#define TAB_WIDTH     62.0f

@interface HomeContainerController ()

@property (nonatomic, retain) NSManagedObjectContext *MOC;
@property (nonatomic, retain) TabBarView *tabBar;
@property (nonatomic, retain) WXWRootViewController *currentVC;
@property (nonatomic, copy) NSString *sharedItemId;
@property (nonatomic, retain) UIWindow *statusBarBackground;

@property (nonatomic, retain) EventWebViewController *eventWebVC;

@end

@implementation HomeContainerController

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC {
    
    self = [super init];
    if (self) {
        self.MOC = MOC;
        
        _noNeedBackButton = YES;
    }
    return self;
}

- (void)clearCurrentVC {
    [self.currentVC cancelConnectionAndImageLoading];
    [self.currentVC cancelLocation];
    
    if (self.currentVC.view) {
        [self.currentVC.view removeFromSuperview];
    }
    
    self.currentVC = nil;
}

- (void)dealloc {
    self.MOC = nil;
    
    self.sharedItemId = nil;
    
    self.tabBar = nil;
    
    [self removeCurrentView];
    
    self.statusBarBackground = nil;
    
    [super dealloc];
}

- (CGFloat)contentHeight {
    return self.view.frame.size.height - HOMEPAGE_TAB_HEIGHT;
}

- (void)initTabBar {
    if (CURRENT_OS_VERSION >= IOS7) {
        _tabbarOriginalY = self.view.frame.size.height - HOMEPAGE_TAB_HEIGHT;
    } else {
        _tabbarOriginalY = self.view.frame.size.height - HOMEPAGE_TAB_HEIGHT - self.navigationController.navigationBar.frame.size.height;
    }
    
    self.tabBar = [[[TabBarView alloc] initWithFrame:CGRectMake(0, _tabbarOriginalY, self.view.frame.size.width, HOMEPAGE_TAB_HEIGHT) delegate:self] autorelease];
    [self.view addSubview:self.tabBar];
}

- (void)initNavigationBarTitle {
    self.navigationItem.title = LocaleStringForKey(NSAppTitle, nil);
}

- (void)openSharedItem {
    switch (_sharedItemType) {
        case SHARED_EVENT_TY:
        {
            if (self.sharedItemId.longLongValue > 0ll) {
                [self openSharedEventById:self.sharedItemId.longLongValue];
                
                [self selectTabItemByTag:EVENT_TAG];
            }
            break;
        }
            
        case SHARED_BRAND_TY:
        {
            if (self.sharedItemId.longLongValue > 0ll) {
                [self openSharedBrandWithId:self.sharedItemId.longLongValue];
            }
            break;
        }
            
        case SHARED_VIDEO_TY:
        {
            if (self.sharedItemId.longLongValue > 0) {
                [self openSharedVideoWithId:self.sharedItemId.longLongValue];
            }
            break;
        }
            
        case SHARED_WELFARE_TY:
        {
            if (self.sharedItemId.length > 0) {
                [self openSharedWelfareWithId:self.sharedItemId];
                
                [self selectTabItemByTag:BIZ_TAG];
            }
            break;
        }
            
        default:
            [self selectHomepage];
            break;
    }
    
    // reset
    self.sharedItemId = 0ll;
    
}

- (void)openPushedItem {
    
    switch ([AppManager instance].pushMessageType) {
        case DM_MSG_PUSH_TY:
        {
            
            MyInfoViewController *vc = [self arrangePersonalVC];
            
            [vc openDMForPush];
            
            [self selectTabItemByTag:MORE_TAG];
            
            if (CURRENT_OS_VERSION >= IOS7) {
                [self displayNavigationBarForiOS7];
                
                self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x,
                                               self.view.frame.size.height - self.tabBar.frame.size.height,
                                               self.tabBar.frame.size.width,
                                               self.tabBar.frame.size.height);
            }
            
            break;
        }
            
        case NEW_EVENT_PUSH_TY:
        {
//            [self selectEvent];
            [self selectEventByHtml5];
            [self selectTabItemByTag:EVENT_TAG];
            break;
        }
            
        case REMIND_EVENT_PUSH_TY:
        {
            if ([AppManager instance].pushedItemId.length > 0) {
                [self openSharedEventById:[AppManager instance].pushedItemId.longLongValue];
                
                [self selectTabItemByTag:EVENT_TAG];
            } else {
                [self selectHomepage];
            }
            
            break;
        }
            
        case NEW_SUPPLY_DEMAND_PUSH_TY:
        {
            BizOppViewController *vc = [self createBizOppEntranceVC];
            
            [self arrangeCurrentVC:vc];
            
            if (CURRENT_OS_VERSION >= IOS7) {
                [self hideNavigationBarForiOS7];
            }
            
            [vc openSupplyDemand];
            
            [self selectTabItemByTag:BIZ_TAG];
            break;
        }
            
        case NEW_WELFARE_PUSH_TY:
        {
            
            BizOppViewController *vc = [self createBizOppEntranceVC];
            
            [self arrangeCurrentVC:vc];
            
            if (CURRENT_OS_VERSION >= IOS7) {
                [self hideNavigationBarForiOS7];
            }
            
            [vc openWelfare];
            
            [self selectTabItemByTag:BIZ_TAG];
            break;
        }
            
        default:
            break;
    }
    
}

- (void)initItems {
    
    [self initTabBar];
    
    [self initNavigationBarTitle];
    
    switch (_sharedItemType) {
        case SHARED_EVENT_TY:
        {
            if (self.sharedItemId.longLongValue > 0ll) {
                [self openSharedEventById:self.sharedItemId.longLongValue];
                
                [self selectTabItemByTag:EVENT_TAG];
            }
            break;
        }
            
        case SHARED_BRAND_TY:
        {
            if (self.sharedItemId.longLongValue > 0ll) {
                [self openSharedBrandWithId:self.sharedItemId.longLongValue];
            }
            break;
        }
            
        case SHARED_VIDEO_TY:
        {
            if (self.sharedItemId.longLongValue > 0) {
                [self openSharedVideoWithId:self.sharedItemId.longLongValue];
            }
            break;
        }
            
        case SHARED_WELFARE_TY:
        {
            if (self.sharedItemId.length > 0) {
                [self openSharedWelfareWithId:self.sharedItemId];
                
                [self selectTabItemByTag:BIZ_TAG];
            }
            break;
        }
            
        default:
            [self selectHomepage];
            break;
    }
    
    // reset
    self.sharedItemId = 0ll;
    
}

- (void)showUpdateMessageIfNeeded {
    
    if ([AppManager instance].isNewVersion) {
        ShowAlertWithTwoButton(self, LocaleStringForKey(NSNoteTitle, nil), [AppManager instance].softDesc, LocaleStringForKey(NSNoThanksTitle, nil), LocaleStringForKey(NSSureTitle, nil));
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    [self initTabBar];
    
    [self initNavigationBarTitle];
    
    switch ([AppManager instance].appOpenTriggerType) {
        case PUSH_TRIGGER_TY:
            [self openPushedItem];
            
            [AppManager instance].pushedItemId = nil; // reset pushed item id
            break;
            
        case SHARE_ITEM_TRIGGER_TY:
            [self openSharedItem];
            break;
            
        case NORMAL_TRIGGER_TY:
            [self selectHomepage];
            break;
            
        default:
            break;
    }
    
    //  [self initItems];
    [self showUpdateMessageIfNeeded];
    
    /* //add Demo label
    UILabel *demoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 40)];
    demoLabel.textAlignment = UITextAlignmentCenter;
    demoLabel.text = @"Demo";
    demoLabel.textColor = [UIColor blackColor];
    [((iAlumniAppDelegate*)APP_DELEGATE).window addSubview:demoLabel];
     */
}

- (void)hideNavigationBarForiOS7 {
    
    self.navigationController.navigationBarHidden = YES;
    
    [WXWSystemInfoManager instance].navigationBarHidden = YES;
    
    if (self.statusBarBackground == nil) {
        self.statusBarBackground = [[[UIWindow alloc] initWithFrame: CGRectMake(0, 0, APP_WINDOW.frame.size.width, 20)] autorelease];
        self.statusBarBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationBarBackground.png"]];
        [self.statusBarBackground setHidden:NO];
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    if (self.currentVC != nil) {
        self.currentVC.view.frame = CGRectMake(self.currentVC.view.frame.origin.x,
                                               SYS_STATUS_BAR_HEIGHT,
                                               self.currentVC.view.frame.size.width,
                                               self.view.frame.size.height - SYS_STATUS_BAR_HEIGHT);
    }
}

- (void)displayNavigationBarForiOS7 {
    self.navigationController.navigationBarHidden = NO;
    [WXWSystemInfoManager instance].navigationBarHidden = NO;
    self.statusBarBackground = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![AppManager instance].messageAutoLoaded) {
        // load new system message
        [self fetchSystemMessages];
    }
    
    if (self.currentVC) {
        if ([self.currentVC respondsToSelector:@selector(play)]) {
            [self.currentVC performSelector:@selector(play)];
        }
        
        if (CURRENT_OS_VERSION >= IOS7) {
            if ([self.currentVC isKindOfClass:[HomepageEntranceViewController class]] ||
                [self.currentVC isKindOfClass:[BizOppViewController class]]) {
                [self hideNavigationBarForiOS7];
            }
        } else {
            if ([self.currentVC isKindOfClass:[HomepageEntranceViewController class]]) {
                self.navigationController.navigationBarHidden = YES;
                
                [WXWSystemInfoManager instance].navigationBarHidden = YES;
            }
        }
        
        [self.currentVC viewWillAppear:animated];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.currentVC isKindOfClass:[HomepageEntranceViewController class]]) {
        [self performSelector:@selector(displayNavigationBarForiOS7)
                   withObject:nil
                   afterDelay:0.1f];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.currentVC) {
        if ([self.currentVC respondsToSelector:@selector(stopPlay)]) {
            [self.currentVC performSelector:@selector(stopPlay)];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - refresh tab items
- (void)refreshTabItems {
    [self.tabBar refreshItems];
}

- (void)adjustTabbarForNavigationBarVisible {
    self.tabBar.frame = CGRectMake(0, self.view.frame.size.height - self.tabBar.frame.size.height, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
}

- (void)adjustTabbarForNavigationBarInvisible {
    
    self.tabBar.frame = CGRectMake(0, _tabbarOriginalY, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
}

#pragma mark - TabDelegate methods

- (void)removeCurrentView {
    
    if ([self.currentVC respondsToSelector:@selector(stopPlay)]) {
        [self.currentVC performSelector:@selector(stopPlay)];
    }
    
    [self clearCurrentVC];
}

- (void)arrangeCurrentVC:(WXWRootViewController *)vc {
    
    [self removeCurrentView];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.tabBar.frame = CGRectMake(0, _tabbarOriginalY, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    
    self.currentVC = vc;
    
    [self.view addSubview:self.currentVC.view];
    
    if ([WXWCommonUtils currentOSVersion] < IOS5) {
        [self.currentVC viewWillAppear:YES];
    }
    
    [self.view bringSubviewToFront:self.tabBar];
    
}

- (void)refreshBadges {
    [self.tabBar refreshBadges];
}

- (void)selectHomepage {
    
    if ([self.currentVC isKindOfClass:[HomepageEntranceViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSAppTitle, nil);
    
    HomepageEntranceViewController *vc = [[[HomepageEntranceViewController alloc] initWithMOC:self.MOC
                                                                                   viewHeight:[self contentHeight]
                                                                                     parentVC:self] autorelease];
    [self arrangeCurrentVC:vc];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        [self hideNavigationBarForiOS7];
    } else {
        self.navigationController.navigationBarHidden = YES;
        
        [WXWSystemInfoManager instance].navigationBarHidden = YES;
        
        self.tabBar.frame = CGRectMake(0, self.view.frame.size.height - self.tabBar.frame.size.height,
                                       self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    }
}

- (AlumniEntranceViewController *)arrangeAlumniEntranceVC {
    
    AlumniEntranceViewController *vc = [[[AlumniEntranceViewController alloc] initWithMOC:self.MOC
                                                                               viewHeight:[self contentHeight]
                                                                                 parentVC:self
                                                                      refreshBadgesAction:@selector(refreshBadges)] autorelease];
    [self arrangeCurrentVC:vc];
    
    return vc;
}

- (SupplyDemandListViewController *)arrangeSupplyDemandVC {
    
    SupplyDemandListViewController *vc = [[[SupplyDemandListViewController alloc] initWithMOC:_MOC
                                                                            needAdjustForiOS7:YES
                                                                                     parentVC:self] autorelease];
    vc.title = LocaleStringForKey(NSAllSupplyDemandTitle, nil);
    
    [self arrangeCurrentVC:vc];
    
    return vc;
}

- (EventListViewController *)creaetEvent2ClubEntranceVC {
    
    EventListViewController *eventListVC = [[[EventListViewController alloc] initWithMOC:_MOC parentVC:self tabIndex:EVENT_TAB_IDX] autorelease];
    eventListVC.title = LocaleStringForKey(NSEventTitle, nil);
    
    eventListVC.view.frame = CGRectOffset(eventListVC.view.frame, 0, -20);
    
    return eventListVC;
}

- (GroupEventMainViewController *)createGroupEventEntranceVC {
    GroupEventMainViewController *groupEventVC = [[[GroupEventMainViewController alloc] initWithMOC:_MOC parentVC:self] autorelease];
    
    groupEventVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 40 + self.view.frame.size.height - HOMEPAGE_TAB_HEIGHT);
    
    return groupEventVC;
}

- (BizOppViewController *)createBizOppEntranceVC {
    BizOppViewController *vc = [[[BizOppViewController alloc] initWithMOC:self.MOC
                                                               viewHeight:[self contentHeight]
                                                     parentViewController:self] autorelease];
    return vc;
}

- (GroupEventMainViewController *)gotoGroupEventEntranceVC {
    self.navigationItem.title = LocaleStringForKey(NSEventTitle, nil);
    
    GroupEventMainViewController *groupEventMainVC = [self createGroupEventEntranceVC];
    [self arrangeCurrentVC:groupEventMainVC];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.tabBar.frame = CGRectMake(0, self.view.frame.size.height - HOMEPAGE_TAB_HEIGHT, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    
    return groupEventMainVC;
}

- (void)selectEvent {
    
    if ([self.currentVC isKindOfClass:[GroupEventMainViewController class]]) {
        return;
    }
    
    [self gotoGroupEventEntranceVC];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        [self hideNavigationBarForiOS7];
        
        self.currentVC.view.frame = CGRectMake(self.currentVC.view.frame.origin.x,
                                               0,
                                               self.currentVC.view.frame.size.width,
                                               APP_WINDOW.frame.size.height);
    }
}

- (UIWebViewController *)goEventHtml5VC {
    self.navigationItem.title = LocaleStringForKey(NSEventTitle, nil);
    
    NSString *userName = [AppManager instance].userName;
    if (![AppManager instance].isLogin) {
        userName = @"";
    }
    
    EventWebViewController *webVC = [[[EventWebViewController alloc] initWithNeedAdjustForiOS7:NO] autorelease];
    webVC.strTitle = LocaleStringForKey(NSTodoItemMsg, nil);
    webVC.strUrl = [NSString stringWithFormat:@"%@&vipId=%@&name=%@&iconUrl=%@&class=%@&email=%@", EVENT_H5_URL, [AppManager instance].personId, userName, [AppManager instance].userImgUrl, [AppManager instance].className, [AppManager instance].email];
    
    [self arrangeCurrentVC:webVC];
    
    self.eventWebVC = webVC;
    
    return webVC;
}

- (void)selectEventByHtml5
{
    if ([self.currentVC isKindOfClass:[UIWebViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSEventTitle, nil);
    self.navigationItem.rightBarButtonItem = nil;
    
    
    WXWBarItemButton *backButton = [[[WXWBarItemButton alloc] initBackStyleButtonWithFrame:CGRectMake(0, 0, 48.0f, 44.0f)] autorelease];
    [backButton addTarget:self action:@selector(doWebBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    [self addLeftBarButtonWithTitle:LocaleStringForKey(NSBackTitle, nil)
                             target:self
                             action:@selector(doWebBack:)];
    
    /*
    UIBarButtonItem* sendItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSPublishTitle, nil) style:UIBarButtonItemStyleDone
                                                                 target:self action:@selector(doSendSupplyDemand)] autorelease];
    [sendItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = sendItem;
    */
    
    [self goEventHtml5VC];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        [self displayNavigationBarForiOS7];
        
        self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x,
                                       self.view.frame.size.height - self.tabBar.frame.size.height,
                                       self.tabBar.frame.size.width,
                                       self.tabBar.frame.size.height);
    }
}

- (void)selectBiz {
    
    if ([self.currentVC isKindOfClass:[BizEntranceViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSBizCoopTitle, nil);
    
    BizEntranceViewController *vc = [[[BizEntranceViewController alloc] initWithMOC:self.MOC
                                                                         viewHeight:[self contentHeight]
                                                                           parentVC:self] autorelease];
    
    [self arrangeCurrentVC:vc];
}

- (void)selectBizOpp {
    
    if ([self.currentVC isKindOfClass:[BizOppViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSBizCoopTitle, nil);
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [self arrangeCurrentVC:[self createBizOppEntranceVC]];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        [self hideNavigationBarForiOS7];
    }
}

- (void)selectSupplyDemand {
    
    if (![AppManager instance].isLogin) {
        
        [AppManager instance].prepareForLogin = YES;
        LoginViewController *loginVC = [[[LoginViewController alloc] initWithMOC:_MOC] autorelease];
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        navi.navigationBar.tintColor = TITLESTYLE_COLOR;
        
        [self.currentVC presentModalViewController:navi animated:YES];
        return;
    }

    
    if ([self.currentVC isKindOfClass:[SupplyDemandListViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSAllSupplyDemandTitle, nil);
    
    WXWBarItemButton *backButton = [[[WXWBarItemButton alloc] initBackStyleButtonWithFrame:CGRectMake(0, 0, 48.0f, 44.0f)] autorelease];
    [backButton addTarget:self action:@selector(doSendSupplyDemand) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    [self addRightBarButtonWithTitle:LocaleStringForKey(NSPublishTitle, nil)
                             target:self
                             action:@selector(doSendSupplyDemand)];
    
    /*
    UIBarButtonItem* sendItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSPublishTitle, nil) style:UIBarButtonItemStyleDone
                                                                   target:self action:@selector(doSendSupplyDemand)] autorelease];
    [sendItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = sendItem;
    */
    
    self.navigationItem.leftBarButtonItem = nil;

    [self arrangeSupplyDemandVC];
    if (CURRENT_OS_VERSION >= IOS7) {
        [self displayNavigationBarForiOS7];
        
        self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x,
                                       self.view.frame.size.height - self.tabBar.frame.size.height,
                                       self.tabBar.frame.size.width,
                                       self.tabBar.frame.size.height);
    }
}

- (void)selectAlumni {
    
    if ([self.currentVC isKindOfClass:[AlumniEntranceViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSAlumniTitle, nil);
    
    [self arrangeAlumniEntranceVC];
    if (CURRENT_OS_VERSION >= IOS7) {
        [self displayNavigationBarForiOS7];
    }
}

- (void)selectMore {
    if ([self.currentVC isKindOfClass:[UserProfileViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSMoreTitle, nil);
    
    UserProfileViewController *vc = [[[UserProfileViewController alloc] initWithMOC:self.MOC
                                                                         viewHeight:[self contentHeight]
                                                                           parentVC:self] autorelease];
    [self arrangeCurrentVC:vc];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        [self displayNavigationBarForiOS7];
    }
}

- (MyInfoViewController *)arrangePersonalVC {
    
    //  PersonalInfoViewController *vc = [[[PersonalInfoViewController alloc] initWithMOC:self.MOC
    //                                                                         viewHeight:[self contentHeight]
    //                                                               parentViewController:self] autorelease];
    
    MyInfoViewController *vc = [[[MyInfoViewController alloc] initWithMOC:_MOC parentVC:self] autorelease];
    [self arrangeCurrentVC:vc];
    
    return vc;
}

- (void)selectPersonal {
    
    if (![AppManager instance].isLogin) {
        
        [AppManager instance].prepareForLogin = YES;
        LoginViewController *loginVC = [[[LoginViewController alloc] initWithMOC:_MOC] autorelease];
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        navi.navigationBar.tintColor = TITLESTYLE_COLOR;
        
        [self.currentVC presentModalViewController:navi animated:YES];
        return;
    }
    
    if ([self.currentVC isKindOfClass:[MyInfoViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSMeTitle, nil);
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [self arrangePersonalVC];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        [self displayNavigationBarForiOS7];
        
        self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x,
                                       self.view.frame.size.height - self.tabBar.frame.size.height,
                                       self.tabBar.frame.size.width,
                                       self.tabBar.frame.size.height);
    }
}

#pragma mark - notify handle
- (UIWebViewController *)goNotifyEventHtml5VC {
    self.navigationItem.title = LocaleStringForKey(NSEventTitle, nil);
    
    UIWebViewController *webVC = [[[UIWebViewController alloc] initWithNeedAdjustForiOS7:NO] autorelease];
    webVC.strTitle = LocaleStringForKey(NSTodoItemMsg, nil);
    if ([[AppManager instance].eventUrl hasPrefix:@"http://"]) {
        webVC.strUrl = [AppManager instance].eventUrl;
    } else {
        webVC.strUrl = [NSString stringWithFormat:@"http://%@", [AppManager instance].eventUrl];
    }
    
    [self arrangeCurrentVC:webVC];
    
    return webVC;
}

- (void)selectNotifyEventByHtml5
{
    if ([self.currentVC isKindOfClass:[UIWebViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSEventTitle, nil);
    
    // left
    UIBarButtonItem* backItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSBackTitle, nil) style:UIBarButtonItemStyleDone
                                                                 target:self action:@selector(doBack)] autorelease];
    [backItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = backItem;
    
    // right
    UIBarButtonItem* sendItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSCloseTitle, nil) style:UIBarButtonItemStyleDone
                                                                 target:self action:@selector(doCloseNotifyEvent)] autorelease];
    [sendItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = sendItem;
    
    [self goNotifyEventHtml5VC];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        [self displayNavigationBarForiOS7];
        
        self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x,
                                       self.view.frame.size.height - self.tabBar.frame.size.height,
                                       self.tabBar.frame.size.width,
                                       self.tabBar.frame.size.height);
    }
    
}

#pragma mark - system message
- (void)fetchSystemMessages {
    
    NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:LOAD_SYS_MESSAGE_TY];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:LOAD_SYS_MESSAGE_TY];
    
    [connFacade fetchGets:url];
}


#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
    switch (contentType) {
            
        case LOAD_SYS_MESSAGE_TY:
        {
            // parser the loaded system message, then homepage responseible for showing them
            [XMLParser parserResponseXml:result
                                    type:contentType
                                     MOC:_MOC
                       connectorDelegate:self
                                     url:url];
            
            [AppManager instance].messageAutoLoaded = YES;
        }
            break;
            
        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
    
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    
    // no need to load message again although loading failed, message only be loaded when app startup
    [AppManager instance].messageAutoLoaded = YES;
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - alert delegate method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager instance].softUrl]];
    }
}

#pragma mark - open shared item
- (void)openSharedEventById:(long long)eventId {
    
    GroupEventMainViewController *vc = [self gotoGroupEventEntranceVC];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        [self hideNavigationBarForiOS7];
        
        self.currentVC.view.frame = CGRectMake(self.currentVC.view.frame.origin.x,
                                               0,
                                               self.currentVC.view.frame.size.width,
                                               APP_WINDOW.frame.size.height);
    }
    
    [vc openSharedEventById:eventId];
}

- (void)openSharedBrandWithId:(long long)brandId {
    
    [self selectHomepage];
    
    [(HomepageEntranceViewController *)self.currentVC openSharedBrandWithId:brandId];
}

- (void)openSharedVideoWithId:(long long)videoId {
    [self selectHomepage];
    
    [(HomepageEntranceViewController *)self.currentVC openSharedVideoWithId:videoId];
}

- (void)openSharedWelfareWithId:(NSString *)welfareId {
    
    BizOppViewController *vc = [self createBizOppEntranceVC];
    
    [self arrangeCurrentVC:vc];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        [self hideNavigationBarForiOS7];
    }
    
    [vc openWelfare];
}

- (void)setAutoSelectEventTabFlagWithId:(long long)eventId eventType:(int)eventType {
    //_autoSelectEventTab = YES;
    _openTriggerType = SHARE_ITEM_TRIGGER_TY;
    
    _sharedItemType = SHARED_EVENT_TY;
    
    self.sharedItemId = STR_FORMAT(@"%lld", eventId);
    
    _sharedEventType = eventType;
}

- (void)setAutoSelectBrandId:(long long)brandId {
    
    _openTriggerType = SHARE_ITEM_TRIGGER_TY;
    
    _sharedItemType = SHARED_BRAND_TY;
    
    self.sharedItemId = STR_FORMAT(@"%lld", brandId);
}

- (void)setAutoSelectVideoId:(long long)videoId {
    
    _openTriggerType = SHARE_ITEM_TRIGGER_TY;
    
    _sharedItemType = SHARED_VIDEO_TY;
    
    self.sharedItemId = STR_FORMAT(@"%lld", videoId);
}

- (void)setAutoSelectWelfareId:(NSString *)welfareId {
    
    _openTriggerType = SHARE_ITEM_TRIGGER_TY;
    
    _sharedItemType = SHARED_WELFARE_TY;
    
    self.sharedItemId = welfareId;
}

- (void)selectTabItemByTag:(EventEntranceItemTagType)tag {
    [self.tabBar switchTabHighlightStatus:tag];
}

#pragma mark - MFMessageComposeViewControllerDelegate method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    switch (result) {
        case MessageComposeResultSent:
            break;
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)hideTabBar {
    
    self.tabBar.alpha = 0;
}

- (void)showTabBar {
    self.tabBar.alpha = 1;
}

- (void)doSendSupplyDemand
{
    [(SupplyDemandListViewController *)self.currentVC doSendSupplyDemand];
}

#pragma mark - notify vc
- (void)doBack
{
    [(UIWebViewController *)self.currentVC doBack];
}

- (void)doCloseNotifyEvent
{
    [self selectHomepage];
}

- (void)doWebBack:(id)sender
{
    if ([self.eventWebVC.webView canGoBack]) {
        
        [self.eventWebVC.webView goBack];
    } else {
        
        [self selectHomepage];
    }
}

@end
