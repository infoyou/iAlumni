//
//  CouponInfoCell.h
//  ExpatCircle
//
//  Created by Adam on 12-1-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECTextBoardCell.h"

@class WXWLabel;

@interface CouponInfoCell : ECTextBoardCell {
  @private
  WXWLabel *_couponInfoLabel;
  
  UIView *_iconBackgroundView;
}

- (void)drawNoShadowCell:(NSString *)content needCornerRadius:(BOOL)needCornerRadius;

- (void)drawShadowCell:(NSString *)content 
                height:(CGFloat)height 
      needCornerRadius:(BOOL)needCornerRadius;

@end
