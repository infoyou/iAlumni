//
//  AlumniEntranceViewController.m
//  iAlumni
//
//  Created by Adam on 13-1-16.
//
//

#import "AlumniEntranceViewController.h"
#import "AlumniExampleCell.h"
#import "AlumniEntranceItemCell.h"
#import "SearchAlumniViewController.h"
#import "UserListViewController.h"
#import "KnownAlumniListViewController.h"
#import "AttractiveAlumniListViewController.h"
#import "ShakeForNameCardViewController.h"
#import "News.h"
#import "UIWebViewController.h"
#import "WXWNavigationController.h"
#import "NearbyEntranceViewController.h"
#import "FriendCategoryViewController.h"
#import "ProfileSettingViewController.h"
#import "SupplyDemandListViewController.h"

#define NEWS_CELL_COUNT    3

#define GRID_HEIGHT       100
#define GRID_CELL_HEIGHT  GRID_HEIGHT + MARGIN * 2

#define NEWS_AREA_35INCH_HEIGHT   150.0f
#define NEWS_AREA_40INCH_HEIGHT   238.0f

#define TABLE_35INCH_OFFSET  132.0f
#define TABLE_40INCH_OFFSET  132.0f + 88.0f

enum {
  NEWS_CELL,
  ALUMNI_CONTACT_CELL,
  ALUMNI_EXCHANGE_CELL,
  //ALUMNI_CONNECT_CELL,
};


@interface AlumniEntranceViewController ()

@end

@implementation AlumniEntranceViewController

#pragma mark - adjust layout for no alumni news
- (void)arrangeLayoutForNoAlumniNews:(NSNotification *)notification {
  _noAlumniNews = YES;
  
  [_tableView reloadData];

  _tableView.frame = CGRectOffset(_tableView.frame,
                                  _tableView.frame.origin.x,
                                  _tableView.frame.origin.y + MARGIN * 2);  
}

#pragma mark - lifecycle methods

- (void)addNoAlumniNewsNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(arrangeLayoutForNoAlumniNews:)
                                               name:NO_ALUMNI_NEWS_NOTIFY
                                             object:nil];
  
}


- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
         parentVC:(UIViewController *)parentVC
refreshBadgesAction:(SEL)refreshBadgesAction {
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
    
    _refreshBadgesAction = refreshBadgesAction;
    
    _noNeedBackButton = YES;
    
    [self addNoAlumniNewsNotification];
  }
  return self;
}

- (void)dealloc {
  
  // stop alumni news wall scroll view loading
  [[NSNotificationCenter defaultCenter] postNotificationName:CONN_CANCELL_NOTIFY
                                                      object:self
                                                    userInfo:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NO_ALUMNI_NEWS_NOTIFY
                                                object:nil];
  [super dealloc];
}

- (void)adjustTableLayout {
  self.view.frame = CGRectMake(0,
                               0,
                               self.view.frame.size.width,
                               _viewHeight);
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                _tableView.frame.origin.y,
                                _tableView.frame.size.width,
                                _viewHeight);
  
  _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad
{    
  [super viewDidLoad];
  
    if (self.parentVC) {
        self.parentVC.navigationItem.rightBarButtonItem = nil;
    }
    
  [self adjustTableLayout];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // reset the badge for friend entrance block
  [self refreshDMItemView];
  
  // reset the badge for tab
  if (self.parentVC && [self.parentVC respondsToSelector:@selector(refreshTabItems)]) {
    [self.parentVC performSelector:@selector(refreshTabItems)];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ScrollAutoPlayerDelegate methods
- (void)play {
  [_exampleCell play];
}

- (void)stopPlay {
  [_exampleCell stopPlay];
}

#pragma mark - draw cell

- (void)refreshDMItemView {
  
  [_tableView beginUpdates];
  [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:ALUMNI_EXCHANGE_CELL
                                                                                 inSection:0]]
                    withRowAnimation:UITableViewRowAnimationNone];
  [_tableView endUpdates];
  
}

