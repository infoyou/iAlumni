//
//  VenueListViewController.m
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import "VenueListViewController.h"
#import "Brand.h"
#import "NearbyMapView.h"
#import "MKMapView+ZoomLevel.h"
#import "Store.h"
#import "NearbyAnnotation.h"
#import "ItemCalloutView.h"
#import "NearbyItemAnnotationView.h"
#import "ServiceItemCell.h"
#import "ServiceItemDetailViewController.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "StoreDetailViewController.h"

#import "Welfare.h"

#define DISPLAYED_ITEMS_COUNT 20

#define CALLOUT_VIEW_WIDTH            240.0f
#define CALLOUT_VIEW_HEIGHT           80.0f

#define ITEM_CELL_HEIGHT              90.0f

#define DISTANCE_FACTOR       550
#define MAX_ZOOM_LEVEL        8
#define MIN_ZOON_LEVEL        2

@interface VenueListViewController ()
@property (nonatomic, retain) Brand *brand;
@property (nonatomic, copy) NSString *storeTel;
@end

@implementation VenueListViewController

@synthesize brand = _brand;

#pragma mark - user action
- (void)callSupport:(NSString *)tel {
  
  self.storeTel = tel;
  
  if ([NULL_PARAM_VALUE isEqualToString:tel] || tel == nil) {
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
  [as showInView:self.navigationController.view];
  
  RELEASE_OBJ(as);

}

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
           forNew:(BOOL)forNew {

  [super loadListData:triggerType forNew:forNew];
  
  NSInteger startIndex = 1;
  
  if (!forNew) {
    startIndex = ++_currentPhaseIndex;
  }
  
  NSMutableString *param = [NSMutableString stringWithFormat:@"<itemId>%@</itemId><latitude>%@</latitude><longitude>%@</longitude><page>%d</page><pageSize>%@</pageSize>",
                            _welfare.itemId,
                            LOCDATA_TO_STRING([AppManager instance].latitude),
                            LOCDATA_TO_STRING([AppManager instance].longitude),
                            startIndex,
                            ITEM_LOAD_COUNT];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_STORE_LIST_TY];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:LOAD_STORE_LIST_TY] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchNearbyItems:url];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"Store";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
  [self.descriptors addObject:descriptor1];  
}

#pragma mark - refresh nearby location info
- (void)refreshBranchList:(NSNotification *)notification {
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - lifecycle methods

- (void)registerNotifications {
  
  // user entered nearby service, then he/she click 'Home' button for iPhone, then app deactivec,
  // if user actives the app again, the location info should be refreshed
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(refreshBranchList:)
                                               name:REFRESH_NEARBY_NOTIFY
                                             object:nil];
  
}

- (void)setInitProperties:(BOOL)locationRefreshed {
  _currentLocationIsLatest = locationRefreshed; 
  _currentShowList = YES;
  
  [self registerNotifications];
}

- (id)initNearbyVenuesWithMOC:(NSManagedObjectContext *)MOC
            locationRefreshed:(BOOL)locationRefreshed
                      welfare:(Welfare *)welfare {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    
    _currentPhaseIndex = 1;
    
    _welfare = welfare;
    
    _brandId = 0ll;
    
    [self setInitProperties:locationRefreshed];
    
    _allowSwipeBackToParentVC = NO;
    
    DELETE_OBJS_FROM_MOC(MOC, @"Store", nil);
  }
  return self;
}

- (id)initBranchVenuesWithMOC:(NSManagedObjectContext *)MOC
                        brand:(Brand *)brand
            locationRefreshed:(BOOL)locationRefreshed {
  self = [self initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    self.brand = brand;
    
    _brandId = brand.brandId.longLongValue;
    
    [self setInitProperties:locationRefreshed];
    
    _allowSwipeBackToParentVC = NO;
  }
  return self;
}

- (void)dealloc {
  
  self.brand = nil;
  
  self.storeTel = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:REFRESH_NEARBY_NOTIFY
                                                object:nil];
  [super dealloc];
}

- (void)initTableAndMapContainer {
  
  // becauser the table view has been initialized and added to self.view in super viewDidLoad method,
  // then we need to move table view from self.view to current container;
  _tableAndMapContainer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height)];
  _tableAndMapContainer.backgroundColor = TRANSPARENT_COLOR;
  [self.view addSubview:_tableAndMapContainer];
  
  // remove table view from self.vew
  [_tableView removeFromSuperview];
  
  // move table view to new container
  [_tableAndMapContainer addSubview:_tableView];
}

