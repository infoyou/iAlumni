//
//  ECNodeFilter.m
//  ExpatNightlife
//
//  Created by Adam on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECNodeFilter.h"
#define LEFT_OFFSET 25
#define RIGHT_OFFSET 25
#define TITLE_SELECTED_DISTANCE 5
#define TITLE_FADE_ALPHA 0.7f
#define TITLE_FONT [UIFont fontWithName:@"Optima" size:8]
#define TITLE_SHADOW_COLOR [UIColor whiteColor]
#define TITLE_COLOR [UIColor blackColor]

#define KNOB_RADIUS   16.0f
#define AXIS_HEIGHT   5.0f//2.0f
#define NODE_RADIUS   8.0f//6.0f

#define UNSELECTED_FONT  HK_FONT(11)
#define SELECTED_FONT    BOLD_HK_FONT(12)

@interface ECNodeFilter() {
  ECNodeFilterKnob *handler;
  CGPoint diffPoint;
  NSArray *titlesArr;
  float oneSlotSize;
}

@end

@implementation ECNodeFilter
@synthesize SelectedIndex, progressColor;

- (CGPoint)getCenterPointForIndex:(int)i {
  return CGPointMake((i/(float)(titlesArr.count-1)) * (self.frame.size.width-RIGHT_OFFSET-LEFT_OFFSET) + LEFT_OFFSET,
                     i == 0 ?
                     self.frame.size.height - 55 - TITLE_SELECTED_DISTANCE :
                     self.frame.size.height-55);
}

- (CGPoint)fixFinalPoint:(CGPoint)pnt {

  if (pnt.x < LEFT_OFFSET - (handler.frame.size.width / 2.f)) {
    pnt.x = LEFT_OFFSET - (handler.frame.size.width / 2.f);
  } else if (pnt.x + (handler.frame.size.width / 2.f) > self.frame.size.width - RIGHT_OFFSET) {
    pnt.x = self.frame.size.width - RIGHT_OFFSET - (handler.frame.size.width / 2.f);
  }
  return pnt;
}

- (id)initWithFrame:(CGRect)frame
             Titles:(NSArray *)titles
         allowSwipe:(BOOL)allowSwipe
  initSelectedIndex:(NSInteger)initSelectedIndex
