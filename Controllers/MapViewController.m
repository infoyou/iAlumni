//
//  MapViewController.m
//  iAlumni
//
//  Created by Adam on 11-12-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TextConstants.h"
#import "ECMapAnnotation.h"
#import "CommonUtils.h"

@implementation MapViewController

#pragma mark - user action

- (void)close:(id)sender {
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)lanuchGoogleMap:(id)sender {
  NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=Current%%20Location&daddr=%f,%f", _latitude, _longitude];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - draw location
- (void)drawUserLocation {
	
	// draw map
	CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:_latitude 
                                                           longitude:_longitude];
	/*
   _mapView.centerCoordinate = currentLocation.coordinate;
   
   MKCoordinateRegion region;
   region.center.latitude = _latitude;
   region.center.longitude = _longitude;
   
   MKCoordinateSpan span;
   span.latitudeDelta = INIT_ZOOM_LEVEL;
   span.longitudeDelta = INIT_ZOOM_LEVEL;
   
   region.span = span;
   _mapView.region = region;
   */
  [_mapView setCenterCoordinate:currentLocation.coordinate
                      zoomLevel:INIT_ZOOM_LEVEL
                       animated:YES];
  
	ECMapAnnotation *annotation = [[ECMapAnnotation alloc] initWithCoordinate:currentLocation.coordinate];
	[_mapView addAnnotation:annotation];
	
	RELEASE_OBJ(currentLocation)
	
	RELEASE_OBJ(annotation);
}

#pragma mark mapView delegate functions

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView* annotationView = nil;
	
	// determine the type of annotation, and produce the correct type of annotation view for it.
	ECMapAnnotation* csAnnotation = (ECMapAnnotation*)annotation;
	
	NSString* identifier = @"Pin";
	MKPinAnnotationView* pin = (MKPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if(nil == pin) {
		pin = [[[MKPinAnnotationView alloc] initWithAnnotation:csAnnotation reuseIdentifier:identifier] autorelease];
		pin.animatesDrop = YES;
	}
  
	pin.pinColor = MKPinAnnotationColorRed;
  
	annotationView = pin;
	
	return annotationView;
}

#pragma mark - lifecycle methods
- (id)initWithLatitude:(double)latitude 
             longitude:(double)longitude
  allowLaunchGoogleMap:(BOOL)allowLaunchGoogleMap {

  self = [super initWithMOC:nil holder:nil backToHomeAction:nil needGoHome:NO];
  if (self) {
    _latitude = latitude;
    _longitude = longitude;
    _allowLaunchGoogleMap = allowLaunchGoogleMap;
  }
  return self;
}

- (void)viewDidLoad {
  
	[super viewDidLoad];
  
  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSBackTitle, nil)
                           target:self
                           action:@selector(close:)];
  
  if (_allowLaunchGoogleMap) {
    [self addRightBarButtonWithTitle:LocaleStringForKey(NSRouteTitle, nil)
                              target:self
                              action:@selector(lanuchGoogleMap:)];
  }
  
  _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  _mapView.delegate = self;
	_mapView.autoresizesSubviews = YES;
	_mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);  
	[self.view addSubview:_mapView];
  
  self.navigationItem.title = LocaleStringForKey(NSUserPlaceTitle, nil);
  
  [self drawUserLocation];
}

- (void)dealloc {
  
  _mapView.delegate = nil;
  RELEASE_OBJ(_mapView);
  
  [super dealloc];
}

@end
