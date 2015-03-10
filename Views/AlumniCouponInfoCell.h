//
//  AlumniCouponInfoCell.h
//  iAlumni
//
//  Created by Adam on 12-8-22.
//
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"

@class WXWLabel;


@interface AlumniCouponInfoCell : ECImageConsumerCell {
  @private
  
  WXWLabel *_title;
}

- (void)drawCell:(NSString *)couponInfo;

@end
