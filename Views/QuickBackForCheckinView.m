//
//  QuickBackForCheckinView.m
//  iAlumni
//
//  Created by Adam on 12-8-31.
//
//

#import "QuickBackForCheckinView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"

@interface QuickBackForCheckinView()
@property (nonatomic, retain) UIColor *topColor;
@property (nonatomic, retain) UIColor *bottomColor;
@end

@implementation QuickBackForCheckinView

@synthesize topColor = _topColor;
@synthesize bottomColor = _bottomColor;

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
    checkinDelegate:(id<EventCheckinDelegate>)checkinDelegate
      directionType:(OvalSideDirectionType)directionType
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    _directionType = directionType;
    
    _checkinDelegate = checkinDelegate;
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    self.topColor = topColor;
    
    self.bottomColor = bottomColor;
    
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:[UIColor whiteColor]
                                      shadowColor:TRANSPARENT_COLOR] autorelease];
    _titleLabel.font = BOLD_FONT(13);
    
    [self addSubview:_titleLabel];
  }
  return self;
}

- (void)dealloc {
  
  self.topColor = nil;
  self.bottomColor = nil;
  
  [super dealloc];
}

#pragma mark - draw methods
- (void)drawOutline:(CGContextRef)context {
  CGFloat radius = self.bounds.size.height/2;
  CGFloat center_x = 0.0f;
  CGFloat center_y = 0.0f;
  CGFloat startAngle = 0.0f;
  CGFloat endAngle = 0.0f;
  CGFloat startLocations[2];
  CGFloat end1Locations[2];
  CGFloat end2Locations[2];
  CGFloat end3Locations[2];
  switch (_directionType) {
    case LEFT_DIR_TY:
    {
      center_x = radius;
      center_y = radius;
      startAngle = 3.0f*M_PI/2.0f;
      endAngle = M_PI/2.0f;
      
      startLocations[0] = radius;
      startLocations[1] = 0.0f;
      end1Locations[0] = self.bounds.size.width;
      end1Locations[1] = 0.0f;
      end2Locations[0] = self.bounds.size.width;
      end2Locations[1] = self.bounds.size.height;
      end3Locations[0] = radius;
      end3Locations[1] = self.bounds.size.height;
      break;
    }
      
    case RIGHT_DIR_TY:
    {
      center_x = self.bounds.size.width - radius;
      center_y = radius;
      startAngle = M_PI / 2.0f;
      endAngle = 3.0f * M_PI/2.0f;
      
      startLocations[0] = self.bounds.size.width - radius;
      startLocations[1] = 0.0f;
      end1Locations[0] = 0.0f;
      end1Locations[1] = 0.0f;
      end2Locations[0] = 0.0f;
      end2Locations[1] = self.bounds.size.height;
      end3Locations[0] = self.bounds.size.width - radius;
      end3Locations[1] = self.bounds.size.height;
      break;
    }
      
    default:
      break;
  }
  CGContextAddArc(context, center_x, center_y, radius, startAngle, endAngle, true);
  CGContextMoveToPoint(context, startLocations[0], startLocations[1]);
  CGContextAddLineToPoint(context, end1Locations[0], end1Locations[1]);
  CGContextAddLineToPoint(context, end2Locations[0], end2Locations[1]);
  CGContextAddLineToPoint(context, end3Locations[0], end3Locations[1]);
    
  CGContextClosePath(context);
  CGContextClip(context);
}

- (void)drawGradientColors:(CGContextRef)context
                      rect:(CGRect)rect {
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGFloat locations[] = { 0.0, 1.0 };
  
  NSArray *colors = @[(id)self.topColor.CGColor,
                     (id)self.bottomColor.CGColor];
  
  // draw gradient colors
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
  
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
  
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGContextSaveGState(context);
  
  CGColorSpaceRelease(colorSpace);
  CGGradientRelease(gradient);
}

- (void)adjustShadow {
  UIBezierPath *outlinePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.bounds.origin.x,
                                                                                 self.bounds.origin.y,
                                                                                 self.bounds.size.width + MARGIN * 2,
                                                                                 self.bounds.size.height)
                                                         cornerRadius:self.bounds.size.height/2.0f];
  self.layer.shadowPath = outlinePath.CGPath;
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOpacity = 0.6f;
  self.layer.shadowRadius = 2.0f;
  self.layer.shadowOffset = CGSizeMake(0, 0);
  self.layer.masksToBounds = NO;
}

- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(context);
  
  // draw arc and sideline
  [self drawOutline:context];
  
  // draw gradient colors
  [self drawGradientColors:context
                      rect:rect];
  
  [self adjustShadow];
}

- (void)setTitle:(NSString *)title {
  _titleLabel.text = title;
  
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat width = size.width + MARGIN * 4;
  self.frame = CGRectMake(320 - width, self.frame.origin.y, width, self.frame.size.height);
  
  _titleLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                                 (self.frame.size.height - size.height)/2.0f,
                                 size.width,
                                 size.height);
}

#pragma mark - touch action
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_checkinDelegate) {
    [_checkinDelegate quickCheck];
  }
}

@end
