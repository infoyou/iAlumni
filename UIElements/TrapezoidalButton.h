//
//  TrapezoidalButton.h
//  iAlumni
//
//  Created by Adam on 12-8-29.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface TrapezoidalButton : UIButton {
@private
  BOOL _topShort;
  
  UIColor *_color;
}

@property (nonatomic, retain) UIColor *color;

- (id)initWithFrame:(CGRect)frame
     topBorderShort:(BOOL)topBorderShort
              title:(NSString *)title
          titleFont:(UIFont *)titleFont
         titleColor:(UIColor *)titleColor
    backgroundColor:(UIColor *)backgroundColor
             target:(id)target
             action:(SEL)action;
@end
