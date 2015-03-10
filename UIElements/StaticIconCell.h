//
//  StaticIconCell.h
//  iAlumni
//
//  Created by Adam on 12-9-7.
//
//

#import "ECTextBoardCell.h"
#import "GlobalConstants.h"

@class WXWLabel;

@interface StaticIconCell : ECTextBoardCell {
  @private
  UIImageView *_icon;
  
  WXWLabel *_title;
  
  CGFloat _cellHeight;
  
  SeparatorType _separatorType;
}

- (void)drawCell:(NSString *)iconName
           title:(NSString *)title
   separatorType:(SeparatorType)separatorType
      cellHeight:(CGFloat)cellHeight;

@end
