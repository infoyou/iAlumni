//
//  WelfareDetailViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-14.
//
//

#import "WelfareDetailViewController.h"
#import "Welfare.h"
#import "WelfareCouponInfoCell.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "StoreEntranceCell.h"
#import "WelfareUseNoticeCell.h"
#import "WelfareBrandEntranceCell.h"
#import "WelfareImageWallCell.h"
#import "VenueListViewController.h"
#import "WelfareBrandViewController.h"
#import "WXWImageManager.h"
#import "UIUtils.h"
#import "DownloadedUserListViewController.h"
#import "OrderViewController.h"
#import "Sku.h"
#import "AppManager.h"
#import "AlbumPhoto.h"

#define CELL_WITH_STORE_COUNT  5

#define CELL_WITHOUT_STORE_COUNT  4

#define CELL_INNER_MARGIN     8.0f

#define USER_PHOTO_SIDE_LEN   26.0f

#define STORE_IMG_SIDE_LEN    56.0f

#define WALL_HEIGHT   175.0f
#define PRICE_VIEW_HEIGHT 60.0f

enum {
  IMAGE_WITH_STORE_CELL,
  COUPON_WITH_STORE_CELL,
  STORE_CELL,
  USE_NOTICE_WITH_STORE_CELL,
  BRAND_WITH_STORE_CELL,
};

enum {
  IMAGE_WITHOUT_STORE_CELL,
  COUPON_WITHOUT_STORE_CELL,
  USE_NOTICE_WITHOUT_STORE_CELL,
  BRAND_WITHOUT_STORE_CELL,
};

enum {
  CALL_AS_TY,
  SHARE_AS_TY,
};

@interface WelfareDetailViewController ()
@property (nonatomic, retain) UIImage *image;
@end

@implementation WelfareDetailViewController

#pragma mark - load data
- (void)loadDetailInfo {
  _currentType = WELFARE_DETAIL_TY;
  
  NSString *param = STR_FORMAT(@"<itemId>%@</itemId>", _welfare.itemId);
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *conn = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  
  [conn asyncGet:url showAlertMsg:YES];
}

#pragma mark - use actions
- (void)openUserList:(id)sender {
  
}

- (void)openAllBranch:(id)sender {
  
}

