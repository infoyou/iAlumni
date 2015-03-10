//
//  HotNewsCell.h
//  iAlumni
//
//  Created by Adam on 12-10-25.
//
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"

@class WXWLabel;
@class News;

@interface HotNewsCell : ECImageConsumerCell {
@private
  WXWLabel *_titleLabel;

  UIView *_imageBackgroundView;
  UIImageView *_newsImageView;
}

- (void)drawNews:(News *)news;

@end
