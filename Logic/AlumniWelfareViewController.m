//
//  AlumniWelfareViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-13.
//
//

#import "AlumniWelfareViewController.h"
#import "AlumniWelfareViewCell.h"
#import "ProvideWelfareViewController.h"
#import "WaterflowView.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "UIImageButton.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "Welfare.h"
#import "WelfareDetailViewController.h"
#import "WXWImageDisplayerDelegate.h"
#import "ILBarButtonItem.h"
#import "WXWBarItemButton.h"
#import "WXWLabel.h"

#define WELFARE_TOOLBAR_HEIGHT          33.5
#define SUBMIT_BUTTON_WIDTH         200.0f
#define SUBMIT_BUTTON_HEIGHT        33.5
#define HIGH_CELL_H                 205
#define LOW_CELL_H                  174

@interface AlumniWelfareViewController () <WaterflowViewDataSource,WaterflowViewDelegate, WXWImageDisplayerDelegate>

@property (nonatomic, retain) WaterflowView *waterflowView;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSString *itemTypeId;

@property (nonatomic, retain) UINavigationController *filterNavVC;
@property (nonatomic, retain) UIView *filterViewOverlay;

@end

@implementation AlumniWelfareViewController

#pragma mark - user action
- (void)close:(id)sender {
  if (self.delegate) {
    [self.delegate backToParent];
    
    [self displayNavigationItemBar];
  }
}

- (void)setNeedReloadFlag {
  _needReload = YES;
}

#pragma mark - life cycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)pVC
{
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 tableStyle:UITableViewStylePlain
                 needGoHome:NO];
  if (self) {
    // Custom initialization
    [self clearData];
    
    self.parentVC = pVC;
    
    [self resetFilter];
    
    _canOpenProvider = YES;
    
    _currentStartIndex = 1;
  }
  return self;
}

- (id)initFavoritedWelfareWithMOC:(NSManagedObjectContext *)MOC parentVC:(UIViewController *)pVC {
  self = [self initWithMOC:MOC parentVC:pVC];
  if (self) {
    self.itemTypeId = STR_FORMAT(@"%d", FAVORITE_WF_TY);
    
    _forFavorited = YES;
  }
  return self;
}

- (void)resetFilter {
  
  [AppManager instance].filterSupIndex = 0;
  [AppManager instance].filterIndex = 0;
  
  // reset filter stuff
  [self resetFilterData];
  
  self.itemTypeId = @"0";
}

- (void)dealloc {
  
  self.waterflowView.delegate = nil;
  self.waterflowView.dataSource = nil;
  self.waterflowView = nil;
  
  self.images = nil;
  self.itemTypeId = nil;
  
  self.filterNavVC = nil;
  self.filterViewOverlay = nil;
  
  [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_filterDataLoaded) {
    [self getWelfareFilterData];
  }
  
  if (_needReload) {
    
    [self clearData];
    [self refreshTable];
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
    _needReload = NO;
  }
}

- (void)adjustTableView {
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width,
                                _tableView.frame.size.height - NAVIGATION_BAR_HEIGHT);
}

- (void)addTopToolBar {
  UIView *tool = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOOLBAR_HEIGHT)] autorelease];
  tool.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationBarBackground.png"]];
  [self.view addSubview:tool];
  
  WXWBarItemButton *backButton = [[[WXWBarItemButton alloc] initBackStyleButtonWithFrame:CGRectMake(0, 0, 48, 44)] autorelease];
  [backButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
  [tool addSubview:backButton];
  backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
  
  if (!_forFavorited) {
    _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBtn.tag = MOVE_TO_LEFT_TY;
    _searchBtn.showsTouchWhenHighlighted = YES;
    [_searchBtn setFrame:CGRectMake(tool.frame.size.width - 46.0f, (TOOLBAR_HEIGHT - 40)/2.0f, 46.0f, 40.f)];
    [_searchBtn addTarget:self action:@selector(clickFilterMenu:) forControlEvents:UIControlEventTouchUpInside];
    [_searchBtn setImage:[UIImage imageNamed:@"btnSearchWhite.png"] forState:UIControlStateNormal];
    [_searchBtn setImage:[UIImage imageNamed:@"btnSearchWhite.png"] forState:UIControlStateHighlighted];
    [tool addSubview:_searchBtn];
  }
  
  WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:[UIColor whiteColor]
                                         shadowColor:TRANSPARENT_COLOR
                                                font:BOLD_FONT(20)] autorelease];
  label.textAlignment = NSTextAlignmentCenter;
  if (_forFavorited) {
    label.text = LocaleStringForKey(NSFavoritedWelfareTitle, nil);
  } else {
    label.text = LocaleStringForKey(NSAlumniExclusiveTitle, nil);
  }
  
  CGSize size = [label.text sizeWithFont:label.font];
  label.frame = CGRectMake((tool.frame.size.width - size.width)/2.0f,
                           (tool.frame.size.height - size.height)/2.0f, size.width, size.height);
  [tool addSubview:label];
}

