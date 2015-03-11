//
//  HomepageEntranceViewController.m
//  iAlumni
//
//  Created by Adam on 13-1-8.
//
//

#import "HomepageEntranceViewController.h"
#import "WXWLabel.h"
#import "VideoWallContainerView.h"
#import "NewsThumbnailView.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "NearbyEntranceView.h"
#import "SearchAlumniEntranceView.h"
#import "TodoEntranceView.h"
#import "AdvEntranceView.h"
#import "VideoListViewController.h"
#import "CEIBSNewsListViewController.h"
#import "AppManager.h"
#import "UserListViewController.h"
#import "SearchAlumniViewController.h"
#import "News.h"
#import "MessageListViewController.h"
#import "QuestionnaireEntranceView.h"
#import "AlumniSurveyViewController.h"
#import "NearbyEntranceViewController.h"
#import "BrandDetailViewController.h"
#import "UIWebViewController.h"
#import "WXWNavigationController.h"
#import "SloganView.h"

#import "LoginViewController.h"
#import "ProfileSettingViewController.h"
#import "BackWebViewController.h"

#define VIDEO_35INCH_HEIGHT   150.0f
#define VIDEO_40INCH_HEIGHT   238.0f

#define GRID_WIDTH            145.0f
#define MEDIUM_GRID_HEIGHT    89.0f
#define SMALL_GRID_HEIGHT     42.0f

#define COMMON_STUFF_CELL_HEIGHT  320.0f

#define CELL_COUNT            2

enum {
    VIDEO_CELL,
    ALUMNI_NEARBY_CELL,
};

@interface HomepageEntranceViewController ()
@property (nonatomic, retain) SloganView *sloganView;
@end

@implementation HomepageEntranceViewController

#pragma mark - load latest system info
- (void)loadSystemInfo {
    NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:LOAD_HOMEPAGE_INFO];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:LOAD_HOMEPAGE_INFO];
    [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)parserSystemInfo {
    
    //[_todoEntranceView arrangeMessages];
    
    if (self.parentVC && [self.parentVC respondsToSelector:@selector(refreshBadges)]) {
        [self.parentVC performSelector:@selector(refreshBadges)];
    }
}

#pragma mark - user actions
- (void)openVideos:(id)sender {
    
    VideoListViewController *videoListVC = [[[VideoListViewController alloc] initWithMOC:_MOC selectedVideoId:[_videoWallContainer currentVideoId]] autorelease];
    videoListVC.title = LocaleStringForKey(NSVideoTitle, nil);
    
    if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:videoListVC animated:YES];
    }
    
    if (CURRENT_OS_VERSION >= IOS7) {
        self.parentVC.navigationController.navigationBarHidden = NO;
    }
}

- (void)openNews0:(id)sender {
    
    CEIBSNewsListViewController *newsListVC = [[[CEIBSNewsListViewController alloc] initWithMOC:_MOC
                                                                                         holder:nil
                                                                               backToHomeAction:nil
                                                                              needAdjustForiOS7:_needAdjustForiOS7] autorelease];
    newsListVC.title = LocaleStringForKey(NSEventReportTitle, nil);
    
    if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:newsListVC animated:YES];
    }
    
    if (CURRENT_OS_VERSION >= IOS7) {
        self.parentVC.navigationController.navigationBarHidden = NO;
    }
}

