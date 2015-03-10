//
//  NearbyViewController.h
//  ExpatCircle
//
//  Created by Adam on 11-12-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import <MapKit/MapKit.h>
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"
#import "ECClickableElementDelegate.h"

@class BizPartnerGroupScrollView;
@class NearbySearchBar;
@class ItemGroup;
@class NearbyMapView;
@class ItemCalloutView;
@class ServiceItem;
@class NearbyItemAnnotationView;
@class TipsEntranceView;
@class ServiceItemListHeaderView;
@class FilterOption;
@class SortOption;
@class Alumni;

@interface NearbyViewController : BaseListViewController <ECFilterListDelegate, MKMapViewDelegate, UIAlertViewDelegate, ECClickableElementDelegate, UIActionSheetDelegate> {
  @private
  BizPartnerGroupScrollView *_itemGroupScrollView;
  
  NearbyMapView *_mapView;

  NSInteger _startIndex;
  NSInteger _endIndex;
  NSInteger _currentPhaseIndex;   // indicate current which phase of item list be displayed in map
  BOOL _loadMoreTriggeredForMap;  // if current loaded items is not enough to displayed in map, then trigger load more
  BOOL _switchTypeInMapView;
  
  ServiceItem *_userLastSelectedItem;
  NearbyItemAnnotationView *_userLastSelectedAnnotationView;
  
  ItemCalloutView *_calloutView;
  
  UIView *_tableAndMapContainer;  // be used to flip between list and map
  
  ItemGroup *_currentGroup;
  
  long long _currentOldestItemId;
  NSTimeInterval _currentOldestTimeline;
  
  ServiceItemSortType _sortType;
  NearbyDistanceFilter _filterType;
  
  FilterOption *_distanceFilterOption;
  FilterOption *_timeFilterOption;
  SortOption *_sortOption;
  
  BOOL _noNeedToContinue;
  
  ServiceItemListHeaderView *_listHeaderView;
  
  BOOL _currentShowList;
  
  BOOL _keepCalloutView;
  
  BOOL _clearCalloutViewForIOS4x;
  
  BOOL _needAdjustMapZoomLevel;
  
  Alumni *_alumni;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
