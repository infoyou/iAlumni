//
//  BranchListViewController.h
//  iAlumni
//
//  Created by Adam on 12-8-14.
//
//

#import "BaseListViewController.h"
#import <MapKit/MapKit.h>

@class ServiceItem;
@class NearbyMapView;
@class ItemCalloutView;
@class NearbyItemAnnotationView;

@interface BranchListViewController : BaseListViewController <MKMapViewDelegate> {
  @private
  
  NearbyMapView *_mapView;
  
  ServiceItem *_userLastSelectedItem;
  NearbyItemAnnotationView *_userLastSelectedAnnotationView;
  
  ItemCalloutView *_calloutView;
  UIView *_tableAndMapContainer;
  
  BOOL _currentShowList;
  
  NSInteger _itemTotalCount;
  
  NSInteger _startIndex;
  NSInteger _endIndex;
  NSInteger _currentPhaseIndex;   // indicate current which phase of item list be displayed in map
  BOOL _loadMoreTriggeredForMap;  // if current loaded items is not enough to displayed in map, then trigger load more
  BOOL _switchTypeInMapView;
  
  BOOL _keepCalloutView;

  BOOL _clearCalloutViewForIOS4x;
  
  BOOL _needAdjustMapZoomLevel;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
