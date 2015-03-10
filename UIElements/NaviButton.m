//
//  NaviButton.m
//  iAlumni
//
//  Created by Adam on 13-2-1.
//
//

#import "NaviButton.h"
#import "WXWUIUtils.h"

@implementation NaviButton

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

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImageView *arrowImgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowDown.png"]] autorelease];
    arrowImgView.frame = CGRectMake(self.frame.size.width-MARGIN*3, 22.f, 7.5f, 4.f);
    arrowImgView.backgroundColor = TRANSPARENT_COLOR;
    [self addSubview:arrowImgView];
    
    [WXWUIUtils draw1PxStroke:context
                   startPoint:CGPointMake(0.5f, 0)
                     endPoint:CGPointMake(0.5f, self.frame.size.height)
                        color:COLOR(125, 28, 27).CGColor
                 shadowOffset:CGSizeMake(1.0f, 0.0f)
                  shadowColor:COLOR(187, 60, 64)];
}


@end