- (void)callSupport:(id)sender {
  if ([NULL_PARAM_VALUE isEqualToString:_welfare.tel]) {
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
  
  _asOwnerType = CALL_AS_TY;
}

- (void)openBrandInfo:(id)sender {
  
}

- (void)favoriteItem:(id)sender {
  NSInteger status = !_welfare.favorited.boolValue ? 1 : 0;
  
  _currentType = FAVORITE_WELFARE_TY;
  
  NSString *param = STR_FORMAT(@"<itemId>%@</itemId><keepStatus>%d</keepStatus>", _welfare.itemId, status);
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
  
}

- (void)saveDisplayedImage:(UIImage *)image {
  self.image = image;
}

- (void)shareItem:(id)sender {
  
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSShareWelfareTitle, nil)
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  
  [as addButtonWithTitle:LocaleStringForKey(NSShareToWechatTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.view];
  
  RELEASE_OBJ(as);

  _asOwnerType = SHARE_AS_TY;
}

- (void)downloadCoupon {
  if (_welfare.couponUrl.length > 0) {
    [self registerImageUrl:_welfare.couponUrl];
    
    [[WXWImageManager instance] fetchImage:_welfare.couponUrl
                                    caller:self
                                  forceNew:NO];
  }
}

- (void)submitOrder {
  if (_welfare.buyType.intValue != SOLD_OUT_WF_SALES_TY && _welfare.skuList.allObjects.count > 0) {
    
    NSString *skuMsg = nil;
    NSInteger i = 0;
    for (Sku *sku in _welfare.skuList.allObjects) {
      if (i == 0) {
        skuMsg = SKU_MSG(sku.skuId, sku.skuProp1, sku.salesPrice, sku.allowMultiple);
      } else {
        skuMsg = APPEND_SKU_MSG(skuMsg, sku.skuId, sku.skuProp1, sku.salesPrice, sku.allowMultiple);
      }
    }
    
    CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
    OrderViewController *orderVC = [[[OrderViewController alloc] initWithFrame:mFrame
                                                                           MOC:_MOC
                                                               paymentItemType:WELFARE_PAYMENT_TY] autorelease];
    
    [orderVC setPayOrderId:nil
                orderTitle:_welfare.itemName
                    skuMsg:skuMsg];
    
    orderVC.title = LocaleStringForKey(NSSubmitOrderTitle, nil);
    [self.navigationController pushViewController:orderVC animated:YES];
  }
}

- (void)buyItem:(id)sender {
  
  switch (_welfare.pTypeId.intValue) {
    case COUPON_WF_TY:
      [self downloadCoupon];
      break;
      
    case BUY_WF_TY:
      [self submitOrder];
      break;
      
    default:
      break;
  }
}

- (void)setCouponDownloadFlag {
  _currentType = DOWNLOAD_COUPON_TY;
  
  NSString *param = STR_FORMAT(@"<itemId>%@</itemId>", _welfare.itemId);
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
          welfare:(Welfare *)welfare
    welfareListVC:(id)welfareListVC
setReloadFlagAction:(SEL)setReloadFlagAction
{
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStylePlain
                                      needGoHome:NO];
  if (self) {
    _welfare = welfare;
        
    _welfareListVC = welfareListVC;
    
    _setReloadFlagAction = setReloadFlagAction;
    
    DELETE_OBJS_FROM_MOC(MOC, @"Store", nil);
    
    DELETE_OBJS_FROM_MOC(MOC, @"Brand", nil);
  }
  return self;
}

- (void)dealloc {
  
  self.image = nil;
  
  [super dealloc];
}

- (void)setTableViewProperties {
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  _tableView.alpha = 0.0f;
  
  _originalTableFrame = _tableView.frame;
  _originalViewFrame = self.view.frame;
  
  if (CURRENT_OS_VERSION >= IOS7) {
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, SYS_STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT,
                                  _tableView.frame.size.width,
                                  _tableView.frame.size.height - SYS_STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT);
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [self setTableViewProperties];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    [self loadDetailInfo];
  } else {
    
    if (CURRENT_OS_VERSION >= IOS7) {
      self.view.frame = _originalViewFrame;
      _tableView.frame = _originalTableFrame;
    }
    
    [_imageWallcell startPlay];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [_imageWallcell stopPlay];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {

  if (_hasStores) {
    return CELL_WITH_STORE_COUNT;
  } else {
    return CELL_WITHOUT_STORE_COUNT;
  }
}

- (WelfareCouponInfoCell *)drawCouponCell {
  static NSString *kCellIdentifier = @"couponCell";
  WelfareCouponInfoCell *cell = (WelfareCouponInfoCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[WelfareCouponInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:kCellIdentifier
                                  imageDisplayerDelegate:self
                                                     MOC:_MOC
                                                detailVC:self
                                      openUserListAction:@selector(openUserList:)] autorelease];
  }
  
  [cell drawCellWithWelfare:_welfare height:[self couponCellHeight] - WELFARE_CELL_MARGIN];
  
  return cell;
}

- (StoreEntranceCell *)drawStoreCell {
  static NSString *kCellIdentifier = @"storeCell";
  StoreEntranceCell *cell = (StoreEntranceCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[StoreEntranceCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:kCellIdentifier
                              imageDisplayerDelegate:self
                                                 MOC:_MOC
                                            detailVC:self
                                 openStoreListAction:@selector(openAllBranch:)] autorelease];
  }
  
  [cell drawCellWithWelfare:_welfare height:[self storeCellHeight] - WELFARE_CELL_MARGIN];
  
  return cell;
}

- (WelfareUseNoticeCell *)drawUseNoticeCell {
  static NSString *kCellIdentifier = @"userNoticeCell";
  WelfareUseNoticeCell *cell = (WelfareUseNoticeCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[WelfareUseNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kCellIdentifier
                                                    MOC:_MOC
                                               detailVC:self
                                             callAction:@selector(callSupport:)] autorelease];
  }
  
  [cell drawCellWithWelfare:_welfare height:[self useNoticeCellHeight] - WELFARE_CELL_MARGIN];
  
  return cell;
}

