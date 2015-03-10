//
//  StartupProjectViewController.m
//  iAlumni
//
//  Created by Adam on 13-3-3.
//
//

#import "StartupProjectViewController.h"
#import "Event.h"
#import "StartupProjectHeaderView.h"
#import "CoreDataUtils.h"
#import "StaticIconCell.h"
#import "AttendInfoCell.h"
#import "ServiceLatestCommentCell.h"
#import "EventIntroCell.h"
#import "VerticalLayoutItemInfoCell.h"
#import "MapViewController.h"
#import "WXWNavigationController.h"
#import "EventAlumniListViewController.h"
#import "TimeoutWebViewController.h"
#import "UIWebViewController.h"
#import "CheckinResultViewController.h"
#import "StartupProjectToolbar.h"
#import "AdminCheckInViewController.h"
#import "EventTopicListViewController.h"
#import "BuzzEntranceCell.h"
#import "GroupChatViewController.h"
#import "Club.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "ECHandyAvatarBrowser.h"
#import "ProjectSurveyViewController.h"
#import "ShakeViewController.h"
#import "UIImageButton.h"
#import "WXWLabel.h"
#import "StartupDiscussionViewController.h"
#import "ProjectBackerListViewController.h"

#define NAME_WIDTH        300.0f
#define BUTTONS_HEIGHT    36.0f
#define POST_H            120.f
#define INTRO_TITLE_H     23.0f
#define BOTTOM_TOOL_H     48.f
#define FONT_SIZE         12.f
#define CELL_COUNT        1
#define AVATAR_DIAMETER   80.0f

#define BUFFER_SIZE 1024 * 100

#define ACTION_BUTTON_WIDTH   155.0f
#define ACTION_BUTTON_HEIGHT  40.0f

#define SECTION_HEADER_HEIGHT 52

static int iIntroHeight = 0;

enum {
  MORE_OWNER_TY,
  CALL_OWNER_TY,
};

enum {
  SHARE_SMS_IDX,
  SHARE_WECHAT_IDX,
  CANCEL_IDX,
};


@interface StartupProjectViewController ()

@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKEvent *dailyEvent;
@property (nonatomic, retain) EKCalendar *defaultCalendar;
@property (nonatomic, retain) UIImage *image;

@end

@implementation StartupProjectViewController

@synthesize event = _event;
@synthesize eventStore = _eventStore;
@synthesize dailyEvent = _dailyEvent;
@synthesize defaultCalendar = _defaultCalendar;

#pragma mark - load data
- (void)loadEventDetail {
  
  _currentType = EVENTDETAIL_TY;
  
  NSString *param = [NSString stringWithFormat:@"<event_id>%@</event_id>",[AppManager instance].eventId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchGets:url];
}

- (void)checkAdminIdentifier {
  
  if (![AppManager instance].isClub2Event){
    if ([AppManager instance].clubAdmin) {
      [AppManager instance].isAdminCheckIn = YES;
      
      [self addRightBarButtonWithTitle:LocaleStringForKey(NSAdminCheckInButTitle, nil)
                                target:self
                                action:@selector(adminCheckin:)];
    }
  } else {
    [AppManager instance].isAdminCheckIn = NO;
  }
}

- (Event *)fetchEventDetailFromMOC {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventId == %lld", _eventId];
  
  return (Event *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                            entityName:@"Event"
                                             predicate:predicate];
}

- (void)getIntroHeight {
  
  CGSize constraint = CGSizeMake(SCREEN_WIDTH-20, CGFLOAT_MAX);
  CGSize descSize = [self.event.desc sizeWithFont:FONT(15) constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
  
  iIntroHeight = descSize.height;
}

#pragma mark - arrange after event detail loaded

- (void)adjustActionButtonPosition {
  
  _actionButtonOriginalY = _headView.frame.size.height - _eventActionButton.frame.size.height;
  
  _eventActionButton.frame = CGRectMake(_eventActionButton.frame.origin.x,
                                        _headView.frame.size.height - _eventActionButton.frame.size.height,
                                        _eventActionButton.frame.size.width,
                                        _eventActionButton.frame.size.height);
}

- (void)arrangeEventBaseInfos {
  [self initHeadView];
  
  if (_eventActionButton.frame.origin.y >= _headView.frame.size.height - _eventActionButton.frame.size.height
      || _eventActionButton.frame.origin.y == 0) {
    [self adjustActionButtonPosition];
  }
  
  if (!_autoLoaded) {
    [UIView animateWithDuration:FADE_IN_DURATION
                     animations:^{
                       _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                                     _tableView.frame.origin.y,
                                                     _tableView.frame.size.width,
                                                     self.view.frame.size.height);
                       _tableView.alpha = 1.0f;
                     }];
  }
}