unselectedTitleColor:(UIColor *)unselectedTitleColor {

  if (self = [super initWithFrame:frame]) {
    
    [self setBackgroundColor:TRANSPARENT_COLOR];
    
    _initSelectedIndex = initSelectedIndex;
    
    _unselectedTitleColor = unselectedTitleColor;
    
    titlesArr = [[NSArray alloc] initWithArray:titles];
    
    [self setProgressColor:[UIColor colorWithRed:103/255.f green:173/255.f blue:202/255.f alpha:1]];
    
    UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                          action:@selector(ItemSelected:)];
    [self addGestureRecognizer:gest];
    [gest release];
    
    int i;
    NSString *title;
    UILabel *lbl;
    
    oneSlotSize = 1.f * (self.frame.size.width-LEFT_OFFSET-RIGHT_OFFSET-1) / (titlesArr.count-1);
    for (i = 0; i < titlesArr.count; i++) {
      title = titlesArr[i];
      lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, oneSlotSize, 25)];
      [lbl setText:title];
      [lbl setFont:HK_FONT(11)];
      [lbl setShadowColor:TITLE_SHADOW_COLOR];
      [lbl setTextColor:TITLE_COLOR];
      [lbl setLineBreakMode:UILineBreakModeMiddleTruncation];
      [lbl setAdjustsFontSizeToFitWidth:YES];
      [lbl setTextAlignment:UITextAlignmentCenter];
      [lbl setShadowOffset:CGSizeMake(0, 1)];
      [lbl setBackgroundColor:TRANSPARENT_COLOR];
      [lbl setTag:i+50];
      
      CGPoint center = [self getCenterPointForIndex:i];
      if (i == _initSelectedIndex) {
        [lbl setCenter:CGPointMake(center.x, self.frame.size.height - 40 - TITLE_SELECTED_DISTANCE)];
        lbl.textColor = NAVIGATION_BAR_COLOR;
        lbl.font = SELECTED_FONT;
      } else {
        [lbl setCenter:CGPointMake(center.x, self.frame.size.height - 40)];
        //[lbl setAlpha:TITLE_FADE_ALPHA];
        lbl.textColor = _unselectedTitleColor;
        lbl.font = UNSELECTED_FONT;
      }
      
      [self addSubview:lbl];
      [lbl release];
    }
    
    // init knob
    handler = [[ECNodeFilterKnob buttonWithType:UIButtonTypeCustom] retain];
    [handler setFrame:CGRectMake(LEFT_OFFSET + _initSelectedIndex * oneSlotSize, 10, KNOB_RADIUS * 2, KNOB_RADIUS * 2)];
    
    [handler setAdjustsImageWhenHighlighted:NO];
    [handler setCenter:CGPointMake(handler.center.x - (handler.frame.size.width/2.f), self.frame.size.height - 19.5f)];
    
    if (allowSwipe) {
      [handler addTarget:self
                  action:@selector(TouchDown:withEvent:)
        forControlEvents:UIControlEventTouchDown];
      
      [handler addTarget:self
                  action:@selector(TouchUp:)
        forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
      
      [handler addTarget:self
                  action:@selector(TouchMove:withEvent:)
        forControlEvents:(UIControlEventTouchDragInside | UIControlEventTouchDragOutside)];
    }
    
    [self addSubview:handler];

  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGColorRef shadowColor = [UIColor colorWithRed:0 green:0
                                            blue:0 alpha:.9f].CGColor;
    
  CGFloat axisTopY = (handler.frame.size.height - AXIS_HEIGHT)/2.0f + handler.frame.origin.y;
  CGFloat axisBottomY = axisTopY + AXIS_HEIGHT;
  
  //Fill Main Path
  CGContextSetFillColorWithColor(context, self.progressColor.CGColor);
  CGContextFillRect(context, CGRectMake(LEFT_OFFSET,
                                        axisTopY,
                                        rect.size.width-RIGHT_OFFSET-LEFT_OFFSET, AXIS_HEIGHT));
  CGContextSaveGState(context);
    
  //Draw Black Top Shadow
  CGContextSetShadowWithColor(context, CGSizeMake(0, 1.f), 2.f, shadowColor);
  
  CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:0
                                                             blue:0 alpha:.6f].CGColor);
  CGContextSetLineWidth(context, .5f);
  CGContextBeginPath(context);
  CGContextMoveToPoint(context, LEFT_OFFSET, axisTopY);
  CGContextAddLineToPoint(context, rect.size.width-RIGHT_OFFSET, axisTopY);
  CGContextStrokePath(context);
  
  CGContextRestoreGState(context);
  
  CGContextSaveGState(context);
  
  //Draw White Bottom Shadow
  CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1 green:1
                                                             blue:1 alpha:1.f].CGColor);
  CGContextSetLineWidth(context, .4f);
  CGContextBeginPath(context);
  CGContextMoveToPoint(context, LEFT_OFFSET, axisBottomY);
  CGContextAddLineToPoint(context, rect.size.width-RIGHT_OFFSET, axisBottomY);
  CGContextStrokePath(context);
  
  CGContextRestoreGState(context);
  
  CGPoint centerPoint;
  int i;
  CGFloat nodeY = axisBottomY - (AXIS_HEIGHT / 2.0f) - NODE_RADIUS;
  CGFloat nodeSideLength = NODE_RADIUS * 2;
  for (i = 0; i < titlesArr.count; i++) {
    centerPoint = [self getCenterPointForIndex:i];
    
    //Draw Selection Circles
    CGContextSetFillColorWithColor(context, self.progressColor.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(centerPoint.x - NODE_RADIUS, nodeY,
                                                   nodeSideLength,
                                                   nodeSideLength));        
    //Draw top Gradient
    CGFloat colors[12] = {0, 0, 0, 1,
                          0, 0, 0, 0,
                          0, 0, 0, 0};
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 3);
    
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, CGRectMake(centerPoint.x - NODE_RADIUS,
                                                  nodeY,
                                                  nodeSideLength, nodeSideLength));
    CGContextClip(context);
    CGContextDrawLinearGradient (context, gradient, CGPointMake(0, 0), CGPointMake(0,rect.size.height), 0);
    CGContextRestoreGState(context);
    
    //Draw White Bottom Shadow
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1
                                                              green:1
                                                               blue:1
                                                              alpha:.4f].CGColor);
    CGContextSetLineWidth(context, .8f);
    CGContextAddArc(context,
                    centerPoint.x,
                    nodeY + NODE_RADIUS,
                    NODE_RADIUS,
                    24*M_PI/180, 156*M_PI/180, 0);
    CGContextDrawPath(context,kCGPathStroke);
    
    //Draw Black Top Shadow
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:0
                                                               blue:0 alpha:.2f].CGColor);
    CGContextAddArc(context,
                    centerPoint.x,
                    nodeY + NODE_RADIUS,
                    NODE_RADIUS - 0.5f,
                    (i == titlesArr.count-1 ? 28 : -20) * M_PI/180,
                    (i == 0 ? -208 : -160) * M_PI / 180, 1);
    CGContextSetLineWidth(context, 1.f);
    CGContextDrawPath(context,kCGPathStroke);
    
    CFRelease(gradient);
    CFRelease(baseSpace);
  }
}

