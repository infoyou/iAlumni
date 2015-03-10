//
//  WelfareUseNoticeCell.h
//  iAlumni
//
//  Created by Adam on 13-8-18.
//
//

#import "WelfareInfoCell.h"

@class WXWLabel;
@class Welfare;

@interface WelfareUseNoticeCell : WelfareInfoCell {
  @private
  WXWLabel *_noticeTextLabel;
  WXWLabel *_telLabel;
  
  UIButton *_telButton;
  UIImageView *_useTextDotView;
  UIImageView *_telDotView;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
         callAction:(SEL)callAction;

- (void)drawCellWithWelfare:(Welfare *)welfare height:(CGFloat)height;
@end
