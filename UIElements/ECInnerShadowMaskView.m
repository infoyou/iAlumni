//
//  ECInnerShadowMaskView.m
//  ExpatCircle
//
//  Created by Adam on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECInnerShadowMaskView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ECInnerShadowMaskView

- (void)initProperties:(CGFloat)radius {
  _radius = radius;
  
  self.backgroundColor = TRANSPARENT_COLOR;
}

- (id)initCircleWithCenterPoint:(CGPoint)centerPoint radius:(CGFloat)radius {
  CGFloat diameter = 2.0f * radius;
  
  self = [super initWithFrame:CGRectMake(centerPoint.x - radius,
                                         centerPoint.y - radius, 
                                         diameter, diameter)];
  if (self) {
    [self initProperties:radius];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame radius:(CGFloat)radius {
  self = [super initWithFrame:frame];
  
  if (self) {
    [self initProperties:radius];
  }
  
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // clip context so shadow only shows on the inside
  CGPathRef roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_radius].CGPath;
  CGContextAddPath(context, roundedRect);
  CGContextClip(context);
  
  CGContextAddPath(context, roundedRect);
  CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), 
                              CGSizeMake(0, 0), 
                              3, 
                              [UIColor colorWithWhite:0 alpha:1].CGColor);
  
  CGContextSetStrokeColorWithColor(context, CELL_COLOR.CGColor);
  CGContextStrokePath(context);

}


@end