- (void)arrangeViewsAfterDetailLoaded {
  self.event = [self fetchEventDetailFromMOC];
  
  if (nil == self.event || self.event.isFault) {
    // if event fetch failed, error message should be displayed
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchEventDetailFailedMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
    
    return;
  }
  
  [self checkAdminIdentifier];
  [self getIntroHeight];
  
  [self arrangeEventBaseInfos];
  
  [_tableView reloadData];
  
  if (!_eventLoaded) {
    _eventLoaded = YES;
    [self performSelector:@selector(arrangeBottomToolbar)
               withObject:nil
               afterDelay:0.2f];
  }
  
}

#pragma mark - arrange action button
- (void)addActionForDifferentType {
  
  [_eventActionButton removeTarget:nil
                            action:NULL
                  forControlEvents:UIControlEventAllEvents];
  
  
  if (self.event.backed.boolValue) {

    [_eventActionButton addTarget:self
                           action:@selector(checkSurvey:)
                 forControlEvents:UIControlEventTouchUpInside];

  } else {
    
    [_eventActionButton addTarget:self
                           action:@selector(backProject:)
                 forControlEvents:UIControlEventTouchUpInside];

  }
}

- (void)arrangeActionButton {
  
  NSString *title = LocaleStringForKey(NSBackProjectTitle, nil);
  if (self.event.backed.boolValue) {
    title = LocaleStringForKey(NSSurveyTitle, nil);
  }
  
  [_eventActionButton setTitle:title
                      forState:UIControlStateNormal];
  
  [self addActionForDifferentType];
  
  if (_eventActionButton.frame.origin.x >= _sectionHeaderView.frame.size.width) {
    [UIView animateWithDuration:0.2f
                          delay:0.2f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                       _eventActionButton.frame = CGRectOffset(_eventActionButton.frame,
                                                               -1 * _eventActionButton.frame.size.width,
                                                               0);
                       
                     }
                     completion:nil];
  }
}


#pragma mark - lifecycle methods

- (void)clearObjectsFromMOC {
  DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", nil);
  
  DELETE_OBJS_FROM_MOC(_MOC, @"EventSponsor", nil);
  
  DELETE_OBJS_FROM_MOC(_MOC, @"EventWinner", nil);
  
  DELETE_OBJS_FROM_MOC(_MOC, @"EventSignedUpAlumni", nil);
  
  DELETE_OBJS_FROM_MOC(_MOC, @"EventCheckinAlumni", nil);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  
  if (self) {
    
    _eventId = eventId;
    
    _noNeedDisplayEmptyMsg = YES;
    
    [AppManager instance].allowSendSMS = NO;
    
    [self clearObjectsFromMOC];
  }
  
  return self;
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event *)event {
  self = [self initWithMOC:MOC
                   eventId:event.eventId.longLongValue];
  
  if (self) {
    
    self.event = event;
  }
  
  return self;
}

- (void)dealloc {
  
  if (_needClearFakeClubInstance) {
    DELETE_OBJS_FROM_MOC(_MOC, @"Club", ([NSPredicate predicateWithFormat:@"(clubId == %@)", self.event.hostId]));
  }
  
  self.event = nil;
  
  self.image = nil;
  
  self.eventStore = nil;
  self.defaultCalendar = nil;
  self.dailyEvent = nil;
  
  [self clearObjectsFromMOC];
  
  RELEASE_OBJ(_sectionHeaderView);
  
  [super dealloc];
}

