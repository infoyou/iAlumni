//
//  ECSingleOvalSideButton.m
//  iAlumni
//
//  Created by Adam on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECSingleOvalSideButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation ECSingleOvalSideButton

- (id)initWithFrame:(CGRect)frame 
      directionType:(OvalSideDirectionType)directionType
          colorType:(ButtonColorType)colorType 
              image:(UIImage *)image {
  self = [super initWithFrame:frame];
  
  if (self) {
    _directionType = directionType;
    
    _colorType = colorType;
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    if (image) {
      [self setImage:image forState:UIControlStateNormal];
      
    }
    
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

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
  
  // draw arc and sideline
  [self drawOutline:context];
  
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

- (void)hesitateUpdate
{
  [self setNeedsDisplay];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
  [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  [self setNeedsDisplay];
  [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.2];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  [self setNeedsDisplay];
  [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.2];
}


@end
