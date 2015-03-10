//
//  BrandDetailViewController.m
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import "BrandDetailViewController.h"
#import "WXWLabel.h"
#import "ECHandyAvatarBrowser.h"
#import "BrandBaseInfoView.h"
#import "Brand.h"
#import "VerticalLayoutItemInfoCell.h"
#import "AlumniCouponTitleCell.h"
#import "AlumniCouponInfoCell.h"
#import "ServiceItem.h"
#import "ServiceLatestCommentCell.h"
#import "HandyCommentListViewController.h"
#import "ItemLikersListViewController.h"
#import "VenueListViewController.h"
#import "BranchCell.h"
#import "ServiceItemDetailViewController.h"
#import "CouponTipsDetailView.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"

#define SECTION_COUNT 6
#define CELL_COUNT    1
#define COUPON_SEC_CELL_COUNT 4

#define BRANCH_CELL_HEIGHT        80.0f
#define COUPON_TITLE_CELL_HEIGHT  30.0f

#define DEFAULT_CELL_HEIGHT       44.0f

#define AVATAR_SIDE_LENGTH  66.0f

#define BRANCH_SHORTCUT_COUNT 3

#define DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH    266.0f
#define DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH  280.0f

#define DETAIL_TIPS_VIEW_OFFSET     150.0f

enum {
  COUPON_SEC = 0,
  ALUMNUS_SEC,
  BRANCH_SEC,
  SHARE_SEC,
  COMMENT_SEC,
  INTRO_SEC,
};

enum {
  COUPON_SEC_SHOW_CELL = 0,
  COUPON_SEC_TITLE_CELL,
  COUPON_SEC_INFO_CELL,
  COUPON_SEC_TIPS_CELL,
};

@interface BrandDetailViewController ()
@property (nonatomic, retain) Brand *brand;
@property (nonatomic, retain) NSIndexPath *commentIndexPath;
@property (nonatomic, retain) UIImage *avatar;
@end

@implementation BrandDetailViewController

@synthesize brand = _brand;
@synthesize commentIndexPath = _commentIndexPath;

#pragma mark - load data
- (void)loadBrandDetail {
  
  NSString *param = [NSString stringWithFormat:@"<channel_id>%lld</channel_id><longitude>%f</longitude><latitude>%f</latitude>", _brandId, [AppManager instance].longitude, [AppManager instance].latitude];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_BRAND_DETAIL_TY];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:LOAD_BRAND_DETAIL_TY] autorelease];
  (self.connDic)[url] = connFacade;
  
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)resetBrand {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"brandId == %lld", _brandId];
  self.brand = (Brand *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                  entityName:@"Brand"
                                                   predicate:predicate];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"ServiceItem";
  
  self.predicate = [NSPredicate predicateWithFormat:@"(brandId == %lld)", _brandId];
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
  [self.descriptors addObject:descriptor1];
  
  NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"itemId" ascending:YES] autorelease];
  [self.descriptors addObject:descriptor2];
  
}

#pragma mark - lifecycle methods

- (void)registerNotifications {
  
  // user entered nearby service, then he/she click 'Home' button for iPhone, then app deactivec,
  // if user actives the app again, the location info should be refreshed
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateBranchSection:)
                                               name:REFRESH_NEARBY_NOTIFY
                                             object:nil];
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
            brand:(Brand *)brand
locationRefreshed:(BOOL)locationRefreshed {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 tableStyle:UITableViewStyleGrouped
                 needGoHome:NO];
  
  if (self) {
    self.brand = brand;
    
    _brandId = brand.brandId.longLongValue;
    
    _currentLocationIsLatest = locationRefreshed;
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Comment", nil);
    
    DELETE_OBJS_FROM_MOC(_MOC, @"ServiceItem", nil);
    
    [self registerNotifications];
  }
  
  return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
          brandId:(long long)brandId
locationRefreshed:(BOOL)locationRefreshed {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 tableStyle:UITableViewStyleGrouped
                 needGoHome:NO];
  
  if (self) {
    
    _brandId = brandId;
    
    _currentLocationIsLatest = locationRefreshed;
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Comment", nil);
    
    [self registerNotifications];
  }
  
  return self;

}