- (void)addActionButton {
  _eventActionButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake(self.view.frame.size.width, 0, ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT)
                                                                 target:nil
                                                                 action:nil
                                                                  title:LocaleStringForKey(NSFollowTitle, nil)
                                                                  image:[UIImage imageNamed:@"hand.png"]
                                                            backImgName:@"orangeButton.png"
                                                         selBackImgName:nil
                                                              titleFont:FONT(16.f)
                                                             titleColor:[UIColor whiteColor]
                                                       titleShadowColor:TRANSPARENT_COLOR
                                                            roundedType:NO_ROUNDED
                                                        imageEdgeInsert:UIEdgeInsetsMake(10, 105, 10, 30)
                                                        titleEdgeInsert:UIEdgeInsetsMake(0, -55, 0, 0)] autorelease];
  [self addActionForDifferentType];
  
  _eventActionButton.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(2.0f, 2.0f,
                                                                                    ACTION_BUTTON_WIDTH,
                                                                                    ACTION_BUTTON_HEIGHT - 1.0f)].CGPath;
  _eventActionButton.layer.shadowRadius = 2.0f;
  _eventActionButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  _eventActionButton.layer.shadowOffset = CGSizeMake(0, 0);
  _eventActionButton.layer.shadowOpacity = 0.9f;
  _eventActionButton.layer.masksToBounds = NO;

  [self.view addSubview:_eventActionButton];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self initTableViewProperties];
  
  [self changeTableStyle];
  
  [self addBottomToolbar];
  
  [self addActionButton];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded || _needRefreshAfterBack) {
    [self loadEventDetail];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - init view
- (void)initHeadView {
  // name
  CGSize size = [self.event.title sizeWithFont:BOLD_FONT(17)
                             constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = MARGIN * 2 + size.height;
  
  // time
  size = [[NSString stringWithFormat:@"%@ %@", self.event.time, self.event.timeStr] sizeWithFont:BOLD_FONT(13)
                                                                               constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                                                                                   lineBreakMode:NSLineBreakByWordWrapping];
  height += MARGIN * 2 + size.height;
  
  // post
  height += POST_H + MARGIN * 2;
  
  // Sign
  height += 40.f + MARGIN * 2;
  
  height += MARGIN;
  
  // Head View
  if (_headView) {
    [_headView removeFromSuperview];
    _headView = nil;
  }
  _headView = [[[StartupProjectHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.view.frame.size.width,
                                                                     height)
                                                    event:self.event
                                                 delegate:self
                                              imageHolder:self
                                          saveImageAction:@selector(saveThumbnail:)] autorelease];
  
  [_headView sizeToFit];
  
  // ios4.3 needs reset the frame of table view, otherwise, the y coordinate will be -44.0
  _tableView.frame = CGRectMake(0, 0, _tableView.frame.size.width, _tableView.frame.size.height);
  
  _tableView.tableHeaderView = _headView;
  
}

- (void)initTableViewProperties {
  _tableView.alpha = 1.0f;
  _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                _tableView.frame.origin.y,
                                _tableView.frame.size.width, 0);
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)changeTableStyle
{
  _tableView.frame = CGRectMake(0, 0, _tableView.frame.size.width, self.view.frame.size.height);
  _tableView.alpha = 0.f;
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)addBottomToolbar {
  // Action View
  _bottomToolbar = [[[StartupProjectToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT,
                                                                                  self.view.frame.size.width,
                                                                                  BOTTOM_TOOL_H)
                                                                 event:self.event
                                                              delegate:self] autorelease];
  
  [self.view addSubview:_bottomToolbar];
}

- (void)arrangeBottomToolbar {
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _bottomToolbar.frame = CGRectOffset(_bottomToolbar.frame, 0, -1 * BOTTOM_TOOL_H);
                     
                     _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                                   _tableView.frame.origin.y,
                                                   _tableView.frame.size.width,
                                                   self.view.frame.size.height - BOTTOM_TOOL_H);
                   }];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  if (contentType == PAY_DATA_TY) {
    [UIUtils showActivityView:self.view
                         text:LocaleStringForKey(NSLoadingTitle, nil)];
    
  } else {
    BOOL blockCurrentview = NO;
    
    if (contentType == EVENTDETAIL_TY) {
      blockCurrentview = YES;
    }
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
              blockCurrentView:blockCurrentview];
  }
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType{
  
  switch (contentType) {
    case EVENTDETAIL_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:EVENTDETAIL_TY
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self arrangeViewsAfterDetailLoaded];
        
        if (!_autoLoaded || _needRefreshAfterBack) {
          [self arrangeActionButton];
          
          _autoLoaded = YES;
        }
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchEventDetailFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      _needRefreshAfterBack = NO;
      
      break;
    }
      
    case CHECKIN_TY:
    {
      CheckinResultType checkinRes = [XMLParser parserEventCheckinResult:result
                                                                   event:self.event
                                                                     MOC:_MOC
                                                       connectorDelegate:self
                                                                     url:url];
      [self verifyCheckinResult:checkinRes url:url];
      
      break;
    }
      
    case PAY_DATA_TY:
    {
      [self goPay:result];
      
      [UIUtils closeActivityView];
      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  
  switch (contentType) {
    case EVENTDETAIL_TY:
    {
      msg = LocaleStringForKey(NSFetchEventDetailFailedMsg, nil);
      _needRefreshAfterBack = NO;
      break;
    }
      
    case CHECKIN_TY:
      msg = LocaleStringForKey(NSCheckinFailedMsg, nil);
      break;
      
    case PAY_DATA_TY:
    {
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentErrorMsg, nil)
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      
      [UIUtils closeActivityView];
      break;
    }
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}


- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

#pragma mark - verify check in result

- (void)verifyCheckinResult:(CheckinResultType)checkinRes url:(NSString *)url {
  
  CheckinResultViewController *checkinResultVC = [[[CheckinResultViewController alloc] initWithMOC:_MOC
                                                                                 checkinResultType:checkinRes
                                                                                             event:self.event
                                                                                          entrance:self
                                                                                        backendMsg:(self.errorMsgDic)[url]] autorelease];
  
  checkinResultVC.title = LocaleStringForKey(NSCheckinResultTitle, nil);
  
  [self.navigationController pushViewController:checkinResultVC animated:YES];
}

#pragma mark - WXApiDelegate methods
- (void)onResp:(BaseResp*)resp
{
  if([resp isKindOfClass:[SendMessageToWXResp class]]) {
    switch (resp.errCode) {
      case WECHAT_OK_CODE:
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
        break;
        
      case WECHAT_BACK_CODE:
        break;
        
      default:
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        break;
    }
  }
  
  ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = nil;
}

#pragma mark - Event action

- (void)doCheckin {
  _needRefreshAfterBack = YES;
  
  _currentType = CHECKIN_TY;
  NSString *param = [NSString stringWithFormat:@"<latitude>%f</latitude><longitude>%f</longitude><event_id>%@</event_id>",
                     [AppManager instance].latitude,
                     [AppManager instance].longitude,
                     self.event.eventId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

- (void)checkin {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLocatingMsg, nil)
            blockCurrentView:NO];
  [self forceGetLocation];
}

#pragma mark - Bottom action
- (void)voteAction {
  EventTopicListViewController *eventTopicListVC = [[[EventTopicListViewController alloc] initWithMOC:_MOC
                                                                                              eventId:self.event.eventId.longLongValue] autorelease];
  eventTopicListVC.title = LocaleStringForKey(NSVoteTitle, nil);
  [self.navigationController pushViewController:eventTopicListVC animated:YES];
  
}

- (void)awardAction {
  
  if (self.event.hasAward.boolValue) {
    ShakeViewController *shakeVC = [[[ShakeViewController alloc] initWithMOC:_MOC eventId:_eventId] autorelease];
    shakeVC.title = LocaleStringForKey(NSAwardTitle, nil);
    [self.navigationController pushViewController:shakeVC animated:YES];
  } else {
    ShowAlertWithOneButton(nil, nil, LocaleStringForKey(NSNoAwardMsg, nil), LocaleStringForKey(NSIKnowTitle, nil));
  }
  
}

- (void)discussAction {
  _needRefreshAfterBack = YES;
  
  StartupDiscussionViewController *discussionVC = [[[StartupDiscussionViewController alloc] initWithMOC:_MOC
                                                                                checkinResultDelegate:nil
                                                                                                event:self.event
                                                                                    checkinResultType:CHECKIN_NONE_TY
                                                                                             entrance:self
                                                                                             listType:EVENT_DISCUSS_TY] autorelease];
  discussionVC.title = LocaleStringForKey(NSProjectDiscussTitle, nil);

  [self.navigationController pushViewController:discussionVC animated:YES];
}

