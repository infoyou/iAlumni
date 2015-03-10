//
//  WelfareInfoCell.h
//  iAlumni
//
//  Created by Adam on 13-8-17.
//
//

#import "ECImageConsumerCell.h"

@class WelfareCellBoardView;
@class WXWLabel;
@class Welfare;

@interface WelfareInfoCell : ECImageConsumerCell {

  WelfareCellBoardView *_boardView;
  
  WXWLabel *_titleLabel;
  WXWLabel *_nameLabel;
  
  CGFloat _textLimitedWidth;
  
  Welfare *_welfare;
  
  @private
  id _detailVC;
  SEL _openAction;
  
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
         openAction:(SEL)openAction;

- (void)drawCellWithWelfare:(Welfare *)welfare
                      title:(NSString *)title
                     height:(CGFloat)height;

- (void)openUserList:(UITapGestureRecognizer *)gesture;

@end
