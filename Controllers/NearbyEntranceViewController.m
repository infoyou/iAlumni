//
//  NearbyEntranceViewController.m
//  iAlumni
//
//  Created by Adam on 12-9-11.
//
//

#import "NearbyEntranceViewController.h"
#import "BrandsViewController.h"
#import "ECAsyncConnectorFacade.h"
#import "Shake.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "WinnerHeaderView.h"
#import "AlumniProfileViewController.h"
#import "PeopleWithDistanceCell.h"
#import "Alumni.h"
#import "ChatListViewController.h"
#import "BrandCell.h"
#import "Brand.h"
#import "BrandDetailViewController.h"
#import "VenueListViewController.h"
#import "DMChatViewController.h"

#define BUTTON_WIDTH  150.0f
#define BUTTON_HEIGHT 50.0f

#define NAME_LIMITED_WIDTH    144.0f
#define PHOTO_WIDTH           56.0f

#define HEADER_HEIGHT   40.0f

#define CONTACT_BTN_HEIGHT  40.0f

// benifts stuff
#define BRAND_CELL_HEIGHT   80.0f
#define LIMITED_WIDTH       220.0f
#define COUPON_INFO_HEIGHT  15.0f

#define ALUMNI_SECTION_COUNT    2
#define BENIFITS_SECTION_COUNT  1

enum {
  NEARBY_ALUMNI_TY,
  NEARBY_BENEFITS_TY,
};

enum {
  WINNER_SEC,
  ALUMNI_SEC,
};

@interface NearbyEntranceViewController ()
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation NearbyEntranceViewController

#pragma mark - load data

- (void)configureFetchAlumni {
  self.entityName = @"Alumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
}

- (void)configureFetchBrands {
  self.entityName = @"Brand";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"brandId" ascending:YES] autorelease];
  [self.descriptors addObject:sortDesc];
}

- (void)configureMOCFetchConditions {
  
  switch (_tapIndex) {
    case NEARBY_ALUMNI_TY:
      [self configureFetchAlumni];
      break;
      
    case NEARBY_BENEFITS_TY:
      [self configureFetchBrands];
      break;
      
    default:
      break;
  }
}

