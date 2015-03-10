//
//  NearbyViewController.m
//  ExpatCircle
//
//  Created by Adam on 11-12-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NearbyViewController.h"
#import <CoreData/CoreData.h>
#import "BizPartnerGroupScrollView.h"
#import "ECAsyncConnectorFacade.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "TextConstants.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "ItemGroup.h"
#import "ItemGroupButton.h"
#import "CoreDataUtils.h"
#import "ServiceItem.h"
#import "NearbySearchBar.h"
#import "NearbyItemFilterSortViewController.h"
#import "WXWNavigationController.h"
#import "WXWLabel.h"
#import "ServiceItemCell.h"
#import "NearbyMapView.h"
#import "NearbyAnnotation.h"
#import "NearbyItemAnnotationView.h"
#import "MKMapView+ZoomLevel.h"
#import "ItemCalloutView.h"
#import "ServiceProviderViewController.h"
#import "HttpUtils.h"
#import "TipsEntranceView.h"
#import "ServiceItemDetailViewController.h"
#import "CouponItemCell.h"
#import "WXWDebugLogOutput.h"
#import "ServiceItemListHeaderView.h"
#import "SearchListViewController.h"
#import "PeopleWithChatCell.h"
#import "FilterOption.h"
#import "SortOption.h"
#import "ChatListViewController.h"
#import "Alumni.h"
#import "AlumniProfileViewController.h"
#import "DMChatViewController.h"

#define ITEM_BUTTON_CONTAINER_HEIGHT  70.0f

#define ITEM_CELL_HEIGHT              80.0f

#define COUPON_ITEM_CELL_HEIGHT       100.0f

#define BASE_OPERATION_VIEW_HEIGHT    40.0f//80.0f
#define SEARCH_BAR_HEIGHT             40.0f
#define TIPS_VIEW_HEIGHT              40.0f

#define MAP_DELTA_FACTOR              0.000045f

#define ENTIRE_CITY_RADIUS            50000
#define WITHIN_2KM_RADIUS             2000
#define WITHIN_5KM_RADIUS             5000
#define WITHIN_10KM_RADIUS            10000

#define DISPLAYED_ITEMS_COUNT         20

#define CALLOUT_VIEW_WIDTH            240.0f
#define CALLOUT_VIEW_HEIGHT           80.0f

#define SEARCH_RESULT_TABLE_TOP_GAP   4.0f

@interface NearbyViewController()
@property (nonatomic, retain) ItemGroup *currentGroup;
@property (nonatomic, retain) FilterOption *distanceFilterOption;
@property (nonatomic, retain) FilterOption *timeFilterOption;
@property (nonatomic, retain) SortOption *sortOption;
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation NearbyViewController

@synthesize currentGroup = _currentGroup;
@synthesize distanceFilterOption = _distanceFilterOption;
@synthesize timeFilterOption = _timeFilterOption;
@synthesize sortOption = _sortOption;
@synthesize alumni = _alumni;

#pragma mark - load nearby items
- (void)loadNearbyPeople:(BOOL)forNew
         loadTriggerType:(LoadTriggerType)loadTriggerType {
  
  _loadForNewItem = forNew;
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  _currentLoadTriggerType = loadTriggerType;
  switch (loadTriggerType) {
    case TRIGGERED_BY_AUTOLOAD:
    case TRIGGERED_BY_SORT:
      DELETE_OBJS_FROM_MOC(_MOC,
                           @"Alumni",
                           ([NSPredicate predicateWithFormat:@"(containerType == %d)", FETCH_SHAKE_USER_TY]));
      break;
      
    default:
      break;
  }
  
  NSMutableString *param = [NSMutableString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude><shake_where>%@</shake_where><shake_what>%@</shake_what><page>%d</page><page_size>30</page_size><refresh_only>0</refresh_only>", [AppManager instance].longitude, [AppManager instance].latitude, [AppManager instance].defaultPlace, [AppManager instance].defaultThing, startIndex];
  
  [param appendFormat:@"<distance_scope>%@</distance_scope>", self.distanceFilterOption.valueString];
  
  [param appendFormat:@"<time_scope>%@</time_scope>", self.timeFilterOption.valueString];
  
  [param appendFormat:@"<order_by_column>%@</order_by_column>", self.sortOption.optionValue];
  
  NSString *url = [CommonUtils geneUrl:param itemType:SHAKE_USER_LIST_TY];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:SHAKE_USER_LIST_TY] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchGets:url];
}

- (void)loadNearbyItems:(LoadTriggerType)type
                 forNew:(BOOL)forNew
        serviceCategory:(ItemGroup *)serviceCategory {
  
  _currentLoadTriggerType = type;
  
  _loadForNewItem = forNew;
  
  /*
   NSString *groupId = nil;
   if (serviceCategory.groupId.longLongValue == ALL_CATEGORY_GROUP_ID) {
   groupId = NULL_PARAM_VALUE;
   } else {
   groupId = LLINT_TO_STRING(serviceCategory.groupId.longLongValue);
   }
   */
  
  NSString *radius = self.distanceFilterOption.valueString;
  
  NSInteger startIndex = 0;
  
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSMutableString *param = [NSMutableString stringWithFormat:@"<category_id>%@</category_id><favorite_by></favorite_by><distance>%@</distance><latitude>%@</latitude><longitude>%@</longitude><sort_type>%d</sort_type><page>%d</page><page_size>%@</page_size>",
                            self.currentGroup.groupId,
                            radius,
                            LOCDATA_TO_STRING([AppManager instance].latitude),
                            LOCDATA_TO_STRING([AppManager instance].longitude),
                            _sortType,
                            startIndex,
                            ITEM_LOAD_COUNT];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_SERVICE_ITEM_TY];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:LOAD_SERVICE_ITEM_TY] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchNearbyItems:url];
}

