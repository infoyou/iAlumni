//
//  EventToolView.m
//  iAlumni
//
//  Created by Adam on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "EventToolView.h"
#import "ECGradientButton.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"

#define ITEM_HEIGHT     30.0f
#define LABEL_HEIGHT    20.0f

#define IMG_EDGE        UIEdgeInsetsMake(-29, 100, -27.0, 0.0)
#define TITLE_EDGE      UIEdgeInsetsMake(-29, -60, -27.0, 0.0)

#define LABEL_X         MARGIN + 3

@implementation EventToolView

- (void)showSorts:(id)sender {
  [_delegate showSortOptionList];
}

#pragma mark - shake user list
- (void)showDistanceFilters:(id)sender {
  [_delegate showDistanceList];
}

- (void)showTimeFilters:(id)sender {
  [_delegate showTimeList];
}

- (void)showSortFilters:(id)sender {
  [_delegate showSortList];
}

- (void)addShadowEffect {
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  [shadowPath moveToPoint:CGPointMake(0, self.frame.size.height)];
  [shadowPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
  [shadowPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height + 2)];
  [shadowPath addLineToPoint:CGPointMake(0, self.frame.size.height + 2)];
  [shadowPath addLineToPoint:CGPointMake(0, self.frame.size.height)];
  
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  self.layer.shadowOpacity = 0.7f;
  self.layer.masksToBounds = NO;
  self.layer.shadowPath = shadowPath.CGPath;
}

- (id)initWithFrame:(CGRect)frame
          topColor:(UIColor *)topColor
       bottomColor:(UIColor *)bottomColor
          delegate:(id<ECFilterListDelegate>)delegate
            tabSize:(int)tabSize
 {
  
  self = [super initWithFrame:frame topColor:topColor bottomColor:bottomColor];
  if (self) {
    self.backgroundColor = COLOR(194, 194, 194);
    _delegate = delegate;
    
      int tab1W = 0;
      int tab2W = 0;
      int tab3W = 0;
      
      switch (tabSize) {
          case 2:
          {
              tab1W = 160.f;
              tab2W = SCREEN_WIDTH - tab1W;
              tab3W = 0;
          }
              break;
              
          case 3:
          {
              tab1W = 106.f;
              tab2W = 106.f;
              tab3W = 106.f;
          }
              break;
      }
      
      CGFloat y = 0;    
    // distance
    _distanceButton = [[[ECGradientButton alloc] initWithFrame:CGRectMake(0, y, tab1W, TOOL_TITLE_HEIGHT)
                                                       target:self
                                                       action:@selector(showDistanceFilters:)
                                                    colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                        title:NULL_PARAM_VALUE
                                                        image:[UIImage imageNamed:@"dropDown.png"]
                                                   titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                             titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                    titleFont:FONT(13)
                                                  roundedType:NO_ROUNDED
                                              imageEdgeInsert:UIEdgeInsetsMake(MARGIN, 0.0, 0.0, -80)
                                              titleEdgeInsert:UIEdgeInsetsMake(MARGIN, -75, 0.0, 0.0)] autorelease];
      
      [_distanceButton setImage:[UIImage imageNamed:@"dropUp.png"] forState:UIControlStateSelected];
//      [_distanceButton setImage:[UIImage imageNamed:@"dropUp.png"] forState:UIControlStateHighlighted];
    [self addSubview:_distanceButton];
    
    _distanceLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(LABEL_X, 12, tab1W - MARGIN, LABEL_HEIGHT)
                                          textColor:COLOR(71, 71, 72)
                                        shadowColor:[UIColor whiteColor]] autorelease];
    _distanceLabel.font = FONT(13);
    _distanceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _distanceLabel.backgroundColor = TRANSPARENT_COLOR;
    _distanceLabel.text = LocaleStringForKey(NSAllTitle, nil);
    [_distanceButton addSubview:_distanceLabel];
    
    // Time
    _timeButton = [[[ECGradientButton alloc] initWithFrame:CGRectMake(tab1W+1, y, tab2W, TOOL_TITLE_HEIGHT)
                                                   target:self
                                                   action:@selector(showTimeFilters:)
                                                colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                    title:NULL_PARAM_VALUE
                                                    image:[UIImage imageNamed:@"dropDown.png"]
                                               titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                         titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                titleFont:FONT(13)
                                              roundedType:NO_ROUNDED
                                          imageEdgeInsert:UIEdgeInsetsMake(MARGIN, -0.0, 0.0, -80)
                                          titleEdgeInsert:UIEdgeInsetsMake(MARGIN, -75, 0.0, 0.0)] autorelease];
    [_timeButton setImage:[UIImage imageNamed:@"dropUp.png"] forState:UIControlStateSelected];
    [self addSubview:_timeButton];
      
    _timeLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(LABEL_X, 12, tab2W - MARGIN, LABEL_HEIGHT) textColor:COLOR(71, 71, 72) shadowColor:[UIColor whiteColor]] autorelease];
    _timeLabel.font = FONT(13);
    _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _timeLabel.backgroundColor = TRANSPARENT_COLOR;
    _timeLabel.text = @"所有";
    [_timeButton addSubview:_timeLabel];
    
      if (tab3W > 0) {
          
          // sort button
          _sortButton = [[[ECGradientButton alloc] initWithFrame:CGRectMake(214, y, tab3W, TOOL_TITLE_HEIGHT)
                                                          target:self
                                                          action:@selector(showSortFilters:)
                                                       colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                           title:NULL_PARAM_VALUE
                                                           image:[UIImage imageNamed:@"dropDown.png"]
                                                      titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                                titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                       titleFont:FONT(13)
                                                     roundedType:NO_ROUNDED
                                                 imageEdgeInsert:UIEdgeInsetsMake(MARGIN, -0.0, 0.0, -80)
                                                 titleEdgeInsert:UIEdgeInsetsMake(MARGIN, -75, 0.0, 0.0)] autorelease];
          [_sortButton setImage:[UIImage imageNamed:@"dropUp.png"] forState:UIControlStateSelected];
          [self addSubview:_sortButton];
          
          _sortLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(LABEL_X, 12, 80.f, LABEL_HEIGHT) textColor:COLOR(71, 71, 72) shadowColor:[UIColor whiteColor]] autorelease];
          _sortLabel.font = FONT(13);
          _sortLabel.lineBreakMode = NSLineBreakByTruncatingTail;
          _sortLabel.backgroundColor = TRANSPARENT_COLOR;
          _sortLabel.text = @"默认";
          [_sortButton addSubview:_sortLabel];
          _sortButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

      }
      
    _distanceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _timeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [self addShadowEffect];
  }
     
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGPoint startPoint = CGPointMake(0, rect.size.height - 1);
  CGPoint endPoint = CGPointMake(rect.size.width, rect.size.height - 1);
  
  CGColorRef borderColorRef = COLOR(225, 225, 226).CGColor;
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:startPoint
                endPoint:endPoint
                   color:borderColorRef
            shadowOffset:CGSizeZero
             shadowColor:TRANSPARENT_COLOR];
  
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - biz methods
- (void)setBackValue:(NSString *)distance time:(NSString *)time sort:(NSString *)sort
{
  if (![@"-1" isEqualToString:distance])
    _distanceLabel.text = distance;
  
  if (![@"-1" isEqualToString:time])
    _timeLabel.text = time;
  
  if (![@"-1" isEqualToString:sort])
    _sortLabel.text = sort;
}

@end
