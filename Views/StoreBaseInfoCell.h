//
//  StoreBaseInfoCell.h
//  iAlumni
//
//  Created by Adam on 13-8-20.
//
//

#import "ECImageConsumerCell.h"

@class WelfareCellBoardView;
@class WXWLabel;
@class Store;

@interface StoreBaseInfoCell : ECImageConsumerCell {
  @private
  WelfareCellBoardView *_boardView;
  
  UIImageView *_storeImageView;
  WXWLabel *_nameLabel;
  UIButton *_telButton;
  WXWLabel *_addressLabel;
  
  
  id _detailVC;
  SEL _callSupportAction;

}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
  callSupportAction:(SEL)callSupportAction;


- (void)drawCellWithStore:(Store *)store height:(CGFloat)height;

@end