- (void)searchItemsByKeywords:(NSString *)keywords {
  // FIXME need new url
}

#pragma mark - switch between map and list

- (void)adjustMapZoomLevel {
  
  NSInteger zoomLevel = 8;
  switch (_filterType) {
    case ENTIRE_CITY:
      zoomLevel = 8;
      break;
      
    case NEARBY_2_KM:
      zoomLevel = 12;
      break;
      
    case NEARBY_5_KM:
      zoomLevel = 11;
      break;
      
    case NEARBY_10_KM:
      zoomLevel = 10;
      break;
      
    default:
      break;
  }
  
  CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:[AppManager instance].latitude
                                                            longitude:[AppManager instance].longitude] autorelease];
	_mapView.centerCoordinate = currentLocation.coordinate;
  
  [_mapView setCenterCoordinate:currentLocation.coordinate
                      zoomLevel:zoomLevel
                       animated:YES];
}

- (void)initMapView {
  _mapView = [[NearbyMapView alloc] initWithFrame:CGRectMake(0, 0,
                                                             self.view.frame.size.width,
                                                             _tableView.frame.size.height)
                               filterListDelegate:self
                                           target:self
                                hideCalloutAction:@selector(hideAnnotationView)
                                   needFilterSort:YES];
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
  
  NSLog(@"count: %d", _fetchedRC.fetchedObjects.count);
  
  if (_fetchedRC.fetchedObjects.count == 0) {
    _startIndex = 0;
    _endIndex = 0;
    return;
  }
  
  _startIndex = _currentPhaseIndex * DISPLAYED_ITEMS_COUNT + 1;
  NSInteger end = _currentPhaseIndex * DISPLAYED_ITEMS_COUNT + DISPLAYED_ITEMS_COUNT;
  if (self.currentGroup.itemTotal.intValue < end) {
    // item total count less than 20
    //_startIndex = 1;
    _endIndex = self.currentGroup.itemTotal.intValue;
  } else {
    _endIndex = end;
  }
  
  // if _loadMoreTriggeredForMap is YES, which means the load more is in progress now,
  // then no need to trigger load again
  if (_endIndex > _fetchedRC.fetchedObjects.count) {
    
    _loadMoreTriggeredForMap = YES;
    
    _currentStartIndex = _fetchedRC.fetchedObjects.count;
    
    // current loaded item is not enough to displayed, then trigger load more
    [self loadNearbyItems:TRIGGERED_BY_SORT forNew:NO serviceCategory:self.currentGroup];
  }
}

- (void)arrangeAnnotationsForMapView {
  
  [self setStartAndEndIndex];
  
  // if load more triggered for map, the re-draw for map will be called in connectDone:url:conentType: method
  if (!_loadMoreTriggeredForMap) {
    
    [self removeAllNonUserLocationAnnotation];
    
    if (_startIndex > 0 && _endIndex > 0) {
      for (NSInteger index = (_startIndex - 1); index < _endIndex; index++) {
        ServiceItem *item = (ServiceItem *)(_fetchedRC.fetchedObjects)[index];
        if (item.latlagAttached.boolValue) {
          CLLocationCoordinate2D coordinate = {item.latitude.doubleValue, item.longitude.doubleValue};
          NearbyAnnotation *annotation = [[[NearbyAnnotation alloc] initWithCoordinate:coordinate
                                                                           serviceItem:item
                                                                        sequenceNumber:index + 1] autorelease];
          [_mapView addAnnotation:annotation];
        }
      }
    }
    
    [_mapView setSPTitleWithStartNumber:_startIndex
                              endNumber:_endIndex
                              itemTotal:self.currentGroup.itemTotal.intValue];
    
    if (_needAdjustMapZoomLevel) {
      // if arrange map triggered by user change search scope, then the zoom level need be adjusted accordingly
      [self adjustMapZoomLevel];
      _needAdjustMapZoomLevel = NO;
    }
  }
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
    
    // disable the people category button, because no people be displayed in map presently
    _itemGroupScrollView.peopleButton.enabled = NO;
    
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
    
    // enable the people category button
    _itemGroupScrollView.peopleButton.enabled = YES;
  }
  [UIView setAnimationTransition:transition
                         forView:_tableAndMapContainer
                           cache:YES];
  [UIView commitAnimations];
  
  _currentShowList = !_currentShowList;
}

#pragma mark - navigate to detail

- (void)backToEntrance:(id)sender {
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)hideAnnotationView {
  
  if (_calloutView) {
    
    _userLastSelectedAnnotationView.image = [UIImage imageNamed:@"itemOrangePin.png"];
    
    [_calloutView removeFromSuperview];
    RELEASE_OBJ(_calloutView);
    
    _userLastSelectedAnnotationView = nil;
  }
}

