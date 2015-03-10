//
//  CouponItemCell.h
//  ExpatCircle
//
//  Created by Adam on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"


@class WXWLabel;
@class ServiceItem;

@interface CouponItemCell : ECImageConsumerCell {
@private
  
  UIImageView *_avatarView;
  
  WXWLabel *_nameLabel;
  WXWLabel *_couponTitleLabel;
  WXWLabel *_addressLabel;
  WXWLabel *_tagsLabel;
  WXWLabel *_distanceLabel;
}

- (void)drawItem:(ServiceItem *)item index:(NSInteger)index;

@end
