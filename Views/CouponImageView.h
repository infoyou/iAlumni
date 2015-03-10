//
//  CouponImageView.h
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

@interface CouponImageView : UIView <WXWImageFetcherDelegate> {
  @private
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  UIButton *_imageButton;
  UIImageView *_loadingImageView;
  
  NSString *_imageUrl;
}

- (id)initWithFrame:(CGRect)frame 
           imageUrl:(NSString *)imageUrl 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

@end
