//
//  GroupEventMainViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-13.
//
//

#import "GroupEventMainViewController.h"
#import "HomeContainerController.h"


#define PANEL_WIDTH   60.0f

#define HORIZONTAL_RIGHT_THRESHOLD    self.view.frame.size.width/2.0f

@interface GroupEventMainViewController ()
@end

@implementation GroupEventMainViewController

#pragma mark - user actions
- (void)openSharedEventById:(long long)eventId {
  if (_eventListVC) {
    [_eventListVC openSharedEventById:eventId];
  }
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(WXWRootViewController *)parentVC {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
                 needGoHome:NO];
  if (self) {
    _parentVC = parentVC;
    
    _currentIsEvent = YES;
  }
  return self;
}

- (void)dealloc {
  
  _eventListVC.delegate = nil;
  
  RELEASE_OBJ(_eventListVC);
  
  _filterVC.delegate = nil;
  RELEASE_OBJ(_filterVC);
  
  if (_panRecognizer != nil) {
    _panRecognizer.delegate = nil;
    RELEASE_OBJ(_panRecognizer);
  }
  
  [super dealloc];
}

- (void)setupGestures
{
  _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(movePanel:)];
  _panRecognizer.delegate = self;
  
  [_eventListVC.view addGestureRecognizer:_panRecognizer];
}

- (void)addCloseTapGesture {
  if (_tapGesture == nil) {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(resetPosition:)];
    _tapGesture.delegate = self;
  }
  
  [_eventListVC.view addGestureRecognizer:_tapGesture];
}

- (void)removeCloseTapGesture {
  [_eventListVC.view removeGestureRecognizer:_tapGesture];
}

- (void)initViews {
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  _eventListVC = [[EventListViewController alloc] initWithMOC:_MOC
                                                     parentVC:_parentVC
                                                     tabIndex:EVENT_TAB_IDX];
  _eventListVC.delegate = self;
  
  CGFloat y = 0;
  CGFloat height = self.view.frame.size.height + 50;
  if (CURRENT_OS_VERSION >= IOS7) {
    y = 20.0f;
  }
  _eventListVC.view.frame = CGRectMake(0, y, self.view.frame.size.width, height);
  
  [self.view addSubview:_eventListVC.view];
  
  [self setupGestures];
}


- (void)viewWillAppear:(BOOL)animated {
  [_parentVC.navigationController setNavigationBarHidden:YES];
  
  [super viewWillAppear:animated];
  
  if (_eventListVC != nil) {
    [_eventListVC viewWillAppear:animated];
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self initViews];
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
      
      [_eventListVC disableTableScroll];
    }
  }
  
  if ([panGesture state] == UIGestureRecognizerStateEnded) {
    
    if (!_showPanel) {

      [self resetPanelPosition];
            
    } else {
      if (_showingFilter) {

        [_eventListVC disableTableScroll];
        
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
      
      [_eventListVC disableTableScroll];
    }
    
    _showPanel = abs([sender view].center.x - _eventListVC.view.frame.size.width/2) > _eventListVC.view.frame.size.width/2;
    
    if (velocity.x < 0 || (velocity.x > 0 && _showingFilter)) {
      [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
    }
  }
}

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
  if (value) {
    _eventListVC.view.layer.cornerRadius = 4.0f;
    _eventListVC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    _eventListVC.view.layer.shadowOpacity = 0.8f;
  } else {
    _eventListVC.view.layer.cornerRadius = 0.0f;
  }
  
  _eventListVC.view.layer.shadowOffset = CGSizeMake(offset, offset);
  
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
  NSMutableArray *paramsArray = nil;
  
  if (_currentIsEvent) {
    searchArray = [NSMutableArray array];
    [searchArray insertObject:LocaleStringForKey(NSFilterEventType, nil)atIndex:0];
    [searchArray insertObject:LocaleStringForKey(NSFilterEventCity, nil)atIndex:1];
    [searchArray insertObject:LocaleStringForKey(NSFilterOrderTitle, nil)atIndex:2];
    [searchArray insertObject:LocaleStringForKey(NSMyEventMsg, nil) atIndex:3];
    
    paramsArray = [NSMutableArray array];
    [paramsArray insertObject:[AppManager instance].eventTypeList atIndex:0];
    [paramsArray insertObject:[AppManager instance].eventCityList atIndex:1];
    [paramsArray insertObject:[AppManager instance].eventSortList atIndex:2];
  } else {
    searchArray = [NSMutableArray array];
    int clubSize = [[AppManager instance].supClubFilterList count];
    
    for (int i=0; i<clubSize; i++) {
      [searchArray insertObject:[[[AppManager instance].supClubFilterList objectAtIndex:i] objectAtIndex:1] atIndex:i];
    }
    
    [searchArray insertObject:LocaleStringForKey(NSFilterOrderTitle, nil) atIndex:clubSize];
    
    paramsArray = [NSMutableArray array];
    for (int i=0; i<clubSize; i++) {
      [paramsArray insertObject:[[AppManager instance].clubFilterList objectAtIndex:i] atIndex:i];
    }
    
    [paramsArray insertObject:[AppManager instance].groupSortList atIndex:clubSize];
  }
  
  [_filterVC setListData:searchArray paramArray:paramsArray parentVC:_eventListVC forGroup:!_currentIsEvent];
  
  
  [self showCenterViewWithShadow:NO withOffset:2];
  
  return _filterVC.view;
}