- (void)initNavigationItemButton {
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSMapTitle, nil)
                            target:self
                            action:@selector(switchMapAndList:)];

  self.navigationItem.rightBarButtonItem.enabled = _currentLocationIsLatest;
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
  
  [self initTableAndMapContainer];
  
  [self initMapView];
  
  //[self initNavigationItemButton];
  
  [self checkLocationRefreshStatus];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded && _currentLocationIsLatest) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - switch between map and list

- (void)adjustMapZoomLevel {
  
  [_mapView zoomToFitMapAnnotations];
}

- (void)initMapView {
  _mapView = [[NearbyMapView alloc] initWithFrame:CGRectMake(0, 0,
                                                             self.view.frame.size.width,
                                                             _tableView.frame.size.height)
                               filterListDelegate:self
                                           target:self
                                hideCalloutAction:@selector(hideAnnotationView)
                                   needFilterSort:NO];
  _mapView.autoresizesSubviews = YES;
  _mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  
  _mapView.showsUserLocation = YES;
  
  [self adjustMapZoomLevel];
  
  _mapView.delegate = self;
  
  _startIndex = 1;
  _endIndex = 1;
}

- (void)removeAllNonUserLocationAnnotation {
  NSMutableArray *anns = [NSMutableArray array];
  for (id<MKAnnotation> annotation in _mapView.annotations) {
    if (![annotation isKindOfClass:[MKUserLocation class]]) {
      [anns addObject:annotation];
    }
  }
  
  [_mapView removeAnnotations:anns];
}

- (void)setStartAndEndIndex {
  
  if (_fetchedRC.fetchedObjects.count == 0) {
    _startIndex = 0;
    _endIndex = 0;
    return;
  }
  
  _startIndex = _currentPhaseIndex * DISPLAYED_ITEMS_COUNT + 1;
  NSInteger end = _currentPhaseIndex * DISPLAYED_ITEMS_COUNT + DISPLAYED_ITEMS_COUNT;
  if (_itemTotleCount.intValue < end) {
    // item total count less than 20
    //_startIndex = 1;
    _endIndex = _itemTotleCount.intValue;
  } else {
    _endIndex = end;
  }
  
  // if _loadMoreTriggeredForMap is YES, which means the load more is in progress now,
  // then no need to trigger load again
  if (_endIndex > _fetchedRC.fetchedObjects.count) {
    
    _loadMoreTriggeredForMap = YES;
    
    _currentStartIndex = _fetchedRC.fetchedObjects.count;
    
    // current loaded item is not enough to displayed, then trigger load more
    [self loadListData:TRIGGERED_BY_SORT forNew:NO];
  }
}

- (void)arrangeAnnotationsForMapView {
  
  [self setStartAndEndIndex];
  
  // if load more triggered for map, the re-draw for map will be called in connectDone:url:conentType: method
  if (!_loadMoreTriggeredForMap) {
    
    [self removeAllNonUserLocationAnnotation];
    
    if (_startIndex > 0 && _endIndex > 0) {
      for (NSInteger index = (_startIndex - 1); index < _endIndex; index++) {
        Store *store = (Store *)(_fetchedRC.fetchedObjects)[index];
        if (store.latitude.doubleValue > 0 && store.longitude.doubleValue > 0) {
          CLLocationCoordinate2D coordinate = {store.latitude.doubleValue, store.longitude.doubleValue};
          NearbyAnnotation *annotation = [[[NearbyAnnotation alloc] initWithCoordinate:coordinate
                                                                                 store:store
                                                                        sequenceNumber:index + 1] autorelease];
          [_mapView addAnnotation:annotation];
        }
      }
    }
    
    [_mapView setSPTitleWithStartNumber:_startIndex
                              endNumber:_endIndex
                              itemTotal:_itemTotleCount.intValue];
    
    [self adjustMapZoomLevel];
  }
}

- (void)clearCalloutView {
  [_calloutView removeFromSuperview];
  RELEASE_OBJ(_calloutView);
}