- (void)showItemDetail:(ServiceItem *)item {
  
  if (nil == _userLastSelectedItem) {
    _userLastSelectedItem = item;
    _keepCalloutView = YES;
    
    ServiceItemDetailViewController *profileVC = [[[ServiceItemDetailViewController alloc] initWithMOC:_MOC
                                                                                                holder:((iAlumniAppDelegate*)APP_DELEGATE)
                                                                                      backToHomeAction:@selector(backToHomepage:)
                                                                                           serviceItem:item] autorelease];
    [self.navigationController pushViewController:profileVC animated:YES];
  }
  
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
                                                     store:nil//annotation.item DEBUG should be store
                                               sequenceNO:annotation.sequenceNumber
                                                   target:self showDetailAction:@selector(showItemDetail:)];
  }
  
  [_mapView addSubview:_calloutView];
}

- (void)clearCalloutView {
  [_calloutView removeFromSuperview];
  RELEASE_OBJ(_calloutView);
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

#pragma mark - switch item type

- (void)adjustTableHeaderViewHeight:(BOOL)hideHeaderView {
  
  if (hideHeaderView) {
    _tableView.tableHeaderView = nil;
  } else {
    _tableView.tableHeaderView = _listHeaderView;
  }
}

- (void)adjustElementsForSwitch {
  if (self.currentGroup.groupId.longLongValue == PEOPLE_CATEGORY_ID) {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self adjustTableHeaderViewHeight:YES];
  } else {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self adjustTableHeaderViewHeight:NO];
  }
}

- (void)swithItem:(ItemGroup *)serviceCategory {
  
  self.fetchedRC = nil;
  [_tableView reloadData];
  
  self.currentGroup = serviceCategory;
  
  if (!_currentShowList) {
    _switchTypeInMapView = YES;
  }
  
  // there is a difference between IOS 5.x and IOS 4.x for mapview delegate methods call flow
  if ([CommonUtils currentOSVersion] < IOS5 && _autoLoaded) {
    // first load no need to clear call out view, because there is no call out view dispalyed
    // before first load finish, so if _autoLoaded is NO, then no need to set this flag
    _clearCalloutViewForIOS4x = YES;
  }
  
  // reset the loading start index
  _currentStartIndex = 0;
  
  _currentStartIndex = 0;
  
  [self setFilterAndSort];
  
  [self adjustElementsForSwitch];
  
  if (serviceCategory.groupId.longLongValue == PEOPLE_CATEGORY_ID) {
    
    _currentStartIndex = 0;
    
    [self loadNearbyPeople:YES loadTriggerType:TRIGGERED_BY_AUTOLOAD];
  } else {
    
    [self loadNearbyItems:TRIGGERED_BY_SORT forNew:YES serviceCategory:serviceCategory];
  }
  
  _listHeaderView.tipsView.firstTipsTitleLabel.text = serviceCategory.firstTipsTitle;
}

- (void)showAllItems {
  [_itemGroupScrollView defaultSelectDummyAll];
}

#pragma mark - refresh nearby location info
- (void)refreshNearbyInfo:(NSNotification *)notification {
  
  [self loadNearbyItems:TRIGGERED_BY_SORT
                 forNew:YES
        serviceCategory:self.currentGroup];
}

#pragma mark - load service category and items
- (void)loadItemGroups {
  // load item group firstly
  NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:LOAD_SERVICE_CATEGORY_TY];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:LOAD_SERVICE_CATEGORY_TY] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchNearbyGroups:url];
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

- (void)clearItemsForInit {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", SERVICE_USAGE_TY];
  DELETE_OBJS_FROM_MOC(_MOC, @"ItemGroup", predicate);
  
  // clear 'FavoritedServiceItem' to avoid duplicate item displayed, because FavoritedServiceItem is
  // inherited from ServiceItem, the fetched objects contains the FavoritedServiceItem and ServiceItem
  DELETE_OBJS_FROM_MOC(_MOC, @"FavoritedServiceItem", nil);
  
  // clear the service items loaded last time (maybe app teriminated abnormally)
  DELETE_OBJS_FROM_MOC(_MOC, @"ServiceItem", nil);
  
  predicate = [NSPredicate predicateWithFormat:@"(containerType == %d)", FETCH_SHAKE_USER_TY];
  DELETE_OBJS_FROM_MOC(_MOC,
                       @"Alumni",
                       predicate);
}


- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    _sortType = SI_SORT_BY_DISTANCE_TY;
    _filterType = ENTIRE_CITY;//NEARBY_10_KM;
    
    _currentStartIndex = 0;
    
    _currentShowList = YES;
    
    [self setFilterAndSort];
    
    [self clearItemsForInit];
    
    [self registerNotifications];
  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_itemGroupScrollView);
  RELEASE_OBJ(_mapView);
  RELEASE_OBJ(_tableAndMapContainer);
  RELEASE_OBJ(_calloutView);
  RELEASE_OBJ(_listHeaderView);
  
  [[WXWImageManager instance].imageCache clearAllCachedImages];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", SERVICE_USAGE_TY];
  DELETE_OBJS_FROM_MOC(_MOC, @"ItemGroup", predicate);
  DELETE_OBJS_FROM_MOC(_MOC, @"ServiceItem", nil);
  
  predicate = [NSPredicate predicateWithFormat:@"(containerType == %d)", FETCH_SHAKE_USER_TY];
  DELETE_OBJS_FROM_MOC(_MOC,
                       @"Alumni",
                       predicate);
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:REFRESH_NEARBY_NOTIFY
                                                object:nil];
  self.currentGroup = nil;
  self.distanceFilterOption = nil;
  self.timeFilterOption = nil;
  self.sortOption = nil;
  
  self.alumni = nil;
  
  [super dealloc];
}

- (void)initItemButtons {
  _itemGroupScrollView = [[BizPartnerGroupScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ITEM_BUTTON_CONTAINER_HEIGHT)
                                                                      MOC:_MOC
                                                            switchHandler:self
                                                             switchAction:@selector(swithItem:)
                                                   imageDisplayerDelegate:self];
  [self.view addSubview:_itemGroupScrollView];
}

- (void)initSearchBarAndTipsView {
  
  _listHeaderView = [[ServiceItemListHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                self.view.frame.size.width,
                                                                                BASE_OPERATION_VIEW_HEIGHT)
                                                  filterListDelegate:self];
  _tableView.tableHeaderView = _listHeaderView;
}

- (void)initTableAndMapContainer {
  
  [self initSearchBarAndTipsView];
  
  // becauser the table view has been initialized and added to self.view in super viewDidLoad method,
  // then we need to move table view from self.view to current container;
  _tableAndMapContainer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   ITEM_BUTTON_CONTAINER_HEIGHT,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height -
                                                                   ITEM_BUTTON_CONTAINER_HEIGHT)];
  _tableAndMapContainer.backgroundColor = TRANSPARENT_COLOR;
  [self.view addSubview:_tableAndMapContainer];
  
  // remove table view from self.vew
  [_tableView removeFromSuperview];
  
  // move table view to new container
  _tableView.frame = CGRectMake(0, 0, _tableAndMapContainer.frame.size.width, _tableAndMapContainer.frame.size.height);
  [_tableAndMapContainer addSubview:_tableView];
}

- (void)getLatestLocationInfo {
  
  if (CURRENT_OS_VERSION >= IOS4_2) {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
      UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNearbyServiceUnavailableMsg, nil)
                                                       message:LocaleStringForKey(NSLocationServiceDeniedMsg, nil)
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:LocaleStringForKey(NSOKTitle, nil), nil] autorelease];
      [alert show];
      return;
    }
  }
  
  [UIUtils showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
                toBeBlockedView:self.view];
  [self getCurrentLocationInfoIfNecessary];
}

- (void)initNavigationItemButtons {
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSMapTitle, nil)
                            target:self
                            action:@selector(switchMapAndList:)];

  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSBackTitle, nil)
                           target:self
                           action:@selector(backToEntrance:)];
}

- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self initTableAndMapContainer];
  
  [self initItemButtons];
  
  [self initMapView];
  
  [self initNavigationItemButtons];
  
  // trigger load item groups
  [self loadItemGroups];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
  _userLastSelectedItem = nil;
  
  [self updateLastSelectedCell];
}

#pragma mark - ECFilterListDelegate methods

- (void)showPreviousItems:(id)sender {
  _currentPhaseIndex--;
  [self arrangeAnnotationsForMapView];
}

- (void)showNextItems:(id)sender {
  _currentPhaseIndex++;
  [self arrangeAnnotationsForMapView];
}

- (void)showNearbyFilterSortView {
  
  NearbyItemType itemType = 0;
  if (self.currentGroup.groupId.longLongValue == PEOPLE_CATEGORY_ID) {
    itemType = PEOPLE_ITEM_TY;
  } else {
    itemType = VENUE_ITEM_TY;
  }
  
  NearbyItemFilterSortViewController *nearbyItemSearchVC = [[[NearbyItemFilterSortViewController alloc] initWithMOC:_MOC
                                                                                                             holder:_holder
                                                                                                   backToHomeAction:@selector(backToHomepage:)
                                                                                                         filterType:_filterType
                                                                                                           sortType:_sortType
                                                                                                           itemType:itemType
                                                                                                 filterListDelegate:self] autorelease];
  nearbyItemSearchVC.title = LocaleStringForKey(NSFilterSortTitle, nil);
  
  
  WXWNavigationController *nearbyItemNav = [[[WXWNavigationController alloc] initWithRootViewController:nearbyItemSearchVC] autorelease];
  [self.navigationController presentModalViewController:nearbyItemNav animated:YES];
  /*
   [self performSelector:@selector(presentModalQuickViewController:)
   withObject:nearbyItemSearchVC
   afterDelay:0.1f];
   */
}

- (void)clearLoadedItems {
  DELETE_OBJS_FROM_MOC(_MOC, @"ServiceItem", nil);
  [self refreshTable];
}

