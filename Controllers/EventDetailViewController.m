//
//  EventDetailViewController.m
//  iAlumni
//
//  Created by Adam on 13-1-25.
//
//

#import "EventDetailViewController.h"
#import "Event.h"
#import "EventDetailHeadView.h"
#import "UIImage-Extensions.h"
#import "CoreDataUtils.h"
#import "StaticIconCell.h"
#import "AttendInfoCell.h"
#import "ServiceLatestCommentCell.h"
#import "EventIntroCell.h"
#import "VerticalLayoutItemInfoCell.h"
#import "MapViewController.h"
#import "WXWNavigationController.h"
#import "EventAlumniListViewController.h"
#import "SignedUpAlumnusViewController.h"
#import "TimeoutWebViewController.h"
#import "UIWebViewController.h"
#import "CheckinResultViewController.h"
#import "AlumniEventDetailActionView.h"
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
#import "EventSignUpViewController.h"
#import "ShakeViewController.h"
#import "UIImageButton.h"
#import "WXWLabel.h"
#import "ClubDetailViewController.h"
#import "OrderViewController.h"

#define HEADER_H          235.f
#define NAME_WIDTH        300.0f
#define BUTTONS_HEIGHT    36.0f
#define POST_H            120.f
#define INTRO_TITLE_H     23.0f
#define BOTTOM_TOOL_H     48.f
#define FONT_SIZE         15.f
#define CELL_COUNT        6
#define AVATAR_DIAMETER   80.0f
#define EVENT_IMG_WIDTH   285
#define EVENT_IMG_HEIGHT  173

#define BUFFER_SIZE         1024 * 100

#define ACTION_BUTTON_WIDTH   155.0f
#define ACTION_BUTTON_HEIGHT  32.0f

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#define SECTION_HEADER_HEIGHT 20
#else
#define SECTION_HEADER_HEIGHT 10
#endif

enum {
  MORE_OWNER_TY,
  CALL_OWNER_TY,
};

enum {
  SHARE_SMS_IDX,
  SHARE_WECHAT_IDX,
  CANCEL_IDX,
};

@interface EventDetailViewController () <UITableViewDelegate, UITableViewDataSource>
{
}

@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKEvent *dailyEvent;
@property (nonatomic, retain) EKCalendar *defaultCalendar;
@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) NSArray *cellImgArray;
@property (nonatomic, retain) NSArray *cellLabelArray;
@property (nonatomic, retain) NSArray *cellTextArray;
@property (nonatomic, retain) NSMutableArray *cellHeightArray;

@property (nonatomic, retain) UIImageView *cellIconView;
@property (nonatomic, copy) NSString *imageUrl;
@end

@implementation EventDetailViewController

@synthesize event = _event;
@synthesize eventStore = _eventStore;
@synthesize dailyEvent = _dailyEvent;
@synthesize defaultCalendar = _defaultCalendar;

#pragma mark - set refresh flag
- (void)setRefreshFlag {
  if (_parentListVC != nil) {
    if ([_parentListVC respondsToSelector:@selector(setTriggerReloadListFlag)]) {
      [_parentListVC performSelector:@selector(setTriggerReloadListFlag)];
    }
  }
}

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

#pragma mark - arrange after event detail loaded
- (void)arrangeEventBaseInfos {
  [self initHeadView];
  
  if (!_autoLoaded) {
    [UIView animateWithDuration:FADE_IN_DURATION
                     animations:^{
//                       _tableView.frame = CGRectMake(_tableView.frame.origin.x,
//                                                     _tableView.frame.origin.y,
//                                                     _tableView.frame.size.width,
//                                                     self.view.frame.size.height- BOTTOM_TOOL_H);
                       _tableView.alpha = 1.0f;
                     }];
  }
}

