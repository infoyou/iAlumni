//
//  PostToolView.h
//  iAlumni
//
//  Created by Adam on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"
#import "ECClickableElementDelegate.h"

@class ECGradientButton;
@class WXWLabel;
@class WinnerHeaderView;

@interface PostToolView : WXWGradientView {
  
@private
  ECGradientButton *_distanceButton;
  ECGradientButton *_timeButton;
  WXWLabel *_distanceLabel;
  WXWLabel *_timeLabel;
  
  ECGradientButton *_filterButton;
  WXWLabel *_filterLabel;
  ECGradientButton *_sortButton;
  WXWLabel *_sortLabel;
  
  WinnerHeaderView *_winnerHeaderView;
  
  id<ECFilterListDelegate> _delegate;
}

- (id)initWithFrame:(CGRect)frame
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
           delegate:(id<ECFilterListDelegate>)delegate;

- (id)initForShake:(CGRect)frame
          topColor:(UIColor *)topColor
       bottomColor:(UIColor *)bottomColor
          delegate:(id<ECFilterListDelegate>)delegate
  userListDelegate:(id<ECClickableElementDelegate>)userListDelegate;

#pragma mark - biz methods
- (void)setWinnerInfo:(NSString *)info winnerType:(WinnerType)winnerType;

- (void)animationGift;

- (void)setFiltersText:(NSString *)text;

- (void)setSortText:(NSString *)text;

- (void)setBackValue:(NSString *)distance time:(NSString *)time sort:(NSString *)sort;

@end
