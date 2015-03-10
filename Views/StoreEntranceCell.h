//
//  StoreEntranceCell.h
//  iAlumni
//
//  Created by Adam on 13-8-17.
//
//

#import "ECImageConsumerCell.h"
#import "WelfareInfoCell.h"

@class WXWLabel;


@interface StoreEntranceCell : WelfareInfoCell {
  @private

  WXWLabel *_addressLabel;
  WXWLabel *_branchLabel;
  
  UIImageView *_storeImageView;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
openStoreListAction:(SEL)openStoreListAction;

- (void)drawCellWithWelfare:(Welfare *)welfare height:(CGFloat)height;

@end
