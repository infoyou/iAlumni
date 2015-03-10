//
//  ECHandyAvatarBrowser.m
//  ExpatCircle
//
//  Created by Adam on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECHandyAvatarBrowser.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "CommonUtils.h"

#define LONG_SIDE             280.0f
#define SHORT_SIDE            210.0f

@implementation ECHandyAvatarBrowser

- (id)initWithFrame:(CGRect)frame 
             imgUrl:(NSString *)imgUrl
    imageStartFrame:(CGRect)imageStartFrame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate {
  
  self = [super initWithFrame:frame];
  if (self) {
    
    self.frame = frame;
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    
    _imageView = [[UIImageView alloc] initWithFrame:imageStartFrame];
    _imageStartFrame = imageStartFrame;
    
    // add canvas view
    _canvasView = [[UIView alloc] initWithFrame:frame];
    _canvasView.backgroundColor = [UIColor blackColor];
    _canvasView.alpha = 0.75;
    [self addSubview:_canvasView];
    
    [self addSubview:_imageView];

    [_imageDisplayerDelegate registerImageUrl:imgUrl];
    
    [[WXWImageManager instance] fetchImage:imgUrl caller:self forceNew:NO];

  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_imageView);
  RELEASE_OBJ(_canvasView);
  
  [super dealloc];
}

#pragma mark - destory self
- (void)destorySelf {
  _canvasView.alpha = 0;
  self.alpha = 0;
  [self removeFromSuperview];
}

#pragma mark - WXWImageFetcherDelegate methods 
- (void)imageFetchStarted:(NSString *)url {

  [UIUtils showNoBackgroundActivityView:self];
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  _imageView.image = image;
  
  [UIUtils closeNoBackgroundActivityView];
  
  [self setNeedsDisplay];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  [UIUtils closeNoBackgroundActivityView];
}

#pragma mark - adjust layout
- (void)adjustImageViewFrame {
  
  self.layer.cornerRadius = 0;
  self.layer.masksToBounds = NO;
  
  CGRect frame;
  
  float imageWidth = _imageView.image.size.width;
  float imageHeight = _imageView.image.size.height;
  switch ([CommonUtils imageOrientationType:_imageView.image]) {
      
    case IMG_SQUARE_TY:
      frame = CGRectMake(0, 0, LONG_SIDE, LONG_SIDE);
      break;
      
    case IMG_PORTRAIT_TY:
      imageWidth = (imageWidth / imageHeight) * LONG_SIDE;
      imageHeight = LONG_SIDE;
      frame = CGRectMake(0, 0, imageWidth, imageHeight);
      break;
      
    case IMG_LANDSCAPE_TY:
      imageHeight = (imageHeight / imageWidth) * LONG_SIDE;
      imageWidth = LONG_SIDE;
      frame = CGRectMake(0, 0, imageWidth, imageHeight);
      break;
      
    default:
      frame = CGRectZero;
      break;
  }
  
  float x = self.bounds.size.width/2 - frame.size.width/2;
  float y = self.bounds.size.height/2 - frame.size.height/2;
  
  _imageView.frame = CGRectMake(x, y, frame.size.width, frame.size.height);
}

#pragma mark - override methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  _toBeRemoved = YES;
  
  [UIView beginAnimations:@"close" context:nil];
  [UIView setAnimationDuration:0.5f];
  [UIView setAnimationDelegate:self];
  _imageView.frame = _imageStartFrame;
  
  [UIView setAnimationDidStopSelector:@selector(destorySelf)];
  [UIView commitAnimations];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (!_toBeRemoved) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    [self adjustImageViewFrame];
    [UIView commitAnimations];
  }
}

@end
