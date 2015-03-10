//
//  ECPlainButton.h
//  iAlumni
//
//  Created by Adam on 12-9-7.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface ECPlainButton : UIButton {
  @private
  
  CGFloat _hue;
  CGFloat _saturation;
  CGFloat _brightness;
}

- (id)initPlainButtonWithFrame:(CGRect)frame
                        target:(id)target
                        action:(SEL)action
                         title:(NSString *)title
                         image:(UIImage*)image
                           hue:(CGFloat)hue
                    saturation:(CGFloat)saturation
                    brightness:(CGFloat)brightness
                   borderColor:(UIColor *)borderColor
                     titleFont:(UIFont *)titleFont
                    titleColor:(UIColor *)titleColor
              titleShadowColor:(UIColor *)titleShadowColor
                   roundedType:(ButtonRoundedType)roundedType
               imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert
               titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert;

@end
