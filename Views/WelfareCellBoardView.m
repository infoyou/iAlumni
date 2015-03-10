//
//  WelfareCellBoardView.m
//  iAlumni
//
//  Created by Adam on 13-8-14.
//
//

#import "WelfareCellBoardView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWUIUtils.h"
#import "CommonUtils.h"

#define LINE_MARGIN   8.0f

#define LINE_WIDTH    MARGIN

@implementation WelfareCellBoardView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor whiteColor];
  }
  return self;
}

- (void)adjustShadow {
  self.layer.shadowColor = [UIColor grayColor].CGColor;
  self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(2, 10, self.bounds.size.width - 4, self.bounds.size.height - 10)].CGPath;
  self.layer.shadowOffset = CGSizeZero;
  self.layer.shadowOpacity = 1.0f;
  self.layer.shadowRadius = 2.0f;
}

- (void)arrangeHeight:(CGFloat)height {

  [self arrangeHeight:height lineOrdinate:-5];
}

- (void)arrangeHeight:(CGFloat)height lineOrdinate:(CGFloat)lineOrdinate {
  
  _needLeftRedPad = YES;
  
  self.frame = CGRectMake(self.frame.origin.x,
                          self.frame.origin.y,
                          self.frame.size.width,
                          height);
  
  _separatorOrdinate = lineOrdinate;
  [self setNeedsDisplay];
  
  //[self adjustShadow];
}

- (void)arrangeWithoutLeftRedPadHeight:(CGFloat)height lineOrdinate:(CGFloat)lineOrdinate {
  
  _needLeftRedPad = NO;
  
  self.frame = CGRectMake(self.frame.origin.x,
                          self.frame.origin.y,
                          self.frame.size.width,
                          height);
  
  _separatorOrdinate = lineOrdinate;
  [self setNeedsDisplay];
  
  //[self adjustShadow];
  
}


- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  if (CURRENT_OS_VERSION >= IOS7) {
    // avoid top line
    CGContextSaveGState(ctx);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
  }
  
  [WXWUIUtils draw1PxStroke:ctx
                 startPoint:CGPointMake(LINE_MARGIN, _separatorOrdinate)
                   endPoint:CGPointMake(self.frame.size.width - LINE_MARGIN, _separatorOrdinate)
                      color:SEPARATOR_LINE_COLOR.CGColor
               shadowOffset:CGSizeZero
                shadowColor:TRANSPARENT_COLOR];
  
  if (_needLeftRedPad) {
    CGContextSaveGState(ctx);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, 0, self.frame.size.height);
    CGContextSetStrokeColorWithColor(ctx, ORANGE_COLOR.CGColor);
    CGContextSetLineWidth(ctx, LINE_WIDTH);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
  }
}

@end
