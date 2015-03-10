//
//  ShakeViewController.m
//  iAlumni
//
//  Created by Adam on 12-5-11.ƒ
//  Copyright (c) 2012年 __MyCompanyName__. All rights ƒreserved.
//

#import "ShakeViewController.h"
#import "UserListViewController.h"
#import "ECGradientButton.h"
#import "WXWDebugLogOutput.h"
#import "Shake.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "UIWebViewController.h"
#import "WXWNavigationController.h"

#define FONT_SIZE       20
#define LABEL_Y         316.0f
#define LABEL_W         135.0f
#define LABEL_H         20.0f
#define BUTTON_Y        362.0f
#define BUTTON_H        44.0f
#define PLACE_THING_H   44.0f

static BOOL checkShakeing(UIAcceleration* last, UIAcceleration* current, double threshold) {
  double
  deltaX = fabs(last.x - current.x),
  deltaY = fabs(last.y - current.y),
  deltaZ = fabs(last.z - current.z);
  
  return
  (deltaX > threshold && deltaY > threshold) ||
  (deltaX > threshold && deltaZ > threshold) ||
  (deltaY > threshold && deltaZ > threshold);
}

@interface ShakeViewController ()
@property(nonatomic, retain) UIAcceleration* lastAcceleration;
@end

@implementation ShakeViewController
@synthesize imageView;
@synthesize shakeStartImg;
@synthesize shakeEndImg;
@synthesize lastAcceleration;

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
  
  if (self) {
    // Custom initialization
  }
  return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId {
  self = [self initWithMOC:MOC];
  
  if (self) {
    _eventId = eventId;
  }
  return self;
}

