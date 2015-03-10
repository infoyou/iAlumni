//
//  HandyUserAvatarBrowser.h
//  CEIBS
//
//  Created by Adam on 11-6-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWImageCacheReceiver.h"

@class PhotoBrowser;

@interface HandyUserAvatarBrowser : UIView {
  @private
  UIImageView *_imageView;
  UIView *_canvasView;
  WXWImageCacheReceiver *_receiver;
  NSString *_imgUrl;
  
  CGRect _imageStartFrame;
  //BOOL _toBeRemoved;
  
  UILabel *_authorInfoLabel;
  UILabel *_commentLabel;
  BOOL _forAblum;
}

- (id)initWithFrame:(CGRect)frame imgUrl:(NSString *)imgUrl imageStartFrame:(CGRect)imageStartFrame;

@end