- (void)arrangeViewsAfterDetailLoaded {
  self.event = [self fetchEventDetailFromMOC];
  
  if (self.event.imageUrl && self.event.imageUrl.length > 0) {
    [self drawImage:self.event.imageUrl];
  }
  if (nil == self.event || self.event.isFault) {
    // if event fetch failed, error message should be displayed
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchEventDetailFailedMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
    
    return;
  }
  
  [self initResource];
  //  [self checkAdminIdentifier];
  
  [self arrangeEventBaseInfos];
  
  [_tableView reloadData];
  
  if (!_eventLoaded) {
    _eventLoaded = YES;
    [self performSelector:@selector(arrangeBottomToolbar)
               withObject:nil
               afterDelay:0.2f];
  }
  
}

- (void)initResource {
  self.cellImgArray = [[[NSArray alloc] initWithObjects:@"eventDetailTopic.png", @"eventDetailGroup.png", @"eventDetailDate.png", @"eventDetailContract.png", @"eventDetailAddress.png", @"eventDetailDesc.png", nil] autorelease];
  
  self.cellLabelArray = [[[NSArray alloc] initWithObjects:LocaleStringForKey(NSEventTopicTitle, nil), LocaleStringForKey(NSEventGroupTitle, nil),LocaleStringForKey(NSEventDateTitle, nil), LocaleStringForKey(NSContactTitle, nil), LocaleStringForKey(NSEventAddressTitle, nil), LocaleStringForKey(NSEventDescTitle, nil), nil] autorelease];
  
  NSString *eventTitle = NULL_PARAM_VALUE;
  NSString *eventGroup = NULL_PARAM_VALUE;
  NSString *eventDate = NULL_PARAM_VALUE;
  NSString *eventContract = NULL_PARAM_VALUE;
  NSString *eventAddress = NULL_PARAM_VALUE;
  NSString *eventDesc = LocaleStringForKey(NSEmptyListMsg, nil);
  
  if (self.event.title) {
    eventTitle = self.event.title;
  }
  
  if (self.event.hostName) {
    eventGroup = self.event.hostName;
  }
  
  if (self.event.time) {
    eventDate = [NSString stringWithFormat:@"%@ %@", self.event.time, self.event.timeStr];
  }
  
  if (self.event.contact) {
    eventContract = [NSString stringWithFormat:@"%@ %@", self.event.contact, self.event.tel];
  }
  
  if (self.event.address) {
    eventAddress = self.event.address;
  }
  
  if (self.event.desc) {
    eventDesc = self.event.desc;
  }
  
  self.cellTextArray = [[[NSArray alloc] initWithObjects:eventTitle, eventGroup, eventDate, eventContract, eventAddress, eventDesc, nil] autorelease];
  
  self.cellHeightArray = [NSMutableArray array];
  
  for (int i=0; i<CELL_COUNT; i++) {
    CGSize fontSize = [[self.cellTextArray objectAtIndex:i] sizeWithFont:BOLD_FONT(FONT_SIZE-2)
                                                       constrainedToSize:CGSizeMake(234, CGFLOAT_MAX)
                                                           lineBreakMode:NSLineBreakByCharWrapping];
    
    float cellHeight = 58.f;
    if (fontSize.height+50 > cellHeight) {
      cellHeight = fontSize.height + 40.f;
    }
    
    [self.cellHeightArray insertObject:@(cellHeight) atIndex:i];
  }
}

#pragma mark - arrange action button
- (void)addActionForDifferentType {
  
  [_eventActionButton removeTarget:nil
                            action:NULL
                  forControlEvents:UIControlEventAllEvents];
  
  switch (self.event.actionType.intValue) {
    case SIGNUP_BTN_TY:
      [_eventActionButton addTarget:self
                             action:@selector(doSignUp)
                   forControlEvents:UIControlEventTouchUpInside];
      break;
      
    case CHECKIN_BTN_TY:
      [_eventActionButton addTarget:self
                             action:@selector(checkin)
                   forControlEvents:UIControlEventTouchUpInside];
      break;
      
    case PAYMENT_BTN_TY:
      [_eventActionButton addTarget:self
                             action:@selector(triggerOnlinePayment)
                   forControlEvents:UIControlEventTouchUpInside];
      
      break;
    default:
      break;
  }
  
}

