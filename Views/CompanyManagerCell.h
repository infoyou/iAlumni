//
//  CompanyManagerCell.h
//  iAlumni
//
//  Created by Adam on 13-9-8.
//
//

#import "FlatTableCell.h"

@class WXWLabel;
@class HintEnlargedButton;

@interface CompanyManagerCell : FlatTableCell {
  @private
  
  WXWLabel *_titleLabel;
  
  WXWLabel *_nameLabel;
  WXWLabel *_separatorLabel;
  WXWLabel *_classLabel;
  WXWLabel *_jobTitleLabel;
  HintEnlargedButton *_chatButton;
  UIImageView *_avatar;

  id _brandInfoVC;
  SEL _chatAction;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
        brandInfoVC:(UIViewController *)brandInfoVC
         chatAction:(SEL)chatAction;

- (void)drawCellWithAlumni:(Alumni *)alumni title:(NSString *)title;

@end
