//
//  UIView+ShakeAnimation.m
//  iAlumni
//
//  Created by Adam on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIView+ShakeAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (ShakeAnimation)

- (void)shakeX {
	[self shakeXWithOffset:40.0 breakFactor:0.85 duration:1.5 maxShakes:30];
}

- (void)shakeXWithOffset:(CGFloat)aOffset 
             breakFactor:(CGFloat)aBreakFactor 
                duration:(CGFloat)aDuration 
               maxShakes:(NSInteger)maxShakes {
  
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	[animation setDuration:aDuration];
	
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:20];
	int infinitySec = maxShakes;
	while(aOffset > 0.01) {
		[keys addObject:[NSValue valueWithCGPoint:CGPointMake(self.center.x - aOffset, self.center.y)]];
		aOffset *= aBreakFactor;
		[keys addObject:[NSValue valueWithCGPoint:CGPointMake(self.center.x + aOffset, self.center.y)]];
		aOffset *= aBreakFactor;
		infinitySec--;
		if(infinitySec <= 0) {
			break;
		}
	}
	
	animation.values = keys;
	
	[self.layer addAnimation:animation forKey:@"position"];
}

@end