- (void)arrangeActionButton {
  
  [_eventActionButton setTitle:self.event.actionStr
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
  
  //  DELETE_OBJS_FROM_MOC(_MOC, @"Event", nil);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
          eventId:(long long)eventId
     parentListVC:(BaseListViewController *)parentListVC {
  
  self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
  if (self) {
    
    _eventId = eventId;
    
    _parentListVC = parentListVC;
    
    [AppManager instance].allowSendSMS = NO;
    [self clearObjectsFromMOC];
  }
  
  return self;
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
            event:(Event *)event
     parentListVC:(BaseListViewController *)parentListVC {
  self = [self initWithMOC:MOC
                   eventId:event.eventId.longLongValue
              parentListVC:parentListVC];
  
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

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [self initTableView];
  self.tableView.alpha = 0;
  
  [self addBottomToolbar];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded || _needRefreshAfterBack) {
    [self loadEventDetail];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - init view
- (void)initHeadView {
  
  UIView *headerBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEADER_H)] autorelease];
  [headerBGView setBackgroundColor:TRANSPARENT_COLOR];
  
  UIImageView *eventBoardImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(15.f, 19.f, 285, HEADER_H)] autorelease];
  [eventBoardImgView setBackgroundColor:TRANSPARENT_COLOR];
  [eventBoardImgView setImage:[UIImage imageNamed:@"clubDetailMiddleBoard.png"]];
  [headerBGView addSubview:eventBoardImgView];
  
  self.cellIconView = [[[UIImageView alloc] initWithFrame:CGRectMake(15.f, 15.f, EVENT_IMG_WIDTH, EVENT_IMG_HEIGHT)] autorelease];

  self.cellIconView.image = [UIImage imageNamed:@"clubDetailTopBG.png"];
  [headerBGView addSubview:self.cellIconView];
  
  UIImageView *eventBottomImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(15.f, 185.f, 285, 9.975f)] autorelease];
  eventBottomImgView.image = [UIImage imageNamed:@"eventDetailWave.png"];
  [headerBGView addSubview:eventBottomImgView];
  
  // button
  UIImageButton *eventSignBut = [[[UIImageButton alloc]
                                  initImageButtonWithFrame:CGRectMake(30, 203.f, 120.f, 34.f)
                                  target:self
                                  action:@selector(goSignUpList)
                                  title:LocaleStringForKey(NSAppliedTitle, nil)
                                  image:nil
                                  backImgName:@"eventSignUpList.png"
                                  selBackImgName:nil
                                  titleFont:FONT(FONT_SIZE)
                                  titleColor:[UIColor whiteColor]
                                  titleShadowColor:TRANSPARENT_COLOR
                                  roundedType:NO_ROUNDED
                                  imageEdgeInsert:ZERO_EDGE
                                  titleEdgeInsert:UIEdgeInsetsMake(15.f, 5.f, 10.f, 40.f)] autorelease];
  [headerBGView addSubview:eventSignBut];
  
  WXWLabel *signUpNumLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(73.f, 10.f, 49.f, 20.f) textColor:[UIColor whiteColor] shadowColor:[UIColor grayColor]] autorelease];
  signUpNumLabel.font = FONT(FONT_SIZE);
  signUpNumLabel.text = [NSString stringWithFormat:@"%@%@", self.event.signupCount, LocaleStringForKey(NSPeopleTitle, nil)];
  signUpNumLabel.textAlignment = NSTextAlignmentCenter;
  [eventSignBut addSubview:signUpNumLabel];
  
  int type = self.event.actionType.intValue;
  NSString *imageName = @"eventJoinBut.png";
  
  if (type < 0 || type == EXIT_EVENT_BTN_TY) {
    imageName = @"exitEventBut.png";
  }
  
  
  UIImageButton *eventCheckinBut = [[[UIImageButton alloc]
                                     initImageButtonWithFrame:CGRectMake(SCREEN_WIDTH/2, 203.f, 120.f, 34.f)
                                     target:self
                                     action:@selector(doSignUp)
                                     title:self.event.actionStr
                                     image:nil
                                     backImgName:imageName
                                     selBackImgName:nil
                                     titleFont:FONT(FONT_SIZE)
                                     titleColor:[UIColor whiteColor]
                                     titleShadowColor:TRANSPARENT_COLOR
                                     roundedType:NO_ROUNDED
                                     imageEdgeInsert:ZERO_EDGE
                                     titleEdgeInsert:UIEdgeInsetsMake(15.f, 0, 10.f, 0)] autorelease];
  [headerBGView addSubview:eventCheckinBut];
  
  self.tableView.tableHeaderView = headerBGView;
  
  // ios4.3 needs reset the frame of table view, otherwise, the y coordinate will be -44.0
  if ([CommonUtils currentOSVersion] < IOS7) {
    _tableView.frame = CGRectMake(0, 0, _tableView.frame.size.width, self.view.frame.size.height - BOTTOM_TOOL_H);
  }
}