- (void)doLoadWithParam:(NSString *)param {
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

- (void)loadAlumniForNew:(BOOL)forNew {
  
  _currentType = SHAKE_USER_LIST_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSInteger refreshOnlyFlag = _userRefreshList ? 0 : 1;
  
  NSString *param = [NSString stringWithFormat:@"<refresh_only>%d</refresh_only><longitude>%f</longitude><latitude>%f</latitude><distance_scope>50</distance_scope><time_scope></time_scope><order_by_column>datetime</order_by_column><is_for_namecard>0</is_for_namecard><shake_where></shake_where><shake_what></shake_what><page>%d</page><page_size>%@</page_size>", refreshOnlyFlag, [AppManager instance].longitude, [AppManager instance].latitude, index, ITEM_LOAD_COUNT];
  
  [self doLoadWithParam:param];
}

- (void)loadBrandsForNew:(BOOL)forNew {
  
  _currentType = LOAD_BRANDS_TY;
  
  NSString *param = [NSString stringWithFormat:@"<start_index>0</start_index><count>1000</count><category_id></category_id><longitude>%f</longitude><latitude>%f</latitude>", [AppManager instance].longitude, [AppManager instance].latitude];
  
  [self doLoadWithParam:param];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  switch (_tapIndex) {
    case NEARBY_ALUMNI_TY:
      [self loadAlumniForNew:forNew];
      break;
      
    case NEARBY_BENEFITS_TY:
      [self loadBrandsForNew:forNew];
      break;
      
    default:
      break;
  }
}

#pragma mark - refresh nearby location info
- (void)refreshNearbyInfo:(NSNotification *)notification {
  [self clearList];

  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - user actions

- (void)showProfile:(Alumni *)alumni {
  
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                      alumni:alumni
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)beginChat {
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:self.alumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];
  
  /*
  DELETE_OBJS_FROM_MOC(_MOC, @"Chat", nil);
  
  ChatListViewController *chartVC = [[ChatListViewController alloc] initWithMOC:_MOC
                                                                         alumni:self.alumni];
  [self.navigationController pushViewController:chartVC animated:YES];
  RELEASE_OBJ(chartVC);
   */
}

- (void)refresh:(id)sender
{
  _userRefreshList = YES;
  
  [self forceGetLocation];
}

- (void)changeSubLayerViewControllerBackButtonText {
  UIBarButtonItem *backBarButton = [[[UIBarButtonItem alloc] init] autorelease];
  backBarButton.title = LocaleStringForKey(NSBackBtnTitle, nil);
  self.navigationItem.backBarButtonItem = backBarButton;
}

- (void)enterNearbyCoupon:(id)sender {
  BrandsViewController *brandsVC = [[[BrandsViewController alloc] initWithMOC:_MOC] autorelease];
  brandsVC.title = LocaleStringForKey(NSAlumniCouponTitle, nil);
  
  [self changeSubLayerViewControllerBackButtonText];
  
  [self.navigationController pushViewController:brandsVC animated:YES];
}

- (void)showWinnersAndAwards {
  
  NSString *url = [NSString stringWithFormat:@"%@event?action=page_load&page_name=shake_it_off_wap&locale=%@&user_id=%@&plat=%@&version=%@&sessionId=%@&person_id=%@&channel=%d&user_name=%@&user_type=%@&class_id=%@&class_name=%@&latitude=%f&longitude=%f&winner_type=%d",
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
                   [AppManager instance].shakeWinnerType];
  
  [CommonUtils openWebView:self.navigationController
                     title:LocaleStringForKey(NSShakeAwardsTitle, nil)
                       url:url
           needCloseButton:YES
            needNavigation:NO
            needHomeButton:NO];
  
}

- (void)searchNearby:(id)sender {
  VenueListViewController *venueListVC = [[[VenueListViewController alloc] initNearbyVenuesWithMOC:_MOC
                                                                                 locationRefreshed:_currentLocationIsLatest] autorelease];
  venueListVC.title = LocaleStringForKey(NSNearbyVenuesTitle, nil);
  [self.navigationController pushViewController:venueListVC animated:YES];
}

- (void)contactUs:(id)sender {
  
  NSString *url = [NSString stringWithFormat:@"%@event?action=visit_coopertion_suggest&user_id=%@&session=%@&plat=i&version=%@&locale=%@&person_id=%@&user_type=%@",
                   [AppManager instance].hostUrl,
                   [AppManager instance].userId,
                   [AppManager instance].sessionId,
                   VERSION,
                   [WXWSystemInfoManager instance].currentLanguageDesc,
                   [AppManager instance].personId,
                   [AppManager instance].userType];
  
  [CommonUtils openWebView:self.navigationController
                     title:LocaleStringForKey(NSWantProvideBenefitTitle, nil)
                       url:url
           needCloseButton:YES
            needNavigation:NO
            needHomeButton:NO];

}

#pragma mark - lifecycle methods

- (void)registerNotifications {
  
  // user entered nearby service, then he/she click 'Home' button for iPhone, then app deactivec,
  // if user actives the app again, the location info should be refreshed
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(refreshNearbyInfo:)
                                               name:REFRESH_NEARBY_NOTIFY
                                             object:nil];
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    // DEBUG
    //_tapIndex = NEARBY_ALUMNI_TY;
    
    _tapIndex = NEARBY_BENEFITS_TY;
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", nil);
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Brand", nil);
    
    [self registerNotifications];
  }
  
  return self;
}

- (void)dealloc {
  
  self.alumni = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:REFRESH_NEARBY_NOTIFY
                                                object:nil];
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Brand", nil);
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", nil);
  [super dealloc];
}

- (void)initTabSwitchView {
  _tabSwitchView = [[[PlainTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT) buttonTitles:@[LocaleStringForKey(NSAlumniTitle, nil), LocaleStringForKey(NSAlumniCouponTitle, nil)] tapSwitchDelegate:self] autorelease];
  
  [self.view addSubview:_tabSwitchView];
  
  [self adjustTableViewProperties];
  
  // set initial status
  [_tabSwitchView selectButtonWithIndexWithoutTriggerEvent:_tapIndex];
}

- (void)adjustTableViewProperties {
  _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                HEADER_HEIGHT,
                                _tableView.frame.size.width,
                                _tableView.frame.size.height - HEADER_HEIGHT);
  
  _tableView.alpha = 1.0f;
}

