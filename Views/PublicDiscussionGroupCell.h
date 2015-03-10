//
//  PublicDiscussionGroupCell.h
//  iAlumni
//
//  Created by Adam on 13-1-28.
//
//

#import "ECImageConsumerCell.h"

@class WXWLabel;
@class Club;

@interface PublicDiscussionGroupCell : ECImageConsumerCell {
  @private
  UIView *_thumbnailBackgroundView;
  
  UIView *_contentBackgroundView;
  
  UIImageView *_thumbnial;
  
  WXWLabel *_groupNameLabel;
  WXWLabel *_authorLabel;
  WXWLabel *_contentLabel;
  WXWLabel *_dateTimeLabel;
}

#pragma mark - draw cell
- (void)drawCellWithGroup:(Club *)group index:(NSInteger)index;

@end