- (void)addBottomToolbar {
  
  CGFloat y = self.view.frame.size.height - NAVIGATION_BAR_HEIGHT;
  if (CURRENT_OS_VERSION >= IOS7) {
    y -= SYS_STATUS_BAR_HEIGHT;
  }
  
  // Action View
  _bottomToolbar = [[[AlumniEventDetailActionView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, BOTTOM_TOOL_H)
                                                                 event:self.event
                                                              delegate:self] autorelease];
  
  [self.view addSubview:_bottomToolbar];
}

- (void)arrangeBottomToolbar {
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _bottomToolbar.frame = CGRectOffset(_bottomToolbar.frame, 0, -1 * BOTTOM_TOOL_H);
                     
//                     _tableView.frame = CGRectMake(_tableView.frame.origin.x,
//                                                   _tableView.frame.origin.y,
//                                                   _tableView.frame.size.width,
//                                                   self.view.frame.size.height - BOTTOM_TOOL_H);
                     
                     [self.view bringSubviewToFront:_bottomToolbar];
                     
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
    
    if (contentType == IMAGE_TY) {
      self.cellIconView.image = [WXWCommonUtils cutPartImage:[UIImage imageNamed:@"clubDetailTopBG.png"]
                                                       width:EVENT_IMG_WIDTH
                                                      height:EVENT_IMG_HEIGHT];
      return;
    }
    
    if (contentType == EVENTDETAIL_TY) {
      blockCurrentview = YES;
    }
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
              blockCurrentView:blockCurrentview];
  }
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case IMAGE_TY:
    {
      if (url && url.length > 0) {
        UIImage *image = [UIImage imageWithData:result];
        if (image) {
          [[WXWImageManager instance].imageCache saveImageIntoCache:url image:image];
          
        }
        
        if ([url isEqualToString:self.imageUrl]) {
          self.cellIconView.image = [WXWCommonUtils cutPartImage:image
                                                           width:EVENT_IMG_WIDTH
                                                          height:EVENT_IMG_HEIGHT];
          [self.tableView reloadData];
        }
      }
      
      break;
    }
      
    case EXIT_EVENT_TY:
    {
      if( RESP_OK == [XMLParser handleCommonResult:result showFlag:YES] ){
        _autoLoaded = NO;
        [self loadEventDetail];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchEventDetailFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      _needRefreshAfterBack = YES;
    }
      break;
      
    case EVENTDETAIL_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self arrangeViewsAfterDetailLoaded];
        
        if (!_autoLoaded || _needRefreshAfterBack) {
          //          [self arrangeActionButton];
          _autoLoaded = YES;
          self.tableView.alpha = 1;
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
  /*
   else if ([resp isKindOfClass:[SendAuthResp class]]) {
   NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
   NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
   
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
   [alert show];
   [alert release];
   
   }
   */
  
  ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = nil;
}