- (void)moreAction {
  
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  
  [as addButtonWithTitle:LocaleStringForKey(NSShareBySMSTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSShareByWeixinTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
  
  RELEASE_OBJ(as);
  
  _actionSheetOwnerType = MORE_OWNER_TY;
}

#pragma mark - EventActionDeleage method

- (void)shareBySMS {
  MFMessageComposeViewController *smsComposeVC = [[[MFMessageComposeViewController alloc] init] autorelease];
  if ([MFMessageComposeViewController canSendText]) {
    
    NSString *downloadUrl = [NSString stringWithFormat:CONFIGURABLE_DOWNLOAD_URL,
                             [AppManager instance].hostUrl,
                             [WXWSystemInfoManager instance].currentLanguageDesc,
                             [AppManager instance].releaseChannelType];
    
    smsComposeVC.body = [NSString stringWithFormat:@"%@, %@: %@ %@; %@: %@. %@: %@ %@. %@.",
                         self.event.title,
                         LocaleStringForKey(NSTimeTitle, nil),
                         self.event.time,
                         self.event.timeStr,
                         LocaleStringForKey(NSAddressTitle, nil),
                         self.event.address,
                         LocaleStringForKey(NSContactTitle, nil),
                         self.event.contact,
                         self.event.tel,
                         [NSString stringWithFormat:LocaleStringForKey(NSMoreInfoDownloadTitle, nil), downloadUrl]];
    smsComposeVC.messageComposeDelegate = self;
    [self presentModalViewController:smsComposeVC animated:YES];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotSendSMSMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
}

- (void)shareByWeChat {
  if ([WXApi isWXAppInstalled]) {
    ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = self;
    
    [CommonUtils shareEvent:self.event scene:WXSceneSession image:self.image];
    
  } else {
    
    ShowAlertWithTwoButton(self, nil, LocaleStringForKey(NSNoWeChatMsg, nil), LocaleStringForKey(NSDonotInstallTitle, nil),LocaleStringForKey(NSInstallTitle, nil));
  }
}

- (void)goSignUpList {
  
  _needRefreshAfterBack = YES;
  
  ProjectBackerListViewController *alumnusVC = [[[ProjectBackerListViewController alloc] initWithMOC:_MOC eventId:self.event.eventId.longLongValue] autorelease];
  alumnusVC.title = LocaleStringForKey(NSBackedAlumnusTitle, nil);
  [self.navigationController pushViewController:alumnusVC animated:YES];
}

- (void)goCheckInList {
  
  _needRefreshAfterBack = YES;
  
  EventAlumniListViewController *eventAlumniListVC = [[[EventAlumniListViewController alloc] initWithMOC:_MOC
                                                                                   checkinResultDelegate:nil
                                                                                                   event:self.event
                                                                                       checkinResultType:CHECKIN_NONE_TY
                                                                                                entrance:self
                                                                                                listType:EVENT_APPEAR_ALUMNUS_TY] autorelease];
  eventAlumniListVC.title = LocaleStringForKey(NSCheckedinAlumnusListTitle, nil);
  [self.navigationController pushViewController:eventAlumniListVC animated:YES];
}

- (void)adminCheckin:(id)sender {
  
  _needRefreshAfterBack = YES;
  
  AdminCheckInViewController *mClubSearchVC = [[[AdminCheckInViewController alloc] initWithMOC:_MOC event:self.event] autorelease];
  mClubSearchVC.type = 0;
  UINavigationController *mNC = [[[UINavigationController alloc] initWithRootViewController:mClubSearchVC] autorelease];
  mNC.navigationBar.tintColor = TITLESTYLE_COLOR;
  [self.navigationController presentModalViewController:mNC animated:YES];
}

- (void)goLocation {
  if ([NULL_PARAM_VALUE isEqualToString:self.event.latitude] || [NULL_PARAM_VALUE isEqualToString:self.event.longitude]) {
    return;
  }
  
  MapViewController *mapVC = [[[MapViewController alloc] initWithLatitude:self.event.latitude.doubleValue
                                                                longitude:self.event.longitude.doubleValue
                                                     allowLaunchGoogleMap:NO] autorelease];
  
  mapVC.title = LocaleStringForKey(NSMapTitle, nil);
  WXWNavigationController *mapNav = [[[WXWNavigationController alloc] initWithRootViewController:mapVC] autorelease];
  [self.navigationController presentModalViewController:mapNav animated:YES];
}

- (void)goContracts {
  if ([NULL_PARAM_VALUE isEqualToString:self.event.tel]) {
    return;
  }
  
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCallActionSheetTitle, nil)
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  
  [as addButtonWithTitle:LocaleStringForKey(NSCallTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
  
  RELEASE_OBJ(as);
  
  _actionSheetOwnerType = CALL_OWNER_TY;
}

- (void)gotoBackWebUrl:(NSString*)url aTitle:(NSString*)title
{
  
  TimeoutWebViewController *webVC = [[[TimeoutWebViewController alloc] initWithBackTitle:LocaleStringForKey(NSBackBtnTitle, nil)] autorelease];
  UINavigationController *webViewNav = [[[UINavigationController alloc] initWithRootViewController:webVC] autorelease];
  webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.urlStr = url;
  webVC.title = title;
  
  [self.parentViewController presentModalViewController:webViewNav
                                               animated:YES];
}

- (void)gotoUrl:(NSString*)url aTitle:(NSString*)title {
  UIWebViewController *webVC = [[[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES] autorelease];
  UINavigationController *webViewNav = [[[UINavigationController alloc] initWithRootViewController:webVC] autorelease];
  webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = url;
  webVC.strTitle = title;
  
  [self.parentViewController presentModalViewController:webViewNav
                                               animated:YES];
}

- (void)displayIntro {
  NSString *url = [NSString stringWithFormat:@"%@%@&event_id=%@&user_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@&person_id=%@",
                   [AppManager instance].hostUrl,
                   EVENT_DESC_URL,
                   self.event.eventId,
                   [AppManager instance].userId,
                   [WXWSystemInfoManager instance].currentLanguageDesc,
                   PLATFORM,
                   VERSION,
                   [AppManager instance].sessionId,
                   [AppManager instance].personId];
  
  [self gotoBackWebUrl:url aTitle:LocaleStringForKey(NSIntroductionTitle, nil)];
}

- (void)goSponsor {
  if ([AppManager instance].isClub2Event) {
    return;
  }
  
  [AppManager instance].clubName = [NSString stringWithFormat:@"%@", self.event.hostName];
  [AppManager instance].clubId = [NSString stringWithFormat:@"%@", self.event.hostId];
  [AppManager instance].clubType = [NSString stringWithFormat:@"%@", self.event.hostType];
  [AppManager instance].hostSupTypeValue = self.event.hostSubTypeValue;
  [AppManager instance].hostTypeValue = self.event.hostTypeValue;
  
  [AppManager instance].isNeedReLoadClubDetail = YES;
  
  [AppManager instance].allowSendSMS = NO;
  
  //////////
  Club *group = (Club *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                  entityName:@"Club"
                                                   predicate:[NSPredicate predicateWithFormat:@"(clubId == %@)", self.event.hostId]];
  
  if (nil == group) {
    group = (Club *)[NSEntityDescription insertNewObjectForEntityForName:@"Club"
                                                  inManagedObjectContext:_MOC];
    group.clubId = @(self.event.hostId.intValue);
    group.clubName = self.event.hostName;
    group.clubType = self.event.hostType;
    group.hostSupTypeValue = self.event.hostSubTypeValue;
    group.hostTypeValue = self.event.hostTypeValue;
    
    _needClearFakeClubInstance = YES;
  }
  
  GroupChatViewController *groupChatVC = [[[GroupChatViewController alloc] initWithMOC:_MOC
                                                                                 group:group] autorelease];
  groupChatVC.title = group.clubName;
  
  [self.navigationController pushViewController:groupChatVC animated:YES];
  
}

- (void)backProject:(id)sender {
  _needRefreshAfterBack = YES;
  
  ProjectSurveyViewController *detailVC = [[[ProjectSurveyViewController alloc] initWithMOC:_MOC
                                                                                      event:self.event] autorelease];
  detailVC.title = LocaleStringForKey(NSBackProjectTitle, nil);
  
  [self.navigationController pushViewController:detailVC animated:YES];

}

- (void)checkSurvey:(id)sender {
  _needRefreshAfterBack = YES;
  
  ProjectSurveyViewController *detailVC = [[[ProjectSurveyViewController alloc] initWithMOC:_MOC
                                                                                      event:self.event] autorelease];
  detailVC.title = LocaleStringForKey(NSSurveyTitle, nil);
  
  [self.navigationController pushViewController:detailVC animated:YES];

}

- (void)doSignUp {
  _needRefreshAfterBack = YES;
  
  ProjectSurveyViewController *detailVC = [[[ProjectSurveyViewController alloc] initWithMOC:_MOC
                                                                                  event:self.event] autorelease];
  detailVC.title = LocaleStringForKey(NSFollowTitle, nil);
  
  [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)doAddCalendar {
  // Create a new event
  self.dailyEvent = [EKEvent eventWithEventStore:self.eventStore];
  
  // Create NSDates to hold the start and end date
  NSDate *startDate = [CommonUtils convertDateTimeFromUnixTS:[self.event.date doubleValue]];
  NSDate *endDate  = [CommonUtils convertDateTimeFromUnixTS:[self.event.date doubleValue]];
  
  // Set properties of the new event object
  self.dailyEvent.title     = self.event.title;
  self.dailyEvent.notes     = self.event.hostName;
  self.dailyEvent.startDate = startDate;
  self.dailyEvent.endDate   = endDate;
  self.dailyEvent.allDay    = YES;
  self.dailyEvent.location  = self.event.address;
  // set event's calendar to the default calendar
  self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
  [self.dailyEvent setCalendar:self.defaultCalendar];
  
  // Create the EditViewController
  EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
  controller.event = self.dailyEvent;
  controller.eventStore = self.eventStore;
  controller.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
  controller.editViewDelegate = self;
  UITableView *tv = (UITableView*)[controller view];
  [tv setBackgroundColor:BACKGROUND_COLOR];
  
  [self presentModalViewController:controller animated:YES];
  
  RELEASE_OBJ(controller);
}

- (void)addCalendar {
  
  self.eventStore = [[[EKEventStore alloc] init] autorelease];
  
  if ([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                    completion:^(BOOL granted, NSError *error) {
                                      
                                      if (!granted) {
                                        // no granted, then alert user
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                          UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoGrantedForCalendarTitle, nil)
                                                                                           message:LocaleStringForKey(NSHowToGrantCalendarMsg, nil)
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:nil
                                                                                 otherButtonTitles:LocaleStringForKey(NSIKnowTitle, nil), nil] autorelease];
                                          [alert show];
                                          
                                        });
                                        
                                      } else {
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                          [self doAddCalendar];
                                        });
                                      }
                                      
                                    }];
  } else {
    [self doAddCalendar];
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

#pragma mark - UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_actionSheetOwnerType) {
    case CALL_OWNER_TY:
    {
      switch (buttonIndex) {
        case CALL_ACTION_SHEET_IDX:
        {
          if (self.event.tel && self.event.tel.length > 0) {
            NSString *phoneNumber = [self.event.tel stringByReplacingOccurrencesOfString:@" " withString:NULL_PARAM_VALUE];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:NULL_PARAM_VALUE];
            NSString *phoneStr = [[NSString alloc] initWithFormat:@"tel:%@", phoneNumber];
            NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
            [[UIApplication sharedApplication] openURL:phoneURL];
            [phoneURL release];
            [phoneStr release];
          }
          break;
        }
        case CANCEL_ACTION_SHEET_IDX:
          return;
          
        default:
          break;
      }
      
      break;
    }
      
    case MORE_OWNER_TY:
    {
      switch (buttonIndex) {
        case SHARE_SMS_IDX:
          [self shareBySMS];
          break;
          
        case SHARE_WECHAT_IDX:
          [self shareByWeChat];
          break;
          
        default:
          break;
      }
      
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return CELL_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return iIntroHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"EventIntroCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  [subviews release];
  
  [self drawIntroCell:cell];
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return SECTION_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (nil == _sectionHeaderView) {
    _sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                  self.view.frame.size.width,
                                                                  SECTION_HEADER_HEIGHT)];
    _sectionHeaderView.backgroundColor = TRANSPARENT_COLOR;
    
    _descTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                             textColor:COLOR(50, 50, 51)
                                           shadowColor:TRANSPARENT_COLOR] autorelease];
    _descTitleLabel.font = BOLD_FONT(15);
    _descTitleLabel.text = LocaleStringForKey(NSIntroTitle, nil);
    CGSize size = [_descTitleLabel.text sizeWithFont:_descTitleLabel.font];
    _descTitleLabel.frame = CGRectMake(MARGIN * 2, SECTION_HEADER_HEIGHT - size.height - MARGIN * 2, size.width, size.height);
    [_sectionHeaderView addSubview:_descTitleLabel];
  }
  
  return _sectionHeaderView;
}

