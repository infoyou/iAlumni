//
//  WelfareBrandEntranceCell.h
//  iAlumni
//
//  Created by Adam on 13-8-18.
//
//

#import "WelfareInfoCell.h"

@class WXWLabel;

@interface WelfareBrandEntranceCell : WelfareInfoCell {
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
    openBrandAction:(SEL)openBrandAction;

- (void)drawCellWithWelfare:(Welfare *)welfare height:(CGFloat)height;

@end