- (void)resetMainView {
  if (_filterVC != nil) {
    [_filterVC.view removeFromSuperview];
    _filterVC.delegate = nil;
    RELEASE_OBJ(_filterVC);
    
    [_eventListVC setViewMoveWayType:MOVE_TO_LEFT_TY];
    
    [_eventListVC setShowingFilter:NO];    
  }
  
  _showingFilter = NO;
  
  [self showCenterViewWithShadow:NO withOffset:0];
  
  [(HomeContainerController *)_parentVC showTabBar];
}

#pragma mark - PanMoveProtocol methods
- (void)movePanelLeft {
  
  [self addCloseTapGesture];
  
  [_eventListVC disableTableScroll];
  
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
                     
                     _eventListVC.view.frame = CGRectMake((self.view.frame.size.width - PANEL_WIDTH) * -1, y, self.view.frame.size.width, _eventListVC.view.frame.size.height);
                     
                     [(HomeContainerController *)_parentVC hideTabBar];
                   }
                   completion:^(BOOL finished){
                     if (finished) {
                       [_eventListVC setViewMoveWayType:RESET_MAIN_TY];
                       
                       [_eventListVC setShowingFilter:YES];
                     }
                   }];
}

- (void)resetPanelPosition {
  
  [self removeCloseTapGesture];
  
  [_eventListVC enableTableScroll];
  
  [UIView animateWithDuration:0.2f
                        delay:0
                      options:UIViewAnimationOptionBeginFromCurrentState
                   animations:^{
                     
                     CGFloat y = 0;
                     if (CURRENT_OS_VERSION >= IOS7) {
                       y = 20.0f;
                     }

                     _eventListVC.view.frame = CGRectMake(0, y, self.view.frame.size.width, _eventListVC.view.frame.size.height);
                   }
                   completion:^(BOOL finished){
                     if (finished) {
                       [self resetMainView];
                     }
                   }];
}

- (void)setCurrentEventFlag:(BOOL)flag {
  _currentIsEvent = flag;
}

#pragma mark - HorizontalScrollArrangeDelegate methods
- (void)arrangeViewsForKeywordsSearch {
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _filterVC.view.frame = CGRectMake(0, _filterVC.view.frame.origin.y, self.view.frame.size.width, _filterVC.view.frame.size.height);
                     
                     _eventListVC.view.frame = CGRectOffset(_eventListVC.view.bounds, -1 * _eventListVC.view.frame.size.width, 0);
                   }
                   completion:^(BOOL finished){
                     
                   }];
}

- (void)arrangeViewsForCancelKeywordsSearch {
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _filterVC.view.frame = CGRectMake(PANEL_WIDTH, _filterVC.view.frame.origin.y, self.view.frame.size.width - PANEL_WIDTH, _filterVC.view.frame.size.height);
                     
                     _eventListVC.view.frame = CGRectOffset(_eventListVC.view.bounds, (_eventListVC.view.frame.size.width - PANEL_WIDTH) * -1, 0);
                   }
                   completion:^(BOOL finished){
                     
                   }];
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  
  if ([_eventListVC tableScrolling]) {
    return NO;
  } else {
    return YES;
  }
}

@end
