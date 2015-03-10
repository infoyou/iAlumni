//
//  ListSectionView.m
//  iAlumni
//
//  Created by Adam on 12-10-25.
//
//

#import "ListSectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "GlobalConstants.h"
#import "UIUtils.h"

@implementation ListSectionView

- (void)addShadow {
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 4.0f,
                                                                         self.bounds.size.width,
                                                                         self.bounds.size.height - 6.0f)];
  
  self.layer.shadowPath = shadowPath.CGPath;
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.masksToBounds = NO;
  self.layer.shadowOffset = CGSizeMake(0, 0);
  self.layer.shadowOpacity = 0.9f;
}

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title {
  self = [self initWithFrame:frame
                       title:title
                   titleFont:BOLD_FONT(12)];
  return self;
}

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
          titleFont:(UIFont *)titleFont
{
  self = [super initWithFrame:frame
                     topColor:COLOR(170, 170, 170)
                  bottomColor:COLOR(212, 212, 212)];
  if (self) {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = TRANSPARENT_COLOR;
    
    [self addShadow];
    
    WXWLabel *titleLable = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                textColor:[UIColor whiteColor]
                                              shadowColor:COLOR(136, 136, 136)] autorelease];
    titleLable.backgroundColor = TRANSPARENT_COLOR;
    titleLable.font = titleFont;
    titleLable.text = title;
    CGSize size = [titleLable.text sizeWithFont:titleLable.font
                              constrainedToSize:CGSizeMake(self.frame.size.width, frame.size.height - 2)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    titleLable.frame = CGRectMake(MARGIN * 2, (self.frame.size.height - size.height)/2.0f, size.width, size.height);
    [self addSubview:titleLable];
    
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  // draw top and bottom border
  CGPoint startPoint = CGPointMake(0.0f, 0.0f);
  CGPoint endPoint = CGPointMake(self.frame.size.width, 0.0f);
  
  CGColorRef borderColorRef = SEPARATOR_LINE_COLOR.CGColor;
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:startPoint
                endPoint:endPoint
                   color:borderColorRef
            shadowOffset:CGSizeMake(0.0f, 0.0f)
             shadowColor:TRANSPARENT_COLOR];
  
}


+ (Class)layerClass
{
	return [CAGradientLayer class];
}


- (void)dealloc {
  
  [super dealloc];
}


@end
