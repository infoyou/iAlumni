//
//  MyInfoViewController.m
//  iAlumni
//
//  Created by Adam on 13-10-23.
//
//

#import "MyInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UserProfileHeaderView.h"
#import "WXWNumberBadge.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "AppManager.h"
#import "ECPhotoPickerOverlayViewController.h"
#import "UIUtils.h"
#import "UIWebViewController.h"
#import "WXWNavigationController.h"
#import "ProfileSettingViewController.h"
#import "UserProfileViewController.h"
#import "UserListViewController.h"
#import "AlumniJoinedGroupListViewController.h"
#import "KnownAlumniListViewController.h"
#import "AttractiveAlumniListViewController.h"
#import "EncryptUtil.h"
#import "Alumni.h"
#import "DMChatterListViewController.h"
#import "WXWLabel.h"

#define SECTION_COUNT         4

#define BASE_INFO_CELL_COUNT  3
#define MORE_INFO_CELL_COUNT  2

#define CELL_HEIGHT         50.0f

#define BTN_HEIGHT          30.0f

#define TITLE_FONT          BOLD_FONT(15)

#define BADGE_TAG           100

#define DOT_RADIUS          5.0f

#define DOT_TAG             200

#define FOOTER_HEIGHT     100.0f

typedef enum{
    UPDATE_SOFT_TYPE = 0,
    CHANGE_AVTOR_TYPE,
} LOGIN_ALERT_TYPE;

enum {
  BASE_INFO_SEC,
  MORE_INFO_SEC,
};

enum {
  BASE_INFO_SEC_DM_CELL,
  BASE_INFO_SEC_GP_CELL,
  BASE_INFO_SEC_FRIENDS_CELL,
};

enum {
  MORE_INFO_SEC_SHARE_CELL,
  MORE_INFO_SEC_SETTING_CELL,
  MORE_INFO_SEC_VERSION_CELL,
  MORE_INFO_SEC_ADV_CELL,
};

enum {
  SHARE_AS_TY,
  TAKE_PHOTO_AS_TY,
};

enum {
	SHARE_SMS_AS_IDX,
	SHARE_WX_AS_IDX,
    SHARE_CANCEL_IDX,
};

@interface MyInfoViewController () <ECPhotoPickerOverlayDelegate, ECItemUploaderDelegate, UIActionSheetDelegate, ECClickableElementDelegate, UIGestureRecognizerDelegate, WXApiDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>

{
    UserProfileHeaderView *_headerView;
    
    UIImagePickerControllerSourceType _photoSourceType;
    
    UITapGestureRecognizer *_tapGesture;
    
    NSInteger _asOwnerType;
    
    BOOL _needRefreshNewDMNumberBadge;
    
    NSInteger _joinedGroupCount;
    
    BOOL _friendsCountLoaded;
    BOOL _joinedGroupCountLoaded;
    
    CGRect _originalFrame;
    CGRect _tableOriginalFrame;
    
}
@end

@interface FriendCell : UITableViewCell {
@private
  
  WXWNumberBadge *_knownBadge;
  WXWNumberBadge *_wantBadge;
  
  UIButton *_openKnownButton;
  
  UIButton *_openWantButton;
}

@end

