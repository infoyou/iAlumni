//
//  CouponTipsDetailView.m
//  iAlumni
//
//  Created by Adam on 12-8-25.
//
//

#import "CouponTipsDetailView.h"
#import "UIUtils.h"
#import "ECColorfulButton.h"
#import "WXWRootViewController.h"
#import "WXWLabel.h"
#import "CommonUtils.h"

#define SEPARATOR_Y   44.0f

#define BUTTON_WIDTH  60.0f
#define BUTTON_HEIGHT 30.0f

@implementation CouponTipsDetailView


#pragma mark - user action
- (void)close:(id)sender {
  if (_holder) {
    [((WXWRootViewController *)_holder) dismissModalQuickView];
  }
}

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame holder:(id)holder {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = CELL_COLOR;
    
    _holder = holder;
    
    ECColorfulButton *closeButton = [[[ECStandardButton alloc] initWithFrame:CGRectMake(self.frame.size.width - MARGIN * 2 - BUTTON_WIDTH,
                                                                                        (SEPARATOR_Y - BUTTON_HEIGHT)/2.0f,
                                                                                        BUTTON_WIDTH,
                                                                                        BUTTON_HEIGHT)
                                                                      target:self
                                                                      action:@selector(close:)
                                                                       title:LocaleStringForKey(NSCloseTitle, nil)
                                                                   tintColor:NAVIGATION_BAR_COLOR
                                                                   titleFont:BOLD_FONT(14)
                                                                 borderColor:nil] autorelease];
    [self addSubview:closeButton];
    
    
    WXWLabel *label_1 = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                             textColor:BASE_INFO_COLOR
                                           shadowColor:[UIColor whiteColor]] autorelease];
    label_1.font = BOLD_FONT(15);
    label_1.numberOfLines = 0;
    label_1.text = LocaleStringForKey(NSCouponTip_1Msg, nil);
    
    CGSize size = [label_1.text sizeWithFont:label_1.font
                           constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    label_1.frame = CGRectMake(MARGIN * 2, SEPARATOR_Y + MARGIN * 2, size.width, size.height);
    
    [self addSubview:label_1];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat pattern[2] = {1.0, 2.0};
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(0, SEPARATOR_Y + 0.5f)
                  endPoint:CGPointMake(self.frame.size.width, SEPARATOR_Y + 0.5f)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0, 1.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];
}

@end
