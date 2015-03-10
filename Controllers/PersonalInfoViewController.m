//
//  PersonalInfoViewController.m
//  iAlumni
//
//  Created by Adam on 13-9-24.
//
//

#import "PersonalInfoViewController.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "UserListViewController.h"
#import "AppManager.h"
#import "KnownAlumniListViewController.h"
#import "AttractiveAlumniListViewController.h"
#import "ProfileSettingViewController.h"
#import "UserProfileViewController.h"
#import "WXWNumberBadge.h"

#define VIEW_WIDTH    145.0f

#define LABEL_TAG     100

@interface PersonalInfoViewController ()
@property (nonatomic, retain) UIViewController *parentVC;
@end

@implementation PersonalInfoViewController

#pragma mark - user actions

- (void)pushVC:(UIViewController *)vc {
  if (self.parentVC) {
    [self.parentVC.navigationController pushViewController:vc animated:YES];
  }
}

- (void)openDMForPush {
  [self openDM:nil];
}

- (void)openDM:(UIGestureRecognizer *)gesture {
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", nil);
  
  UserListViewController *userListVC = [[[UserListViewController alloc] initWithType:CHAT_USER_LIST_TY
                                                                        needGoToHome:NO
                                                                                 MOC:_MOC
                                                                               group:nil
                                                                   needAdjustForiOS7:NO] autorelease];
  userListVC.pageIndex = 0;
  userListVC.requestParam = [NSString stringWithFormat:@"<page>0</page><page_size>30</page_size>"];
  userListVC.title = LocaleStringForKey(NSShakeChatListTitle, nil);
  
  [self pushVC:userListVC];
  
  _needRefreshNewDMNumberBadge = YES;
}

- (void)openKnownAlumnus:(UIGestureRecognizer *)gesture {
  KnownAlumniListViewController *alumniListVC = [[[KnownAlumniListViewController alloc] initWithMOC:_MOC] autorelease];
  alumniListVC.title = LocaleStringForKey(NSKnownAlumnusTitle, nil);
  
  [self pushVC:alumniListVC];
}

- (void)openWantKnowAlumnus:(UIGestureRecognizer *)gesture {
  AttractiveAlumniListViewController *alumniListVC = [[[AttractiveAlumniListViewController alloc] initResettedWithMOC:_MOC] autorelease];
  alumniListVC.title = LocaleStringForKey(NSWantToKnowAlumniTitle, nil);
  [self pushVC:alumniListVC];
}

- (void)openProfileSetting:(UIGestureRecognizer *)gesture {
  ProfileSettingViewController *profileSettingVC = [[[ProfileSettingViewController alloc] initWithMOC:_MOC] autorelease];
  profileSettingVC.title = LocaleStringForKey(NSProfileSettingTitle, nil);
  [self pushVC:profileSettingVC];
}

- (void)openAppSetting:(UIGestureRecognizer *)gesture {
  
  UserProfileViewController *vc = [[[UserProfileViewController alloc] initWithMOC:_MOC
                                                                         parentVC:self.parentVC
                                                                 personalEntrance:self
                                                                    refreshAction:@selector(refreshViewForLanguageSwitch)] autorelease];
  vc.title = LocaleStringForKey(NSSettingsTitle, nil);
  [self pushVC:vc];
  
}

#pragma mark - arrange badges

- (void)updateNewDMNumberBadgeForPushNotification:(NSNotification *)notification {
  [self setNewDMNumberBadge];
}

- (void)setNewDMNumberBadge {
  
  NSInteger msgNumber = [AppManager instance].msgNumber.intValue;
  if (msgNumber > 0) {
    if (nil == _dmNewNumberBadge) {
      _dmNewNumberBadge = [[[WXWNumberBadge alloc] initWithFrame:CGRectMake(VIEW_WIDTH/2.0f + MARGIN * 4, 170/2.0f - MARGIN * 6, 0, NUMBER_BADGE_HEIGHT)
                                                        topColor:NUMBER_BADGE_TOP_COLOR
                                                     bottomColor:NUMBER_BADGE_TOP_COLOR
                                                            font:BOLD_FONT(12)] autorelease];
      [_dmEntranceView addSubview:_dmNewNumberBadge];
    }
    _dmNewNumberBadge.hidden = NO;
    
    [_dmNewNumberBadge setNumberWithTitle:[AppManager instance].msgNumber];
  } else if (msgNumber == 0 && _dmNewNumberBadge != nil) {
    _dmNewNumberBadge.hidden = YES;
  }
  
  if (self.parentVC && [self.parentVC respondsToSelector:@selector(refreshBadges)]) {
    [self.parentVC performSelector:@selector(refreshBadges)];
  }
}

#pragma mark - arrange Views

- (UIView *)arrangeEntranceWithFrame:(CGRect)frame
                            selector:(SEL)selector
                     backgroundColor:(UIColor *)backgroundColor
                            iconName:(NSString *)iconName
                          iconCenter:(CGPoint)iconCenter
                               title:(NSString *)title {
  
  UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
  UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:selector] autorelease];
  [view addGestureRecognizer:tapGesture];
  
  view.backgroundColor = backgroundColor;
  
  [self.view addSubview:view];
  
  UIImageView *icon = [[[UIImageView alloc] initWithImage:IMAGE_WITH_NAME(iconName)] autorelease];
  icon.center = iconCenter;
  [view addSubview:icon];
  
  WXWLabel *titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                textColor:[UIColor whiteColor]
                                              shadowColor:TRANSPARENT_COLOR
                                                     font:BOLD_FONT(18)] autorelease];
  titleLabel.tag = LABEL_TAG;
  titleLabel.text = title;
  CGSize size = [titleLabel.text sizeWithFont:titleLabel.font];
  titleLabel.frame = CGRectMake(MARGIN * 3, view.frame.size.height - size.height - MARGIN * 3, size.width, size.height);
  [view addSubview:titleLabel];
  
  return view;
}