@implementation FriendCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             target:(id)target
    openKnownAction:(SEL)openKnownAction
     openWantAction:(SEL)openWantAction {
  
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryView = [[[UIImageView alloc] initWithImage:IMAGE_WITH_NAME(@"blueRightArrow.png")] autorelease];
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    
    UIView *backView = [[[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0f, 0, 0.5f, CELL_HEIGHT)] autorelease];
    backView.backgroundColor = COLOR(200, 199, 204);
    [self.contentView addSubview:backView];
    
    _openKnownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _openKnownButton.frame = CGRectMake(0, (CELL_HEIGHT - BTN_HEIGHT)/2.0f, self.frame.size.width/2.0f, BTN_HEIGHT);
    [_openKnownButton addTarget:target action:openKnownAction forControlEvents:UIControlEventTouchUpInside];
    [_openKnownButton setTitle:LocaleStringForKey(NSKnownAlumnusTitle, nil) forState:UIControlStateNormal];
    [_openKnownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _openKnownButton.backgroundColor = [UIColor whiteColor];

    _openKnownButton.titleLabel.font = TITLE_FONT;
    [self.contentView addSubview:_openKnownButton];
    
    UIEdgeInsets titleEdge = ZERO_EDGE;
    CGRect frame = CGRectZero;
    if (CURRENT_OS_VERSION >= IOS7) {
      frame = CGRectMake(108, (BTN_HEIGHT - NUMBER_BADGE_HEIGHT)/2.0f, 0, NUMBER_BADGE_HEIGHT);
    } else {
      frame = CGRectMake(108, (BTN_HEIGHT - NUMBER_BADGE_HEIGHT)/2.0f, 0, NUMBER_BADGE_HEIGHT);
    }
    _openKnownButton.titleEdgeInsets = UIEdgeInsetsMake(0, -50, 0, 0);
    
    _knownBadge = [[[WXWNumberBadge alloc] initWithFrame:frame
                                                topColor:COLOR(204, 204, 204)
                                             bottomColor:COLOR(204, 204, 204)
                                                    font:BOLD_FONT(12)] autorelease];
    [_openKnownButton addSubview:_knownBadge];
    [_knownBadge setNumberWithTitle:NULL_PARAM_VALUE];
    _knownBadge.hidden = YES;
    
    _openWantButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _openWantButton.frame = CGRectMake(_openKnownButton.frame.origin.x + _openKnownButton.frame.size.width + 1.0f,
                                      (CELL_HEIGHT - BTN_HEIGHT)/2.0f, 135, BTN_HEIGHT);
    [_openWantButton addTarget:target action:openWantAction forControlEvents:UIControlEventTouchUpInside];
    [_openWantButton setTitle:LocaleStringForKey(NSWantToKnowAlumniTitle, nil) forState:UIControlStateNormal];
    [_openWantButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _openWantButton.backgroundColor = [UIColor whiteColor];
    _openWantButton.titleLabel.font = TITLE_FONT;
    [self.contentView addSubview:_openWantButton];

    titleEdge = ZERO_EDGE;
    frame = CGRectZero;
    if (CURRENT_OS_VERSION >= IOS7) {
      titleEdge = UIEdgeInsetsMake(0, -25, 0, 0);
      frame = CGRectMake(108, (BTN_HEIGHT - NUMBER_BADGE_HEIGHT)/2.0f, 0, NUMBER_BADGE_HEIGHT);
    } else {
      titleEdge = UIEdgeInsetsMake(0, -35, 0, 0);
      frame = CGRectMake(98, (BTN_HEIGHT - NUMBER_BADGE_HEIGHT)/2.0f, 0, NUMBER_BADGE_HEIGHT);
    }
    
    _openWantButton.titleEdgeInsets = titleEdge;

    _wantBadge = [[[WXWNumberBadge alloc] initWithFrame:frame
                                               topColor:COLOR(204, 204, 204)
                                            bottomColor:COLOR(204, 204, 204)
                                                   font:BOLD_FONT(12)] autorelease];
    [_openWantButton addSubview:_wantBadge];
    [_wantBadge setNumberWithTitle:NULL_PARAM_VALUE];
    _wantBadge.hidden = YES;
    
  }
  return self;
}

- (void)drawCellWithWantCount:(NSNumber *)wantCount knownCount:(NSNumber *)knownCount {
  
  if (wantCount.intValue > 0) {
    _wantBadge.hidden = NO;
    [_wantBadge setNumberWithTitle:STR_FORMAT(@"%@", wantCount)];
  }
  
  if (knownCount.intValue > 0) {
    _knownBadge.hidden = NO;
    [_knownBadge setNumberWithTitle:STR_FORMAT(@"%@", knownCount)];
  }
  
  [_openKnownButton setTitle:LocaleStringForKey(NSKnownAlumnusTitle, nil) forState:UIControlStateNormal];
  [_openWantButton setTitle:LocaleStringForKey(NSWantToKnowAlumniTitle, nil) forState:UIControlStateNormal];
}

- (void)dealloc {
  
  [super dealloc];
}

@end

@interface MyInfoViewController ()
@property (nonatomic, retain) ECPhotoPickerOverlayViewController *pickerOverlayVC;
@property (nonatomic, retain) UIImage *selectedPhoto;
@property (nonatomic, copy) NSString *enterpriseSolutionName;
@end

@implementation MyInfoViewController

#pragma mark - user action

- (void)pushVC:(UIViewController *)vc {
  if (self.parentVC) {
    [self.parentVC.navigationController pushViewController:vc animated:YES];
  }
}

- (void)openKnownAlumnus:(id)sender {
  KnownAlumniListViewController *alumniListVC = [[[KnownAlumniListViewController alloc] initWithMOC:_MOC] autorelease];
  alumniListVC.title = LocaleStringForKey(NSKnownAlumnusTitle, nil);
  
  [self pushVC:alumniListVC];

}

- (void)openWantAlumnus:(id)sender {
  AttractiveAlumniListViewController *alumniListVC = [[[AttractiveAlumniListViewController alloc] initResettedWithMOC:_MOC] autorelease];
  alumniListVC.title = LocaleStringForKey(NSWantToKnowAlumniTitle, nil);
  [self pushVC:alumniListVC];

}

- (void)openJoinedGroups {
  AlumniJoinedGroupListViewController *joinedGroupsVC = [[[AlumniJoinedGroupListViewController alloc] initWithMOC:_MOC alumniPersonId:[AppManager instance].personId userType:[AppManager instance].userType] autorelease];
  joinedGroupsVC.title = LocaleStringForKey(NSJoinedGroupTitle, nil);
  [self pushVC:joinedGroupsVC];
}

- (void)openDMForPush {
  [self openDM];
}

- (void)openDM {
    
  DMChatterListViewController *vc = [[[DMChatterListViewController alloc] initWithMOC:_MOC] autorelease];
  vc.title = LocaleStringForKey(NSShakeChatListTitle, nil);
  
  [self pushVC:vc];
  
  _needRefreshNewDMNumberBadge = YES;
}

- (void)updateNewDMNumberBadgeForPushNotification:(NSNotification *)notification {
  [self setNewDMNumberBadge];
}

- (void)setNewDMNumberBadge {
  
  [self updateCellForSection:BASE_INFO_SEC row:BASE_INFO_SEC_DM_CELL];
  
  if (self.parentVC && [self.parentVC respondsToSelector:@selector(refreshBadges)]) {
    [self.parentVC performSelector:@selector(refreshBadges)];
  }
}

- (void)openProfileSetting:(UITapGestureRecognizer *)gesture {
  ProfileSettingViewController *profileSettingVC = [[[ProfileSettingViewController alloc] initWithMOC:_MOC] autorelease];
  profileSettingVC.title = LocaleStringForKey(NSProfileSettingTitle, nil);
  [self pushVC:profileSettingVC];

}

- (void)openEnterpriseSolution {
  
  UIWebViewController *webVC = [[[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES] autorelease];
  WXWNavigationController *webViewNav = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
  webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:ENTERPRISE_SOLUTION_TY];
  
  [self.parentVC presentModalViewController:webViewNav
                                   animated:YES];
  
  [AppManager instance].hasNewEnterpriseSolution = NO;
  
  [self updateCellForSection:MORE_INFO_SEC row:MORE_INFO_SEC_ADV_CELL];
  
  if (self.parentVC && [self.parentVC respondsToSelector:@selector(refreshBadges)]) {
    [self.parentVC performSelector:@selector(refreshBadges)];
  }

}

- (void)openAppSetting {
  
  UserProfileViewController *vc = [[[UserProfileViewController alloc] initWithMOC:_MOC
                                                                         parentVC:self.parentVC
                                                                 personalEntrance:self
                                                                    refreshAction:@selector(refreshViewForLanguageSwitch)] autorelease];
  vc.title = LocaleStringForKey(NSSettingsTitle, nil);
  [self pushVC:vc];
}

- (void)shareAndInvite {
  UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil] autorelease];
  
  [as addButtonWithTitle:LocaleStringForKey(NSShareBySMSTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSShareByWeixinTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  
  [as showInView:self.view];
  
  _asOwnerType = SHARE_AS_TY;

}

- (void)refreshViewForLanguageSwitch {
  [_tableView reloadData];
}

#pragma mark - load data
- (void)loadConnectedAlumnusCount {
  NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:LOAD_CONNECTED_ALUMNUS_COUNT_TY];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:LOAD_CONNECTED_ALUMNUS_COUNT_TY];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)loadUserDetails
{
  
  NSString *url = [NSString stringWithFormat:@"%@%@&personId=%@&username=%@&sessionId=%@&userType=%@&active_personId=%@", [AppManager instance].hostUrl, ALUMNI_DETAIL_URL, [AppManager instance].personId, [AppManager instance].userId, [AppManager instance].sessionId, [AppManager instance].userType, [AppManager instance].personId];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:ALUMNI_QUERY_DETAIL_TY];
  
  [connFacade fetchGets:url];
}

