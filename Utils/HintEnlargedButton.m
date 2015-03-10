//
//  HintEnlargedButton.m
//  iAlumni
//
//  Created by Adam on 13-9-2.
//
//

#import "HintEnlargedButton.h"

#define HIT_OFFSET   20.0f

@implementation HintEnlargedButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  CGRect bounds = self.bounds;
  
  bounds = CGRectMake(bounds.origin.x - HIT_OFFSET, bounds.origin.y - HIT_OFFSET,
                      bounds.size.width + HIT_OFFSET * 2, bounds.size.height + HIT_OFFSET * 2);
  return CGRectContainsPoint(bounds, point);
}

@end
