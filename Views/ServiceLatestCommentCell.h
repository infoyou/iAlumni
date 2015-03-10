//
//  ServiceLatestCommentCell.h
//  ExpatCircle
//
//  Created by Adam on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECTextBoardCell.h"

@class WXWLabel;

@interface ServiceLatestCommentCell : ECTextBoardCell {
  @private
  WXWLabel *_titleLabel;
  WXWLabel *_subTitleLabel;
  WXWLabel *_contentLabel;
  
  WXWLabel *_commenterNameLabel;
  WXWLabel *_locatoinLabel;
  WXWLabel *_dateLabel;
  
  SeparatorType _separatorType;
  
  CGFloat _cellHeight;
}

- (void)drawCell:(NSString *)title 
        subTitle:(NSString *)subTitle
        location:(NSString *)location
         comment:(NSString *)comment
   commenterName:(NSString *)commenterName
            date:(NSString *)date
      cellHeight:(CGFloat)cellHeight;

- (void)drawNOShadowCell:(NSString *)title
                subTitle:(NSString *)subTitle
                location:(NSString *)location
                 comment:(NSString *)comment
           commenterName:(NSString *)commenterName
                    date:(NSString *)date
              cellHeight:(CGFloat)cellHeight
           separatorType:(SeparatorType)separatorType;

@end