#pragma mark - life cycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC
{
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStyleGrouped
                                      needGoHome:NO];
  if (self) {
    
    self.parentVC = parentVC;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNewDMNumberBadgeForPushNotification:)
                                                 name:DM_REFRESH_IN_PERSONAL_VIEW_KEY
                                               object:nil];
    
  }
  return self;
}

- (void)dealloc {
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
  
  self.pickerOverlayVC = nil;
  self.selectedPhoto = nil;
  
  _tapGesture.delegate = nil;
  
  self.enterpriseSolutionName = nil;
  
  [super dealloc];
}

- (void)getEnterpriseSolutionName {
  self.enterpriseSolutionName = [CommonUtils fetchStringValueFromLocal:ENTERPRISE_SOLUTION_NAME_LOCAL_KEY];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor blueColor];//COLOR(229, 229, 229);
  _tableView.backgroundColor = COLOR(229, 229, 229);
  
  
  CGRect frame = _tableView.frame;
  frame.size.height = self.view.frame.size.height - HOMEPAGE_TAB_HEIGHT - NAVIGATION_BAR_HEIGHT;
  if (CURRENT_OS_VERSION < IOS7) {
    frame.origin.y -= SYS_STATUS_BAR_HEIGHT;
  }
  
  _tableView.frame = frame;

  _originalFrame = self.view.frame;
  _tableOriginalFrame = _tableView.frame;
  
  [self getEnterpriseSolutionName];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_friendsCountLoaded) {
    [self loadConnectedAlumnusCount];
  }
  
  if (!_joinedGroupCountLoaded) {
    [self loadUserDetails];
  }
  
  // refresh badges
  if (_needRefreshNewDMNumberBadge) {
    [self setNewDMNumberBadge];
    
    _needRefreshNewDMNumberBadge = NO;
  }
    
  self.view.frame = _originalFrame;
  _tableView.frame = _tableOriginalFrame;

  if (self.parentVC && [self.parentVC respondsToSelector:@selector(adjustTabbarForNavigationBarVisible)]) {
    [self.parentVC performSelector:@selector(adjustTabbarForNavigationBarVisible)];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  
  switch (section) {
    case BASE_INFO_SEC:
      return BASE_INFO_CELL_COUNT;
      
    case MORE_INFO_SEC:
      return MORE_INFO_CELL_COUNT;
      
    default:
      return 0;
  }
}