#pragma mark - Event action
- (void)signUp {
  
  _needRefreshAfterBack = YES;
  
  NSString *url = [NSString stringWithFormat:@"%@%@&event_id=%@&user_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@&person_id=%@",[AppManager instance].hostUrl, EVENT_SIGNUP_URL,self.event.eventId,[AppManager instance].userId,[WXWSystemInfoManager instance].currentLanguageDesc, PLATFORM, VERSION, [AppManager instance].sessionId,[AppManager instance].personId];
  [self gotoUrl:url aTitle:LocaleStringForKey(NSSignUpTitle, nil)];
  
  [self setRefreshFlag];
}

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
  
  [self setRefreshFlag];
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
  eventTopicListVC.title = LocaleStringForKey(NSEventVoteTitle, nil);
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
  
  EventAlumniListViewController *eventAlumniListVC = [[[EventAlumniListViewController alloc] initWithMOC:_MOC
                                                                                   checkinResultDelegate:nil
                                                                                                   event:self.event
                                                                                       checkinResultType:CHECKIN_NONE_TY
                                                                                                entrance:self
                                                                                                listType:EVENT_DISCUSS_TY] autorelease];
  eventAlumniListVC.title = LocaleStringForKey(NSEventDiscussionTitle, nil);
  [self.navigationController pushViewController:eventAlumniListVC animated:YES];
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
  [as showInView:self.view];
  
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
  
  SignedUpAlumnusViewController *alumnusVC = [[[SignedUpAlumnusViewController alloc] initWithMOC:_MOC
                                                                                           event:self.event] autorelease];
  alumnusVC.title = LocaleStringForKey(NSSignedUpAlumniTitle, nil);
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
  [as showInView:self.view];
  
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

- (void)goClubDetail {
  
  [AppManager instance].clubName = [NSString stringWithFormat:@"%@", self.event.hostName];
  [AppManager instance].clubId = [NSString stringWithFormat:@"%@", self.event.hostId];
  [AppManager instance].clubType = [NSString stringWithFormat:@"%@", self.event.hostType];
  [AppManager instance].hostSupTypeValue = self.event.hostSubTypeValue;
  [AppManager instance].hostTypeValue = self.event.hostTypeValue;
  
  CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
  ClubDetailViewController *sponsorDetail = [[[ClubDetailViewController alloc] initWithFrame:mFrame MOC:_MOC parentListVC:nil] autorelease];
  
  sponsorDetail.title = LocaleStringForKey(NSClubDetailTitle, nil);
  [self.navigationController pushViewController:sponsorDetail animated:YES];
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

- (void)doSignUp {
  _needRefreshAfterBack = YES;
  
  switch (self.event.actionType.intValue) {
    case SIGNUP_BTN_TY:
    {
      EventSignUpViewController *detailVC = [[[EventSignUpViewController alloc] initWithMOC:_MOC
                                                                                      event:self.event] autorelease];
      detailVC.title = self.event.actionStr;
      
      [self.navigationController pushViewController:detailVC animated:YES];
      
      [self setRefreshFlag];
    }
      break;
      
    case PAYMENT_BTN_TY:
    {
      CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
      OrderViewController *orderVC = [[[OrderViewController alloc] initWithFrame:mFrame MOC:_MOC paymentItemType:EVENT_PAYMENT_TY] autorelease];
      
      [orderVC setPayOrderId:self.event.payOrderId orderTitle:self.event.orderTitle skuMsg:self.event.skuMsg];
      
      orderVC.title = LocaleStringForKey(NSSubmitOrderTitle, nil);
      [self.navigationController pushViewController:orderVC animated:YES];
      
      [self setRefreshFlag];
    }
      break;
      
    case EXIT_EVENT_BTN_TY:
    {
      _currentType = EXIT_EVENT_TY;
      
      NSString *param = [NSString stringWithFormat:@"<event_id>%@</event_id>",[AppManager instance].eventId];
      
      NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
      
      ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:_currentType] autorelease];
      (self.connDic)[url] = connFacade;
      [connFacade fetchGets:url];
      
      [self setRefreshFlag];
    }
      break;
      
    default:
      break;
  }
  
  
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
  //controller.modalPresentationStyle = UIModalPresentationFullScreen;//UIModalPresentationFormSheet;
  
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
                                        
                                        /*
                                         ShowAlertWithOneButton(self,
                                         LocaleStringForKey(NSNoGrantedForCalendarTitle, nil),
                                         LocaleStringForKey(NSHowToGrantCalendarMsg, nil), LocaleStringForKey(NSIKnowTitle, nil));
                                         */
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