- (void)adjustFilterSortTinyTitle {
  
  NSMutableString *searchCondition = [NSMutableString string];
  
  if (self.distanceFilterOption.valueFloat.floatValue != CGFLOAT_MAX) {
    [searchCondition appendFormat:@"%@, ", self.distanceFilterOption.desc];
  }
  
  if (self.currentGroup.groupId.longLongValue == PEOPLE_CATEGORY_ID) {
    [searchCondition appendFormat:@"%@", self.timeFilterOption.desc];
  }
  
  NSLog(@"desc: %@", self.distanceFilterOption.desc);
  
  if ([LANG_EN_TY isEqualToString:[WXWSystemInfoManager instance].currentLanguageDesc]) {
    [searchCondition appendFormat:@"%@", self.sortOption.optionName];
  } else {
    [searchCondition appendFormat:@"%@%@", self.sortOption.optionName, LocaleStringForKey(NSSortTitle, nil)];
  }
  
  _listHeaderView.toolbar.searchResultLabel.text = searchCondition;
  
}

- (void)setFilterAndSort {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((type == %d) AND (selected == 1))", DISTANCE_FILTER_TY];
  self.distanceFilterOption = (FilterOption *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                     entityName:@"FilterOption"
                                                                      predicate:predicate];
  
  predicate = [NSPredicate predicateWithFormat:@"((type == %d) AND (selected == 1))", TIME_FILTER_TY];
  self.timeFilterOption = (FilterOption *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                 entityName:@"FilterOption"
                                                                  predicate:predicate];
  
  NearbyItemType type = 0;
  if (self.currentGroup.groupId.longLongValue == PEOPLE_CATEGORY_ID) {
    type = PEOPLE_ITEM_TY;
  } else {
    type = VENUE_ITEM_TY;
  }
  predicate = [NSPredicate predicateWithFormat:@"((usageType == %d) AND (selected == 1))", type];
  self.sortOption = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                         entityName:@"SortOption"
                                                          predicate:predicate];
  
  
  [self adjustFilterSortTinyTitle];
  //_filterType = filterType;
  //_sortType = sortType;
  
  
  /*
   switch (_filterType) {
   case ENTIRE_CITY:
   searchCondition = LocaleStringForKey(NSEntireCityTitle, nil);
   break;
   
   case NEARBY_2_KM:
   searchCondition = LocaleStringForKey(NSWithin2kmTitle, nil);
   break;
   
   case NEARBY_5_KM:
   searchCondition = LocaleStringForKey(NSWithin5kmTitle, nil);
   break;
   
   case NEARBY_10_KM:
   searchCondition = LocaleStringForKey(NSWithin10kmTitle, nil);
   break;
   
   default:
   break;
   }
   
   if (_sortType == SI_SORT_BY_MY_CO_LIKE_TY) {
   // as items of this sort type is less than other sort type, then the list should be
   // cleaned firstly
   [self clearLoadedItems];
   }
   
   switch (_sortType) {
   case SI_SORT_BY_DISTANCE_TY:
   searchCondition = [NSString stringWithFormat:@"%@, %@",
   searchCondition, LocaleStringForKey(NSSortByDistanceTitle, nil)];
   break;
   case SI_SORT_BY_LIKE_COUNT_TY:
   searchCondition = [NSString stringWithFormat:@"%@, %@",
   searchCondition, LocaleStringForKey(NSSortByCommonRateTitle, nil)];
   break;
   
   case SI_SORT_BY_MY_CO_LIKE_TY:
   // as items of this sort type is less than other sort type, then the list should be
   // cleaned firstly
   [self clearLoadedItems];
   searchCondition = [NSString stringWithFormat:@"%@, %@",
   searchCondition, LocaleStringForKey(NSSortByMyCountryRateTitle, nil)];
   break;
   
   case SI_SORT_BY_COMMENT_COUNT_TY:
   searchCondition = [NSString stringWithFormat:@"%@, %@",
   searchCondition, LocaleStringForKey(NSSortByCommentTitle, nil)];
   break;
   
   default:
   break;
   }
   _listHeaderView.toolbar.searchResultLabel.text = searchCondition;
   */
  
  // reset the phase to start from 0
  _currentPhaseIndex = 0;
  
  _needAdjustMapZoomLevel = YES;
}

- (void)filterSortNearbyItem {
  
  [self setFilterAndSort];
  
  if (self.currentGroup.groupId.longLongValue == PEOPLE_CATEGORY_ID) {
    [self loadNearbyPeople:YES loadTriggerType:TRIGGERED_BY_SORT];
  } else {
    [self loadNearbyItems:TRIGGERED_BY_SORT forNew:YES serviceCategory:self.currentGroup];
  }
}

- (void)searchNearbyWithFilter:(NearbyDistanceFilter)filterType
                      sortType:(ServiceItemSortType)sortType
                      keywords:(NSString *)keywords {
  
  [self setFilterAndSort];
  
  //[self searchItemsByKeywords:keywords];
  // FIXME temp
  [self loadNearbyItems:TRIGGERED_BY_SORT forNew:YES serviceCategory:self.currentGroup];
}

