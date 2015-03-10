//
//  ECRoundButton.h
//  iAlumni
//
//  Created by Adam on 12-2-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface ECRoundButton : UIButton {
  @private
  
  ButtonColorType _colorType;
  
  CGFloat _radius;
}

- (id)initWithCenterPoint:(CGPoint)centerPoint
                   radius:(CGFloat)radius
                colorType:(ButtonColorType)colorType 
              borderWidth:(CGFloat)borderWidth
              borderColor:(UIColor *)borderColor
                    image:(UIImage *)image
                    title:(NSString *)title
                titleFont:(UIFont *)titleFont
               titleColor:(UIColor *)titleColor
         titleShadowColor:(UIColor *)titleShadowColor
                   target:(id)target
                   action:(SEL)action;

@end