- (void)addBottomToolbar {
  _bottomToolDisplayedY = self.view.frame.size.height - WELFARE_TOOLBAR_HEIGHT;
  if (CURRENT_OS_VERSION >= IOS7) {
    _bottomToolDisplayedY = self.view.frame.size.height - 20 - WELFARE_TOOLBAR_HEIGHT;
  }
  
  _bottomToolHiddenY = _bottomToolDisplayedY + WELFARE_TOOLBAR_HEIGHT;
  
  _bottomToolbar = [[[UIView alloc] initWithFrame:CGRectMake(0, _bottomToolHiddenY, self.view.frame.size.width, WELFARE_TOOLBAR_HEIGHT)] autorelease];
  _bottomToolbar.backgroundColor = TRANSPARENT_COLOR;
  [self.view addSubview:_bottomToolbar];
  
  UIImageButton *submitButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SUBMIT_BUTTON_HEIGHT)
                                                                          target:self
                                                                          action:@selector(doProvideWelfare:)
                                                                           title:LocaleStringForKey(NSWantProvideBenefitTitle, nil)
                                                                           image:[UIImage imageNamed:@"provideWelfare.png"]
                                                                     backImgName:@"welfareBottom.png"
                                                                  selBackImgName:nil
                                                                       titleFont:BOLD_FONT(15)
                                                                      titleColor:[UIColor whiteColor]
                                                                titleShadowColor:TRANSPARENT_COLOR
                                                                     roundedType:NO_ROUNDED
                                                                 imageEdgeInsert:UIEdgeInsetsMake(7, 109, 7, 198)
                                                                 titleEdgeInsert:ZERO_EDGE] autorelease];
  [submitButton setAlpha:0.7];
  [_bottomToolbar addSubview:submitButton];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self adjustTableView];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [self addTopToolBar];
  
  [self addWaterFlowView];
  
  [self addBottomToolbar];
}

- (void)addWaterFlowView {
  
  self.waterflowView = [[[WaterflowView alloc] initWithFrame:CGRectMake(0, TOOLBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - SYS_STATUS_BAR_HEIGHT)] autorelease];
	self.waterflowView.delegate = self;
	self.waterflowView.dataSource = self;
	
	[self.view addSubview:self.waterflowView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (NSString *)imageAtIndexPath:(NSIndexPath *)indexPath {
  
  Welfare *welfare = (Welfare *)[self.fetchedRC objectAtIndexPath:indexPath];
  return welfare.imageUrl;
}

#pragma mark - WaterflowViewDelegate method

- (NSInteger)quiltViewNumberOfCells:(WaterflowView *)WaterflowView {
  return [self.fetchedRC.fetchedObjects count];
}

- (AlumniWelfareViewCell *)quiltView:(WaterflowView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *kCellIdentifier = @"WaterflowViewCell";
  
  AlumniWelfareViewCell *cell = (AlumniWelfareViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[AlumniWelfareViewCell alloc] initWithReuseIdentifier:kCellIdentifier
                                            imageDisplayerDelegate:self] autorelease];
  }
  Welfare *welfare = (Welfare *)[self.fetchedRC objectAtIndexPath:indexPath];
  [cell drawWelfare:welfare index:[indexPath row]];
  return cell;
}

- (NSInteger)quiltViewNumberOfColumns:(WaterflowView *)quiltView {
  
  if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
      || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
	{
    return 3;
  } else {
    return 2;
  }
}

- (CGFloat)quiltView:(WaterflowView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
  int row = [indexPath row];
  if (row %2 == 0) {
    return LOW_CELL_H;
  }
  return HIGH_CELL_H;
}

- (void)enterWelfareDetailWithWelfare:(Welfare *)welfare {
  WelfareDetailViewController *detailVC = [[[WelfareDetailViewController alloc] initWithMOC:_MOC
                                                                                    welfare:welfare
                                                                              welfareListVC:self
                                                                        setReloadFlagAction:@selector(setNeedReloadFlag)] autorelease];
  detailVC.title = LocaleStringForKey(NSWelfareDetailTitle, nil);
  if (self.delegate && [self.delegate isKindOfClass:[UIViewController class]]) {
    [((UIViewController *)self.delegate).navigationController pushViewController:detailVC animated:YES];
  }
  
  [self performSelector:@selector(displayNavigationItemBar) withObject:nil afterDelay:0.1f];
}

