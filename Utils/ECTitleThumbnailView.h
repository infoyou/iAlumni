//
//  ECTitleThumbnailView.h
//  ExpatCircle
//
//  Created by Adam on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWImageDisplayerDelegate.h"

@class WXWLabel;

@interface ECTitleThumbnailView : UIButton {
  @private
  
  UIImageView *_thumbnailImageView;
  UIImageView *_defaultImageView;
  UIView *_defaultImageBackgroundView;
  WXWLabel *_titleLabel;
  
  CGFloat _photoSideLength;
}

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title;

- (void)updateImage:(UIImage *)image;

@end