- (void)openNearby:(id)sender {
    
    if (![AppManager instance].isLogin) {
        
        [AppManager instance].prepareForLogin = YES;
        LoginViewController *loginVC = [[[LoginViewController alloc] initWithMOC:_MOC] autorelease];
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        navi.navigationBar.tintColor = TITLESTYLE_COLOR;
        
        [self.parentVC presentModalViewController:navi animated:YES];
        return;
    }
    
    /*
     UserListViewController *userListVC = [[[UserListViewController alloc] initWithType:SHAKE_USER_LIST_TY
     needGoToHome:NO
     MOC:_MOC
     group:nil
     needAdjustForiOS7:_needAdjustForiOS7] autorelease];
     userListVC.pageIndex = 0;
     userListVC.requestParam = [NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude><distance_scope>10</distance_scope><time_scope>1000</time_scope><order_by_column>datetime</order_by_column><shake_where>%@</shake_where><shake_what>%@</shake_what><page>0</page><page_size>30</page_size><refresh_only>0</refresh_only>", [AppManager instance].longitude, [AppManager instance].latitude, [AppManager instance].defaultPlace, [AppManager instance].defaultThing];
     [AppManager instance].shakeLocationHistory = [NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude>",[AppManager instance].longitude, [AppManager instance].latitude];
     userListVC.title = LocaleStringForKey(NSAlumniTitle, nil);
     */
    
    ProfileSettingViewController *profileSettingVC = [[[ProfileSettingViewController alloc] initWithMOC:_MOC] autorelease];
    profileSettingVC.title = LocaleStringForKey(NSProfileSettingTitle, nil);
    
    if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:profileSettingVC animated:YES];
    }
    
    if (CURRENT_OS_VERSION >= IOS7) {
        self.parentVC.navigationController.navigationBarHidden = NO;
    }
}

- (void)openSearchAlumni:(id)sender {
    
    if (![AppManager instance].isLogin) {
        
        [AppManager instance].prepareForLogin = YES;
        LoginViewController *loginVC = [[[LoginViewController alloc] initWithMOC:_MOC] autorelease];

        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        navi.navigationBar.tintColor = TITLESTYLE_COLOR;

        [self.parentVC presentModalViewController:navi animated:YES];
        return;
    }
    
    SearchAlumniViewController *searchVC = [[[SearchAlumniViewController alloc] initWithMOC:_MOC
                                                                          needAdjustForiOS7:_needAdjustForiOS7] autorelease];
    searchVC.title = LocaleStringForKey(NSAlumniSearchTitle, nil);
    
    if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:searchVC animated:YES];
    }
    
    if (CURRENT_OS_VERSION >= IOS7) {
        self.parentVC.navigationController.navigationBarHidden = NO;
    }
}

- (void)openNews:(id)sender {
    
    BackWebViewController *webVC = [[[BackWebViewController alloc] initWithNeedAdjustForiOS7:YES] autorelease];
    WXWNavigationController *webViewNav = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
    webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
    
    webVC.strTitle = LocaleStringForKey(NSNewsActivityTitle, nil);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@&vipId=%@&name=%@&iconUrl=%@&class=%@&email=%@", NEWS_H5_URL, [AppManager instance].personId, [AppManager instance].userName, [AppManager instance].userImgUrl, [AppManager instance].className, [AppManager instance].email];
    NSString *encodingStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    webVC.strUrl = encodingStr;
    
    [self.parentVC presentModalViewController:webViewNav
                                     animated:YES];
}

- (void)openTodoList:(id)sender {
    
    if (![AppManager instance].isLogin) {
        
        [AppManager instance].prepareForLogin = YES;
        LoginViewController *loginVC = [[[LoginViewController alloc] initWithMOC:_MOC] autorelease];
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        navi.navigationBar.tintColor = TITLESTYLE_COLOR;
        
        [self.parentVC presentModalViewController:navi animated:YES];
        return;
    }
    
    BackWebViewController *webVC = [[[BackWebViewController alloc] initWithNeedAdjustForiOS7:YES] autorelease];
    WXWNavigationController *webViewNav = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
    webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
    
//    NSString *encodingImgUrlStr = [[AppManager instance].userImgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSString *encodingImgUrlStr = [AppManager instance].userImgUrl;
    NSString *urlStr = [NSString stringWithFormat:@"%@&vipId=%@&name=%@&iconUrl=%@&class=%@&email=%@", HOME_EVENT_H5_URL, [AppManager instance].personId, [AppManager instance].userName, encodingImgUrlStr, [AppManager instance].className, [AppManager instance].email];
//    NSString *encodingStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    webVC.strTitle = LocaleStringForKey(NSTodoItemMsg, nil);
//    webVC.strUrl = encodingStr;
    webVC.strUrl = urlStr;
    
    [self.parentVC presentModalViewController:webViewNav
                                     animated:YES];
    
    /*
     NSArray *types = [NSArray arrayWithObjects:@(GROUP_PAYMENT_MSG_TY), @(EVENT_PAYMENT_MSG_TY), nil];
     MessageListViewController *messageListVC = [[[MessageListViewController alloc] initWithMOC:self.MOC
     holder:nil
     backToHomeAction:nil
     messageTypes:types] autorelease];
     messageListVC.title = LocaleStringForKey(NSMessageTitle, nil);
     
     if (self.parentVC) {
     [self.parentVC.navigationController pushViewController:messageListVC animated:YES];
     }
     */
}

