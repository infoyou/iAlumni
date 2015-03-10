//
//  PostToolView.m
//  iAlumni
//
//  Created by Adam on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PostToolView.h"
#import "ECGradientButton.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "WinnerHeaderView.h"


#define ITEM_HEIGHT     30.0f
#define LABEL_HEIGHT    20.0f

#define IMG_EDGE        UIEdgeInsetsMake(-29, 100, -27.0, 0.0)
#define TITLE_EDGE      UIEdgeInsetsMake(-29, -60, -27.0, 0.0)

#define LABEL_X         MARGIN + 3

@implementation PostToolView

- (void)showFilters:(id)sender {
  [_delegate showFilterList];
}

- (void)showSorts:(id)sender {
  [_delegate showSortOptionList];
}

- (void)setWinnerInfo:(NSString *)info winnerType:(WinnerType)winnerType {
  
  [_winnerHeaderView setWinnerInfo:info
                        winnerType:winnerType];
  
}

- (void)animationGift {
  if (_winnerHeaderView) {
    [_winnerHeaderView animationGift];
  }
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
           delegate:(id<ECFilterListDelegate>)delegate {
  
  self = [super initWithFrame:frame topColor:topColor bottomColor:bottomColor];
  if (self) {
    
    _delegate = delegate;
    
    _filterButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, 170, ITEM_HEIGHT)
                                                     target:self
                                                     action:@selector(showFilters:)
                                                  colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                      title:LocaleStringForKey(NSFilterHeaderTitle, nil)
                                                      image:[UIImage imageNamed:@"filter.png"]
                                                 titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                           titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                  titleFont:FONT(13)
                                                roundedType:HAS_ROUNDED
                                            imageEdgeInsert:UIEdgeInsetsMake(-29, 145, -27.0, 0.0)
                                            titleEdgeInsert:UIEdgeInsetsMake(MARGIN, -20, 0.0, 0.0)];
    
    [self addSubview:_filterButton];
    
    _filterLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 9 + 3, MARGIN + 2, 100, LABEL_HEIGHT)
                                        textColor:COLOR(71, 71, 72)
                                      shadowColor:[UIColor whiteColor]];
    _filterLabel.font = FONT(13);
    _filterLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _filterLabel.backgroundColor = TRANSPARENT_COLOR;
    _filterLabel.text = LocaleStringForKey(NSAllTitle, nil);
    [_filterButton addSubview:_filterLabel];
    
    
    _sortButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(_filterButton.frame.origin.x + _filterButton.frame.size.width + MARGIN, MARGIN, 135, ITEM_HEIGHT)
                                                   target:self
                                                   action:@selector(showSorts:)
                                                colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                    title:LocaleStringForKey(NSSortHeaderTitle, nil)
                                                    image:[UIImage imageNamed:@"sort.png"]
                                               titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                         titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                titleFont:FONT(13)
                                              roundedType:HAS_ROUNDED
                                          imageEdgeInsert:UIEdgeInsetsMake(-29, 112, -27.0, 0.0)
                                          titleEdgeInsert:UIEdgeInsetsMake(MARGIN, -20, 0.0, 0.0)];
    [self addSubview:_sortButton];
    
    _sortLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 7, MARGIN + 2, 80, LABEL_HEIGHT) textColor:COLOR(71, 71, 72) shadowColor:[UIColor whiteColor]];
    _sortLabel.font = FONT(13);
    _sortLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _sortLabel.backgroundColor = TRANSPARENT_COLOR;
    _sortLabel.text = LocaleStringForKey(NSSortByCreateTimeTitle, nil);
    [_sortButton addSubview:_sortLabel];
    
    
    _filterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _sortButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [self addShadowEffect];
  }
  return self;
}

- (void)initWinnerHeaderView:(id<ECClickableElementDelegate>)userListDelegate {
  _winnerHeaderView = [[[WinnerHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          self.frame.size.width,
                                                                          WINNER_HEADER_HEIGHT)
                                              userListDelegate:userListDelegate] autorelease];
  [self addSubview:_winnerHeaderView];
}

