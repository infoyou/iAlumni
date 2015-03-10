//
//  EventIntroCell.h
//  iAlumni
//
//  Created by Adam on 12-9-7.
//
//

#import "ECTextBoardCell.h"
#import "GlobalConstants.h"

@class WXWLabel;

@interface EventIntroCell : ECTextBoardCell {
  @private
  WXWLabel *_titleLabel;
  
  WXWLabel *_contentLabel;
  
  SeparatorType _separatorType;
  
  CGFloat _cellHeight;
}

- (void)drawCell:(NSString *)title
         content:(NSString *)content
       maxHeight:(CGFloat)maxHeight
   separatorType:(SeparatorType)separatorType;

@end