- (void)initTableView {
  if (self.tableView == nil) {
    
    CGFloat height = self.view.frame.size.height - BOTTOM_TOOL_H - SYS_STATUS_BAR_HEIGHT;
    if (CURRENT_OS_VERSION >= IOS7) {
      height -= SYS_STATUS_BAR_HEIGHT;
    }
    
    CGRect mTabFrame = CGRectMake(0, 0, SCREEN_WIDTH, height);
    self.tableView = [[[UITableView alloc] initWithFrame:mTabFrame
                                                   style:UITableViewStyleGrouped] autorelease];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = TRANSPARENT_COLOR;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.separatorColor = TRANSPARENT_COLOR;
  }
  
	[self.view addSubview:self.tableView];
  
  [self.view sendSubviewToBack:self.tableView];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return CELL_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  int row = [indexPath row];
  float cellHeight = [[self.cellHeightArray objectAtIndex:row] floatValue];
  
  if (row == CELL_COUNT-1) {
    return cellHeight;
  } else {
    return cellHeight;
  }
  return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"EventDetailCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  [subviews release];
  
  cell.backgroundColor = TRANSPARENT_COLOR;
  [self drawEventCell:cell row:[indexPath row]];
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch ([indexPath row]) {
    case 1:
    {
      [self goClubDetail];
    }
      break;
      
    case 3:
    {
      [self goContracts];
    }
      break;
      
    case 4:
    {
      [self goLocation];
    }
      break;
      
    default:
      break;
  }
  //  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
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
    
    /*
     _descTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
     textColor:COLOR(50, 50, 51)
     shadowColor:TRANSPARENT_COLOR] autorelease];
     _descTitleLabel.font = BOLD_FONT(15);
     _descTitleLabel.text = LocaleStringForKey(NSIntroTitle, nil);
     CGSize size = [_descTitleLabel.text sizeWithFont:_descTitleLabel.font];
     _descTitleLabel.frame = CGRectMake(MARGIN * 2, SECTION_HEADER_HEIGHT - size.height - MARGIN * 2, size.width, size.height);
     [_sectionHeaderView addSubview:_descTitleLabel];
     
     _eventActionButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake(_sectionHeaderView.frame.size.width, MARGIN * 2, ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT)
     target:nil
     action:nil
     title:self.event.actionStr
     image:[UIImage imageNamed:@"hand.png"]
     backImgName:@"orangeButton.png"
     selBackImgName:nil
     titleFont:FONT(16.f)
     titleColor:[UIColor whiteColor]
     titleShadowColor:TRANSPARENT_COLOR
     roundedType:NO_ROUNDED
     imageEdgeInsert:UIEdgeInsetsMake(8, 85, 8, 55)
     titleEdgeInsert:UIEdgeInsetsMake(0, -75, 0, 0)] autorelease];
     [self addActionForDifferentType];
     
     _eventActionButton.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(2.0f, 2.0f,
     ACTION_BUTTON_WIDTH,
     ACTION_BUTTON_HEIGHT - 1.0f)].CGPath;
     _eventActionButton.layer.shadowRadius = 2.0f;
     _eventActionButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
     _eventActionButton.layer.shadowOffset = CGSizeMake(0, 0);
     _eventActionButton.layer.shadowOpacity = 0.9f;
     _eventActionButton.layer.masksToBounds = NO;
     
     [_sectionHeaderView addSubview:_eventActionButton];
     */
  }
  
  return _sectionHeaderView;
}

