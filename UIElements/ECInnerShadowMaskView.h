//
//  ECInnerShadowMaskView.h
//  ExpatCircle
//
//  Created by Adam on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface ECInnerShadowMaskView : UIView {
  @private
  
  CGFloat _radius;
}

- (id)initCircleWithCenterPoint:(CGPoint)centerPoint radius:(CGFloat)radius;

- (id)initWithFrame:(CGRect)frame radius:(CGFloat)radius;
@end