- (UITableViewCell *)drawImageAndTitleCellWithIdentifier:(NSString *)identifier
                                               imageName:(NSString *)imageName
                                                   title:(NSString *)title
                                             badgeNumber:(NSInteger)badgeNumber
                                      badegNeedHighlight:(BOOL)badgeNeedHighlight {
  
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    cell.textLabel.font = TITLE_FONT;
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.accessoryView = [[[UIImageView alloc] initWithImage:IMAGE_WITH_NAME(@"blueRightArrow.png")] autorelease];

    CGFloat x = 0;
    if (CURRENT_OS_VERSION >= IOS7) {
      x = 269.0f;
    } else {
      x = 258.0f;
    }
    
    UIColor *color = nil;
    if (badgeNeedHighlight) {
      color = NUMBER_BADGE_TOP_COLOR;
    } else {
      color = COLOR(204, 204, 204);
    }
    
    WXWNumberBadge *badge = [[[WXWNumberBadge alloc] initWithFrame:CGRectMake(x, (CELL_HEIGHT - NUMBER_BADGE_HEIGHT)/2.0f, 0, NUMBER_BADGE_HEIGHT)
                                                          topColor:color
                                                       bottomColor:color
                                                              font:BOLD_FONT(12)] autorelease];
    badge.tag = BADGE_TAG;
    [cell.contentView addSubview:badge];
  }
  
  WXWNumberBadge *badge = (WXWNumberBadge *)[cell.contentView viewWithTag:BADGE_TAG];
  if (badgeNumber > 0) {
    badge.hidden = NO;
    [badge setNumberWithTitle:STR_FORMAT(@"%d", badgeNumber)];
  } else {
    badge.hidden = YES;
  }
  
  cell.detailTextLabel.text = @"test";
  
  if (imageName.length > 0) {
    cell.imageView.image = IMAGE_WITH_NAME(imageName);
  }
  
  cell.textLabel.text = title;
  
  return cell;
}

- (FriendCell *)drawFriendsCell {
  static NSString *kCellIdentifier = @"friendCell";
  FriendCell *cell = (FriendCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:kCellIdentifier
                                       target:self
                              openKnownAction:@selector(openKnownAlumnus:)
                               openWantAction:@selector(openWantAlumnus:)] autorelease];
  }
  
  [cell drawCellWithWantCount:[AppManager instance].wantToKnowAlumnusCount
                   knownCount:[AppManager instance].knownAlumnusCount];
  
  return cell;
}