- (void)showServiceItemTips {
  
  /*
   NSString *url = [NSString stringWithFormat:@"%@/service_category_tips/category_id:%@/lang:%@/userid:%@",
   [AppManager instance].host,
   self.currentGroup.groupId,
   [WXWSystemInfoManager instance].currentLanguageCode,
   [AppManager instance].userId];
   //@"http://192.168.100.27/xampp/expatcircle/xml/table.html";
   
   ECHTML5ViewController *webVC = [[[ECHTML5ViewController alloc] initWithBackTitle:LocaleStringForKey(NSCloseTitle, nil)
   urlStr:url] autorelease];
   
   webVC.title = [NSString stringWithFormat:@"%@ %@",
   self.currentGroup.groupName, LocaleStringForKey(NSTipsTitle, nil)];
   
   [self.navigationController pushViewController:webVC animated:YES];
   */
}

- (void)activeSearchController {
  SearchListViewController *searchListVC = [[[SearchListViewController alloc] initNoSwipeBackWithMOC:_MOC
                                                                                              holder:nil
                                                                                    backToHomeAction:nil
                                                                                  filterListDelegate:self] autorelease];
  searchListVC.title = LocaleStringForKey(NSSearchTitle, nil);
  WXWNavigationController *searchNav = [[[WXWNavigationController alloc] initWithRootViewController:searchListVC] autorelease];
  [self.navigationController presentModalViewController:searchNav animated:YES];
  /*
   [self performSelector:@selector(presentModalQuickViewController:)
   withObject:searchListVC
   afterDelay:0.15f];
   */
}

#pragma mark - ECLocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(WXWLocationManager *)manager
                                 location:(CLLocation *)location {
  
  [super locationManagerDidReceiveLocation:manager
                                  location:location];
  
  // user enter nearby service first time and location data info be fetched successfully
  [UIUtils closeAsyncLoadingView];
  [self loadItemGroups];
}

- (void)locationManagerDidFail:(WXWLocationManager *)manager {
  [super locationManagerDidFail:manager];
  
  [UIUtils closeAsyncLoadingView];
  
  if (!_noNeedToContinue) {
    // only continue load groups when user does not cancel locate
    [self loadItemGroups];
  }
}

- (void)locationManagerCancelled:(WXWLocationManager *)manager {
  [super locationManagerCancelled:manager];
  
  _noNeedToContinue = YES;
}

#pragma mark - override methods
- (void)configureMOCFetchConditions {
  
  if (self.currentGroup.groupId.longLongValue == PEOPLE_CATEGORY_ID) {
    self.entityName = @"Alumni";
    
    self.predicate = [NSPredicate predicateWithFormat:@"(containerType == %d)", FETCH_SHAKE_USER_TY];
    
    self.descriptors = [NSMutableArray array];
    
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES] autorelease];
    
    [self.descriptors addObject:dateDesc];
    
  } else {
    self.entityName = @"ServiceItem";
    /*
     if (self.currentGroup.groupId.longLongValue == COUPON_CATEGORY_ID) {
     
     switch (_filterType) {
     case NEARBY_2_KM:
     self.predicate = [NSPredicate predicateWithFormat:@"((hasCoupon == 1) AND (distance < %f))", 2.00f];
     break;
     
     case NEARBY_5_KM:
     self.predicate = [NSPredicate predicateWithFormat:@"((hasCoupon == 1) AND (distance < %f))", 5.00f];
     break;
     
     case NEARBY_10_KM:
     self.predicate = [NSPredicate predicateWithFormat:@"((hasCoupon == 1) AND (distance < %f))", 10.00f];
     break;
     
     default:
     self.predicate = [NSPredicate predicateWithFormat:@"(hasCoupon == 1)"];
     break;
     }
     
     } else {
     */
    self.predicate = [NSPredicate predicateWithFormat:@"((categoryId == %@) AND (distance < %f))",
                      self.currentGroup.groupId, _distanceFilterOption.valueFloat.floatValue];
    
    /*
     switch (_filterType) {
     case NEARBY_2_KM:
     self.predicate = [NSPredicate predicateWithFormat:@"((categoryId == %@) AND (distance < %f))",
     self.currentGroup.groupId, 2.00f];
     break;
     
     case NEARBY_5_KM:
     self.predicate = [NSPredicate predicateWithFormat:@"((categoryId == %@) AND (distance < %f))",
     self.currentGroup.groupId, 5.00f];
     break;
     
     case NEARBY_10_KM:
     self.predicate = [NSPredicate predicateWithFormat:@"((categoryId == %@) AND (distance < %f))",
     self.currentGroup.groupId, 10.00f];
     break;
     
     default:
     self.predicate = [NSPredicate predicateWithFormat:@"(categoryId == %@)", self.currentGroup.groupId];
     break;
     }
     */
  }
  
  self.descriptors = [NSMutableArray array];
  switch (/*_sortType*/self.sortOption.optionId.intValue) {
    case SI_SORT_BY_DISTANCE_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
      [self.descriptors addObject:descriptor1];
      
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"itemId" ascending:YES] autorelease];
      [self.descriptors addObject:descriptor2];
      break;
    }
    case SI_SORT_BY_LIKE_COUNT_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"likeCount" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor1];
      
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
      [self.descriptors addObject:descriptor2];
      
      NSSortDescriptor *descriptor3 = [[[NSSortDescriptor alloc] initWithKey:@"itemId" ascending:YES] autorelease];
      [self.descriptors addObject:descriptor3];
      break;
    }
      
    case SI_SORT_BY_MY_CO_LIKE_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"myCountryLikeCount" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor1];
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
      [self.descriptors addObject:descriptor2];
      NSSortDescriptor *descriptor3 = [[[NSSortDescriptor alloc] initWithKey:@"itemId" ascending:YES] autorelease];
      [self.descriptors addObject:descriptor3];
      
      break;
    }
      
    case SI_SORT_BY_COMMENT_COUNT_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"commentCount" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor1];
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
      [self.descriptors addObject:descriptor2];
      NSSortDescriptor *descriptor3 = [[[NSSortDescriptor alloc] initWithKey:@"itemId" ascending:YES] autorelease];
      [self.descriptors addObject:descriptor3];
      break;
    }
      
    default:
      break;
  }
  //}
}

