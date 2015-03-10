//
//  WelfareCouponInfoCell.h
//  iAlumni
//
//  Created by Adam on 13-8-14.
//
//

#import "ECImageConsumerCell.h"
#import "WelfareInfoCell.h"

@class WelfareCellBoardView;
@class Welfare;
@class WXWLabel;

@interface WelfareCouponInfoCell : WelfareInfoCell {
  @private
  
  
  WXWLabel *_descLabel;
  WXWLabel *_downloadLabel;
  WXWLabel *_dateLabel;
  
  UIImageView *_flagIcon;
  UIImageView *_alumniIcon;
  UIImageView *_arrowIcon;
  UIImageView *_timeIcon;
  
  UIView *_userListView;
  UITapGestureRecognizer *_tapGesture;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
 openUserListAction:(SEL)openUserListAction;

- (void)drawCellWithWelfare:(Welfare *)welfare height:(CGFloat)height;

@end