- (void)quiltView:(WaterflowView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
  // 进入优惠明细
  Welfare *welfare = (Welfare *)[self.fetchedRC objectAtIndexPath:indexPath];
  switch (welfare.pTypeId.intValue) {
    case EXHIBITION_WF_TY:
      
      break;
      
    case COUPON_WF_TY:
    case BUY_WF_TY:
      [self enterWelfareDetailWithWelfare:welfare];
      break;
      
    default:
      break;
  }
}

- (void)getWelfareFilterData {
  _currentType = WELFARE_TYPE_TY;
  NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:_currentType];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  [connFacade fetchGets:url];
}

#pragma mark - load news
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = WELFARE_LIST_TY;
  
  NSInteger index = 1;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSString *param = nil;
  
  if (self.itemTypeId.intValue == FAVORITE_WF_TY) {
    param = [NSString stringWithFormat:@"<page>%d</page><pageSize>%@</pageSize><itemName></itemName><itemTypeId></itemTypeId><isFavorite>%d</isFavorite>", index, ITEM_LOAD_COUNT, 1];
  } else {
    param = [NSString stringWithFormat:@"<page>%d</page><pageSize>%@</pageSize><itemName>%@</itemName><itemTypeId>%@</itemTypeId>", index, /*ITEM_LOAD_COUNT*/@"5", [AppManager instance].searchKeyWords, self.itemTypeId];
  }
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - hide / display bottom tool bar
- (void)displayBottomToolbar {
  
  [UIView animateWithDuration:0.2f
                        delay:0.1f
                      options:UIViewAnimationOptionTransitionNone
                   animations:^{
                     
                     _bottomToolbar.frame = CGRectMake(_bottomToolbar.frame.origin.x,
                                                       _bottomToolDisplayedY, _bottomToolbar.frame.size.width,
                                                       _bottomToolbar.frame.size.height);
                   }
                   completion:^(BOOL finished){
                     
                   }];
  
}

- (void)hideBottomToolbar {
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _bottomToolbar.frame = CGRectMake(_bottomToolbar.frame.origin.x,
                                                       _bottomToolHiddenY, _bottomToolbar.frame.size.width,
                                                       _bottomToolbar.frame.size.height);
                   }];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:NO];
  
  _loadingData = YES;
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  _loadingData = NO;
  
  switch (contentType) {
    case WELFARE_TYPE_TY:
    {
      if ([XMLParser handleWelfareFilterData:result MOC:_MOC] == RESP_OK) {
        [self resetFilterData];
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
        
        _filterDataLoaded = YES;
      } else {
        
        _searchBtn.enabled = NO;
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadWelfareFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
    }
      break;
      
    case WELFARE_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:self.MOC
                     connectorDelegate:self
                                   url:url]) {
        
        if (!_autoLoaded) {
          _autoLoaded = YES;
        }
        
        [self refreshTable];
        
        if ([self listIsEmpty]) {
          self.waterflowView.alpha = 0;
        } else {
          self.waterflowView.alpha = 1.0f;
        }
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadWelfareFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      if (!_scrolling) {
        [self displayBottomToolbar];
      }
    }
      break;
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  if (WELFARE_TYPE_TY == contentType) {
    _searchBtn.enabled = NO;
  }
  
  _loadingData = NO;
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSLoadWelfareFailedMsg, nil);
  }
  
  if (!_scrolling) {
    [self displayBottomToolbar];
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  if (_loadingData) {
    return NO;
  } else {
    return [super listIsEmpty];
  }
}

#pragma mark - set predicate
- (void)configureMOCFetchConditions {
  
  self.entityName = @"Welfare";
  self.descriptors = [NSMutableArray array];
  
  NSSortDescriptor *timestampDesc = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
  [self.descriptors addObject:timestampDesc];
  
  self.predicate = nil;
}

- (void)refreshTable {
  
  [super refreshTable];
  
  if ([self.fetchedRC.fetchedObjects count] > 0) {
    [self.waterflowView reloadData];
  }
}

- (void)clearData {
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Welfare", nil);
}

#pragma mark - click Filter Menu
-(void)clickFilterMenu:(id)sender {
  
  [AppManager instance].searchKeyWords = NULL_PARAM_VALUE;
  
  if (self.delegate) {
    
    switch (_searchBtn.tag) {
      case RESET_MAIN_TY:
        [self.delegate resetPanelPosition];
        break;
        
      case MOVE_TO_LEFT_TY:
        [self.delegate movePanelLeft];
        break;
        
      default:
        break;
    }
  }
  
}

#pragma mark - handle vc

- (void)setShowingFilter:(BOOL)flag {
  _showingFilter = flag;
}

- (void)setViewMoveWayType:(ScrollMoveWayType)tag {
  
  _searchBtn.tag = tag;
}