- (id)initForShake:(CGRect)frame
          topColor:(UIColor *)topColor
       bottomColor:(UIColor *)bottomColor
          delegate:(id<ECFilterListDelegate>)delegate
  userListDelegate:(id<ECClickableElementDelegate>)userListDelegate {
  
  self = [super initWithFrame:frame topColor:topColor bottomColor:bottomColor];
  if (self) {
    self.backgroundColor = COLOR(194, 194, 194);
    _delegate = delegate;
    
      CGFloat y = 0;
    /*
      if (frame.size.height > WINNER_HEADER_HEIGHT) {
          
          [self initWinnerHeaderView:userListDelegate];
          y = WINNER_HEADER_HEIGHT - 1.0f;
      }
     */
    
    // distance
    _distanceButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(0, y, 106, TOOL_TITLE_HEIGHT)
                                                       target:self
                                                       action:@selector(showDistanceFilters:)
                                                    colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                        title:NULL_PARAM_VALUE
                                                        image:[UIImage imageNamed:@"drop.png"]
                                                   titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                             titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                    titleFont:FONT(13)
                                                  roundedType:NO_ROUNDED
                                              imageEdgeInsert:UIEdgeInsetsMake(MARGIN, 0.0, 0.0, -80)
                                              titleEdgeInsert:UIEdgeInsetsMake(MARGIN, -75, 0.0, 0.0)];
    
    [self addSubview:_distanceButton];
    
    _distanceLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(LABEL_X, 12, 100, LABEL_HEIGHT)
                                          textColor:COLOR(71, 71, 72)
                                        shadowColor:[UIColor whiteColor]];
    _distanceLabel.font = FONT(13);
    _distanceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _distanceLabel.backgroundColor = TRANSPARENT_COLOR;
    _distanceLabel.text = LocaleStringForKey(NSAllTitle, nil);
    [_distanceButton addSubview:_distanceLabel];
    
    // Time
    _timeButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(107, y, 106, TOOL_TITLE_HEIGHT)
                                                   target:self
                                                   action:@selector(showTimeFilters:)
                                                colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                    title:NULL_PARAM_VALUE
                                                    image:[UIImage imageNamed:@"drop.png"]
                                               titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                         titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                titleFont:FONT(13)
                                              roundedType:NO_ROUNDED
                                          imageEdgeInsert:UIEdgeInsetsMake(MARGIN, -0.0, 0.0, -80)
                                          titleEdgeInsert:UIEdgeInsetsMake(MARGIN, -75, 0.0, 0.0)];
    [self addSubview:_timeButton];
    
    _timeLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(LABEL_X, 12, 80, LABEL_HEIGHT) textColor:COLOR(71, 71, 72) shadowColor:[UIColor whiteColor]];
    _timeLabel.font = FONT(13);
    _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _timeLabel.backgroundColor = TRANSPARENT_COLOR;
    _timeLabel.text = @"所有";
    [_timeButton addSubview:_timeLabel];
    
    // sort button
    _sortButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(214, y, 106, TOOL_TITLE_HEIGHT)
                                                   target:self
                                                   action:@selector(showSortFilters:)
                                                colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                    title:NULL_PARAM_VALUE
                                                    image:[UIImage imageNamed:@"drop.png"]
                                               titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                         titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                titleFont:FONT(13)
                                              roundedType:NO_ROUNDED
                                          imageEdgeInsert:UIEdgeInsetsMake(MARGIN, -0.0, 0.0, -80)
                                          titleEdgeInsert:UIEdgeInsetsMake(MARGIN, -75, 0.0, 0.0)];
    [self addSubview:_sortButton];
    
    _sortLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(LABEL_X, 12, 80, LABEL_HEIGHT) textColor:COLOR(71, 71, 72) shadowColor:[UIColor whiteColor]];
    _sortLabel.font = FONT(13);
    _sortLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _sortLabel.backgroundColor = TRANSPARENT_COLOR;
    _sortLabel.text = @"默认";
    [_sortButton addSubview:_sortLabel];
    
    _distanceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _timeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _sortButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    //[self addShadowEffect];
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
  
  RELEASE_OBJ(_filterLabel);
  RELEASE_OBJ(_sortLabel);
  RELEASE_OBJ(_filterButton);
  RELEASE_OBJ(_sortButton);
  
  [super dealloc];
}

#pragma mark - biz methods
- (void)setFiltersText:(NSString *)text {
  _filterLabel.text = text;
}

- (void)setSortText:(NSString *)text {
  _sortLabel.text = text;
}

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
