//
//  MapViewController.h
//  iAlumni
//
//  Created by Adam on 11-12-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import "GlobalConstants.h"

@interface MapViewController : WXWRootViewController <MKMapViewDelegate, UIAlertViewDelegate> {
  @private
  MKMapView				*_mapView;
  
  double _latitude;
  double _longitude;
  
  BOOL _allowLaunchGoogleMap;
}

- (id)initWithLatitude:(double)latitude 
             longitude:(double)longitude
  allowLaunchGoogleMap:(BOOL)allowLaunchGoogleMap;

@end