#pragma mark - draw intro cell
- (void)drawIntroCell:(UITableViewCell *)cell {
  
  CGRect introFrame = CGRectMake(MARGIN*2, 0, SCREEN_WIDTH-20.f, iIntroHeight);
  UILabel *mIntro = [[UILabel alloc] initWithFrame:introFrame];
  [mIntro setText:self.event.desc];
  mIntro.numberOfLines = 0;
  mIntro.lineBreakMode = NSLineBreakByCharWrapping;
  [mIntro setFont:FONT(15)];
  [mIntro setBackgroundColor:TRANSPARENT_COLOR];
  [mIntro setTextColor:COLOR(111, 112, 111)];
  [cell.contentView addSubview:mIntro];
  [mIntro release];
}

#pragma mark - EKEventEditViewDelegate method
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
  
  NSError *err = nil;
  
  switch (action) {
    case EKEventEditViewActionCanceled:
      break;
      
    case EKEventEditViewActionSaved:
    {      
      // Save the event
      [self.eventStore saveEvent:self.dailyEvent
                            span:EKSpanThisEvent
                           error:&err];
      
      if (err != noErr) {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAddCalendarFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
    }
      break;
      
    case EKEventEditViewActionDeleted:
      [controller.eventStore removeEvent:controller.event span:EKSpanThisEvent error:&err];
      break;
      
    default:
      break;
  }
  
  [controller dismissModalViewControllerAnimated:YES];
}

// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
	EKCalendar *calendarForEdit = self.defaultCalendar;
	return calendarForEdit;
}

#pragma mark - MFMessageComposeViewControllerDelegate method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
  switch (result) {
    case MessageComposeResultCancelled:
      
      break;
      
    case MessageComposeResultFailed:
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSMSSentFailed, nil)
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      break;
      
    case MessageComposeResultSent:
      
      break;
      
    default:
      break;
  }
  
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ECLocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(WXWLocationManager *)manager
                                 location:(CLLocation *)location {
  
  [super locationManagerDidReceiveLocation:manager
                                  location:location];
  
  [self changeAsyncLoadingMessage:LocaleStringForKey(NSLoadingTitle, nil)];
  [self doCheckin];
}

- (void)locationManagerDidFail:(WXWLocationManager *)manager {
  [super locationManagerDidFail:manager];
  
  [self closeAsyncLoadingView];
}

- (void)locationManagerCancelled:(WXWLocationManager *)manager {
  [super locationManagerCancelled:manager];
  
}

- (void)showBigPhotoWithUrl:(NSString *)url imageFrame:(CGRect)imageFrame {
  
  if (nil == url || 0 == url.length) {
    return;
  }
  
  CGRect smallAvatarFrame = CGRectMake(imageFrame.origin.x,
                                       imageFrame.origin.y - _tableView.contentOffset.y,
                                       imageFrame.size.width,
                                       imageFrame.size.height);
  
  ECHandyAvatarBrowser *avatarBrowser = [[[ECHandyAvatarBrowser alloc] initWithFrame:CGRectMake(0, 0,
                                                                                                self.view.frame.size.width,
                                                                                                self.view.frame.size.height)
                                                                              imgUrl:url
                                                                     imageStartFrame:smallAvatarFrame
                                                              imageDisplayerDelegate:self] autorelease];
  [self.view addSubview:avatarBrowser];
}

