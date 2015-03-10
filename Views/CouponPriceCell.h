//
//  CouponPriceCell.h
//  ExpatCircle
//
//  Created by Adam on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECTextBoardCell.h"
#import "GlobalConstants.h"

@class CouponItem;
@class WXWLabel;

@interface CouponPriceCell : ECTextBoardCell {
  @private
  
  WXWLabel *_priceInfoTitleLabel;
  WXWLabel *_priceInfoValueLabe;
  WXWLabel *_prpTitleLabel;
  WXWLabel *_prpValueLabel;
}

- (void)drawCell:(CouponItem *)couponItem;

@end
