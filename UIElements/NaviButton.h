//
//  NaviButton.h
//  iAlumni
//
//  Created by Adam on 13-2-1.
//
//

#import <UIKit/UIKit.h>

@interface NaviButton : UIButton

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
          titleFont:(UIFont *)titleFont
         titleColor:(UIColor *)titleColor
    backgroundColor:(UIColor *)backgroundColor
             target:(id)target
             action:(SEL)action;

@end
