//
//  BrandCell.h
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"

@class WXWLabel;
@class Brand;

@interface BrandCell : ECImageConsumerCell {
  @private
  UIView *_avatarBackgroundView;
  UIImageView *_avatar;
  
  WXWLabel *_nameLabel;
  WXWLabel *_categoryLabel;
  WXWLabel *_companyType;
  WXWLabel *_couponInfoLabel;
  WXWLabel *_distanceLabel;
}

- (void)drawCell:(Brand *)brand;

@end