- (void)openAdv:(id)sender {
    
    if ([WXApi isWXAppInstalled]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_PUBLIC_NO_URL]];
        
    } else {
        
        ShowAlertWithTwoButton(self, nil, LocaleStringForKey(NSNoWeChatMsg, nil), LocaleStringForKey(NSDonotInstallTitle, nil),LocaleStringForKey(NSInstallTitle, nil));
    }
}

- (void)openDonation:(id)sender {
    
    BackWebViewController *webVC = [[[BackWebViewController alloc] initWithNeedAdjustForiOS7:YES] autorelease];
    WXWNavigationController *webViewNav = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
    webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
    webVC.strTitle = LocaleStringForKey(NSDonateTitle, nil);
    
//    NSString *url = [CommonUtils geneUrl:DONATE_URL itemType:DONATE_TY];
    webVC.strUrl = DONATION_H5_URL;
    
    [self.parentVC presentModalViewController:webViewNav
                                     animated:YES];
    
}

- (void)openQuestion:(id)sender {
    
    AlumniSurveyViewController *surveyVC = [[[AlumniSurveyViewController alloc] initWithMOC:_MOC] autorelease];
    surveyVC.title = LocaleStringForKey(NSSurveyTitle, nil);
    
    if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:surveyVC animated:YES];
    }
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
         parentVC:(UIViewController *)parentVC {
    self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                            holder:nil
                                  backToHomeAction:nil
                             needRefreshHeaderView:NO
                             needRefreshFooterView:NO
                                        tableStyle:UITableViewStylePlain
                                        needGoHome:NO];
    if (self) {
        _viewHeight = viewHeight;
        
        self.parentVC = parentVC;
        
        _noNeedBackButton = YES;
        
        _needAdjustForiOS7 = NO;
        if (CURRENT_OS_VERSION >= IOS7) {
            _needAdjustForiOS7 = YES;
        }
        
    }
    return self;
}

- (void)dealloc {
    
    // stop video wall scroll view loading
    [[NSNotificationCenter defaultCenter] postNotificationName:CONN_CANCELL_NOTIFY
                                                        object:self
                                                      userInfo:nil];
    
    self.sloganView = nil;
    
    [super dealloc];
}

