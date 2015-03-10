//
//  TopicContentView.m
//  iAlumni
//
//  Created by Adam on 12-9-11.
//
//

#import "TopicContentView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"

@implementation TopicContentView

- (void)addShadowEffectToView:(UIView *)view {
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  CGFloat curlFactor = 10.0f;
  CGFloat shadowDepth = 8.0f;
  [shadowPath moveToPoint:CGPointMake(2.0f, MARGIN)];
  [shadowPath addLineToPoint:CGPointMake(view.bounds.size.width - 2.0f, MARGIN)];
  [shadowPath addLineToPoint:CGPointMake(view.bounds.size.width - 2.0f,
                                         view.bounds.size.height + shadowDepth)];
  [shadowPath addCurveToPoint:CGPointMake(2.0f, view.bounds.size.height + shadowDepth)
                controlPoint1:CGPointMake(view.bounds.size.width - curlFactor,
                                          view.bounds.size.height + shadowDepth - curlFactor)
                controlPoint2:CGPointMake(curlFactor,
                                          view.bounds.size.height + shadowDepth - curlFactor)];
  view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  view.layer.shadowOpacity = 0.7f;
  view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  view.layer.shadowRadius = 2.0f;
  view.layer.masksToBounds = NO;
  view.layer.shadowPath = shadowPath.CGPath;
}

- (id)initWithFrame:(CGRect)frame content:(NSString *)content
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = CELL_COLOR;
    
    UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, frame.size.width - MARGIN * 4, frame.size.height - MARGIN * 4)] autorelease];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backgroundView];
    [self addShadowEffectToView:backgroundView];
    
    _contentLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:DARK_TEXT_COLOR
                                        shadowColor:TRANSPARENT_COLOR] autorelease];
    _contentLabel.font = BOLD_FONT(15);
    _contentLabel.numberOfLines = 0;
    _contentLabel.text = content;
    CGSize size = [content sizeWithFont:_contentLabel.font
                      constrainedToSize:CGSizeMake(self.frame.size.width - (MARGIN * 4 + MARGIN * 2), CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
    _contentLabel.frame = CGRectMake(MARGIN, MARGIN, size.width, size.height);
    [backgroundView addSubview:_contentLabel];
    
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}



@end
