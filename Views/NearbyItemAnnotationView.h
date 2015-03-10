//
//  NearbyItemAnnotationView.h
//  ExpatCircle
//
//  Created by Adam on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GlobalConstants.h"


@class NearbyAnnotation;
@class WXWLabel;

@interface NearbyItemAnnotationView : MKAnnotationView {
  @private
  WXWLabel *_label;
}

- (id)initWithAnnotation:(NearbyAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setSequenceNumber:(NSInteger)number;

- (void)setPinTextColor:(UIColor *)color;

@end