#pragma mark - draw event cell
- (void)drawEventCell:(UITableViewCell *)cell row:(int)row
{
  CGFloat x = 0;
  if (CURRENT_OS_VERSION >= IOS7) {
    x = MARGIN * 3;
  } else {
    x = MARGIN;
  }
  UIImageView *eventTopImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(x, 0.f, 285, [[self.cellHeightArray objectAtIndex:row] floatValue])] autorelease];
  [eventTopImgView setImage:[UIImage imageNamed:@"clubDetailMiddleBoard.png"]];
  eventTopImgView.backgroundColor = TRANSPARENT_COLOR;
  [cell.contentView addSubview:eventTopImgView];
  
  UIImageView *cellImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(17, 10, 16, 16)] autorelease];
  cellImageView.image = [UIImage imageNamed:[self.cellImgArray objectAtIndex:row]];
  [eventTopImgView addSubview:cellImageView];
  
  // Label
  UILabel *mUILable = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
  mUILable.text = [self.cellLabelArray objectAtIndex:row];
  mUILable.font = BOLD_FONT(FONT_SIZE);
  CGSize mDescSize = [mUILable.text sizeWithFont:mUILable.font];
  mUILable.frame = CGRectMake(37, 10, 234, mDescSize.height);
  mUILable.textColor = COLOR(0, 101, 153);
  [mUILable setBackgroundColor:TRANSPARENT_COLOR];
  [eventTopImgView addSubview:mUILable];
  
  // context Label
  UILabel *contextLable = [[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(111, 112, 111) shadowColor:TRANSPARENT_COLOR];
  [contextLable setFont:BOLD_FONT(FONT_SIZE-2)];
  contextLable.lineBreakMode = NSLineBreakByCharWrapping;
  [contextLable setText:[self.cellTextArray objectAtIndex:row]];
  
  CGSize fontSize = [contextLable.text sizeWithFont:contextLable.font
                                  constrainedToSize:CGSizeMake(234, CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByCharWrapping];
  
  contextLable.frame = CGRectMake(37, 32, fontSize.width, fontSize.height);
  contextLable.numberOfLines = 0;
  
  [eventTopImgView addSubview:contextLable];
  [contextLable release];
  
  if (row != 0) {
    UIImageView *eventDetailLineView = [[[UIImageView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-70.f, 3.5)] autorelease];
    eventDetailLineView.image = [UIImage imageNamed:@"eventDetailLine.png"];
    [eventTopImgView addSubview:eventDetailLineView];
  }
  
  if (row == CELL_COUNT - 1) {
    UIView *line = [[[UIView alloc] initWithFrame:CGRectMake(x + MARGIN, [[self.cellHeightArray objectAtIndex:row] floatValue] - 0.5f, 275, 0.5f)] autorelease];
    line.backgroundColor = COLOR(200, 200, 200);
    [cell.contentView addSubview:line];
  }
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
  
  [self setRefreshFlag];
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
  NSLog(@"resultStr = %@", resultStr);
  
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

- (void)drawImage:(NSString *)imageUrl
{
  UIImage *image = nil;
  if (imageUrl && [imageUrl length] > 0 ) {
    self.imageUrl = imageUrl;
    
    image = [[WXWImageManager instance].imageCache getImage:self.imageUrl];
    if (!image) {
      ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:IMAGE_TY] autorelease];
      [connFacade fetchGets:self.imageUrl];
    }
  } else {
    image = [UIImage imageNamed:@"clubDetailTopBG.png"];
  }
  
  if (image) {
    self.cellIconView.image = [WXWCommonUtils cutPartImage:image
                                                     width:EVENT_IMG_WIDTH
                                                    height:EVENT_IMG_HEIGHT];
  }
  
  [self initTableView];
}

@end