- (void)addSlogan {
    if ([CommonUtils screenHeightIs4Inch]) {
        
        self.sloganView = [[[SloganView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 20) MOC:_MOC] autorelease];
        
        _tableView.tableFooterView = self.sloganView;
        /*
         _tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width,
         40)] autorelease];
         
         _sloganLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
         textColor:DARK_TEXT_COLOR
         shadowColor:TRANSPARENT_COLOR
         font:BOLD_FONT(20)] autorelease];
         _sloganLabel.text = LocaleStringForKey(NSHomepageSolganTitle, nil);
         CGSize size = [CommonUtils sizeForText:_sloganLabel.text font:_sloganLabel.font];
         _sloganLabel.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f,
         -5,
         size.width, size.height);
         [_tableView.tableFooterView addSubview:_sloganLabel];
         */
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.parentVC) {
        self.parentVC.navigationItem.rightBarButtonItem = nil;
    }
    
    self.view.frame = CGRectMake(0,
                                 0,
                                 self.view.frame.size.width,
                                 _viewHeight);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    if (CURRENT_OS_VERSION >= IOS7) {
        _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                      _tableView.frame.origin.y,
                                      _tableView.frame.size.width,
                                      self.view.frame.size.height - NAVIGATION_BAR_HEIGHT);
    }
    
    [self loadSystemInfo];
    
    [self addSlogan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ScrollAutoPlayerDelegate methods
- (void)play {
    if (_videoWallContainer) {
        [_videoWallContainer play];
    }
    
    /*
     if (_todoEntranceView) {
     [_todoEntranceView arrangeMessages];
     }
     */
}

- (void)stopPlay {
    if (_videoWallContainer) {
        [_videoWallContainer stopPlay];
    }
    
    /*
     if (_todoEntranceView) {
     [_todoEntranceView stopPlay];
     }
     */
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
    
    if ([XMLParser parserResponseXml:result
                                type:contentType
                                 MOC:_MOC
                   connectorDelegate:self
                                 url:url]) {
        _loaded = YES;
        
        [self parserSystemInfo];
        
        [self displaySloganIfNeeded];
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return CELL_COUNT;
}

- (UITableViewCell *)drawVideoCell {
    
    static NSString *kCellIdentifier = @"videoCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kCellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = TRANSPARENT_COLOR;
        cell.contentView.backgroundColor = TRANSPARENT_COLOR;
        
        _videoWallContainer = [[[VideoWallContainerView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2,
                                                                                        self.view.frame.size.width -
                                                                                        MARGIN * 4, VIDEO_35INCH_HEIGHT)
                                                      imageDisplayerDelegate:self
                                                      connectTriggerDelegate:self
                                                                         MOC:self.MOC
                                                                    entrance:self
                                                                      action:@selector(openVideos:)] autorelease];
        [cell.contentView addSubview:_videoWallContainer];
    }
    
    return cell;
}

- (UITableViewCell *)drawCommonStuffCell {
    
    static NSString *kCellIdentifier = @"alumniAndNearbyCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (nil == cell) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kCellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = TRANSPARENT_COLOR;
        cell.contentView.backgroundColor = TRANSPARENT_COLOR;
        
        // News
        CGFloat height = 0;
        if ([CommonUtils screenHeightIs4Inch]) {
            height = 140;
        } else {
            height = 110;
        }
        
        _newsThumbnailView = [[[NewsThumbnailView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, GRID_WIDTH, height)
                                                                   MOC:_MOC
                                                imageDisplayerDelegate:self
                                                connectTriggerDelegate:self
                                                              entrance:self
                                                                action:@selector(openNews:)] autorelease];
        
        [cell.contentView addSubview:_newsThumbnailView];
        
        WXWLabel *newsLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2, height-40, GRID_WIDTH-MARGIN * 4, 25)
                                                    textColor:[UIColor whiteColor]
                                                  shadowColor:TRANSPARENT_COLOR];
        newsLabel.text = LocaleStringForKey(NSNewsActivityTitle, nil);
        newsLabel.font = BOLD_FONT(18);
        [_newsThumbnailView addSubview:newsLabel];
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(58.4f, 28.f, 57.5f, 57.5f)] autorelease];
        imageView.image = [UIImage imageNamed:@"news.png"];
        [_newsThumbnailView addSubview:imageView];
        
        //    [_newsThumbnailView loadNews];
        
        // Search
        if ([CommonUtils screenHeightIs4Inch]) {
            height = 145.0f;
        } else {
            height = 114.0f;
        }
        _searchAlumniEntranceView = [[[SearchAlumniEntranceView alloc]
                                      initWithFrame:CGRectMake(MARGIN * 2, _newsThumbnailView.frame.origin.y + _newsThumbnailView.frame.size.height + MARGIN * 2, GRID_WIDTH, height)
                                      entrancce:self
                                      action:@selector(openSearchAlumni:)] autorelease];
        [cell.contentView addSubview:_searchAlumniEntranceView];
        
        
        // Nearby
        if ([CommonUtils screenHeightIs4Inch]) {
            height = 94.0f;
        } else {
            height = 74.0f;
        }
        
        _nearbyEntranceView = [[[NearbyEntranceView alloc] initWithFrame:CGRectMake(_newsThumbnailView.frame.origin.x + _newsThumbnailView.frame.size.width + MARGIN * 2, _newsThumbnailView.frame.origin.y, GRID_WIDTH, height)
                                                               entrancce:self
                                                                  action:@selector(openNearby:)] autorelease];
        [cell.contentView addSubview:_nearbyEntranceView];
        
        // Event
        if ([CommonUtils screenHeightIs4Inch]) {
            height = 90.0f;
        } else {
            height = 70.0f;
        }
        _todoEntranceView = [[[TodoEntranceView alloc] initWithFrame:CGRectMake(_nearbyEntranceView.frame.origin.x, _nearbyEntranceView.frame.origin.y + _nearbyEntranceView.frame.size.height + MARGIN * 2, GRID_WIDTH, height)
                                                           entrancce:self
                                                              action:@selector(openTodoList:)] autorelease];
        
        [cell.contentView addSubview:_todoEntranceView];
        
        // Donate
        if ([CommonUtils screenHeightIs4Inch]) {
            height = 90.0f;
        } else {
            height = 70.0f;
        }
        _advEntranceView = [[[AdvEntranceView alloc] initWithFrame:CGRectMake(_todoEntranceView.frame.origin.x, _todoEntranceView.frame.origin.y + _todoEntranceView.frame.size.height + MARGIN * 2, GRID_WIDTH, height)
                                                         entrancce:self
                                                            action:@selector(openDonation:)
                                                               MOC:self.MOC] autorelease];
        [cell.contentView addSubview:_advEntranceView];
        
    }
    
    return cell;
}