- (void)extendFilterVC
{
  
  [self.parentVC.navigationController.view setFrame:CGRectMake(0-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
  [self.filterNavVC.view setFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, SCREEN_HEIGHT)];
  [self removeFilterView];
  
}

- (void)recoveryMainVC
{
  
  self.itemTypeId = [[AppManager instance].welfareTypeList objectAtIndex:[AppManager instance].filterSupIndex][RECORD_ID_IDX];
  
  [self clearData];
  [self refreshTable];
  [self.waterflowView reloadData];
  
  [self hideFilterView:nil];
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)disableTableScroll {
  self.waterflowView.scrollEnabled = NO;
  _tableView.scrollEnabled = NO;
  self.waterflowView.userInteractionEnabled = NO;
}

- (void)enableTableScroll {
  self.waterflowView.scrollEnabled = YES;
  _tableView.scrollEnabled = YES;
  self.waterflowView.userInteractionEnabled = YES;
}

- (BOOL)tableScrolling {
  return _scrolling;
}

#pragma mark - Filter View option
- (void)initFilterView:(CGRect)frame {
  self.filterViewOverlay = [[[UIView alloc]
                             initWithFrame:frame] autorelease];
  self.filterViewOverlay.backgroundColor = [UIColor clearColor];
  self.filterViewOverlay.alpha = 0;
  
  if (!_forFavorited) {
    [self addTapGestureRecognizer];
  }
}

- (void)showFilterView {
  self.filterViewOverlay.alpha = 0;
  [self.view addSubview:self.filterViewOverlay];
  
  [UIView beginAnimations:@"FadeIn" context:nil];
  [UIView setAnimationDuration:0.5];
  self.filterViewOverlay.alpha = 0.6;
  self.filterViewOverlay.userInteractionEnabled = YES;
  [UIView commitAnimations];
  
}

- (void)removeFilterView {
  if (self.delegate) {
    [self.delegate resetPanelPosition];
  }
}

- (void)addTapGestureRecognizer {
  UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFilterView:)] autorelease];
  [self.filterViewOverlay addGestureRecognizer:tap];
}

- (void)hideFilterView:(id)sender {
  
  [self enableTableScroll];
  
  [UIView animateWithDuration:0.5 animations:^(void){
    if (self.filterNavVC) {
      [self.filterNavVC removeFromParentViewController];
      [self.filterNavVC.view removeFromSuperview];
    }
  } completion:^(BOOL finished) {
    self.parentVC.navigationController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self removeFilterView];
  }];
}

#pragma mark - Scroll

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  _scrolling = YES;
  
  [self hideBottomToolbar];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  _scrolling = NO;

  [self displayBottomToolbar];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if ([UIUtils shouldLoadOlderItems:scrollView
                    tableViewHeight:scrollView.contentSize.height
                         footerView:_footerRefreshView
                          reloading:_reloading]) {
    
    _reloading = YES;
    
    [self loadListData:TRIGGERED_BY_SCROLL forNew:NO];
  }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  
  if (!decelerate) {
    
    _scrolling = NO;
  
    [self displayBottomToolbar];
  }
}

#pragma mark - set navigation button item
- (void)displayNavigationItemBar {
  if (self.parentVC) {
    [(WXWNavigationController *)self.parentVC.parentViewController setNavigationBarHidden:NO];
  }
}

#pragma mark - reset filter data
- (void)resetMutableArray:(NSMutableArray *)contentList index:(NSInteger)index {
  if (contentList.count > 0) {
    if (contentList.count >= RECORD_SELECTION_IDX + 1) {
      
      if (index > 0) {
        contentList[RECORD_SELECTION_IDX] = @(UNSELECTED_TY);
      } else {
        contentList[RECORD_SELECTION_IDX] = @(SELECTED_TY);
      }
    }
  }
}

-(void)resetFilterData {
  for (NSInteger i = 0; i < [AppManager instance].welfareTypeList.count; i++) {
    [self resetMutableArray:(NSMutableArray *)[AppManager instance].welfareTypeList[i] index:i];
  }
}

- (void)doProvideWelfare:(id)sender
{
  if (_canOpenProvider) {
    
    ProvideWelfareViewController *provideWelfareVC = [[[ProvideWelfareViewController alloc] initWithMOC:_MOC] autorelease];
    provideWelfareVC.title = LocaleStringForKey(NSWantProvideBenefitTitle, nil);
    
    if (self.delegate && [self.delegate isKindOfClass:[UIViewController class]]) {
      [((UIViewController *)self.delegate).navigationController pushViewController:provideWelfareVC animated:YES];
    }
    
    [self performSelector:@selector(displayNavigationItemBar) withObject:nil afterDelay:0.1f];
  }
}

#pragma mark - gesture controllers
- (void)enableTapGotoDetail {
  self.waterflowView.tapEnable = YES;
  
  _canOpenProvider = YES;
}

- (void)disableTapGotoDetail {
  self.waterflowView.tapEnable = NO;
  
  _canOpenProvider = NO;
}

@end