- (UITableViewCell *)drawBaseInfoCellsForIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.row) {
    case BASE_INFO_SEC_DM_CELL:
      return [self drawImageAndTitleCellWithIdentifier:@"baseInfoDMCell"
                                             imageName:@"blueDM.png"
                                                 title:LocaleStringForKey(NSDMTitle, nil)
                                           badgeNumber:[AppManager instance].msgNumber.intValue
                                    badegNeedHighlight:YES];
      
    case BASE_INFO_SEC_GP_CELL:
      return [self drawImageAndTitleCellWithIdentifier:@"baseInfoFriendsCell"
                                             imageName:@"blueFriends.png"
                                                 title:LocaleStringForKey(NSGroupsTitle, nil)
                                           badgeNumber:_joinedGroupCount
                                    badegNeedHighlight:NO];
      
    case BASE_INFO_SEC_FRIENDS_CELL:
      return [self drawFriendsCell];
      
    default:
      return nil;
  }
}

- (UITableViewCell *)drawPlainImageTitleCellWithImageName:(NSString *)imageName
                                                    title:(NSString *)title
                                           cellIdentifier:(NSString *)cellIdentifier
                                              showNewFlag:(BOOL)showNewFlag
                                                indexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    cell.textLabel.font = TITLE_FONT;
    cell.textLabel.numberOfLines = 0;
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryView = [[[UIImageView alloc] initWithImage:IMAGE_WITH_NAME(@"blueRightArrow.png")] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat x = 265.0f;
    if (CURRENT_OS_VERSION >= IOS7) {
      x = 280.0f;
    }
    UIView *dot = [[[UIView alloc] initWithFrame:CGRectMake(x, 0, DOT_RADIUS * 2, DOT_RADIUS * 2)] autorelease];
    dot.tag = DOT_TAG;
    dot.backgroundColor = NAVIGATION_BAR_COLOR;
    dot.layer.cornerRadius = DOT_RADIUS;
    [cell.contentView addSubview:dot];
    dot.hidden = YES;
  }
  
  CGSize size = [CommonUtils sizeForText:title
                                    font:TITLE_FONT
                       constrainedToSize:CGSizeMake(220, CGFLOAT_MAX)
                           lineBreakMode:BREAK_BY_WORD_WRAPPING];
  cell.textLabel.text = title;
  cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x,
                                    cell.textLabel.frame.origin.y,
                                    size.width, size.height);
  cell.imageView.image = IMAGE_WITH_NAME(imageName);
  
  UIView *dot = [cell.contentView viewWithTag:DOT_TAG];
  if (showNewFlag) {
    CGFloat cellHeight = [self tableView:_tableView heightForRowAtIndexPath:indexPath];
    CGFloat y = (cellHeight - dot.frame.size.height)/2.0f;
    dot.frame = CGRectMake(dot.frame.origin.x, y, dot.frame.size.width, dot.frame.size.height);
    dot.hidden = NO;
  } else {
    dot.hidden = YES;
  }
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case BASE_INFO_SEC:
      return [self drawBaseInfoCellsForIndexPath:indexPath];
      
    case MORE_INFO_SEC:
      switch (indexPath.row) {
        case MORE_INFO_SEC_SHARE_CELL:
          return [self drawPlainImageTitleCellWithImageName:@"grayShare.png"
                                                      title:LocaleStringForKey(NSShareAndInviteTitle, nil)
                                             cellIdentifier:@"shareCell"
                                                showNewFlag:NO
                                                  indexPath:indexPath];
        
        case MORE_INFO_SEC_ADV_CELL:
          return [self drawPlainImageTitleCellWithImageName:@"grayProposal.png"
                                                      title:self.enterpriseSolutionName
                                             cellIdentifier:@"proposalCell"
                                                showNewFlag:[AppManager instance].hasNewEnterpriseSolution
                                                  indexPath:indexPath];
          
        case MORE_INFO_SEC_SETTING_CELL:
          return [self drawPlainImageTitleCellWithImageName:@"graySetting.png"
                                                      title:LocaleStringForKey(NSSettingsTitle, nil)
                                             cellIdentifier:@"settingCell"
                                                showNewFlag:NO
                                                  indexPath:indexPath];
              
        case MORE_INFO_SEC_VERSION_CELL:
          {
              UITableViewCell *cell = [self drawPlainImageTitleCellWithImageName:@"lastVersion.png"
                                                          title:LocaleStringForKey(NSVersionTitle, nil)
                                                 cellIdentifier:@"updateVersionCell"
                                                    showNewFlag:NO
                                                      indexPath:indexPath];

              WXWLabel *versionLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(240, 10, 60, 30) textColor:[UIColor blackColor] shadowColor:TRANSPARENT_COLOR] autorelease];
              versionLabel.font = BOLD_FONT(13);
              versionLabel.text = [NSString stringWithFormat:@"V%@", VERSION];
              [cell.contentView addSubview:versionLabel];
              
              return cell;
          }
              
        default:
          return nil;
      }
      
    default:
      return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  switch (section) {
    case BASE_INFO_SEC:
      return USERDETAIL_PHOTO_HEIGHT + PHOTO_MARGIN * 2 + MARGIN * 4;
      
    default:
      return 0;
  }
}

