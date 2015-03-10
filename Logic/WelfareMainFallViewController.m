//
//  WelfareMainFallViewController.m
//  iAlumni
//
//  Created by Adam on 13-9-4.
//
//

#import "WelfareMainFallViewController.h"
#import "AlumniWelfareViewController.h"
#import "AppManager.h"
#import "CommonUtils.h"

#define PANEL_WIDTH   60.0f

#define HORIZONTAL_RIGHT_THRESHOLD    self.view.frame.size.width/2.0f


@interface WelfareMainFallViewController ()

@end

@implementation WelfareMainFallViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC{
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
                 needGoHome:NO];
  if (self) {
    _parentVC = parentVC;
  }
  return self;
}

- (id)initFavoritedWelfareWithMOC:(NSManagedObjectContext *)MOC parentVC:(UIViewController *)pVC {
  self = [self initWithMOC:MOC parentVC:pVC];
  
  if (self) {
    _forFavorited = YES;
  }
  return self;
}

- (void)dealloc {
  
  _welfareListVC.delegate = nil;
  
  RELEASE_OBJ(_welfareListVC);
  
  _filterVC.delegate = nil;
  RELEASE_OBJ(_filterVC);
  
  if (_panRecognizer != nil) {
    _panRecognizer.delegate = nil;
    RELEASE_OBJ(_panRecognizer);
  }

  if (_tapGesture != nil) {
    _tapGesture.delegate = nil;
    RELEASE_OBJ(_tapGesture);
  }
  
  [super dealloc];
}

- (void)setupGestures
{
  _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(movePanel:)];
  _panRecognizer.delegate = self;
  
  [_welfareListVC.view addGestureRecognizer:_panRecognizer];
}

- (void)addCloseTapGesture {
  if (_tapGesture == nil) {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(resetPosition:)];
    _tapGesture.delegate = self;
  }
  
  [_welfareListVC.view addGestureRecognizer:_tapGesture];
}

- (void)removeCloseTapGesture {
  [_welfareListVC.view removeGestureRecognizer:_tapGesture];
}

- (void)initViews {
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  if (_forFavorited) {
    _welfareListVC = [[AlumniWelfareViewController alloc] initFavoritedWelfareWithMOC:_MOC parentVC:_parentVC];
  } else {
    _welfareListVC = [[AlumniWelfareViewController alloc] initWithMOC:_MOC parentVC:_parentVC];
  }
  
  _welfareListVC.delegate = self;
  
  CGFloat y = 0;
  CGFloat height = self.view.frame.size.height + 50;
  if (CURRENT_OS_VERSION >= IOS7) {
    y = 20.0f;
  }
  _welfareListVC.view.frame = CGRectMake(0, y, self.view.frame.size.width, height);
  
  [self.view addSubview:_welfareListVC.view];
  
  [_welfareListVC viewWillAppear:YES];
  
  if (!_forFavorited) {
    [self setupGestures];
  }

}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self initViews];
}