- (void)setHandlerColor:(UIColor *)color {
  [handler setHandlerColor:color];
}

- (void)TouchDown:(UIButton *)btn withEvent:(UIEvent *)ev {
  CGPoint currPoint = [[[ev allTouches] anyObject] locationInView:self];
  diffPoint = CGPointMake(currPoint.x - btn.frame.origin.x, currPoint.y - btn.frame.origin.y);
  
  [self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)setTitlesColor:(UIColor *)color {
  int i;
  UILabel *lbl;
  for (i = 0; i < titlesArr.count; i++) {
    lbl = (UILabel *)[self viewWithTag:i+50];
    [lbl setTextColor:color];
  }
}

- (void)setTitlesFont:(UIFont *)font {
  int i;
  UILabel *lbl;
  for (i = 0; i < titlesArr.count; i++) {
    lbl = (UILabel *)[self viewWithTag:i+50];
    [lbl setFont:font];
  }
}

- (void)animateTitlesToIndex:(int)index {
  int i;
  UILabel *lbl;
  for (i = 0; i < titlesArr.count; i++) {
    lbl = (UILabel *)[self viewWithTag:i+50];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (i == index) {
      [lbl setCenter:CGPointMake(lbl.center.x, self.frame.size.height - 40 -TITLE_SELECTED_DISTANCE)];
      //[lbl setAlpha:1];
      lbl.textColor = NAVIGATION_BAR_COLOR;
      lbl.font = SELECTED_FONT;
    } else {
      [lbl setCenter:CGPointMake(lbl.center.x, self.frame.size.height-40)];
      //[lbl setAlpha:TITLE_FADE_ALPHA];
      lbl.textColor = _unselectedTitleColor;
      lbl.font = UNSELECTED_FONT;
    }
    [UIView commitAnimations];
  }
}

- (void)animateHandlerToIndex:(int)index {
  CGPoint toPoint = [self getCenterPointForIndex:index];
  toPoint = CGPointMake(toPoint.x-(handler.frame.size.width/2.f), handler.frame.origin.y);
  toPoint = [self fixFinalPoint:toPoint];
  
  [UIView beginAnimations:nil context:nil];
  [handler setFrame:CGRectMake(toPoint.x, toPoint.y, handler.frame.size.width, handler.frame.size.height)];
  [UIView commitAnimations];
}

- (void)setSelectedIndex:(int)index {
  SelectedIndex = index;
  [self animateTitlesToIndex:index];
  [self animateHandlerToIndex:index];
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (int)getSelectedTitleInPoint:(CGPoint)pnt {
  return round((pnt.x-LEFT_OFFSET)/oneSlotSize);
}

- (void)ItemSelected:(UITapGestureRecognizer *)tap {
  SelectedIndex = [self getSelectedTitleInPoint:[tap locationInView:self]];
  [self setSelectedIndex:SelectedIndex];
  
  [self sendActionsForControlEvents:UIControlEventTouchUpInside];
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)TouchUp:(UIButton*)btn {
  
  SelectedIndex = [self getSelectedTitleInPoint:btn.center];
  [self animateHandlerToIndex:SelectedIndex];
  [self sendActionsForControlEvents:UIControlEventTouchUpInside];
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)TouchMove:(UIButton *)btn withEvent:(UIEvent *)ev {
  
  CGPoint currPoint = [[[ev allTouches] anyObject] locationInView:self];
  
  CGPoint toPoint = CGPointMake(currPoint.x-diffPoint.x, handler.frame.origin.y);
  
  toPoint = [self fixFinalPoint:toPoint];
  
  [handler setFrame:CGRectMake(toPoint.x, toPoint.y, handler.frame.size.width, handler.frame.size.height)];
  
  int selected = [self getSelectedTitleInPoint:btn.center];
  
  [self animateTitlesToIndex:selected];
  
  [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

- (void)dealloc {
  
  if (_allowSwipe) {
    [handler removeTarget:self
                   action:@selector(TouchDown:withEvent:)
         forControlEvents:UIControlEventTouchDown];
    
    [handler removeTarget:self
                   action:@selector(TouchUp:)
         forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    [handler removeTarget:self
                   action:@selector(TouchMove:withEvent:)
         forControlEvents:UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
  }
  
  RELEASE_OBJ(handler);
  RELEASE_OBJ(titlesArr);
  RELEASE_OBJ(progressColor);
  [super dealloc];
}

@end