#pragma mark - scrolling overrides

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  if ([UIUtils shouldLoadNewItems:scrollView
                       headerView:_headerRefreshView
                        reloading:_reloading]) {
    
    //_reloading = YES;
    
    _shouldTriggerLoadLatestItems = YES;
    
    if (self.currentGroup.groupId.longLongValue == PEOPLE_CATEGORY_ID) {
      [self loadNearbyPeople:YES loadTriggerType:TRIGGERED_BY_SCROLL];
    } else {
      [self loadNearbyItems:TRIGGERED_BY_SCROLL
                     forNew:YES
            serviceCategory:self.currentGroup];
    }
  }
  
  if ([UIUtils shouldLoadOlderItems:scrollView
                    tableViewHeight:_tableView.contentSize.height
                         footerView:_footerRefreshView
                          reloading:_reloading]) {
    
    _reloading = YES;
    
    if (self.currentGroup.groupId.longLongValue == PEOPLE_CATEGORY_ID) {
      [self loadNearbyPeople:NO loadTriggerType:TRIGGERED_BY_SCROLL];
    } else {
      [self loadNearbyItems:TRIGGERED_BY_SCROLL
                     forNew:NO
            serviceCategory:self.currentGroup];
    }
  }
}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)updateCurrentGroup {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(groupId == %@)", self.currentGroup.groupId];
  self.currentGroup = (ItemGroup *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                          entityName:@"ItemGroup"
                                                           predicate:predicate];
  SAVE_MOC(_MOC);
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case LOAD_SERVICE_CATEGORY_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [_itemGroupScrollView drawItemButtons];
        
        [self showAllItems];
      }
      break;
    }
      
    case SHAKE_USER_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self refreshTable];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
      
      [self resetUIElementsForConnectDoneOrFailed];
      
      [self closeAsyncLoadingView];
      
      break;
    }
      
    case LOAD_SERVICE_ITEM_TY:
    {
      
      if ([XMLParser parserLoadedServiceItem:result
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
        
        // update current group info, e.g., total item count
        [self updateCurrentGroup];
        
        [self refreshTable];
        
        ServiceItem *lastItem = (ServiceItem *)_fetchedRC.fetchedObjects.lastObject;
        _currentOldestTimeline = lastItem.lastCommentTimestamp.doubleValue;
        _currentOldestItemId = lastItem.itemId.longLongValue;
        
        if (!_currentShowList) {
          // current show map view
          
          if (_loadMoreTriggeredForMap) {
            // reset this flag, then the map will be redraw in arrangeAnnotationsForMapView method
            _loadMoreTriggeredForMap = NO;
            
          } else if (_switchTypeInMapView) {
            // reset the phase index after new type item list loaded
            _currentPhaseIndex = 0;
            _switchTypeInMapView = NO;
          }
          
          [self arrangeAnnotationsForMapView];
          
        } else {
          // current show list
          // reset the phase index after new type item list loaded
          _currentPhaseIndex = 0;
        }
        
        /*
         if (_loadMoreTriggeredForMap) {
         // reset this flag, then the map will be redraw in arrangeAnnotationsForMapView method
         _loadMoreTriggeredForMap = NO;
         
         [self arrangeAnnotationsForMapView];
         
         } else {
         // reset the phase index after new type item list loaded
         _currentPhaseIndex = 0;
         }
         */
        
      } else {
        
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLoadNearbyFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      [self resetUIElementsForConnectDoneOrFailed];
      
      [self closeAsyncLoadingView];
      
      break;
    }
      
    default:
      break;
  }
  
  // should be called at end of method to clear connFacade instance
  [super connectDone:result url:url contentType:contentType closeAsyncLoadingView:NO];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  // should be called at end of method to clear connFacade instance
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  switch (contentType) {
    case LOAD_SERVICE_ITEM_TY:
      msg = LocaleStringForKey(NSLoadNearbyFailedMsg, nil);
      
      // reset this flag, then the map will be redraw in arrangeAnnotationsForMapView method
      _loadMoreTriggeredForMap = NO;
      break;
      
    case LOAD_SERVICE_CATEGORY_TY:
      msg = LocaleStringForKey(NSLoadServiceGroupFailedMsg, nil);
      break;
      
    case SHAKE_USER_LIST_TY:
      msg = LocaleStringForKey(NSFetchNearbyPeopleFailedMsg, nil);
      break;
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  // should be called at end of method to clear connFacade instance
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - check latest item properties

- (void)checkAndSetCurrentOldestVenue:(NSIndexPath *)indexPath {
	// record the oldest post time
	if (indexPath.section == [_fetchedRC.sections count] - 1) {
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][indexPath.section];
    if (indexPath.row == [sectionInfo numberOfObjects] - 1) {
      
      _currentStartIndex = indexPath.row + 1;
    }
	}
}


#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSLog(@"row count: %d", _fetchedRC.fetchedObjects.count + 1);
  
  return _fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)drawItemCell:(NSIndexPath *)indexPath item:(ServiceItem *)item {
  
  [self checkAndSetCurrentOldestVenue:indexPath];
  
  static NSString *cellIdentifier = @"serviceItemCell";
  ServiceItemCell *cell = (ServiceItemCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[ServiceItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellIdentifier
                            imageDisplayerDelegate:self
                                               MOC:_MOC] autorelease];
  }
  
  [cell drawItem:item index:indexPath.row];
  return cell;
}

