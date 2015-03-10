//
//  ECNodeFilterKnob.m
//  ExpatNightlife
//
//  Created by Adam on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECNodeFilterKnob.h"

@implementation ECNodeFilterKnob
@synthesize handlerColor;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    // Initialization code
    [self setHandlerColor:COLOR(230, 230, 230)];
    
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  _radius = frame.size.height / 2.0f - 7.0f;
}

- (void)setHandlerColor:(UIColor *)hc {
  [handlerColor release];
  handlerColor = nil;
  
  handlerColor = [hc retain];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  CGColorRef shadowColor = [UIColor colorWithRed:0 green:0
                                            blue:0 alpha:.4f].CGColor;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  //Draw Main Cirlce
  CGContextSaveGState(context);
  CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 2.f, shadowColor);
  
  CGContextSetStrokeColorWithColor(context, handlerColor.CGColor);
  CGContextSetLineWidth(context, _radius);
  CGContextStrokeEllipseInRect(context, CGRectMake(CGRectGetMidX(self.bounds) - _radius,
                                                   CGRectGetMidY(self.bounds) - _radius,
                                                   _radius * 2, _radius * 2));
  
  CGContextRestoreGState(context);
  
  //Draw Outer Outline
  CGContextSaveGState(context);
  
  CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:.5 alpha:.6f].CGColor);
  CGContextSetLineWidth(context, 0.5);
  CGContextStrokeEllipseInRect(context, CGRectMake(1,
                                                   1,
                                                   self.bounds.size.width - 2,
                                                   self.bounds.size.height - 2));
  
  CGContextRestoreGState(context);
  
  //Draw Inner Outline
  CGContextSaveGState(context);
  
  CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:.5 alpha:.6f].CGColor);
  CGContextSetLineWidth(context, 1);
  CGContextStrokeEllipseInRect(context, CGRectMake(CGRectGetMidX(self.bounds) - 4,
                                                   CGRectGetMidY(self.bounds) - 4, 8, 8));
  CGContextRestoreGState(context);
  
  
  CGFloat colors[8] = { 0,0, 0, 0,
    0, 0, 0, .6};
  CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
  
  CGContextSaveGState(context);
  CGContextAddEllipseInRect(context, CGRectMake(1, 1,
                                                self.bounds.size.width - 2,
                                                self.bounds.size.height - 2));
  CGContextClip(context);
  CGContextDrawLinearGradient (context, gradient, CGPointMake(0, 0), CGPointMake(0,rect.size.height), 0);
  CGContextRestoreGState(context);
  
  CFRelease(gradient);
  CFRelease(baseSpace);
}

-(void) dealloc{
  RELEASE_OBJ(handlerColor);
  
  [super dealloc];
}

@end