- (void)switchMapAndList:(id)sender {
  [UIView beginAnimations:nil
                  context:nil];
  [UIView setAnimationDuration:1.0f];
  UIViewAnimationTransition transition;
  if (_currentShowList) {
    // switch from list to map
    
    // as user could click 'Show Nexst' button to trigger load more items in map view,
    // then the param need the latest start index, we should set the load start index when
    // the list switch to map
    _currentStartIndex = _fetchedRC.fetchedObjects.count;
    
    [self setRightButtonTitle:LocaleStringForKey(NSListTitle, nil)];
    transition = UIViewAnimationTransitionFlipFromLeft;
    
    [self adjustMapZoomLevel];
    
    [_tableView removeFromSuperview];
    [_tableAndMapContainer addSubview:_mapView];
    
    [self arrangeAnnotationsForMapView];
    
  } else {
    
    // switch from map to list
    [self setRightButtonTitle:LocaleStringForKey(NSMapTitle, nil)];
    transition = UIViewAnimationTransitionFlipFromRight;
    
    // clear current displayed call out view
    if (_calloutView) {
      [self clearCalloutView];
    }
    
    [_mapView removeFromSuperview];
    [_tableAndMapContainer addSubview:_tableView];    
  }
  [UIView setAnimationTransition:transition
                         forView:_tableAndMapContainer
                           cache:YES];
  [UIView commitAnimations];
  
  _currentShowList = !_currentShowList;
}

#pragma mark mapView delegate functions

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  
  NearbyItemAnnotationView *itemAnnotationView = (NearbyItemAnnotationView *)view;
  NearbyAnnotation *annotation = (NearbyAnnotation *)itemAnnotationView.annotation;
  
  _userLastSelectedAnnotationView = itemAnnotationView;
  
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return;
  }
  
  ((NearbyItemAnnotationView *)view).image = [UIImage imageNamed:@"itemRedPin.png"];
  [((NearbyItemAnnotationView *)view) setPinTextColor:[UIColor whiteColor]];
  
  [_mapView setCenterCoordinate:annotation.coordinate animated:YES];
  
  if (nil == _calloutView) {
    _calloutView = [[ItemCalloutView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - CALLOUT_VIEW_WIDTH)/2,
                                                                     _mapView.frame.origin.y + 40.0f + MARGIN * 2,
                                                                     CALLOUT_VIEW_WIDTH, CALLOUT_VIEW_HEIGHT)
                                                    store:nil // DEBUG should be store
                                               sequenceNO:annotation.sequenceNumber
                                                   target:self showDetailAction:@selector(showItem:)];
  }
  
  [_mapView addSubview:_calloutView];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
  
  NearbyItemAnnotationView *itemAnnotationView = (NearbyItemAnnotationView *)view;
  NearbyAnnotation *annotation = (NearbyAnnotation *)itemAnnotationView.annotation;
  
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return;
  }
  
  if (!_keepCalloutView) {
    
    ((NearbyItemAnnotationView *)view).image = [UIImage imageNamed:@"itemOrangePin.png"];
    
    // there is a difference between IOS 5.x and IOS 4.x for the process flow,
    // flow of IOS 4.x: pointInside-->mapView: didSelectAnnotationView:-->
    // mapView: didDeselectAnnotationView:
    // foow of IOS 5.x: pointInside-->mapView: didDeselectAnnotationView:-->
    // mapView: didSelectAnnotationView:
    // so we need handle them separately
    if (CURRENT_OS_VERSION >= IOS5) {
      if (_calloutView) {
        [self clearCalloutView];
      }
    } else {
      if (_clearCalloutViewForIOS4x && _calloutView) {
        [self clearCalloutView];
        
        _clearCalloutViewForIOS4x = NO;
      }
    }
    
  } else {
    _keepCalloutView = NO;
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation {
  
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }
  
	// determine the type of annotation, and produce the correct type of annotation view for it.
	NearbyAnnotation* csAnnotation = (NearbyAnnotation*)annotation;
	
	static NSString* identifier = @"Pin";
  
	NearbyItemAnnotationView* pin = (NearbyItemAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if(nil == pin) {
		pin = [[[NearbyItemAnnotationView alloc] initWithAnnotation:csAnnotation
                                                reuseIdentifier:identifier] autorelease];
  } else {
    pin.annotation = csAnnotation;
  }
  
  [pin setSequenceNumber:csAnnotation.sequenceNumber];
  
  return pin;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)drawItemCell:(NSIndexPath *)indexPath item:(ServiceItem *)item {
  
  static NSString *cellIdentifier = @"serviceItemCell";
  ServiceItemCell *cell = (ServiceItemCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[ServiceItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellIdentifier
                            imageDisplayerDelegate:self
                                               MOC:_MOC
                                       venueListVC:self
                                        callAction:@selector(callSupport:)] autorelease];
  }
  
  [cell drawItem:item index:indexPath.row];
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  }
  
  ServiceItem *item = (ServiceItem *)[_fetchedRC objectAtIndexPath:indexPath];
  
  return [self drawItemCell:indexPath item:item];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return ITEM_CELL_HEIGHT;
}

