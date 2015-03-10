//
//  TabSwitchButton.m
//  iAlumni
//
//  Created by Adam on 13-2-1.
//
//

#import "TabSwitchButton.h"

@implementation TabSwitchButton

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
          titleFont:(UIFont *)titleFont
         titleColor:(UIColor *)titleColor
    backgroundColor:(UIColor *)backgroundColor
             target:(id)target
             action:(SEL)action
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitle:title forState:UIControlStateNormal];
        
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        self.titleLabel.font = titleFont;
        self.titleLabel.shadowColor = [UIColor whiteColor];
        self.titleEdgeInsets = UIEdgeInsetsMake(MARGIN, 0, 0, 0);
        
        [self addTarget:target
                 action:action
       forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

@end