- (UITableViewCell *)drawCouponItemCell:(NSIndexPath *)indexPath item:(ServiceItem *)item {
  [self checkAndSetCurrentOldestVenue:indexPath];
  
  static NSString *cellIdentifier = @"couponItemCell";
  CouponItemCell *cell = (CouponItemCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[CouponItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier
                           imageDisplayerDelegate:self
                                              MOC:_MOC] autorelease];
  }
  
  [cell drawItem:item index:indexPath.row];
  return cell;
}

- (UITableViewCell *)drawPeopleCell:(NSIndexPath *)indexPath {
  
  [self checkAndSetCurrentOldestVenue:indexPath];
  
  static NSString *cellIdentifier = @"PeopleCell";
  
	PeopleWithChatCell *cell = (PeopleWithChatCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[PeopleWithChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier
                               imageDisplayerDelegate:self
                               imageClickableDelegate:self
                                                  MOC:_MOC] autorelease];
  }
  
  Alumni *aAlumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  [cell drawCell:aAlumni];
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  ServiceItem *item = nil;
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  }
  
  item = [_fetchedRC objectAtIndexPath:indexPath];
  
  switch (self.currentGroup.groupId.longLongValue) {
    case COUPON_CATEGORY_ID:
      return [self drawCouponItemCell:indexPath item:item];
      
    case PEOPLE_CATEGORY_ID:
      return [self drawPeopleCell:indexPath];
      
    default:
      return [self drawItemCell:indexPath item:item];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (self.currentGroup.groupId.longLongValue) {
    case COUPON_CATEGORY_ID:
      return COUPON_ITEM_CELL_HEIGHT;
      
    case PEOPLE_CATEGORY_ID:
      return USER_LIST_CELL_HEIGHT;
      
    default:
      return ITEM_CELL_HEIGHT;
  }
}

- (void)showAlumniDetail:(NSIndexPath *)indexPath {
  
  Alumni *alumni = (Alumni *)[_fetchedRC objectAtIndexPath:indexPath];
  [AppManager instance].latitude = [alumni.latitude doubleValue];
  [AppManager instance].longitude = [alumni.longitude doubleValue];
  [AppManager instance].defaultPlace = alumni.shakePlace;
  [AppManager instance].defaultDistance = alumni.distance;
  [AppManager instance].defaultThing = alumni.shakeThing;
  
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                      alumni:alumni
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)showVenueDetail:(NSIndexPath *)indexPath {
  ServiceItem *item = (ServiceItem *)[_fetchedRC objectAtIndexPath:indexPath];
  ServiceItemDetailViewController *profileVC = [[[ServiceItemDetailViewController alloc] initWithMOC:_MOC
                                                                                              holder:((iAlumniAppDelegate*)APP_DELEGATE)
                                                                                    backToHomeAction:@selector(backToHomepage:)
                                                                                         serviceItem:item] autorelease];
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (self.currentGroup.groupId.longLongValue) {
    case PEOPLE_CATEGORY_ID:
      [self showAlumniDetail:indexPath];
      break;
      
    default:
      [self showVenueDetail:indexPath];
      break;
  }
}

#pragma mark - ECClickableElementDelegate method
- (void)doChat:(Alumni*)aAlumni
{
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

- (void)openProfile:(NSString*)userId userType:(NSString*)userType {
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:userId
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - Action Sheet
- (void)beginChat {
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:self.alumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];

  /*
  [CommonUtils doDelete:_MOC entityName:@"Chat"];
  ChatListViewController *chartVC = [[ChatListViewController alloc] initWithMOC:_MOC
                                                                         alumni:self.alumni];
  [self.navigationController pushViewController:chartVC animated:YES];
  RELEASE_OBJ(chartVC);
   */
}

- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case CHAT_SHEET_IDX:
		{
      [self beginChat];
      return;
		}
      
		case DETAIL_SHEET_IDX:
      [self openProfile:self.alumni.personId userType:self.alumni.userType];
			return;
			
    case CANCEL_SHEET_IDX:
      return;
      
		default:
			break;
	}
}

@end
