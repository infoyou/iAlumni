//
//  ItemTitleAvatarView.h
//  iAlumni
//
//  Created by Adam on 12-8-6.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWImageDisplayerDelegate.h"

@class WXWLabel;
@class ServiceItem;

@interface ItemTitleAvatarView : UIView <WXWImageFetcherDelegate> {
  @private
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  
  ServiceItem *_item;
  
  UIImageView *_avatar;
  UIView *_avatarBackgroundView;
  
  UIImage *_image;
  
  UIView *_priceBackgroundView;
  WXWLabel *_priceLabel;
  
  WXWLabel *_nameLabel;
  UIImageView *_tagIcon;
  WXWLabel *_tagsLabel;  
}

- (id)initWithFrame:(CGRect)frame
               item:(ServiceItem *)item
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate;

#pragma mark - adjust scroll speed
- (void)adjustScrollSpeedWithOffset:(CGPoint)offset;


@end