- (void)addRefreshBarButton {
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSRefreshTitle, nil)
                            target:self
                            action:@selector(refresh:)];
  self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)addVenuesSearchBarButton {
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSNearbyVenuesTitle, nil)
                            target:self
                            action:@selector(searchNearby:)];
  self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  { // DEBUG
  //[self addRefreshBarButton];
  
  //[self initTabSwitchView];
  }
  
  //
  [self addVenuesSearchBarButton];
  
  // get location
  [self forceGetLocation];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_winnerLoaded) {
    [_tableView reloadData];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [UIUtils closeActivityView];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case SHAKE_USER_LIST_TY:
      [UIUtils showActivityView:self.view
                           text:LocaleStringForKey(NSShakeLoadingTitle, nil)];
      break;
      
    case LOAD_BRANDS_TY:
      [UIUtils showActivityView:self.view
                           text:LocaleStringForKey(NSLoadingTitle, nil)];
      break;
      
    default:
      break;
  }
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  switch (contentType) {
      
    case SHAKE_USER_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [_winnerHeaderView setWinnerInfo:[AppManager instance].shakeWinnerInfo
                              winnerType:[AppManager instance].shakeWinnerType];
        
        _tableView.alpha = 1.0f;
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
      
      _winnerLoaded = YES;
      
      break;
    }
      
    case LOAD_BRANDS_TY:
    {
      if (![XMLParser parserResponseXml:result
                                   type:contentType
                                    MOC:_MOC
                      connectorDelegate:self
                                    url:url]) {
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchBrandsFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      } else {
        
        _tableView.alpha = 1.0f;
        
      }
      
    }
      
    default:
      break;
  }
  
  [self refreshTable];
  
  [UIUtils closeActivityView];
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    
    switch (contentType) {
        
      case SHAKE_USER_LIST_TY:
        self.connectionErrorMsg = LocaleStringForKey(NSFetchAlumniFailedMsg, nil);
        _winnerLoaded = YES;
        break;
        
      case LOAD_BRANDS_TY:
        self.connectionErrorMsg = LocaleStringForKey(NSFetchBrandsFailedMsg, nil);
        break;
        
      default:
        break;
    }
  }
  
  [UIUtils closeActivityView];
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
// override this method, this method only support alumni list
- (BOOL)currentCellIsFooter:(NSIndexPath *)indexPath {
  if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
    return YES;
  } else {
    return NO;
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  switch (_tapIndex) {
    case NEARBY_ALUMNI_TY:
      return ALUMNI_SECTION_COUNT;
      
    case NEARBY_BENEFITS_TY:
      return BENIFITS_SECTION_COUNT;
      
    default:
      return 0;
  }
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  switch (_tapIndex) {
    case NEARBY_ALUMNI_TY:
      switch (section) {
        case WINNER_SEC:
          return 1;
          
        case ALUMNI_SEC:
          return self.fetchedRC.fetchedObjects.count + 1;
          
        default:
          return 0;
      }
      
    case NEARBY_BENEFITS_TY:
      return self.fetchedRC.fetchedObjects.count;
      
    default:
      return 0;
  }
}

- (UITableViewCell *)drawWinnerCell {
  
  static NSString *kCellIdentifier = @"winnerCell";
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = UITableViewCellAccessoryNone;
    
    _winnerHeaderView = [[[WinnerHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                            self.view.frame.size.width,
                                                                            WINNER_HEADER_HEIGHT)
                                                userListDelegate:self] autorelease];
    [cell.contentView addSubview:_winnerHeaderView];
  }
  
  if (_winnerLoaded) {
    
    [_winnerHeaderView setWinnerInfo:[AppManager instance].shakeWinnerInfo
                          winnerType:[AppManager instance].shakeWinnerType];
    
  } else {
    [_winnerHeaderView animationGift];
    
  }
  
  
  return cell;
}

- (UITableViewCell *)drawAlumniCell:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return [self drawFooterCell];
  }
  
  static NSString *kCellIdentifier = @"userCell";
  PeopleWithDistanceCell *cell = (PeopleWithDistanceCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[PeopleWithDistanceCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:kCellIdentifier
                                   imageDisplayerDelegate:self
                                   imageClickableDelegate:self
                                                      MOC:_MOC] autorelease];
  }
  
  Alumni *alumni = (Alumni *)self.fetchedRC.fetchedObjects[indexPath.row];
  
  [cell drawCell:alumni];
  
  return cell;
}

- (UITableViewCell *)drawBrandCell:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"BrandCell";
  
  BrandCell *cell = (BrandCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[BrandCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:kCellIdentifier] autorelease];
  }
  
  Brand *brand = (Brand *)[_fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawCell:brand];
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (_tapIndex) {
    case NEARBY_ALUMNI_TY:
      switch (indexPath.section) {
        case WINNER_SEC:
          return [self drawWinnerCell];
          
        case ALUMNI_SEC:
          return [self drawAlumniCell:indexPath];
          
        default:
          return nil;
      }
      
    case NEARBY_BENEFITS_TY:
      return [self drawBrandCell:indexPath];
      
    default:
      return nil;
  }
}