- (UITableViewCell *)drawExampleCell {
  static NSString *cellIdentifier = @"exampleCell";
  AlumniExampleCell *cell = (AlumniExampleCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[AlumniExampleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellIdentifier
                              imageDisplayerDelegate:self
                     connectionTriggerHolderDelegate:self
                                                 MOC:_MOC
                                            entrance:self
                                              action:@selector(clickExampleArea:)] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  _exampleCell = cell;
  
  return cell;
}

- (void)setContactCellInfoWithLeftImage:(UIImage **)leftImage
                                  leftTitle:(NSString **)leftTitle
                               leftSubTitle:(NSString **)leftSubTitle
                                 leftAction:(SEL *)leftAction
                           rightNumberBadge:(NSInteger *)rightNumberBadge
                             rightImage:(UIImage **)rightImage
                                 rightTitle:(NSString **)rightTitle
                              rightSubTitle:(NSString **)rightSubTitle
                                rightAction:(SEL *)rightAction {
  
  *leftImage = [UIImage imageNamed:@"whiteSearch_60.png"];
  *leftTitle = LocaleStringForKey(NSAlumniSearchTitle, nil);
  *leftAction = @selector(openAlumniSearch);
  
  *rightImage = [UIImage imageNamed:@"goodFriends.png"];
  *rightTitle = LocaleStringForKey(NSFriendsTitle, nil);
  *rightAction = @selector(openFriends);
}

- (void)setConnectCellInfoWithLeftImage:(UIImage **)leftImage
                              leftTitle:(NSString **)leftTitle
                           leftSubTitle:(NSString **)leftSubTitle
                             leftAction:(SEL *)leftAction
                       rightNumberBadge:(NSInteger *)rightNumberBadge
                             rightImage:(UIImage **)rightImage
                             rightTitle:(NSString **)rightTitle
                          rightSubTitle:(NSString **)rightSubTitle
                            rightAction:(SEL *)rightAction {
  
  *leftImage = [UIImage imageNamed:@"profileSetting.png"];
  *leftTitle = LocaleStringForKey(NSProfileSettingTitle, nil);
  *leftAction = @selector(openProfileSetting);
  
  *rightImage = [UIImage imageNamed:@"whiteMap_60.png"];
  *rightTitle = LocaleStringForKey(NSNearbyTitle, nil);
  *rightAction = @selector(openNearbyAlumnus);

}

- (void)setExchangeCellInfoWithLeftImage:(UIImage **)leftImage
                              leftTitle:(NSString **)leftTitle
                           leftSubTitle:(NSString **)leftSubTitle
                             leftAction:(SEL *)leftAction
                       rightNumberBadge:(NSInteger *)rightNumberBadge
                             rightImage:(UIImage **)rightImage
                             rightTitle:(NSString **)rightTitle
                          rightSubTitle:(NSString **)rightSubTitle
                            rightAction:(SEL *)rightAction {
  
  *leftImage = [UIImage imageNamed:@"profileSetting.png"];
  *leftTitle = LocaleStringForKey(NSProfileSettingTitle, nil);
  *leftAction = @selector(openProfileSetting);
  
  *rightImage = [UIImage imageNamed:@"homepageDM.png"];
  *rightTitle = LocaleStringForKey(NSDMTitle, nil);
  *rightAction = @selector(openDM);
  
  *rightNumberBadge = [AppManager instance].msgNumber.intValue;
}

- (void)drawNoNewsCells:(NSIndexPath *)indexPath {
  
}

- (UITableViewCell *)drawItemCell:(NSIndexPath *)indexPath {
  
  NSString *cellIdentifier = [NSString stringWithFormat:@"cell_%d", indexPath.row];
  
  AlumniEntranceItemCell *cell = (AlumniEntranceItemCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  if (nil == cell) {
    cell = [[[AlumniEntranceItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellIdentifier] autorelease];
  }
  
  UIImage *leftImage = nil;
  UIImage *rightImage = nil;
  
  NSString *leftTitle = NULL_PARAM_VALUE;
  NSString *rightTitle = NULL_PARAM_VALUE;
  
  NSString *leftSubTitle = NULL_PARAM_VALUE;
  NSString *rightSubTitle = NULL_PARAM_VALUE;
  
  NSInteger rightNumberBadge = 0;
  
  SEL leftAction = nil;
  SEL rightAction = nil;
  
  UIColor *leftColor = nil;
  UIColor *rightColor = nil;
  
    switch (indexPath.row) {
      case ALUMNI_CONTACT_CELL:
      {
        [self setContactCellInfoWithLeftImage:&leftImage
                                    leftTitle:&leftTitle
                                 leftSubTitle:&leftSubTitle
                                   leftAction:&leftAction
                             rightNumberBadge:nil
                                   rightImage:&rightImage
                                   rightTitle:&rightTitle
                                rightSubTitle:&rightSubTitle
                                  rightAction:&rightAction];
        leftColor = COLOR(107, 196, 234);
        rightColor = COLOR(91, 182, 93);
        
        break;
      }
        
      case ALUMNI_EXCHANGE_CELL:
      {
        [self setExchangeCellInfoWithLeftImage:&leftImage
                                     leftTitle:&leftTitle
                                  leftSubTitle:&leftSubTitle
                                    leftAction:&leftAction
                              rightNumberBadge:&rightNumberBadge
                                    rightImage:&rightImage
                                    rightTitle:&rightTitle
                                 rightSubTitle:&rightSubTitle
                                   rightAction:&rightAction];
        
        leftColor = COLOR(255, 111, 73);
        rightColor = COLOR(255, 186, 77);

        break;
      }
      default:
        break;
    }
  
  [cell drawLeftItem:indexPath.row
               image:leftImage
               title:leftTitle
            subTitle:leftSubTitle
         numberBadge:0
            entrance:self
              action:leftAction
               color:leftColor];
  
  [cell drawRightItem:indexPath.row
                image:rightImage
                title:rightTitle
             subTitle:rightSubTitle
          numberBadge:rightNumberBadge
             entrance:self
               action:rightAction
                color:rightColor];
  
  return cell;
}

#pragma mark - user actions
- (void)openAlumniNews:(News *)news {
  if (news) {
    UIWebViewController *webVC = [[[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES] autorelease];
    WXWNavigationController *webViewNav = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
    webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
    webVC.strUrl = news.url;
    
    [self.parentVC presentModalViewController:webViewNav
                                 animated:YES];
  }
}


- (void)clickExampleArea:(News *)news {

  [self openAlumniNews:news];
  
  /*
  NearbyEntranceViewController *nearbyEntranceVC = [[[NearbyEntranceViewController alloc] initWithMOC:_MOC] autorelease];
  
  nearbyEntranceVC.title = LocaleStringForKey(NSAlumniCouponTitle, nil);
  [self pushVC:nearbyEntranceVC];
   */
}

- (void)pushVC:(WXWRootViewController *)vc {
  [_exampleCell stopPlay];
  
  if (self.parentVC) {
    [self.parentVC.navigationController pushViewController:vc animated:YES];
  }
}

- (void)openAlumniSearch {
  
  SearchAlumniViewController *searchVC = [[[SearchAlumniViewController alloc] initWithMOC:_MOC needAdjustForiOS7:NO] autorelease];
  searchVC.title = LocaleStringForKey(NSAlumniSearchTitle, nil);
  
  [self pushVC:searchVC];
}

- (void)openDM {
  DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", nil);
  
  UserListViewController *userListVC = [[[UserListViewController alloc] initWithType:CHAT_USER_LIST_TY needGoToHome:NO MOC:_MOC group:nil needAdjustForiOS7:NO] autorelease];
  userListVC.pageIndex = 0;
  userListVC.requestParam = [NSString stringWithFormat:@"<page>0</page><page_size>30</page_size>"];
  userListVC.title = LocaleStringForKey(NSShakeChatListTitle, nil);

  [self pushVC:userListVC];
  
  if (self.parentVC && _refreshBadgesAction) {
    [self.parentVC performSelector:_refreshBadgesAction];
  }
}

- (void)openFriends {
  FriendCategoryViewController *friendsVC = [[[FriendCategoryViewController alloc] initWithMOC:_MOC] autorelease];
  friendsVC.title = LocaleStringForKey(NSFriendsTitle, nil);

  [self pushVC:friendsVC];
}

- (void)openProfileSetting {
  ProfileSettingViewController *profileSettingVC = [[[ProfileSettingViewController alloc] initWithMOC:_MOC] autorelease];
  profileSettingVC.title = LocaleStringForKey(NSProfileSettingTitle, nil);
  [self pushVC:profileSettingVC];
}

- (void)openKnownAlumnus {
  KnownAlumniListViewController *alumniListVC = [[[KnownAlumniListViewController alloc] initWithMOC:_MOC] autorelease];
  alumniListVC.title = LocaleStringForKey(NSKnownAlumnusTitle, nil);
  
  [self pushVC:alumniListVC];
}

- (void)openSupplyDemand {
  SupplyDemandListViewController *supplyDemandListVC = [[[SupplyDemandListViewController alloc] initWithMOC:_MOC needAdjustForiOS7:NO] autorelease];
  supplyDemandListVC.title = LocaleStringForKey(NSAllSupplyDemandTitle, nil);
  [self pushVC:supplyDemandListVC];
}

- (void)openWantKnowAlumnus {
  AttractiveAlumniListViewController *alumniListVC = [[[AttractiveAlumniListViewController alloc] initResettedWithMOC:_MOC] autorelease];
  alumniListVC.title = LocaleStringForKey(NSWantToKnowAlumniTitle, nil);
  [self pushVC:alumniListVC];
}

- (void)openShakeNamecard {
  ShakeForNameCardViewController *exchangeNameCardVC = [[[ShakeForNameCardViewController alloc] initWithMOC:_MOC] autorelease];
  exchangeNameCardVC.title = LocaleStringForKey(NSShakeNameCardTitle, nil);
  
  [self pushVC:exchangeNameCardVC];
}

- (void)openNearbyAlumnus {
  
  NearbyEntranceViewController *nearbyEntranceVC = [[[NearbyEntranceViewController alloc] initWithMOC:_MOC] autorelease];
  
  nearbyEntranceVC.title = LocaleStringForKey(NSNearbyTitle, nil);
  
  [self pushVC:nearbyEntranceVC];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  return NEWS_CELL_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.row) {
    case NEWS_CELL:
    {
      UITableViewCell *cell = [self drawExampleCell];
      if (_noAlumniNews) {
        cell.hidden = YES;
      } else {
        cell.hidden = NO;
      }
      
      return cell;
    }
    default:
      return [self drawItemCell:indexPath];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case NEWS_CELL:
    {
      if (_noAlumniNews) {
        return 0;
      } else {
        return NEWS_AREA_35INCH_HEIGHT + MARGIN * 4;
      }
    }
    default:
      return GRID_CELL_HEIGHT;
  }

}

@end
