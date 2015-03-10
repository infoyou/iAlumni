//
//  AuthorCell.h
//  iAlumni
//
//  Created by Adam on 13-6-4.
//
//

#import "ECImageConsumerCell.h"

@class WXWLabel;

@interface AuthorCell : ECImageConsumerCell {
  @private
  UIImageView *_authorPhotoImageView;
  
  WXWLabel *_authorLabel;
}

- (void)drawCellWithImageUrl:(NSString *)imageUrl authorName:(NSString *)authorName;

@end