- (void)addDMEntrance {
  _dmEntranceView = [self arrangeEntranceWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, VIEW_WIDTH, 170.0f)
                                          selector:@selector(openDM:)
                                   backgroundColor:COLOR(73, 142, 186)
                                          iconName:@"largeWhiteDM.png"
                                        iconCenter:CGPointMake(VIEW_WIDTH/2.0f, 170.0f/2.0f)
                                             title:LocaleStringForKey(NSDMTitle, nil)];
  [self setNewDMNumberBadge];
}

- (void)addKnownAlumnus {
  _knownAlumnusEntranceView =  [self arrangeEntranceWithFrame:CGRectMake(self.view.frame.size.width - MARGIN * 2 - VIEW_WIDTH, MARGIN * 2, VIEW_WIDTH, 111)
                                                     selector:@selector(openKnownAlumnus:)
                                              backgroundColor:COLOR(254, 186, 77)
                                                     iconName:@"largeKnownAlumnus.png"
                                                   iconCenter:CGPointMake(VIEW_WIDTH/2.0f, 111/2.0f - MARGIN * 4)
                                                        title:LocaleStringForKey(NSKnownAlumnusTitle, nil)];
}

- (void)addProfile {
  _profileEntranceView = [self arrangeEntranceWithFrame:CGRectMake(MARGIN * 2, 190, VIEW_WIDTH, 176.0f)
                                               selector:@selector(openProfileSetting:)
                                        backgroundColor:COLOR(107, 194, 234)
                                               iconName:@"largeWhiteProfile.png"
                                             iconCenter:CGPointMake(VIEW_WIDTH/2.0f, 176.0f/2.0f)
                                                  title:LocaleStringForKey(NSProfileSettingTitle, nil)];
}

- (void)addWantKnowAlumnus {
  _wantKnowAlumnusEntranceView = [self arrangeEntranceWithFrame:CGRectMake(self.view.frame.size.width - MARGIN * 2 - VIEW_WIDTH, MARGIN * 2 + 111 + MARGIN * 2,  VIEW_WIDTH, 110)
                                                       selector:@selector(openWantKnowAlumnus:)
                                                backgroundColor:COLOR(94, 191, 168)
                                                       iconName:@"largeWantKnowAlumnus.png"
                                                     iconCenter:CGPointMake(VIEW_WIDTH/2.0f, 110/2.0f - MARGIN * 4)
                                                          title:LocaleStringForKey(NSWantToKnowAlumniTitle, nil)];
}

- (void)addAppSetting {
  _appSettingEntranceView = [self arrangeEntranceWithFrame:CGRectMake(self.view.frame.size.width - MARGIN * 2 - VIEW_WIDTH,
                                                                      MARGIN * 2 + 111 + MARGIN * 2 + 110 + MARGIN * 2, VIEW_WIDTH, 115.0f)
                                                  selector:@selector(openAppSetting:)
                                           backgroundColor:COLOR(109, 192, 111)
                                                  iconName:@"largeWhiteSetting.png"
                                                iconCenter:CGPointMake(VIEW_WIDTH/2.0f, 115.0f/2.0f - MARGIN * 4)
                                                     title:LocaleStringForKey(NSSettingsTitle, nil)];
}

- (void)arrangeViews {
  
  [self addDMEntrance];
  
  [self addKnownAlumnus];
  
  [self addProfile];
  
  [self addWantKnowAlumnus];
  
  [self addAppSetting];
}

#pragma mark - life cycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
parentViewController:(UIViewController *)parentViewController {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
                 needGoHome:NO];
  
  if (self) {
    self.parentVC = parentViewController;
    
    _viewHeight = viewHeight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNewDMNumberBadgeForPushNotification:)
                                                 name:DM_REFRESH_IN_PERSONAL_VIEW_KEY
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
  
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  if ([CommonUtils currentOSVersion] < IOS7) {
    self.view.frame = CGRectOffset(self.view.frame, 0, -20);
  }
  
  [self arrangeViews];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // refresh badges
  if (_needRefreshNewDMNumberBadge) {
    [self setNewDMNumberBadge];
    
    _needRefreshNewDMNumberBadge = NO;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - refresh for language switch
- (void)adjustLabelInView:(UIView *)view title:(NSString *)title {
  WXWLabel *label = (WXWLabel *)[view viewWithTag:LABEL_TAG];
  label.text = title;
  CGSize size = [label.text sizeWithFont:label.font];
  label.frame = CGRectMake(MARGIN * 3, view.frame.size.height - size.height - MARGIN * 3, size.width, size.height);
}

- (void)refreshViewForLanguageSwitch {
  
  [self adjustLabelInView:_dmEntranceView title:LocaleStringForKey(NSDMTitle, nil)];

  [self adjustLabelInView:_knownAlumnusEntranceView title:LocaleStringForKey(NSKnownAlumnusTitle, nil)];
  
  [self adjustLabelInView:_profileEntranceView title:LocaleStringForKey(NSProfileSettingTitle, nil)];

  [self adjustLabelInView:_wantKnowAlumnusEntranceView title:LocaleStringForKey(NSWantToKnowAlumniTitle, nil)];

  [self adjustLabelInView:_appSettingEntranceView title:LocaleStringForKey(NSSettingsTitle, nil)];
  
  if (self.parentVC) {
    self.parentVC.navigationItem.title = LocaleStringForKey(NSMeTitle, nil);
  }
}

@end
