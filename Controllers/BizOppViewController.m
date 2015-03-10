//
//  BizOppViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-13.
//
//

#import "BizOppViewController.h"
#import "BizOppWallView.h"
#import "AlumniEntranceItemCell.h"
#import "SupplyDemandListViewController.h"
#import "News.h"
#import "UIWebViewController.h"
#import "WXWNavigationController.h"
#import "AlumniWelfareViewController.h"
#import "WelfareMainFallViewController.h"
#import "RectCellAreaView.h"
#import "CommonUtils.h"
#import "AppManager.h"

#define CELL_COUNT  4

#define EXAMPLE_AREA_35INCH_HEIGHT   150.0f

#define GRID_HEIGHT       100
#define GRID_CELL_HEIGHT  GRID_HEIGHT + MARGIN * 2

enum {
  BRAND_CELL,
  ITEM_CELL,
  FAVORITE_ITEM_CELL,
  FAVORITE_WELFARE_CELL
};

@interface BizOppViewController ()

@end

@implementation BizOppViewController

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
parentViewController:(UIViewController *)parentViewController {
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStylePlain
                                      needGoHome:NO];
  if (self) {
    self.parentVC = parentViewController;
    
    _viewHeight = viewHeight;
    
    if (CURRENT_OS_VERSION >= IOS7) {
      _needAdjustForiOS7 = YES;
    }
  }
  return self;
}

- (void)dealloc {
  
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

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [self adjustTableLayout];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - user actions

- (void)pushVC:(WXWRootViewController *)vc {
  [_bizOppWallView stopPlay];
  
  if (self.parentVC) {
    [self.parentVC.navigationController pushViewController:vc animated:YES];
  }
}

- (void)openWelfare {
  WelfareMainFallViewController *welfareVC = [[[WelfareMainFallViewController alloc] initWithMOC:_MOC parentVC:self.parentVC] autorelease];
  welfareVC.title = LocaleStringForKey(NSAlumniCouponTitle, nil);
  
  if (self.parentVC) {
    [self.parentVC.navigationController pushViewController:welfareVC animated:YES];
  }
}

- (void)openSupplyDemand {
  SupplyDemandListViewController *supplyDemandListVC = [[[SupplyDemandListViewController alloc] initWithMOC:_MOC needAdjustForiOS7:_needAdjustForiOS7] autorelease];
  supplyDemandListVC.title = LocaleStringForKey(NSAllSupplyDemandTitle, nil);
  [self pushVC:supplyDemandListVC];
  
  if (CURRENT_OS_VERSION >= IOS7 && [self.parentVC respondsToSelector:@selector(displayNavigationBarForiOS7)]) {
    [self.parentVC performSelector:@selector(displayNavigationBarForiOS7)];
  }
}

- (void)openBrands:(News *)news {
  if (news) {
    UIWebViewController *webVC = [[[UIWebViewController alloc] initWithNeedAdjustForiOS7:_needAdjustForiOS7] autorelease];
    WXWNavigationController *webViewNav = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
    webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
    
    if (news.url.length > 0) {
      
      NSString *url = STR_FORMAT(@"%@&user_id=%@&local=%@", news.url, [AppManager instance].personId, [WXWSystemInfoManager instance].currentLanguageDesc);
      
      webVC.strUrl = url;
      
      [self.parentVC presentModalViewController:webViewNav
                                       animated:YES];
      
      webVC.view.frame = CGRectMake(0, webVC.view.frame.origin.y, webVC.view.frame.size.width, webVC.view.frame.size.height + SYS_STATUS_BAR_HEIGHT);
    }
  }
  
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return CELL_COUNT;
}

- (UITableViewCell *)drawBrandCell {
  static NSString *kCellIdentifier = @"brandCell";
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kCellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = TRANSPARENT_COLOR;
    cell.contentView.backgroundColor = TRANSPARENT_COLOR;
    
    _bizOppWallView = [[[BizOppWallView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2,
                                                                        self.view.frame.size.width -
                                                                        MARGIN * 4, EXAMPLE_AREA_35INCH_HEIGHT)
                                      imageDisplayerDelegate:self
                                      connectTriggerDelegate:self
                                                         MOC:self.MOC
                                                    entrance:self
                                                      action:@selector(openBrands:)] autorelease];
    [cell.contentView addSubview:_bizOppWallView];
    
  }
  
  return cell;
}

