//
//  AlumniCouponTitleCell.h
//  iAlumni
//
//  Created by Adam on 12-8-22.
//
//

#import "ECTextBoardCell.h"
#import "GlobalConstants.h"

@class WXWLabel;

@interface AlumniCouponTitleCell : ECTextBoardCell {
  @private
  
  WXWLabel *_title;
  
  WXWLabel *_subTitleLabel;
}

- (void)drawCell:(NSString *)text
        subTitle:(NSString *)subTitle
            font:(UIFont *)font
       textColor:(UIColor *)textColor
   textAlignment:(UITextAlignment)textAlignment
      cellHeight:(CGFloat)cellHeight
showBottomShadow:(BOOL)showBottomShadow;

@end