- (void)dealloc
{
  _shake = nil;
  
  self.imageView = nil;
  self.shakeStartImg = nil;
  self.shakeEndImg = nil;
  
  self.lastAcceleration = nil;
  
  [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
  isRun = NO;
  [UIAccelerometer sharedAccelerometer].delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated {
  
  isRun = YES;
  [UIAccelerometer sharedAccelerometer].delegate = self;
  [super viewDidAppear:animated];
  [self becomeFirstResponder];
  
  [self changeImages:self.imageView];
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
	// Do any additional setup after loading the view.
  [self initResource];
  
  [self initView];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - load data

- (void)triggerLocationAndFetch:(id)sender {
  
  if (_processing) {
    return;
  }
  
  _processing = YES;
  
  [self prepareLocationCondition];
}

- (void)loadData
{
  [CommonUtils doDelete:_MOC entityName:@"Tag"];
  [CommonUtils doDelete:_MOC entityName:@"Place"];
  _currentType = SHAKE_PLACE_THING_TY;
  NSString *param = [NSString stringWithFormat:@"<latitude>%f</latitude><longitude>%f</longitude>",
                     [AppManager instance].latitude,
                     [AppManager instance].longitude];
  
  NSMutableString *requestParam = [NSMutableString stringWithString:param];
  if (!isShakeAction) {
    [requestParam appendString:@"<not_shake>1</not_shake>"];
  } else {
    isShakeAction = NO;
  }
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  // [self.connDic setObject:connFacade forKey:url];
  [connFacade fetchGets:url];
}

- (void)loadAwardResult {
  NSString *param = [NSString stringWithFormat:@"<event_id>%lld</event_id><latitude>%f</latitude><longitude>%f</longitude>", _eventId, [AppManager instance].latitude,
                     [AppManager instance].longitude];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_EVENT_AWARD_RESULT_TY];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:LOAD_EVENT_AWARD_RESULT_TY];
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - init view
- (void)initResource
{
  // Img
  self.shakeStartImg = [UIImage imageNamed:@"shake0.png"];
  self.shakeEndImg = [UIImage imageNamed:@"shake1.png"];
  
  // Sound
  NSString *shakePath = [[NSBundle mainBundle] pathForResource:@"shake"
                                                        ofType:@"wav"];
  AudioServicesCreateSystemSoundID((CFURLRef)[NSURL
                                              fileURLWithPath:shakePath], &shakeSoundID);
  
}

- (void)changeImages:(UIImageView *)aImageView
{
  if (!isRun) {
    return;
  }
  
  NSTimeInterval timeInterval = 1.0;
  if (!_isShakeImg) {
    aImageView.transform = CGAffineTransformMakeRotation(150);
    _isShakeImg = YES;
    timeInterval = 0.5;
  }else {
    aImageView.transform = CGAffineTransformMakeRotation(0);
    _isShakeImg = NO;
    timeInterval = 2.0;
  }
  
  [self performSelector:@selector(changeImages:)
             withObject:aImageView
             afterDelay:timeInterval
   ];
}

- (void)initView
{
  CGRect mFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  UIView *backView = [[[UIView alloc] initWithFrame:mFrame] autorelease];
  
  
  UIImageView *backImgView = [[[UIImageView alloc] initWithFrame:mFrame] autorelease];
  [backImgView setImage:[UIImage imageNamed:@"shakeBg.png"]];
  [backView addSubview:backImgView];
  
  // Image
  self.imageView = [[[UIImageView alloc] init] autorelease];
  self.imageView.frame = CGRectMake((SCREEN_WIDTH-shakeStartImg.size.width)/2, 30, shakeStartImg.size.width, shakeStartImg.size.height);
  self.imageView.image = shakeStartImg;
  [backView addSubview:self.imageView];
  
  // Note
  WXWLabel *shakeAlumnusLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                       textColor:COLOR(162, 162, 162)
                                                     shadowColor:TRANSPARENT_COLOR] autorelease];
  shakeAlumnusLabel.font = BOLD_FONT(FONT_SIZE - 1);
  shakeAlumnusLabel.textAlignment = UITextAlignmentCenter;
  shakeAlumnusLabel.text = LocaleStringForKey(NSShakeNoteTitle, nil);
  CGSize size = [shakeAlumnusLabel.text sizeWithFont:shakeAlumnusLabel.font
                                   constrainedToSize:CGSizeMake(SCREEN_WIDTH - 30, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
  shakeAlumnusLabel.frame = CGRectMake(15, 300, SCREEN_WIDTH - 30, size.height);
  [backView addSubview:shakeAlumnusLabel];
  
  [self.view addSubview:backView];
  
  [backView becomeFirstResponder];
}

#pragma mark - prepare Condition
- (void)prepareLocationCondition
{
  
  [AppManager instance].defaultPlace = NULL_PARAM_VALUE;
  [AppManager instance].defaultThing = NULL_PARAM_VALUE;
  if (![IPHONE_SIMULATOR isEqualToString:[CommonUtils deviceModel]]) {
    [AppManager instance].latitude = 0.0;
    [AppManager instance].longitude = 0.0;
    
    [self getCurrentLocationInfoIfNecessary];
    //        [UIUtils showActivityView:self.view
    //                             text:LocaleStringForKey(NSShakeLoadingTitle, nil)];
  } else {
    [AppManager instance].latitude = [SIMULATION_LATITUDE doubleValue];
    [AppManager instance].longitude = [SIMULATION_LONGITUDE doubleValue];
    [self loadData];
  }
}

#pragma mark - handle award
- (void)displayAwardResult {
  NSString *url = [NSString stringWithFormat:@"%@event?action=page_load&page_name=shake_it_off_wap&locale=%@&user_id=%@&plat=%@&version=%@&sessionId=%@&person_id=%@&channel=%d&user_name=%@&user_type=%@&class_id=%@&class_name=%@&latitude=%f&longitude=%f&winner_type=%d&event_id=%lld",
                   [AppManager instance].hostUrl,
                   [WXWSystemInfoManager instance].currentLanguageDesc,
                   [AppManager instance].userId,
                   PLATFORM,
                   VERSION,
                   [AppManager instance].sessionId,
                   [AppManager instance].personId,
                   [AppManager instance].releaseChannelType,
                   [AppManager instance].userName,
                   [AppManager instance].userType,
                   [AppManager instance].classGroupId,
                   [AppManager instance].className,
                   [AppManager instance].latitude,
                   [AppManager instance].longitude,
                   [AppManager instance].shakeWinnerType,
                   _eventId];

  UIWebViewController *webVC = [[[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES] autorelease];
  WXWNavigationController *webViewNav = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
  //webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = url;

  [self.parentViewController presentModalViewController:webViewNav
                                               animated:YES];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  [UIUtils showActivityView:self.view
                       text:LocaleStringForKey(NSShakeLoadingTitle, nil)];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  switch (contentType) {
      
    case SHAKE_PLACE_THING_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        //      [self doPlace2Thing];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
      
    case LOAD_EVENT_AWARD_RESULT_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self displayAwardResult];
        
      } else {
        
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSEventAwardFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
    }
      
    default:
      break;
  }
  
  _processing = NO;
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  
  _processing = NO;
  
  switch (contentType) {
      
    case LOAD_EVENT_AWARD_RESULT_TY:
    {
      if ([self connectionMessageIsEmpty:error]) {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSEventAwardFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
      
    default:
      break;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - location result
- (void)locationResult:(LocationResultType)type{
  NSLog(@"shake type is %d", type);
  
  [UIUtils closeActivityView];
  
  switch (type) {
    case LOCATE_SUCCESS_TY:
    {
      [self loadData];
    }
      break;
      
    case LOCATE_FAILED_TY:
    {
      [UIUtils showNotificationOnTopWithMsg:@"定位失败"
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      _processing = NO;
      isShakeAction = NO;
    }
      break;
      
    default:
      break;
  }
  
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
  
  if (self.lastAcceleration) {
    
    if (!_processing) {
      if (checkShakeing(self.lastAcceleration, acceleration, 0.9)) {
        /* SHAKE DETECTED. DO HERE WHAT YOU WANT. */
        AudioServicesPlaySystemSound(shakeSoundID);
        self.imageView.image = shakeEndImg;
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        _processing = YES;
        isShakeAction = YES;
        //[self prepareLocationCondition];
        
        [self loadAwardResult];
        
      }
    }
  }
  
  self.lastAcceleration = acceleration;
}

@end
