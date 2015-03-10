//
//  UIView+ShakeAnimation.h
//  iAlumni
//
//  Created by Adam on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ShakeAnimation)

- (void)shakeX;

/*!
 @discussion		You can give a special offset (the amount of pixel to break out) and the breakfactor (which must be < 1). A animation duration is also possible
 */
- (void)shakeXWithOffset:(CGFloat)aOffset 
             breakFactor:(CGFloat)aBreakFactor
                duration:(CGFloat)aDuration
               maxShakes:(NSInteger)maxShakes;

@end