- (void)displaySloganIfNeeded {
    
    if ([CommonUtils screenHeightIs4Inch]) {
        [_sloganView triggerAutoScroll];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case VIDEO_CELL:
            return [self drawVideoCell];
            
        case ALUMNI_NEARBY_CELL:
            return [self drawCommonStuffCell];
            
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case VIDEO_CELL:
            return VIDEO_35INCH_HEIGHT + MARGIN * 2;
            
        case ALUMNI_NEARBY_CELL:
            return COMMON_STUFF_CELL_HEIGHT;
            
        default:
            return 0;
    }
}

#pragma mark - alert delegate method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_ITUNES_URL]];
            break;
        default:
            break;
    }
}

#pragma mark - open shared items
- (void)openSharedBrandWithId:(long long)brandId {
    if (brandId > 0ll) {
        BrandDetailViewController *brandVC = [[[BrandDetailViewController alloc] initWithMOC:_MOC
                                                                                     brandId:brandId
                                                                           locationRefreshed:NO] autorelease];
        brandVC.title = LocaleStringForKey(NSDetailsTitle, nil);
        
        if (self.parentVC) {
            [self.parentVC.navigationController pushViewController:brandVC animated:YES];
        }
    }
}

- (void)openSharedVideoWithId:(long long)videoId {
    if (videoId > 0ll) {
        VideoListViewController *videoListVC = [[[VideoListViewController alloc] initWithMOC:_MOC selectedVideoId:videoId] autorelease];
        videoListVC.title = LocaleStringForKey(NSVideoTitle, nil);
        
        if (self.parentVC) {
            [self.parentVC.navigationController pushViewController:videoListVC animated:YES];
        }
        
        self.parentVC.navigationController.navigationBarHidden = NO;
        
    }
}


@end
