//
//  CouponInfoHeaderView.h
//  ExpatCircle
//
//  Created by Adam on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"


@class CouponItem;
@class WXWLabel;
@class CouponImageView;

@interface CouponInfoHeaderView : UIView {
  @private
  CouponItem *_item;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  CouponImageView *_imageView;
  WXWLabel *_nameLabel;
  WXWLabel *_validityTitleLabel;
  WXWLabel *_validityValueLabel;
}

- (id)initWithFrame:(CGRect)frame 
               item:(CouponItem *)item
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

@end
