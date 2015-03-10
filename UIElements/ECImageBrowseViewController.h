//
//  ECImageBrowseViewController.h
//  iAlumni
//
//  Created by Adam on 11-11-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWRootViewController.h"

@class WXWLabel;

@interface ECImageBrowseViewController : WXWRootViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, WXWImageFetcherDelegate> {
  @private
  UIImageView	*imageView;
	UIScrollView *imgScrollView;
	
	float		initialZoom;
	
	UIImage		*_image;
  
  BOOL isHidden;
  
  UITapGestureRecognizer *_oneTapRecoginzer;

  NSString *_imageUrl;
  
  NSString *_imageCaption;
  
  WXWLabel *_captionLabel;
}
- (id)initWithImage:(UIImage *)anImage;
- (id)initWithImageUrl:(NSString *)imageUrl;
- (id)initWithImageUrl:(NSString *)imageUrl imageCaption:(NSString *)imageCaption;

@end
