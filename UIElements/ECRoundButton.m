//
//  ECRoundButton.m
//  iAlumni
//
//  Created by Adam on 12-2-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECRoundButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation ECRoundButton

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
                   action:(SEL)action {
  
  self = [super initWithFrame:CGRectMake(centerPoint.x - radius, centerPoint.y - radius, radius * 2, radius * 2)];
  
  if (self) {
    
    _colorType = colorType;
    
    _radius = radius;
    
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    if (image) {
      [self setImage:image forState:UIControlStateNormal];      
    }
    
    if (title) {
      [self setTitle:title forState:UIControlStateNormal];
    }
    
    self.titleLabel.font = titleFont;
    self.titleLabel.textColor = titleColor;
    [self setTitleShadowColor:titleShadowColor 
                     forState:UIControlStateNormal];
    
    self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    
    if (borderColor) {
      self.layer.borderColor = borderColor.CGColor;
    } else {
      self.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    self.layer.borderWidth = borderWidth;
    
    self.layer.masksToBounds = YES;
    
    self.layer.cornerRadius = radius;
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)drawGradientColors:(CGContextRef)context 
               topColorRef:(CGColorRef)topColorRef
            bottomColorRef:(CGColorRef)bottomColorRef 
                      rect:(CGRect)rect {
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGFloat locations[] = { 0.0, 1.0 };
  
  NSArray *colors = @[(id)topColorRef, (id)bottomColorRef];
  
  // draw gradient colors
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
  
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
  
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGContextSaveGState(context);
  
  CGColorSpaceRelease(colorSpace);
  CGGradientRelease(gradient);
}

- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(context);
  
  // define top and bottom color
  CGColorRef topColorRef;
  CGColorRef bottomColorRef;
  CGFloat actualBrightness = 1.0f;
  
  actualBrightness = 1.0f;
  if (self.state == UIControlStateHighlighted) {
    actualBrightness -= 0.20;
  } 
  
  switch (_colorType) {
    case LIGHT_GRAY_BTN_COLOR_TY:
      topColorRef = [UIColor colorWithHue:1 saturation:0 brightness:0.92*actualBrightness alpha:1.0].CGColor;
      bottomColorRef = [UIColor colorWithHue:0.667f saturation:0 brightness:0.731*actualBrightness alpha:1.0].CGColor;
      break;
      
    case RED_BTN_COLOR_TY:
      topColorRef = COLOR_HSB(360.0f, 100.0f, 78.0f, actualBrightness).CGColor;
      bottomColorRef = COLOR_HSB(359.0f, 77.0f, 47.0f, actualBrightness).CGColor;
      break;
      
    default:
      topColorRef = [UIColor whiteColor].CGColor;
      bottomColorRef = [UIColor whiteColor].CGColor;
      break;
  }
  
  // draw gradient colors
  [self drawGradientColors:context
               topColorRef:topColorRef 
            bottomColorRef:bottomColorRef
                      rect:rect];
}

#pragma mark - override touch methods to show highlight 

- (void)hesitateUpdate {
  [self setNeedsDisplay];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  [self setNeedsDisplay];
  [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.2];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];
  [self setNeedsDisplay];
  [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.2];
}

@end
