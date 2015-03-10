//
//  VenueListViewController.h
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import "BaseListViewController.h"
#import <MapKit/MapKit.h>
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"

@class Brand;
@class NearbyMapView;
@class ItemCalloutView;
@class NearbyItemAnnotationView;
@class Welfare;

@interface VenueListViewController : BaseListViewController <MKMapViewDelegate, ECFilterListDelegate, UIActionSheetDelegate> {
  @private
  
  Welfare *_welfare;
  
  //-------------
  Brand *_brand;
  
  NSNumber *_itemTotleCount;
  
  long long _brandId;
  
  UIView *_tableAndMapContainer;  // be used to flip between list and map
  
  // map view
  NearbyMapView *_mapView;
  NSInteger _startIndex;
  NSInteger _endIndex;
  BOOL _currentShowList;
  BOOL _loadMoreTriggeredForMap;
  NSInteger _currentPhaseIndex;
  BOOL _keepCalloutView;
  BOOL _clearCalloutViewForIOS4x;
  BOOL _switchTypeInMapView;
  ItemCalloutView *_calloutView;
  NearbyItemAnnotationView *_userLastSelectedAnnotationView;
  
  // location
  BOOL _currentLocationIsLatest;
}

- (id)initNearbyVenuesWithMOC:(NSManagedObjectContext *)MOC
            locationRefreshed:(BOOL)locationRefreshed
                      welfare:(Welfare *)welfare;

- (id)initBranchVenuesWithMOC:(NSManagedObjectContext *)MOC
                        brand:(Brand *)brand
            locationRefreshed:(BOOL)locationRefreshed;

@end
