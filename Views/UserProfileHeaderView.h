//
//  UserProfileHeaderView.h
//  iAlumni
//
//  Created by Adam on 12-9-24.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWImageDisplayerDelegate.h"
#import "WXWImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;

@interface UserProfileHeaderView : UIView <WXWImageFetcherDelegate> {
  @private
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  id _target;
  SEL _action;
  
  UIButton *_avatarButton;
  
  WXWLabel *_nameLabel;
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
             target:(id)target
             action:(SEL)action;

#pragma mark - update avatar
- (void)updateAvatar:(UIImage *)avatar;

- (void)refreshModifyButtonTitle;
@end
