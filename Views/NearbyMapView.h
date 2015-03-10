//
//  NearbyMapView.h
//  ExpatCircle
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"

@class WXWLabel;

@interface NearbyMapView : MKMapView {
  @private
  UIView *_titleView;
  WXWLabel *_spLabel;
  UIButton *_previous20Button;
  UIButton *_next20Button;
  
  id<ECFilterListDelegate> _filterListDelegate;
  
  id _target;
  SEL _hideCalloutAction;
}

- (id)initWithFrame:(CGRect)frame 
 filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate
             target:(id)target
  hideCalloutAction:(SEL)hideCalloutAction
     needFilterSort:(BOOL)needFilterSort;

#pragma mark - set service provider title
- (void)setSPTitleWithStartNumber:(NSInteger)startNumber
                        endNumber:(NSInteger)endNumber 
                        itemTotal:(NSInteger)itemTotal;

#pragma mark - adjust zoom level to cover all annotations
- (void)zoomToFitMapAnnotations;

@end
