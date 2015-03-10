//
//  RecommendedItemThumbnailView.m
//  ExpatCircle
//
//  Created by Adam on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecommendedItemThumbnailView.h"
#import <QuartzCore/QuartzCore.h>
#import "RecommendedItem.h"

@implementation RecommendedItemThumbnailView

#pragma mark - lifecycle methods

- (void)addShadow {
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  CGFloat curlFactor = 10.0f;
  CGFloat shadowDepth = 4.0f;
  [shadowPath moveToPoint:CGPointMake(0, 0)];
  [shadowPath addLineToPoint:CGPointMake(self.frame.size.width, 0)];
  [shadowPath addLineToPoint:CGPointMake(self.frame.size.width, 
                                         self.frame.size.height + shadowDepth)];
  [shadowPath addCurveToPoint:CGPointMake(0.0f, self.frame.size.height + shadowDepth)
                controlPoint1:CGPointMake(self.frame.size.width - curlFactor, 
                                          self.frame.size.height + shadowDepth - curlFactor)
                controlPoint2:CGPointMake(curlFactor, 
                                          self.frame.size.height + shadowDepth - curlFactor)];
  
  self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  self.layer.shadowOpacity = 0.7f;
  self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  self.layer.shadowRadius = 2.0f;
  self.layer.masksToBounds = NO;
  
  self.layer.shadowPath = shadowPath.CGPath;
}

- (id)initWithFrame:(CGRect)frame
        recommended:(RecommendedItem *)recommended {

  _recommendedItem = recommended;
  
  self = [super initWithFrame:frame
                        title:_recommendedItem.enName];
  if (self) {
    
    [self addShadow];
      
  }
  return self;
}

- (void)dealloc {
    
  [super dealloc];
}

@end
