//
//  BranchCell.h
//  iAlumni
//
//  Created by Adam on 12-8-24.
//
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"


@class WXWLabel;
@class ServiceItem;

@interface BranchCell : ECImageConsumerCell {
  
  @private
  
  UIImageView *_avatarView;
  
  WXWLabel *_nameLabel;
  WXWLabel *_addressLabel;
  
  UIImageView *_likeIndicator;
  WXWLabel *_likeCountLabel;
  UIImageView *_commentIndicator;
  WXWLabel *_commentCountLabel;
  
  WXWLabel *_distanceLabel;
}

- (void)drawItem:(ServiceItem *)item index:(NSInteger)index;

@end