- (void)showVenueDetail:(NSIndexPath *)indexPath {
  Store *store = (Store *)[_fetchedRC objectAtIndexPath:indexPath];

  [self showItem:store];
}

- (void)showItem:(Store *)store {
  
  StoreDetailViewController *storeDetailVC = [[[StoreDetailViewController alloc] initWithStore:store MOC:_MOC] autorelease];
  storeDetailVC.title = LocaleStringForKey(NSStoreDetailTitle, nil);
  [self.navigationController pushViewController:storeDetailVC animated:YES];
}

- (void)hideAnnotationView {
  
  if (_calloutView) {
    
    _userLastSelectedAnnotationView.image = [UIImage imageNamed:@"itemOrangePin.png"];
    
    [_calloutView removeFromSuperview];
    RELEASE_OBJ(_calloutView);
    
    _userLastSelectedAnnotationView = nil;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  [self showVenueDetail:indexPath];
}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    
    _autoLoaded = YES;
    
    [self refreshTable];

    
    if (!_currentShowList) {
      // current show map view
      
      if (_loadMoreTriggeredForMap) {
        // reset this flag, then the map will be redraw in arrangeAnnotationsForMapView method
        _loadMoreTriggeredForMap = NO;
        
      } else if (_switchTypeInMapView) {
        // reset the phase index after new type item list loaded
        _currentPhaseIndex = 1;
        _switchTypeInMapView = NO;
      }
      
      [self arrangeAnnotationsForMapView];
      
    } else {
      // current show list
      // reset the phase index after new type item list loaded
      _currentPhaseIndex = 1;
    }
    
  } else {
    
    [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                           alternativeMsg:LocaleStringForKey(NSLoadNearbyFailedMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
  //[self resetUIElementsForConnectDoneOrFailed];
  
  [self closeAsyncLoadingView];
  
  // should be called at end of method to clear connFacade instance
  //[super connectDone:result url:url contentType:contentType closeAsyncLoadingView:NO];
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  // should be called at end of method to clear connFacade instance
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  if (error) {
    msg = [error localizedDescription];
  } else {
    msg = LocaleStringForKey(NSLoadNearbyFailedMsg, nil);
    
    // reset this flag, then the map will be redraw in arrangeAnnotationsForMapView method
    _loadMoreTriggeredForMap = NO;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  // should be called at end of method to clear connFacade instance
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECLocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(WXWLocationManager *)manager
                                 location:(CLLocation *)location {
  
  [super locationManagerDidReceiveLocation:manager
                                  location:location];
  
  // user enter nearby service first time and location data info be fetched successfully
  [self changeAsyncLoadingMessage:LocaleStringForKey(NSLoadingTitle, nil)];
  
  self.navigationItem.rightBarButtonItem.enabled = YES;
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  
  _currentLocationIsLatest = YES;
}

- (void)locationManagerDidFail:(WXWLocationManager *)manager {
  [super locationManagerDidFail:manager];
  
  [self changeAsyncLoadingMessage:LocaleStringForKey(NSLoadingTitle, nil)];
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)locationManagerCancelled:(WXWLocationManager *)manager {
  [super locationManagerCancelled:manager];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case CALL_ACTION_SHEET_IDX:
    {
      if (self.storeTel.length > 0) {
        NSString *phoneNumber = [self.storeTel stringByReplacingOccurrencesOfString:@" " withString:NULL_PARAM_VALUE];
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
}

@end