- (WelfareBrandEntranceCell *)drawBrandCell {
  static NSString *kCellIdentifier = @"brandCell";
  WelfareBrandEntranceCell *cell = (WelfareBrandEntranceCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[WelfareBrandEntranceCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:kCellIdentifier
                                     imageDisplayerDelegate:self
                                                        MOC:_MOC
                                                   detailVC:self
                                            openBrandAction:@selector(openBrandInfo:)] autorelease];
  }
  
  [cell drawCellWithWelfare:_welfare height:[self brandCellHeight] - WELFARE_CELL_MARGIN * 2 - MARGIN];
  
  return cell;
}

- (WelfareImageWallCell *)drawImageWallCell {
  
  static NSString *kCellIdentifier = @"imageWallCell";
  _imageWallcell = (WelfareImageWallCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == _imageWallcell) {
    _imageWallcell = [[[WelfareImageWallCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:kCellIdentifier
                                           imageDisplayerDelegate:self
                                                              MOC:_MOC
                                                  welfareDetailVC:self
                                                   favoriteAction:@selector(favoriteItem:)
                                                      shareAction:@selector(shareItem:)
                                                        buyAction:@selector(buyItem:)
                                                  saveImageAction:@selector(saveDisplayedImage:)] autorelease];
  }
  
  if (_autoLoaded) {
    if (!_imageWallLoaded) {
      [_imageWallcell drawCellWithWelfare:_welfare];
      
      _imageWallLoaded = YES;
    } else {
      [_imageWallcell updateFavoritedStatus:_welfare.favorited.boolValue];
    }
  }
  
  return _imageWallcell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (_hasStores) {
    
    switch (indexPath.row) {
      case IMAGE_WITH_STORE_CELL:
        return [self drawImageWallCell];
        
      case COUPON_WITH_STORE_CELL:
        return [self drawCouponCell];
        
      case STORE_CELL:
        return [self drawStoreCell];
        
      case USE_NOTICE_WITH_STORE_CELL:
        return [self drawUseNoticeCell];
        
      case BRAND_WITH_STORE_CELL:
        return [self drawBrandCell];
        
      default:
        return nil;
    }
  } else {
    
    switch (indexPath.row) {
      case IMAGE_WITHOUT_STORE_CELL:
        return [self drawImageWallCell];
        
      case COUPON_WITHOUT_STORE_CELL:
        return [self drawCouponCell];
        
      case USE_NOTICE_WITHOUT_STORE_CELL:
        return [self drawUseNoticeCell];
        
      case BRAND_WITHOUT_STORE_CELL:
        return [self drawBrandCell];
        
      default:
        return nil;
    }
  }
}

- (CGFloat)couponCellHeight {
  
  CGFloat textLimitedWidth = self.view.frame.size.width - WELFARE_CELL_MARGIN * 2 - CELL_INNER_MARGIN * 2;
  
  CGFloat height = CELL_INNER_MARGIN;
  CGSize size = [LocaleStringForKey(NSCouponInfoTitle, nil) sizeWithFont:BOLD_FONT(20)];
  
  height += size.height + CELL_INNER_MARGIN;
  
  size = [_welfare.itemName sizeWithFont:BOLD_FONT(18) constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  height += size.height + CELL_INNER_MARGIN;
  
  height += CELL_INNER_MARGIN;
  
  if (_welfare.offersTips.length > 0) {
    size = [_welfare.offersTips sizeWithFont:BOLD_FONT(13) constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
    height += size.height + CELL_INNER_MARGIN;
  } else {
    height += CELL_INNER_MARGIN * 2;
  }
  
  height += USER_PHOTO_SIDE_LEN + CELL_INNER_MARGIN;
  
  size = [_welfare.endTime sizeWithFont:BOLD_FONT(13)];
  height += size.height + CELL_INNER_MARGIN;
  
  height += WELFARE_CELL_MARGIN;
  
  return height;
}

- (CGFloat)storeCellHeight {
  
  CGFloat textLimitedWidth = self.view.frame.size.width - WELFARE_CELL_MARGIN * 2 - CELL_INNER_MARGIN * 2 - STORE_IMG_SIDE_LEN - CELL_INNER_MARGIN * 2;
  
  CGFloat height = CELL_INNER_MARGIN;
  
  CGSize size = [LocaleStringForKey(NSAllowedBranchsTitle, nil) sizeWithFont:BOLD_FONT(20)];
  height += size.height + CELL_INNER_MARGIN;
  
  CGFloat photoY = height + STORE_IMG_SIDE_LEN;
  
  size = [_welfare.storeName sizeWithFont:BOLD_FONT(18) constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  height += size.height + CELL_INNER_MARGIN;
  
  size = [_welfare.storeAddress sizeWithFont:BOLD_FONT(13) constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  height += size.height;
  
  CGFloat textY = height;
  
  CGFloat bottonY = textY > photoY ? textY : photoY;
  
  height = bottonY + CELL_INNER_MARGIN * 2;
  
  size = [[NSString stringWithFormat:LocaleStringForKey(NSCheckAllStoreMsg, nil), _welfare.storeCount] sizeWithFont:BOLD_FONT(13)
                                                                                                  constrainedToSize:CGSizeMake(self.view.frame.size.width - WELFARE_CELL_MARGIN * 2 - CELL_INNER_MARGIN * 2, CGFLOAT_MAX)];
  height += size.height + CELL_INNER_MARGIN * 2;
  
  height += WELFARE_CELL_MARGIN;
  
  return height;
}

- (CGFloat)useNoticeCellHeight {
  CGFloat textLimitedWidth = self.view.frame.size.width - WELFARE_CELL_MARGIN * 2 - CELL_INNER_MARGIN * 2 - MARGIN - MARGIN;
  
  CGFloat height = CELL_INNER_MARGIN;
  
  CGSize size = [LocaleStringForKey(NSUseNoticeTitle, nil) sizeWithFont:BOLD_FONT(20)];
  height += size.height + CELL_INNER_MARGIN;
  
  size = [_welfare.useInfo sizeWithFont:BOLD_FONT(13)
                      constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  height += size.height + CELL_INNER_MARGIN;
  
  size = [LocaleStringForKey(NSContactWelfareSupportMsg, nil) sizeWithFont:BOLD_FONT(13)
                                                         constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  height += size.height + CELL_INNER_MARGIN;
  
  size = [_welfare.tel sizeWithFont:BOLD_FONT(13)];
  height += size.height + CELL_INNER_MARGIN * 2;
  
  return height;
}

- (CGFloat)brandCellHeight {
  
  CGFloat textLimitedWidth = /*self.view.frame.size.width*/302 - WELFARE_CELL_MARGIN * 2 - CELL_INNER_MARGIN * 2 - STORE_IMG_SIDE_LEN - CELL_INNER_MARGIN * 2;
  
  CGFloat height = CELL_INNER_MARGIN;
  
  CGSize size = [LocaleStringForKey(NSBrandInfoTitle, nil) sizeWithFont:BOLD_FONT(20)];
  height += size.height + CELL_INNER_MARGIN;
  
  CGFloat photoY = height + STORE_IMG_SIDE_LEN;
  
  size = [_welfare.brandName sizeWithFont:BOLD_FONT(18) constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  height += size.height + CELL_INNER_MARGIN;
  
  size = [_welfare.brandEngName sizeWithFont:BOLD_FONT(13) constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  height += size.height;
  
  CGFloat textY = height;
  
  CGFloat bottonY = textY > photoY ? textY : photoY;
  
  height = bottonY + CELL_INNER_MARGIN * 2;
  
  size = [LocaleStringForKey(NSAlumniWorkedInCompanyTitle, nil) sizeWithFont:BOLD_FONT(13)
                                                           constrainedToSize:CGSizeMake(self.view.frame.size.width - WELFARE_CELL_MARGIN * 2 - CELL_INNER_MARGIN * 2, CGFLOAT_MAX)];
  height += size.height + CELL_INNER_MARGIN * 2;
  
  height += WELFARE_CELL_MARGIN * 2;
  
  return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (_hasStores) {
    switch (indexPath.row) {
      case IMAGE_WITH_STORE_CELL:
        return WALL_HEIGHT + PRICE_VIEW_HEIGHT;
        
      case COUPON_WITH_STORE_CELL:
        return [self couponCellHeight];
        
      case STORE_CELL:
        return [self storeCellHeight];
        
      case USE_NOTICE_WITH_STORE_CELL:
        return [self useNoticeCellHeight];
        
      case BRAND_WITH_STORE_CELL:
        return [self brandCellHeight];
        
      default:
        return 0;
    }
  } else {
    switch (indexPath.row) {
      case IMAGE_WITHOUT_STORE_CELL:
        return WALL_HEIGHT + PRICE_VIEW_HEIGHT;
        
      case COUPON_WITHOUT_STORE_CELL:
        return [self couponCellHeight];
                
      case USE_NOTICE_WITHOUT_STORE_CELL:
        return [self useNoticeCellHeight];
        
      case BRAND_WITHOUT_STORE_CELL:
        return [self brandCellHeight];
        
      default:
        return 0;
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (_hasStores) {
    switch (indexPath.row) {
        
      case STORE_CELL:
      {
        VenueListViewController *venueListVC = [[[VenueListViewController alloc] initNearbyVenuesWithMOC:_MOC
                                                                                       locationRefreshed:YES
                                                                                                 welfare:_welfare] autorelease];
        venueListVC.title = LocaleStringForKey(NSAllBranchesTitle, nil);
        [self.navigationController pushViewController:venueListVC animated:YES];
      }
        break;
                
      case BRAND_WITH_STORE_CELL:
      {
        
        WelfareBrandViewController * brandVC = [[[WelfareBrandViewController alloc] initWithWelfare:_welfare MOC:_MOC] autorelease];
        brandVC.title = LocaleStringForKey(NSBrandDetailTitle, nil);
        [self.navigationController pushViewController:brandVC animated:YES];
        break;
      }
        
      default:
        break;
    }
  } else {
   
    switch (indexPath.row) {        
      case BRAND_WITHOUT_STORE_CELL:
      {
        
        WelfareBrandViewController * brandVC = [[[WelfareBrandViewController alloc] initWithWelfare:_welfare MOC:_MOC] autorelease];
        brandVC.title = LocaleStringForKey(NSBrandDetailTitle, nil);
        [self.navigationController pushViewController:brandVC animated:YES];
        break;
      }
        
      default:
        break;
    }
  }
}


#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  switch (contentType) {
    case WELFARE_DETAIL_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        _welfare = (Welfare *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                        entityName:@"Welfare"
                                                         predicate:[NSPredicate predicateWithFormat:@"(itemId == %@)", _welfare.itemId]];
        
        _autoLoaded = YES;
        
        _hasStores = _welfare.storeCount.intValue > 0 ? YES : NO;
        
        [_tableView reloadData];
        
        _tableView.alpha = 1.0f;
      }
      break;
    }
      
    case DOWNLOAD_COUPON_TY:
    {
      [XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url];
      break;
    }
      
    case FAVORITE_WELFARE_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        _welfare.favorited = @(!_welfare.favorited.boolValue);
        SAVE_MOC(_MOC);
        
        [_imageWallcell updateFavoritedStatus:_welfare.favorited.boolValue];
        
        // set welfare list reload flag
        if (_welfareListVC && _setReloadFlagAction) {
          [_welfareListVC performSelector:_setReloadFlagAction];
        }
      }
      break;
    }
    default:
      break;
  }
  
  [super connectDone:result
                 url:url
         contentType:contentType];
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

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_asOwnerType) {
    case CALL_AS_TY:
    {
      switch (buttonIndex) {
        case CALL_ACTION_SHEET_IDX:
        {
          if (_welfare.tel.length > 0) {
            NSString *phoneNumber = [_welfare.tel stringByReplacingOccurrencesOfString:@" " withString:NULL_PARAM_VALUE];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:NULL_PARAM_VALUE];
            NSString *phoneStr = [[NSString alloc] initWithFormat:@"tel:%@", phoneNumber];
            NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
            [[UIApplication sharedApplication] openURL:phoneURL];
            [phoneURL release];
            [phoneStr release];
          }
          break;
        }
        default:
          break;
      }
      break;
    }
      
    case SHARE_AS_TY:
    {
      if (buttonIndex == 0) {
        [CommonUtils shareWelfare:_welfare image:self.image];
      }
      break;
    }
      
    default:
      break;
  }
  
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  [UIUtils showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
                toBeBlockedView:self.view];
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
  
  [self setCouponDownloadFlag];
  
  [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCouponSaveToAlbumMsg, nil)
                                msgType:SUCCESS_TY
                     belowNavigationBar:YES];
  [UIUtils closeAsyncLoadingView];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  [UIUtils closeAsyncLoadingView];
}


@end
