//
//  ECEmbedMapView.h
//  iAlumni
//
//  Created by Adam on 11-12-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ECClickableElementDelegate.h"

@interface ECEmbedMapView : MKMapView {
  
  @private
  id<ECClickableElementDelegate> _delegate;
  
}
- (id)initWithFrame:(CGRect)frame clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

@end
