//
//  ECHandyImageBrowser.m
//  iAlumni
//
//  Created by Adam on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECHandyImageBrowser.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "CommonUtils.h"

#define LONG_SIDE   280
#define SHORT_SIDE  210

@interface ECHandyImageBrowser()
@property (nonatomic, retain) NSString *imageUrl;
@end

@implementation ECHandyImageBrowser

@synthesize imageUrl = _imageUrl;

- (id)initWithFrame:(CGRect)frame
             imgUrl:(NSString *)imgUrl {
  
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    // add canvas view
    _canvasView = [[UIView alloc] initWithFrame:frame];
    _canvasView.backgroundColor = [UIColor blackColor];
    _canvasView.alpha = 0;
    [self addSubview:_canvasView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageView];

    self.imageUrl = imgUrl;
      
    //[[[AppManager instance] imageCache] fetchImage:self.imageUrl caller:self forceNew:NO];
  }
  
  return self;
}

- (void)dealloc {
  
  [[WXWImageManager instance] clearCallerFromCache:self.imageUrl];
  
  self.imageUrl = nil;

  RELEASE_OBJ(_canvasView);
  RELEASE_OBJ(_imageView);
  
  [super dealloc];
}

#pragma mark - image handlers
- (void)displayImage {
  CGRect frame;
  switch ([CommonUtils imageOrientationType:_imageView.image]) {
      
    case IMG_SQUARE_TY:
      frame = CGRectMake(0, 0, SHORT_SIDE, SHORT_SIDE);
      break;
      
    case IMG_PORTRAIT_TY:
      frame = CGRectMake(0, 0, SHORT_SIDE, LONG_SIDE);
      break;
      
    case IMG_LANDSCAPE_TY:
      frame = CGRectMake(0, 0, LONG_SIDE, SHORT_SIDE);
      break;
      
    default:
      frame = CGRectZero;
      break;
  }
  
  float x = self.bounds.size.width/2 - frame.size.width/2;
  float y = self.bounds.size.height/2 - frame.size.height/2;
  _imageView.frame = CGRectMake(x, y, frame.size.width, frame.size.height);
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  [UIUtils showNoBackgroundActivityView:self];
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5f];
  
  _imageView.image = image;
  [self displayImage];
  [UIView commitAnimations];
  
  [UIUtils closeNoBackgroundActivityView];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  [UIUtils closeNoBackgroundActivityView];  
}

#pragma mark - destory self
- (void)destorySelf {
  [self removeFromSuperview];
}

#pragma mark - override methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  [[WXWImageManager instance] cancelPendingImageLoadProcess:[NSMutableDictionary dictionaryWithObject:self.imageUrl
                                                                                                       forKey:self.imageUrl]];
  
  [UIView beginAnimations:@"close" context:nil];
  [UIView setAnimationDuration:0.5f];
  [UIView setAnimationDelegate:self];
  _canvasView.alpha = 0;
  self.alpha = 0;
  _imageView.alpha = 0;
  [UIView setAnimationDidStopSelector:@selector(destorySelf)];
  [UIView commitAnimations];
  
  //[[NSNotificationCenter defaultCenter] postNotificationName:CLEAR_HANDY_IMAGE_BROWSER_NOTIF 
  //                                                    object:self];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  _imageView.center = self.center;
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:1.0f];
  _canvasView.alpha = 0.5;
  [self displayImage];
  [UIView commitAnimations];
  
  [[WXWImageManager instance] fetchImage:self.imageUrl caller:self forceNew:NO];
}

@end