#pragma mark - scrolling overrides

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [super scrollViewDidScroll:scrollView];
    
  if (_sectionHeaderView.frame.origin.y - _headView.frame.size.height > 0) {
    _descTitleLabel.hidden = YES;    
  } else {
    _descTitleLabel.hidden = NO;
  }
  
  if (_headView.frame.size.height - scrollView.contentOffset.y > _eventActionButton.frame.size.height + MARGIN * 2) {
    _eventActionButton.frame = CGRectMake(_eventActionButton.frame.origin.x,
                                          _actionButtonOriginalY - scrollView.contentOffset.y,
                                          _eventActionButton.frame.size.width,
                                          _eventActionButton.frame.size.height);
  }
}

#pragma mark - save image
- (void)saveThumbnail:(UIImage *)image {
  self.image = image;
}

#pragma mark - payment
- (void)triggerOnlinePayment {
  
  if (nil == self.event.orderId || 0 == self.event.orderId.length) {
    return;
  }
  
  NSString *param = [NSString stringWithFormat:@"<order_id>%@</order_id>", self.event.orderId];
  NSString *url = [CommonUtils geneUrl:param itemType:PAY_DATA_TY];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:PAY_DATA_TY] autorelease];
  [connFacade fetchGets:url];
}

- (void)goPay:(NSData *)result {
  _paymentView = [[UPOMP alloc] init];
  _paymentView.viewDelegate = self;
  [((iAlumniAppDelegate*)APP_DELEGATE).window addSubview:_paymentView.view];
  
  [_paymentView setXmlData:result];
  
  NSLog(@"message: %@", [[[NSString alloc] initWithData:result
                                               encoding:NSUTF8StringEncoding] autorelease]);
}

#pragma mark - handle payment result
- (void)refreshListForPaymentDone {
  [self loadEventDetail];
}

- (BOOL)checkPaymentRecallResult:(NSString *)result {
  if (nil == result || 0 == result.length) {
    return NO;
  }
  
  NSArray *list = [result componentsSeparatedByString:PAYMENT_RESPCODE_START_SEPARATOR];
  if (list.count == 2) {
    NSString *partResult = list[1];
    if (0 == partResult.length) {
      return NO;
    }
    
    NSArray *resultList = [partResult componentsSeparatedByString:PAYMENT_RESPCODE_END_SEPARATOR];
    if (resultList.count == 2) {
      NSString *codeStr = resultList[0];
      if (0 == codeStr.length) {
        return NO;
      }
      
      NSInteger code = codeStr.intValue;
      
      if (code != 0) {
        return NO;
      } else {
        
        return YES;
      }
    }
  }
  
  return NO;
}

#pragma mark - UPOMPDelegate method
-(void)viewClose:(NSData*)data {
  
  //获得返回数据并释放内存
  //以下为自定义相关操作
  
  _paymentView.viewDelegate = nil;
  RELEASE_OBJ(_paymentView);
  
  NSString *resultStr = [[[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding] autorelease];
  
  if ([self checkPaymentRecallResult:resultStr]) {
    
    // refresh payment successful flag
    [self refreshListForPaymentDone];
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentDoneMsg, nil)
                                  msgType:SUCCESS_TY
                       belowNavigationBar:YES];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentErrorMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
}

@end