- (CGFloat)alumniCellHeight:(NSIndexPath *)indexPath {
  Alumni *alumni = (Alumni *)self.fetchedRC.fetchedObjects[indexPath.row];
  
  CGSize constraint = CGSizeMake(NAME_LIMITED_WIDTH, 20);
  CGSize size = [alumni.name sizeWithFont:Arial_FONT(14)
                        constrainedToSize:constraint
                            lineBreakMode:NSLineBreakByTruncatingTail];
  
  CGFloat height = MARGIN + size.height;
  
  size = [alumni.companyName sizeWithFont:FONT(13)
                        constrainedToSize:CGSizeMake((self.view.frame.size.width - MARGIN * 8) - MARGIN -
                                                     (MARGIN + PHOTO_WIDTH + PHOTO_MARGIN * 2 +
                                                      MARGIN * 2),
                                                     CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  
  CGSize distanceSize = [@"km" sizeWithFont:FONT(9)];
  
  height += size.height + MARGIN + distanceSize.height + MARGIN;
  
  if (height < PEOPLE_CELL_HEIGHT) {
    height = PEOPLE_CELL_HEIGHT;
  }
  
  return height;
}

- (CGFloat)brandCellHeight:(NSIndexPath *)indexPath {
  Brand *brand = (Brand *)[_fetchedRC objectAtIndexPath:indexPath];
  
  CGSize size = [brand.name sizeWithFont:BOLD_FONT(15)
                       constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat height = size.height + MARGIN * 2;
  
  size = [brand.tags sizeWithFont:FONT(12)
                constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                    lineBreakMode:NSLineBreakByWordWrapping];
  
  height += MARGIN + size.height;
  
  if (brand.couponInfo && brand.couponInfo.length > 0) {
    height += COUPON_INFO_HEIGHT + MARGIN * 2;
  } else {
    height += MARGIN;
  }
  
  if (height < BRAND_CELL_HEIGHT) {
    height = BRAND_CELL_HEIGHT;
  }
  
  return height;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (_tapIndex) {
    case NEARBY_ALUMNI_TY:
      switch (indexPath.section) {
        case WINNER_SEC:
          return WINNER_HEADER_HEIGHT;
          
        case ALUMNI_SEC:
        {
          if ([self currentCellIsFooter:indexPath]) {
            return PEOPLE_CELL_HEIGHT;
          } else {
            
            return [self alumniCellHeight:indexPath];
          }
        }
          
        default:
          return 0;
      }
      
    case NEARBY_BENEFITS_TY:
      return [self brandCellHeight:indexPath];
      
    default:
      return 0;
  }
}

- (void)selectAlumniCell:(NSIndexPath *)indexPath {
  Alumni *alumni = (Alumni *)self.fetchedRC.fetchedObjects[indexPath.row];
  
  [self showProfile:alumni];
}

- (void)selectBrandCell:(NSIndexPath *)indexPath {
  Brand *brand = (Brand *)[_fetchedRC objectAtIndexPath:indexPath];
  
  BrandDetailViewController *brandDetailVC = [[[BrandDetailViewController alloc] initWithMOC:_MOC
                                                                                       brand:brand
                                                                           locationRefreshed:_currentLocationIsLatest] autorelease];
  brandDetailVC.title = LocaleStringForKey(NSDetailsTitle, nil);
  [self.navigationController pushViewController:brandDetailVC animated:YES];
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (_tapIndex) {
    case NEARBY_ALUMNI_TY:
      switch (indexPath.section) {
        case WINNER_SEC:
          [self showWinnersAndAwards];
          break;
          
        case ALUMNI_SEC:
        {
          if (![self currentCellIsFooter:indexPath]) {
            
            [self selectAlumniCell:indexPath];
          }
          
          break;
        }
        default:
          break;
      }
      
      break;
      
    case NEARBY_BENEFITS_TY:
      [self selectBrandCell:indexPath];
      break;
      
    default:
      break;
  }
}

#pragma mark - location result
- (void)locationResult:(LocationResultType)type{
  
  [self closeAsyncLoadingView];
  
  switch (type) {
    case LOCATE_SUCCESS_TY:
      
      _currentLocationIsLatest = YES;
      
      /* DEBUG 
      if (_winnerHeaderView) {
        [_winnerHeaderView animationGift];
      }
      
      self.navigationItem.rightBarButtonItem.enabled = YES;
      
      [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
       */
      
      // DEBUG demo
    {
      [self loadBrandsForNew:YES];
    }
      
      break;
      
    case LOCATE_FAILED_TY:
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchNearbyPlaceFailedMSg, nil)
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      break;
      
    default:
      break;
  }
  
}

#pragma mark - handle list content refresh for tap switch
- (void)clearList {
  
  _currentStartIndex = 0;
  
  _tableView.alpha = 0.0f;
  
  switch (_tapIndex) {
    case NEARBY_ALUMNI_TY:
    {
      // reset status
      _winnerLoaded = NO;
      if (_winnerHeaderView) {
        [_winnerHeaderView setWinnerInfo:nil winnerType:NO_USER_WINNER_TY];
      }
      
      _userRefreshList = NO;
      
      DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", nil);
      
      [self addRefreshBarButton];
      
      break;
    }
      
    case NEARBY_BENEFITS_TY:
      DELETE_OBJS_FROM_MOC(_MOC, @"Brand", nil);
      
      [self addVenuesSearchBarButton];
      break;
      
    default:
      break;
  }
  
  self.fetchedRC = nil;
  
  [_tableView reloadData];
}

#pragma mark - add contact button
- (void)adjustContactButton:(BOOL)hidden {
  if (nil == _contactUsButton) {
    _contactUsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _contactUsButton.frame = CGRectMake(0,
                                        self.view.frame.size.height,
                                        self.view.frame.size.width, CONTACT_BTN_HEIGHT);
    _contactUsButton.backgroundColor = COLOR(71, 71, 71);
    [_contactUsButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
    _contactUsButton.titleLabel.font = BOLD_FONT(15);
    [_contactUsButton setTitle:LocaleStringForKey(NSWantProvideBenefitTitle, nil)
                      forState:UIControlStateNormal];
    [_contactUsButton setImage:[UIImage imageNamed:@"grayMessage.png"] forState:UIControlStateNormal];
    [_contactUsButton addTarget:self
                         action:@selector(contactUs:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_contactUsButton];
  }
    
  _contactUsButton.hidden = hidden;
  _contactUsButton.enabled = !hidden;
  
  CGRect targetFrame;
  
  if (hidden) {
    targetFrame = CGRectMake(0, self.view.frame.size.height,
                             _contactUsButton.frame.size.width,
                             _contactUsButton.frame.size.height);
  } else {
    targetFrame = CGRectMake(0, self.view.frame.size.height - CONTACT_BTN_HEIGHT,
                             _contactUsButton.frame.size.width,
                             _contactUsButton.frame.size.height);
  }
  
  [UIView animateWithDuration:0.2f
                        delay:0.5f
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     _contactUsButton.frame = targetFrame;
                   }
                   completion:^(BOOL finished){
                   }];
}

#pragma mark - TapSwitchDelegate method
- (void)selectTapByIndex:(NSInteger)index {
  
  if (index == _tapIndex && _autoLoaded) {
    return;
  }
  
  [UIUtils closeActivityView];
  
  _currentStartIndex = 0;
  
  _tapIndex = index;
  
  [self clearList];
  
  [self removeEmptyMessageIfNeeded];
  
  if (_tapIndex == NEARBY_BENEFITS_TY) {
    
    _tableView.frame = CGRectMake(0, HEADER_HEIGHT,
                                  _tableView.frame.size.width,
                                  self.view.frame.size.height - HEADER_HEIGHT - CONTACT_BTN_HEIGHT);

    [self adjustContactButton:NO];
  } else {
    _tableView.frame = CGRectMake(0, HEADER_HEIGHT,
                                  _tableView.frame.size.width,
                                  self.view.frame.size.height - HEADER_HEIGHT);
    
    [self adjustContactButton:YES];
  }
  
  [self forceGetLocation];
}

#pragma mark - ECClickableElementDelegate method
- (void)doChat:(Alumni*)aAlumni {
  
  self.alumni = aAlumni;
  
  UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSActionSheetTitle, nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:LocaleStringForKey(NSChatActionSheetTitle, nil)
                                          otherButtonTitles:nil] autorelease];
  
  [as addButtonWithTitle:LocaleStringForKey(NSProfileActionSheetTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
}

#pragma mark - Action Sheet
- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case CHAT_SHEET_IDX:
		{
      [self beginChat];
      return;
		}
      
		case DETAIL_SHEET_IDX:
      //[self showProfile:self.alumni.personId userType:self.alumni.userType];
      [self showProfile:self.alumni];
			return;
			
    case CANCEL_SHEET_IDX:
      return;
      
		default:
			break;
	}
}


@end