- (void)setItemCellInfoWithLeftImage:(UIImage **)leftImage
                           leftTitle:(NSString **)leftTitle
                        leftSubTitle:(NSString **)leftSubTitle
                          leftAction:(SEL *)leftAction
                    rightNumberBadge:(NSInteger *)rightNumberBadge
                          rightImage:(UIImage **)rightImage
                          rightTitle:(NSString **)rightTitle
                       rightSubTitle:(NSString **)rightSubTitle
                         rightAction:(SEL *)rightAction {
  
  *leftImage = [UIImage imageNamed:@"whiteSupplyDemand.png"];
  *leftTitle = LocaleStringForKey(NSAllSupplyDemandTitle, nil);
  *leftAction = @selector(openSupplyDemand);
  
  *rightImage = [UIImage imageNamed:@"welfare.png"];
  *rightTitle = LocaleStringForKey(NSAlumniExclusiveTitle, nil);
  *rightAction = @selector(openWelfare);
  
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
  
  [self setItemCellInfoWithLeftImage:&leftImage
                           leftTitle:&leftTitle
                        leftSubTitle:&leftSubTitle
                          leftAction:&leftAction
                    rightNumberBadge:&rightNumberBadge
                          rightImage:&rightImage
                          rightTitle:&rightTitle
                       rightSubTitle:&rightSubTitle
                         rightAction:&rightAction];
  leftColor = COLOR(82, 146, 211);
  rightColor = COLOR(26, 188, 156);
  
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

- (UITableViewCell *)drawFavoriteItemCell {
  static NSString *kCellIdentifier = @"favoriteItemCell";
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  
  if (cell == nil) {
    
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    cell.backgroundColor = TRANSPARENT_COLOR;
    cell.contentView.backgroundColor = TRANSPARENT_COLOR;
    
    _favoriteItemArea = [[[RectCellAreaView alloc] initWithFrame:CGRectMake(MARGIN * 2, 0, self.view.frame.size.width - MARGIN * 4, DEFAULT_CELL_HEIGHT)] autorelease];
    [cell.contentView addSubview:_favoriteItemArea];
  }
  
  [_favoriteItemArea drawWithNeedBottomLine:NO title:LocaleStringForKey(NSFavoritedItemTitle, nil)];
  
  return cell;
}

- (UITableViewCell *)drawFavoriteWelfareCell {
  static NSString *kCellIdentifier = @"favoriteWelfareCell";
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  
  if (cell == nil) {
    
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = TRANSPARENT_COLOR;
    cell.contentView.backgroundColor = TRANSPARENT_COLOR;

    _favoriteWelfareArea = [[[RectCellAreaView alloc] initWithFrame:CGRectMake(MARGIN * 2, 0, self.view.frame.size.width - MARGIN * 4, DEFAULT_CELL_HEIGHT)] autorelease];
    [cell.contentView addSubview:_favoriteWelfareArea];

  }
  
  [_favoriteWelfareArea drawWithNeedBottomLine:YES title:LocaleStringForKey(NSFavoritedWelfareTitle, nil)];
  
  return cell;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.row) {
    case BRAND_CELL:
      return [self drawBrandCell];

    case ITEM_CELL:
      return [self drawItemCell:indexPath];
      
    case FAVORITE_ITEM_CELL:
      return [self drawFavoriteItemCell];
      
    case FAVORITE_WELFARE_CELL:
      return [self drawFavoriteWelfareCell];
      
    default:
      return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case BRAND_CELL:
      return EXAMPLE_AREA_35INCH_HEIGHT + MARGIN * 4;

    case ITEM_CELL:
      return GRID_CELL_HEIGHT;
      
    case FAVORITE_ITEM_CELL:
      return DEFAULT_CELL_HEIGHT;
      
    case FAVORITE_WELFARE_CELL:
      return DEFAULT_CELL_HEIGHT;

    default:
      return 0;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  switch (indexPath.row) {
    case FAVORITE_ITEM_CELL:
    {
      SupplyDemandListViewController *supplyDemandListVC = [[[SupplyDemandListViewController alloc] initFavoritedItemsWithMOC:_MOC needAdjustForiOS7:_needAdjustForiOS7] autorelease];
      supplyDemandListVC.title = LocaleStringForKey(NSFavoritedItemTitle, nil);
      
      [self pushVC:supplyDemandListVC];
      
      if (CURRENT_OS_VERSION >= IOS7 && [self.parentVC respondsToSelector:@selector(displayNavigationBarForiOS7)]) {
        [self.parentVC performSelector:@selector(displayNavigationBarForiOS7)];
      }
      
      break;
    }
      
    case FAVORITE_WELFARE_CELL:
    {
      WelfareMainFallViewController *welfareListVC = [[[WelfareMainFallViewController alloc] initFavoritedWelfareWithMOC:_MOC parentVC:self.parentVC] autorelease];
      welfareListVC.title = LocaleStringForKey(NSFavoritedWelfareTitle, nil);
      [self pushVC:welfareListVC];
      
      break;
    }
      
    default:
      break;
  }
}

@end
