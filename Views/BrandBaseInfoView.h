//
//  BrandBaseInfoView.h
//  iAlumni
//
//  Created by Adam on 12-8-21.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWImageDisplayerDelegate.h"

@class Brand;

@interface BrandBaseInfoView : UIView <WXWImageFetcherDelegate> {
  @private
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  UIButton *_itemPicButton;
  
  NSString *_avatarUrl;
}

- (id)initWithFrame:(CGRect)frame
              brand:(Brand *)brand
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
WXWImageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)WXWImageDisplayerDelegate;

@end
