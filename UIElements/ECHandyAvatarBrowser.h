//
//  ECHandyAvatarBrowser.h
//  ExpatCircle
//
//  Created by Adam on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWImageDisplayerDelegate.h"


@interface ECHandyAvatarBrowser : UIView <WXWImageFetcherDelegate> {
  @private
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  
  UIImageView *_imageView;
  UIView *_canvasView;

  CGRect _imageStartFrame;

  BOOL _toBeRemoved;

}

- (id)initWithFrame:(CGRect)frame 
             imgUrl:(NSString *)imgUrl
    imageStartFrame:(CGRect)imageStartFrame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate;

@end