- (void)hideNavigationBarForiOS7 {
  
  _parentVC.navigationController.navigationBarHidden = YES;
  [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}


- (void)viewWillAppear:(BOOL)animated {
  
  if (CURRENT_OS_VERSION >= IOS7) {
    [self hideNavigationBarForiOS7];
  } else {
    [_parentVC.navigationController setNavigationBarHidden:YES];
  }
  
  [super viewWillAppear:animated];
  
  if (_welfareListVC) {
    [_welfareListVC viewWillAppear:animated];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - arrange views

- (void)resetPosition:(UITapGestureRecognizer *)gesture {
  if (_showingFilter) {
    [self resetPanelPosition];
  }
}

- (BOOL)moveOutOfLeftBound:(UIPanGestureRecognizer *)gesture {
  
  CGPoint translation = [gesture translationInView:self.view];
  [gesture setTranslation:CGPointMake(0, 0) inView:self.view];
  
  CGPoint center = gesture.view.center;
  center.x += translation.x;
  
  if (center.x >= HORIZONTAL_RIGHT_THRESHOLD) {
    
    return YES;
  } else {
    
    gesture.view.center = center;
    
    return NO;
  }
}

- (void)displayFilter:(UIPanGestureRecognizer *)panGesture velocity:(CGPoint)velocity {
  
  UIView *childView = nil;
  
  if (!_showingFilter) {
    
    childView = [self getFilterView];
    
    [self.view sendSubviewToBack:childView];
    [[panGesture view] bringSubviewToFront:[panGesture view]];
  }
}

- (void)movePanel:(id)sender {
  
  if ([_welfareListVC tableScrolling]) {
    return;
  }
  
  UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)sender;
  
  if ([self moveOutOfLeftBound:panGesture]) {
    return;
  }
  
  [[[panGesture view] layer] removeAllAnimations];
  
  CGPoint translatedPoint = [panGesture translationInView:self.view];
  CGPoint velocity = [panGesture velocityInView:[sender view]];
  
  if ([panGesture state] == UIGestureRecognizerStateBegan) {
    
    if (velocity.x < 0) {
      [self displayFilter:panGesture velocity:velocity];
      
      [_welfareListVC disableTableScroll];
    }
  }
  
  if ([panGesture state] == UIGestureRecognizerStateEnded) {
    
    if (!_showPanel) {
      
      [self resetPanelPosition];
      
    } else {
      if (_showingFilter) {
        
        [_welfareListVC disableTableScroll];
        
        [self movePanelLeft];
      }
    }
  }
  
  if ([panGesture state] == UIGestureRecognizerStateChanged) {
    
    if (velocity.x < 0) {
      // sometimes, user scroll table view firstly, then scroll the
      // list horizontally, so the state is UIGestureRecognizerStateChanged
      // instead of UIGestureRecognizerStateBegan
      [self displayFilter:panGesture velocity:velocity];
      
      [_welfareListVC disableTableScroll];
    }
    
    _showPanel = abs([sender view].center.x - _welfareListVC.view.frame.size.width/2) > _welfareListVC.view.frame.size.width/2;
    
    if (velocity.x < 0 || (velocity.x > 0 && _showingFilter)) {
      [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
    }
  }
}

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
  if (value) {
    _welfareListVC.view.layer.cornerRadius = 4.0f;
    _welfareListVC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    _welfareListVC.view.layer.shadowOpacity = 0.8f;
  } else {
    _welfareListVC.view.layer.cornerRadius = 0.0f;
  }
  
  _welfareListVC.view.layer.shadowOffset = CGSizeMake(offset, offset);
  
}

- (UIView *)getFilterView {
  if (_filterVC == nil) {
    _filterVC =  [[FilterScrollViewController alloc] initWithNibName:@"FilterScrollViewController" bundle:nil];
    
    _filterVC.delegate = self;
    
    CGFloat y = 0;
    if (CURRENT_OS_VERSION >= IOS7) {
      y = 20.0f;
    }
    _filterVC.view.frame = CGRectMake(PANEL_WIDTH, y, self.view.frame.size.width - PANEL_WIDTH, self.view.frame.size.height + 50);
    
    [self.view addSubview:_filterVC.view];
  }
  
  _showingFilter = YES;
  
  NSMutableArray *searchArray = nil;
  
  searchArray = [NSMutableArray array];
  int size = [[AppManager instance].welfareTypeList count];
  
  for (int i=0; i<size; i++) {
    [searchArray insertObject:[[AppManager instance].welfareTypeList objectAtIndex:i][RECORD_NAME_IDX] atIndex:i];
  }
  
  [_filterVC setListData:searchArray paramArray:nil parentVC:_welfareListVC forGroup:NO];
  
  [self showCenterViewWithShadow:NO withOffset:2];
  
  return _filterVC.view;
}

- (void)resetMainView {
  if (_filterVC != nil) {
    [_filterVC.view removeFromSuperview];
    _filterVC.delegate = nil;
    RELEASE_OBJ(_filterVC);
    
    [_welfareListVC setViewMoveWayType:1];
    
    [_welfareListVC setShowingFilter:NO];
  }
  
  _showingFilter = NO;
  
  [self showCenterViewWithShadow:NO withOffset:0];
}

#pragma mark - PanMoveProtocol methods
- (void)movePanelLeft {
  
  [self addCloseTapGesture];
  
  [_welfareListVC disableTapGotoDetail];
  
  [_welfareListVC disableTableScroll];
  
  UIView *childView = [self getFilterView];
  [self.view sendSubviewToBack:childView];
  [UIView animateWithDuration:0.2f
                        delay:0
                      options:UIViewAnimationOptionBeginFromCurrentState
                   animations:^{
                     
                     CGFloat y = 0;
                     if (CURRENT_OS_VERSION >= IOS7) {
                       y = 20.0f;
                     }
                     _welfareListVC.view.frame = CGRectMake((self.view.frame.size.width - PANEL_WIDTH) * -1, y, self.view.frame.size.width, _welfareListVC.view.frame.size.height);
                     
                   }
                   completion:^(BOOL finished){
                     if (finished) {
                       [_welfareListVC setViewMoveWayType:0];
                       
                       [_welfareListVC setShowingFilter:YES];
                     }
                   }];
}

- (void)resetPanelPosition {
  
  [self removeCloseTapGesture];
  
  [_welfareListVC enableTapGotoDetail];
  
  [_welfareListVC enableTableScroll];
  
  [UIView animateWithDuration:0.2f
                        delay:0
                      options:UIViewAnimationOptionBeginFromCurrentState
                   animations:^{
                     CGFloat y = 0;
                     if (CURRENT_OS_VERSION >= IOS7) {
                       y = 20.0f;
                     }

                     _welfareListVC.view.frame = CGRectMake(0, y, self.view.frame.size.width, _welfareListVC.view.frame.size.height);
                   }
                   completion:^(BOOL finished){
                     if (finished) {
                       [self resetMainView];
                     }
                   }];
}

- (void)backToParent {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - HorizontalScrollArrangeDelegate methods
- (void)arrangeViewsForKeywordsSearch {
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _filterVC.view.frame = CGRectMake(0, _filterVC.view.frame.origin.y, self.view.frame.size.width, _filterVC.view.frame.size.height);
                     
                     _welfareListVC.view.frame = CGRectOffset(_welfareListVC.view.bounds, -1 * _welfareListVC.view.frame.size.width, 0);
                   }
                   completion:^(BOOL finished){
                     
                   }];
}

- (void)arrangeViewsForCancelKeywordsSearch {
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _filterVC.view.frame = CGRectMake(PANEL_WIDTH, _filterVC.view.frame.origin.y, self.view.frame.size.width - PANEL_WIDTH, _filterVC.view.frame.size.height);
                     
                     _welfareListVC.view.frame = CGRectOffset(_welfareListVC.view.bounds, (_welfareListVC.view.frame.size.width - PANEL_WIDTH) * -1, 0);
                   }
                   completion:^(BOOL finished){
                     
                   }];
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  
  if ([_welfareListVC tableScrolling]) {
    return NO;
  } else {
    return YES;
  }
}


@end
