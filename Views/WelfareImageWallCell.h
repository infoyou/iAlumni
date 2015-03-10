//
//  WelfareImageWallCell.h
//  iAlumni
//
//  Created by Adam on 13-8-18.
//
//

#import <UIKit/UIKit.h>
#import "WXWImageDisplayerDelegate.h"

@class WelfareItemWallView;
@class Welfare;
@class WXWLabel;

@interface WelfareImageWallCell : UITableViewCell {
  
  @private
  
  WelfareItemWallView *_itemWallView;
  
  UIView *_priceInfoView;
  
  UIButton *_actionButton;
  WXWLabel *_moneyFlagLabel;
  WXWLabel *_numberLabel;
  WXWLabel *_unitLabel;
  WXWLabel *_originalPriceLabel;
  UIImageView *_dashIcon;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
    welfareDetailVC:(id)welfareDetailVC
     favoriteAction:(SEL)favoriteAction
        shareAction:(SEL)shareAction
          buyAction:(SEL)buyAction
    saveImageAction:(SEL)saveImageAction;

- (void)drawCellWithWelfare:(Welfare *)welfare;

- (void)updateFavoritedStatus:(BOOL)status;

- (void)startPlay;

- (void)stopPlay;
@end