- (UIView *)sectionHeaderView {
  
  if (nil == _headerView) {
    _headerView = [[UserProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          self.view.frame.size.width,
                                                                          USERDETAIL_PHOTO_HEIGHT + PHOTO_MARGIN * 2 + MARGIN * 4)
                                        imageDisplayerDelegate:self
                                      clickableElementDelegate:self
                                                        target:self
                                                        action:@selector(changeAvatar:)];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(openProfileSetting:)] autorelease];
    _tapGesture.delegate = self;
    [_headerView addGestureRecognizer:_tapGesture];
  }
  
  return _headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  switch (section) {
    case BASE_INFO_SEC:
      return [self sectionHeaderView];
      
    default:
      return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  switch (indexPath.section) {
    case BASE_INFO_SEC:
      return CELL_HEIGHT;
      
    case MORE_INFO_SEC:
    {
      switch (indexPath.row) {
          
        case MORE_INFO_SEC_ADV_CELL:
        {
          CGSize size = [CommonUtils sizeForText:self.enterpriseSolutionName
                                            font:TITLE_FONT
                               constrainedToSize:CGSizeMake(220, CGFLOAT_MAX)
                                   lineBreakMode:BREAK_BY_WORD_WRAPPING];
          CGFloat height = size.height + MARGIN * 4;
          return height < CELL_HEIGHT ? CELL_HEIGHT : height;
          break;
        }
        default:
          return CELL_HEIGHT;
      }
    }
      
    default:
      return CELL_HEIGHT;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.section) {
    case BASE_INFO_SEC:
    {
      switch (indexPath.row) {
        case BASE_INFO_SEC_DM_CELL:
          [self openDM];
          break;
          
        case BASE_INFO_SEC_GP_CELL:
          [self openJoinedGroups];
          break;
          
        default:
          break;
      }
      break;
    }
      
    case MORE_INFO_SEC:
    {
      switch (indexPath.row) {
        case MORE_INFO_SEC_SHARE_CELL:
          [self shareAndInvite];
          break;
          
        case MORE_INFO_SEC_ADV_CELL:
          [self openEnterpriseSolution];
          break;
          
        case MORE_INFO_SEC_SETTING_CELL:
          [self openAppSetting];
          break;
        
        case MORE_INFO_SEC_VERSION_CELL:
          [self checkSoftVersion];
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


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case MORE_INFO_SEC:
        return FOOTER_HEIGHT;
        
        default:
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch (section) {
        
        case MORE_INFO_SEC:
        {
            UIView *_footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FOOTER_HEIGHT)];
            _footerView.backgroundColor = TRANSPARENT_COLOR;
            
            WXWLabel *infoLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                         textColor:BASE_INFO_COLOR
                                                       shadowColor:[UIColor blackColor]] autorelease];
            infoLabel.font = BOLD_FONT(12);
            infoLabel.text = [NSString stringWithFormat:@"协会帮提供支持"];
            infoLabel.shadowColor = [UIColor clearColor];
            [_footerView addSubview:infoLabel];
            CGSize size = [infoLabel.text sizeWithFont:infoLabel.font
                                     constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                                         lineBreakMode:NSLineBreakByWordWrapping];
            infoLabel.frame = CGRectMake((self.view.frame.size.width - size.width) / 2.0f,
                                         FOOTER_HEIGHT - 60,
                                         size.width, size.height);
            
            return _footerView;
            
        }
        
        default:
        return nil;
    }
}

#pragma mark - update cell

- (void)updateCellForIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath == nil) {
    return;
  }
  
  [_tableView beginUpdates];
  
  [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                    withRowAnimation:UITableViewRowAnimationNone];
  [_tableView endUpdates];
}

- (void)updateFriendsCell {
  [self updateCellForIndexPath:[NSIndexPath indexPathForRow:BASE_INFO_SEC_FRIENDS_CELL
                                                  inSection:BASE_INFO_SEC]];
}

- (void)updateJoinedGroupCell {
  [self updateCellForIndexPath:[NSIndexPath indexPathForRow:BASE_INFO_SEC_GP_CELL
                                                  inSection:BASE_INFO_SEC]];
}

