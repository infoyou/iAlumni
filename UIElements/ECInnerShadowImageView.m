//
//  ECInnerShadowImageView.m
//  ExpatCircle
//
//  Created by Adam on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECInnerShadowImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "ECInnerShadowMaskView.h"

@implementation ECInnerShadowImageView

- (id)initCircleWithCenterPoint:(CGPoint)centerPoint 
                         radius:(CGFloat)radius {
  
  CGFloat diameter = 2.0f * radius;
  
  self = [super initWithFrame:CGRectMake(centerPoint.x - radius,
                                         centerPoint.y - radius, 
                                         diameter, diameter)];
  if (self) {
    _centerPoint = centerPoint;
    _radius = radius;
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    self.imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, diameter, diameter)] autorelease];
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.layer.cornerRadius = radius;
    self.imageView.layer.masksToBounds = YES;
    [self addSubview:self.imageView];
      
    ECInnerShadowMaskView *shadowMaskView = [[[ECInnerShadowMaskView alloc] initCircleWithCenterPoint:CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f)
                                                                                               radius:radius] autorelease];
    [self addSubview:shadowMaskView];
  }
  return self;
}

- (void)dealloc {
  
  self.imageView = nil;
  
  [super dealloc];
}
@end