- (void)dealloc {
  
  RELEASE_OBJ(_branchTitleView);
  
  self.brand = nil;
  
  self.avatar = nil;
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Comment", nil);
  DELETE_OBJS_FROM_MOC(_MOC, @"ServiceItem", nil);
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:REFRESH_NEARBY_NOTIFY
                                                object:nil];
  [super dealloc];
}

- (void)initTableViewHeaderView {
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  _baseInfoView = [[[BrandBaseInfoView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                         self.view.frame.size.width, 0)
                                                      brand:self.brand
                                   clickableElementDelegate:self
                                  WXWImageDisplayerDelegate:self] autorelease];
  _baseInfoView.backgroundColor = TRANSPARENT_COLOR;
  
  _tableView.tableHeaderView = _baseInfoView;
}

- (void)checkLocationRefreshStatus {
  if (!_currentLocationIsLatest) {
    
    [self showAsyncLoadingView:LocaleStringForKey(NSLocatingMsg, nil) blockCurrentView:YES];
    [self forceGetLocation];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  //[self initTableViewHeaderView];
  
  [self checkLocationRefreshStatus];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    if (_currentLocationIsLatest) {
      [self loadBrandDetail];
    }
  } else {
    if (_needUpdateCommentCount) {
      [self updateCommentCount];
      
      _needUpdateCommentCount = NO;
    }
    
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECClickableElementDelegate method
- (void)showBigPhoto:(NSString *)url {
  
  CGRect smallAvatarFrame = CGRectMake(MARGIN * 2, MARGIN * 2, AVATAR_SIDE_LENGTH, AVATAR_SIDE_LENGTH);
  
  ECHandyAvatarBrowser *avatarBrowser = [[[ECHandyAvatarBrowser alloc] initWithFrame:CGRectMake(0, 0,
                                                                                                self.view.frame.size.width,
                                                                                                self.view.frame.size.height)
                                                                              imgUrl:url
                                                                     imageStartFrame:smallAvatarFrame
                                                              imageDisplayerDelegate:self] autorelease];
  [self.view addSubview:avatarBrowser];
}

- (void)saveImage:(UIImage *)image {
  self.avatar = image;
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:NO];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  
  switch (contentType) {
    case LOAD_BRAND_DETAIL_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:LOAD_BRAND_DETAIL_TY
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        _autoLoaded = YES;
        
        // re-apply the brand info for app return to foreground and wechat share
        [self resetBrand];
        
        if (nil == _baseInfoView) {
          [self initTableViewHeaderView];
        }
        
        [self refreshTable];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchBrandDetailFailedMsg, nil)
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

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {

  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSFetchBrandDetailFailedMsg, nil);
  }

  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECItemUploaderDelegate method
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
  switch (actionType) {
    case LOAD_BRAND_COMMENT_TY:// triggered by send comment in handy comment list
    {
      [self loadBrandDetail];
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - update nearest branches
- (void)updateBranchSection:(NSNotification *)notification {
  [self loadBrandDetail];
}

#pragma mark - update comment section
- (void)updateCommentCount {
  
  if (self.commentIndexPath) {
    // if self.commentIndexPath is nil, which means user does not scroll the screen
    // down to the comment location
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[self.commentIndexPath]
                      withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
  }
}

#pragma mark - draw cell

- (UITableViewCell *)couponSectionCell:(NSIndexPath *)indexPath {
  
  switch (indexPath.row) {
    case COUPON_SEC_SHOW_CELL:
    {
      static NSString *kCellIdentifier = @"CouponShowCell";
      AlumniCouponTitleCell *cell = (AlumniCouponTitleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
      if (nil == cell) {
        cell = [[[AlumniCouponTitleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:kCellIdentifier] autorelease];
        cell.backgroundColor = HIGHLIGHT_TEXT_CELL_COLOR;
      }
      
      [cell drawCell:LocaleStringForKey(NSShowForUseCouponTitle, nil)
            subTitle:nil
                font:BOLD_FONT(12)
           textColor:BASE_INFO_COLOR
       textAlignment:UITextAlignmentCenter
          cellHeight:COUPON_TITLE_CELL_HEIGHT
    showBottomShadow:NO];
      
      return cell;
    }

    case COUPON_SEC_TITLE_CELL:
    {
      static NSString *kCellIdentifier = @"CouponTitleCell";
      
      AlumniCouponTitleCell *cell = (AlumniCouponTitleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
      if (nil == cell) {
        cell = [[[AlumniCouponTitleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:kCellIdentifier] autorelease];
      }
      [cell drawCell:LocaleStringForKey(NSIalumniCouponTitle, nil)
            subTitle:nil
                font:BOLD_FONT(14)
           textColor:CELL_TITLE_COLOR
       textAlignment:UITextAlignmentRight
          cellHeight:COUPON_TITLE_CELL_HEIGHT
    showBottomShadow:NO];
      return cell;
      
    }
      
    case COUPON_SEC_INFO_CELL:
    {
      static NSString *kCellIdentifier = @"CouponInfoCell";
      
      AlumniCouponInfoCell *cell = (AlumniCouponInfoCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
      if (nil == cell) {
        cell = [[[AlumniCouponInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:kCellIdentifier] autorelease];
      }
      
      [cell drawCell:self.brand.couponInfo];
      return cell;
    }
      
    case COUPON_SEC_TIPS_CELL:
    {
      static NSString *kCellIdentifier = @"CouponTipsCell";
      
      AlumniCouponTitleCell *cell = (AlumniCouponTitleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
      if (nil == cell) {
        cell = [[[AlumniCouponTitleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:kCellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.selectionStyle = UITableViewCellSelectionStyleBlue;
      }
      [cell drawCell:LocaleStringForKey(NSCouponTipsMsg, nil)
            subTitle:nil
                font:BOLD_FONT(12)
           textColor:CELL_TITLE_COLOR
       textAlignment:UITextAlignmentRight
          cellHeight:COUPON_TITLE_CELL_HEIGHT
    showBottomShadow:YES];
      
      return cell;
    }
      
    default:
      return nil;
  }
}

- (UITableViewCell *)alumnusSectionCell:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"AlumnusCell";
  
  AlumniCouponTitleCell *cell = (AlumniCouponTitleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[AlumniCouponTitleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:kCellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  [cell drawCell:LocaleStringForKey(NSAlumniWorkedInCompanyTitle, nil)
        subTitle:nil
            font:BOLD_FONT(14)
       textColor:CELL_TITLE_COLOR
   textAlignment:UITextAlignmentRight
      cellHeight:DEFAULT_CELL_HEIGHT
showBottomShadow:YES];
  
  return cell;
}

- (UITableViewCell *)drawShowAllBranchCell {
  static NSString *kCellIdentifier = @"AllBanchsCell";
  
  AlumniCouponTitleCell *cell = (AlumniCouponTitleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[AlumniCouponTitleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:kCellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  NSString *countTitle = nil;
  if (self.brand.itemTotal.intValue > 0) {
    countTitle = [NSString stringWithFormat:@"%@", self.brand.itemTotal];
  }
  [cell drawCell:LocaleStringForKey(NSAllBranchesTitle, nil)
        subTitle:countTitle
            font:BOLD_FONT(14)
       textColor:CELL_TITLE_COLOR
   textAlignment:UITextAlignmentRight
      cellHeight:DEFAULT_CELL_HEIGHT
showBottomShadow:YES];
  
  return cell;
  
}

- (UITableViewCell *)drawBranchCell:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"ServiceItemCell";
  BranchCell *cell = (BranchCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[BranchCell alloc] initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:kCellIdentifier
                       imageDisplayerDelegate:self
                                          MOC:_MOC] autorelease];
  }
  
  ServiceItem *item = (ServiceItem *)[_fetchedRC objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                      inSection:0]];
  
  [cell drawItem:item index:indexPath.row];
  return cell;
}

- (UITableViewCell *)branchSectionCell:(NSIndexPath *)indexPath {
  
  if (_fetchedRC.fetchedObjects.count > BRANCH_SHORTCUT_COUNT) {
    if (indexPath.row == BRANCH_SHORTCUT_COUNT) {
      return [self drawShowAllBranchCell];
    } else {
      return [self drawBranchCell:indexPath];
    }
  } else {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
      
      return [self drawShowAllBranchCell];
      
    } else {
      return [self drawBranchCell:indexPath];
    }
  }
  
}

- (UITableViewCell *)commentSectionCell:(NSIndexPath *)indexPath {
  
  static NSString *cellIdentifier = @"commentCell";
  
  self.commentIndexPath = indexPath;
  
  ServiceLatestCommentCell *cell = (ServiceLatestCommentCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[ServiceLatestCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier] autorelease];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  NSString *timeText = nil;
  NSString *countTitle = nil;
  if (self.brand.commentCount.intValue > 0) {
    timeText = self.brand.latestCommentElapsedTime;
    countTitle = [NSString stringWithFormat:@"%@", self.brand.commentCount];
  }
  
  NSString *latestCommentBranchName = nil;
  if (self.brand.latestCommentBranchName.length > 0) {
    latestCommentBranchName = self.brand.latestCommentBranchName;
  }
  
  NSString *latestComment = nil;
  if (self.brand.latestComment.length > 0) {
    latestComment = self.brand.latestComment;
  }
  
  NSString *latestCommenterName = nil;
  if (self.brand.latestCommenterName.length > 0) {
    latestCommenterName = self.brand.latestCommenterName;
  }
  
  [cell drawCell:LocaleStringForKey(NSReviewsTitle, nil)
        subTitle:countTitle
        location:latestCommentBranchName
         comment:latestComment
   commenterName:latestCommenterName
            date:timeText
      cellHeight:[self heightForCommentCell]];
  
  return cell;
}

- (UITableViewCell *)shareSectionCell:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"ShareCell";
  
  AlumniCouponTitleCell *cell = (AlumniCouponTitleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[AlumniCouponTitleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:kCellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  [cell drawCell:LocaleStringForKey(NSShareToWechatTitle, nil)
        subTitle:nil
            font:BOLD_FONT(14)
       textColor:CELL_TITLE_COLOR
   textAlignment:UITextAlignmentRight
      cellHeight:DEFAULT_CELL_HEIGHT
showBottomShadow:YES];
  
  return cell;

}

- (CGFloat)bioCellHeight {
  CGSize size = [LocaleStringForKey(NSIntroTitle, nil) sizeWithFont:BOLD_FONT(14)
                                                  constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH,
                                                                               CGFLOAT_MAX)
                                                      lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = MARGIN * 2 + size.height + MARGIN * 2;
  
  if (self.brand.bio && self.brand.bio.length > 0) {
    size = [self.brand.bio sizeWithFont:BOLD_FONT(13)
                      constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height;
  }
  
  return height;
}

- (UITableViewCell *)introSectionCell:(NSIndexPath *)indexPath {
  
  static NSString *introCellIdentifier = @"IntroCell";
  
  return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSIntroTitle, nil)
                                 subTitle:nil
                                  content:self.brand.bio
                           cellIdentifier:introCellIdentifier
                                   height:[self bioCellHeight]
                                clickable:NO];
}

- (CGFloat)heightForCommentCell {
  CGFloat height = 0.0f;
  CGSize size = [LocaleStringForKey(NSCommentTitle, nil) sizeWithFont:BOLD_FONT(14)
                                                    constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH,
                                                                                 CGFLOAT_MAX)
                                                        lineBreakMode:NSLineBreakByWordWrapping];
  height += MARGIN * 2 + size.height + MARGIN;
  
  if (self.brand.latestCommenterName && self.brand.latestCommenterName.length > 0) {
    size = [self.brand.latestCommenterName sizeWithFont:FONT(11)
                                      constrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)
                                          lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN;
  }
  
  if (self.brand.latestCommentBranchName && self.brand.latestCommentBranchName.length > 0) {
    size = [self.brand.latestCommentBranchName sizeWithFont:FONT(11)
                                          constrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)
                                              lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN;
  }
  
  if (self.brand.latestComment && self.brand.latestComment.length > 0) {
    size = [self.brand.latestComment sizeWithFont:BOLD_FONT(13)
                                constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN * 2;
  }
  
  if (height < DEFAULT_CELL_HEIGHT) {
    height = DEFAULT_CELL_HEIGHT;
  }
  return height;
}

#pragma mark - user select cell action

- (void)presentTipsView:(CouponTipsDetailView *)tipsDetailView {

  [self presentModalQuickView:tipsDetailView];
  
  _presentTipsProcessing = NO;
}

- (void)showDetailTips {
  
  if (_presentTipsProcessing) {
    return;
  } else {
    _presentTipsProcessing = YES;
  }

  CouponTipsDetailView *tipsDetailView = [[[CouponTipsDetailView alloc] initWithFrame:CGRectMake(0,
                                                                                                DETAIL_TIPS_VIEW_OFFSET,
                                                                                                self.view.frame.size.width,
                                                                                                self.view.frame.size.height - DETAIL_TIPS_VIEW_OFFSET)
                                                                               holder:self] autorelease];

  /*
  [self performSelector:@selector(presentTipsView:)
             withObject:tipsDetailView
             afterDelay:0.3f];
   */
  [self presentTipsView:tipsDetailView];
}

- (void)selectCommentSection:(NSIndexPath *)indexPath {
  
  HandyCommentListViewController *newsCommentListVC = [[[HandyCommentListViewController alloc] initWithMOC:_MOC
                                                                                                    holder:_holder
                                                                                          backToHomeAction:_backToHomeAction
                                                                                                    itemId:0
                                                                                                   brandId:_brandId
                                                                                               contentType:SEND_BRAND_COMMENT_TY
                                                                                      itemUploaderDelegate:self] autorelease];
  
  [self.navigationController pushViewController:newsCommentListVC animated:YES];
  
  _needUpdateCommentCount = YES;
}

- (void)shareToWechat:(NSIndexPath *)indexPath {

    if ([WXApi isWXAppInstalled]) {
      ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = self;
      
      [CommonUtils shareBrand:self.brand scene:WXSceneSession image:self.avatar];
      
    } else {
      
      ShowAlertWithTwoButton(self, nil, LocaleStringForKey(NSNoWeChatMsg, nil), LocaleStringForKey(NSDonotInstallTitle, nil),LocaleStringForKey(NSInstallTitle, nil));
    }

}

- (void)showAlumniFounders {
  ItemLikersListViewController *likerListVC = [[[ItemLikersListViewController alloc] initWithMOC:_MOC
                                                                                          itemId:_brandId
                                                                                 loadContentType:LOAD_BRAND_ALUMNUS_TY] autorelease];
  likerListVC.title = LocaleStringForKey(NSAlumniTitle, nil);
  [self.navigationController pushViewController:likerListVC animated:YES];
}

- (void)showAllBranches {
  VenueListViewController *venueListVC = [[[VenueListViewController alloc] initBranchVenuesWithMOC:_MOC
                                                                                             brand:self.brand
                                                                                 locationRefreshed:_currentLocationIsLatest] autorelease];
  venueListVC.title = LocaleStringForKey(NSAllBranchesTitle, nil);
  [self.navigationController pushViewController:venueListVC animated:YES];
}

- (void)showBranchDetail:(NSIndexPath *)indexPath {
  ServiceItem *item = (ServiceItem *)[_fetchedRC objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                      inSection:0]];
  ServiceItemDetailViewController *profileVC = [[[ServiceItemDetailViewController alloc] initWithMOC:_MOC
                                                                                              holder:((iAlumniAppDelegate*)APP_DELEGATE)
                                                                                    backToHomeAction:@selector(backToHomepage:)
                                                                                         serviceItem:item] autorelease];
  [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
  if (_autoLoaded) {
    return SECTION_COUNT;
  } else {
    return 0;
  }
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  switch (section) {
    case COUPON_SEC:
      return COUPON_SEC_CELL_COUNT;
      
    case ALUMNUS_SEC:
      return CELL_COUNT;
      
    case BRANCH_SEC:
      if (_fetchedRC.fetchedObjects.count > BRANCH_SHORTCUT_COUNT) {
        return BRANCH_SHORTCUT_COUNT + 1;
      } else {
        return _fetchedRC.fetchedObjects.count + 1;
      }
      
    case COMMENT_SEC:
    case SHARE_SEC:
    case INTRO_SEC:
      return CELL_COUNT;
      
    default:
      return 0;
  }
}

- (UIView *)branchTitleView {
  if (nil == _branchTitleView) {
    _branchTitleView = [[UIView alloc] init];
    _branchTitleView.backgroundColor = TRANSPARENT_COLOR;
    
    WXWLabel *title = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:CELL_TITLE_COLOR
                                         shadowColor:[UIColor whiteColor]] autorelease];
    title.font = BOLD_FONT(14);
    title.text = LocaleStringForKey(NSAllowedBranchsTitle, nil);
    CGSize size = [title.text sizeWithFont:title.font
                         constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    title.frame = CGRectMake(MARGIN * 2, MARGIN, size.width, size.height);
    [_branchTitleView addSubview:title];
    
    _branchTitleView.frame = CGRectMake(0, 0, self.view.frame.size.width, MARGIN * 2 + size.height);
  }
  return _branchTitleView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  switch (section) {
    case BRANCH_SEC:
      return [self branchTitleView];
      
    default:
      return nil;
  }
}

- (CGFloat)branchTitleHeight {
  CGSize size = [LocaleStringForKey(NSAllowedBranchsTitle, nil) sizeWithFont:BOLD_FONT(14)
                                                           constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                                                               lineBreakMode:NSLineBreakByWordWrapping];
  return size.height + MARGIN * 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  switch (section) {
    case BRANCH_SEC:
      return [self branchTitleHeight];
      
    default:
      return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case COUPON_SEC:
    {
      switch (indexPath.row) {
        case COUPON_SEC_SHOW_CELL:
        case COUPON_SEC_TITLE_CELL:
        case COUPON_SEC_TIPS_CELL:
          return COUPON_TITLE_CELL_HEIGHT;
          
        case COUPON_SEC_INFO_CELL:
        {
          CGSize size = [self.brand.couponInfo sizeWithFont:FONT(13)
                                          constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                                              lineBreakMode:NSLineBreakByWordWrapping];
          return size.height + MARGIN * 4;
        }
          
        default:
          return 0;
      }
      
    }
      
    case ALUMNUS_SEC:
      return DEFAULT_CELL_HEIGHT;
      
    case BRANCH_SEC:
    {
      
      if (_fetchedRC.fetchedObjects.count > BRANCH_SHORTCUT_COUNT) {
        if (indexPath.row == BRANCH_SHORTCUT_COUNT) {
          return DEFAULT_CELL_HEIGHT;
        } else {
          return BRANCH_CELL_HEIGHT;
        }
      } else {
        
        if (indexPath.row == _fetchedRC.fetchedObjects.count) {
          
          return DEFAULT_CELL_HEIGHT;
          
        } else {
          return BRANCH_CELL_HEIGHT;
        }
      }

    }
      
    case COMMENT_SEC:
      return [self heightForCommentCell];
      
    case SHARE_SEC:
      return DEFAULT_CELL_HEIGHT;
      
    case INTRO_SEC:
      return [self bioCellHeight];
    default:
      return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case COUPON_SEC:
      return [self couponSectionCell:indexPath];
      
    case ALUMNUS_SEC:
      return [self alumnusSectionCell:indexPath];
      
    case BRANCH_SEC:
      return [self branchSectionCell:indexPath];
      
    case COMMENT_SEC:
      return [self commentSectionCell:indexPath];
      
    case SHARE_SEC:
      return [self shareSectionCell:indexPath];
      
    case INTRO_SEC:
      return [self introSectionCell:indexPath];
      
    default:
      return nil;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.section) {
    case COUPON_SEC:
    {
      if (indexPath.row == COUPON_SEC_TIPS_CELL) {
        [self showDetailTips];
      }
      break;
    }
      
    case BRANCH_SEC:
      if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        [self showAllBranches];
      } else {
        [self showBranchDetail:indexPath];
      }
      
      break;
      
    case COMMENT_SEC:
      [self selectCommentSection:indexPath];
      break;
      
    case SHARE_SEC:
      [self shareToWechat:indexPath];
      break;
      
    case ALUMNUS_SEC:
      [self showAlumniFounders];
      break;
      
    default:
      return;
  }
}

#pragma mark - ECLocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(WXWLocationManager *)manager
                                 location:(CLLocation *)location {
  
  [super locationManagerDidReceiveLocation:manager
                                  location:location];
  
  // user enter nearby service first time and location data info be fetched successfully
  [self changeAsyncLoadingMessage:LocaleStringForKey(NSLoadingTitle, nil)];
  
  [self loadBrandDetail];
  
  _currentLocationIsLatest = YES;
}

- (void)locationManagerDidFail:(WXWLocationManager *)manager {
  [super locationManagerDidFail:manager];
  
  [self closeAsyncLoadingView];
}

- (void)locationManagerCancelled:(WXWLocationManager *)manager {
  [super locationManagerCancelled:manager];
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

@end