- (void)updateCellForSection:(NSInteger)section row:(NSInteger)row {
  [self updateCellForIndexPath:[NSIndexPath indexPathForRow:row
                                                  inSection:section]];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
          
      case CHECK_VERSION_TY:
      {
          ReturnCode ret = [XMLParser handleSoftMsg:result MOC:_MOC];
          
          switch (ret) {
              case RESP_OK:
              {
                  ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSLastestVersionTitle, nil), LocaleStringForKey(NSSureTitle, nil));
              }
                  break;
                  
              case SOFT_UPDATE_CODE:
              {
                  _alertType = UPDATE_SOFT_TYPE;
                  ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle, nil),[AppManager instance].softDesc, LocaleStringForKey(NSSureTitle, nil));
                  break;
              }
                  
              case ERR_CODE:
              {
                  [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSNetworkUnstableMsg, nil)
                                                msgType:ERROR_TY
                                     belowNavigationBar:YES];
                  
                  break;
              }
                  
              default:
                  break;
          }
          
          break;
      }
          
    case MODIFY_USER_ICON_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        
        [_headerView updateAvatar:self.selectedPhoto];
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSUpdatePhotoDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSUpdatePhotoFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
      
    case LOAD_CONNECTED_ALUMNUS_COUNT_TY:
    {
      [XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url];
      
      _friendsCountLoaded = YES;
      
      [self updateFriendsCell];
      break;
    }
      
    case ALUMNI_QUERY_DETAIL_TY:
    {
      NSData *decryptedData = [EncryptUtil TripleDESforNSData:result encryptOrDecrypt:kCCDecrypt];
      if ([XMLParser parserResponseXml:decryptedData
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        _autoLoaded = YES;
        
        Alumni *alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                             entityName:@"Alumni"
                                                              predicate:[NSPredicate predicateWithFormat:@"personId == %@", [AppManager instance].personId]];
        if (alumni != nil) {
          _joinedGroupCount = alumni.joinedGroupCount.intValue;
          [self updateJoinedGroupCell];
        }
        
        _joinedGroupCountLoaded = YES;
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSGetUserDetialFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
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
    case MODIFY_USER_ICON_TY:
    {
      msg = LocaleStringForKey(NSUpdatePhotoFailedMsg, nil);
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

#pragma mark - change photo

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
  
  _photoSourceType = sourceType;
  
  self.pickerOverlayVC = [[[ECPhotoPickerOverlayViewController alloc] initWithSourceType:_photoSourceType
                                                                                delegate:self
                                                                        uploaderDelegate:self
                                                                               takerType:USER_AVATAR_TY
                                                                                     MOC:_MOC] autorelease];
  
  [self.pickerOverlayVC arrangeViews];
  
  if (self.parentVC) {
    [self.parentVC presentModalViewController:self.pickerOverlayVC.imagePicker
                                     animated:YES];
  }
}

- (void)changeAvatar:(id)sender {
  
    _alertType = CHANGE_AVTOR_TYPE;
    UIAlertView *pswdAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(NSNoteTitle, nil) message:NSLocalizedString(NSAvatarTitle, nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    
    [pswdAlert show];
    
}

#pragma mark - ECPhotoPickerOverlayDelegate methods

- (void)applyPhotoSelectedStatus:(UIImage *)image {
  
	self.selectedPhoto = image;
  
  // upload new avatar
  self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                               interactionContentType:MODIFY_USER_ICON_TY] autorelease];
  
  [self.connFacade modifyUserIcon:self.selectedPhoto];
}

- (void)checkSoftVersion {
    NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:CHECK_VERSION_TY];
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:CHECK_VERSION_TY] autorelease];
    [connFacade fetchGets:url];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)saveImageIfNecessary:(UIImage *)image
                  sourceType:(UIImagePickerControllerSourceType)sourceType {
  if (sourceType == UIImagePickerControllerSourceTypeCamera) {
    
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	}
}

- (void)handleFinishPickImage:(UIImage *)image
                   sourceType:(UIImagePickerControllerSourceType)sourceType {
  UIImage *handledImage = [CommonUtils scaleAndRotateImage:image sourceType:sourceType];
	
  [self saveImageIfNecessary:handledImage sourceType:sourceType];
	
	[self applyPhotoSelectedStatus:handledImage];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
	
  [self handleFinishPickImage:image
                   sourceType:picker.sourceType];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
  if (self.parentVC) {
    [self.parentVC.navigationController dismissModalViewControllerAnimated:YES];
  }
}

#pragma mark - ECPhotoPickerDelegate method
- (void)selectPhoto:(UIImage *)selectedImage {
  if (_photoSourceType == UIImagePickerControllerSourceTypeCamera) {
    UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
  }
  
  [self applyPhotoSelectedStatus:selectedImage];
}

#pragma mark - ECPhotoPickerOverlayDelegate
- (void)didTakePhoto:(UIImage *)photo {
  [self selectPhoto:photo];
}

- (void)didFinishWithCamera {
  //self.pickerOverlayVC = nil;
}

- (void)adjustUIAfterUserBrowseAlbumInImagePicker {
  // user browse the album in image picker, so UI layout be set as full screen, then we should recovery
  // the layout corresponding
  [UIApplication sharedApplication].statusBarHidden = NO;
  self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0f, 20.0f);
  self.view.frame = CGRectOffset(self.view.frame, 0.0f, 20.0f);
}

#pragma mark - ECItemUploaderDelegate method
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
}

#pragma mark - UIAlertView Delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (_alertType) {
            
        case UPDATE_SOFT_TYPE:
        {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager instance].softUrl]];
            
            break;
        }
            
        case CHANGE_AVTOR_TYPE:
        {
            UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil] autorelease];
            
            if (HAS_CAMERA) {
                [as addButtonWithTitle:LocaleStringForKey(NSTakePhotoTitle, nil)];
                [as addButtonWithTitle:LocaleStringForKey(NSChooseExistingPhotoTitle, nil)];
            } else {
                [as addButtonWithTitle:LocaleStringForKey(NSChooseExistingPhotoTitle, nil)];
            }
            
            [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
            as.cancelButtonIndex = [as numberOfButtons] - 1;
            
            [as showInView:self.view];
            
            _asOwnerType = TAKE_PHOTO_AS_TY;
            break;
        }
            
        default:
            break;
    }

}

#pragma mark - UIActionSheet Delegate method
- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_asOwnerType) {
    case TAKE_PHOTO_AS_TY:
    {
      if (HAS_CAMERA) {
        switch (buttonIndex) {
          case PHOTO_ACTION_SHEET_IDX:
            [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
            break;
            
          case LIBRARY_ACTION_SHEET_IDX:
            [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
          case CANCEL_PHOTO_SHEET_IDX:
            return;
            
          default:
            break;
        }
      } else {
        switch (buttonIndex) {
          case 0:
            [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
          case 1:
            return;
            
          default:
            break;
        }
      }

      break;
    }
      
    case SHARE_AS_TY:
    {
      switch (buttonIndex) {
        case SHARE_SMS_AS_IDX:
          [self shareBySMS];
          break;
          
        case SHARE_WX_AS_IDX:
          if ([WXApi isWXAppInstalled]) {
            ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = self;
            
            NSString *url = [NSString stringWithFormat:CONFIGURABLE_DOWNLOAD_URL,
                             [AppManager instance].hostUrl,
                             [WXWSystemInfoManager instance].currentLanguageDesc,
                             [AppManager instance].releaseChannelType];
            
            [CommonUtils shareByWeChat:WXSceneSession
                                 title:LocaleStringForKey(NSAppRecommendTitle, nil)
                           description:[AppManager instance].recommend
                                   url:url];
          } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:LocaleStringForKey(NSNoWeChatMsg, nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocaleStringForKey(NSDonotInstallTitle, nil)
                                                  otherButtonTitles:LocaleStringForKey(NSInstallTitle, nil), nil];
            [alert show];
            [alert release];
          }
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

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  
  if ([touch.view isKindOfClass:[UIButton class]]) {
    return NO;
  } else {
    return YES;
  }
}

#pragma mark - share app
- (void)shareBySMS {
  if (![MFMessageComposeViewController canSendText]) {
    ShowAlertWithOneButton(self,LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSNoSupportTitle, nil), LocaleStringForKey(NSOKTitle, nil));
    return;
  }
  
  MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
  controller.body = [AppManager instance].recommend;
  controller.recipients = @[NULL_PARAM_VALUE];
  controller.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)self;
  
  if (self.parentVC) {
    [self.parentVC.navigationController presentModalViewController:controller animated:YES];
  }
}

#pragma mark - WXApiDelegate methods
-(void) onResp:(BaseResp*)resp
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

#pragma mark - MFMessageComposeViewControllerDelegate method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
  //NSString *backMsg;
  
  switch (result) {
    case MessageComposeResultSent:
      //backMsg = @"Success";
      break;
    case MessageComposeResultCancelled:
      //backMsg = @"Cancelled";
      break;
    case MessageComposeResultFailed:
      //backMsg = @"Failure";
      break;
    default:
      break;
  }
  
  if (self.parentVC) {
    [self.parentVC dismissModalViewControllerAnimated:YES];
  }
}

@end
