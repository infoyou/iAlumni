//
//  CouponImageView.m
//  ExpatCircle
//
//  Created by Adam on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CouponImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppManager.h"
#import "CommonUtils.h"

@interface CouponImageView()
@property (nonatomic, copy) NSString *imageUrl;
@end

@implementation CouponImageView

@synthesize imageUrl = _imageUrl;

#pragma mark - user action
- (void)browseBigPic:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate openImageUrl:self.imageUrl];
  }
}

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame 
           imageUrl:(NSString *)imageUrl 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = COLOR(200, 200, 200);
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    _clickableElementDelegate = clickableElementDelegate; 
    
    self.imageUrl = imageUrl;
    
    _loadingImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaultCoupon.png"]] autorelease];
    _loadingImageView.backgroundColor = TRANSPARENT_COLOR;
    _loadingImageView.center = CGPointMake(frame.size.width/2, 
                                           frame.size.height/2);    
    [self addSubview:_loadingImageView];
    
    if (_imageDisplayerDelegate && imageUrl.length > 0) {
      
      [_imageDisplayerDelegate registerImageUrl:imageUrl];
      
      [[WXWImageManager instance].imageCache fetchImage:imageUrl caller:self forceNew:NO];
    }
    
  }
  return self;
}

- (void)dealloc {
  
  self.imageUrl = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  CGColorRef lightColor =  CELL_COLOR.CGColor;
  CGColorRef shadowColor = [UIColor blackColor].CGColor; 
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  // draw top shadow
  CGContextSaveGState(context);
  CGContextSetFillColorWithColor(context, lightColor);
  CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.5f), 5, shadowColor);
  CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, 1));
  
  // draw bottom shadow
  CGContextSetShadowWithColor(context, CGSizeMake(0.0f, -0.5f), 5, shadowColor);
  CGContextFillRect(context, CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1));
  
  CGContextRestoreGState(context);
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  if (nil == url || url.length == 0) {
    return;
  }
  
  if (_loadingImageView) {
    [_loadingImageView removeFromSuperview];
  }
  
  CGFloat maxWidth = self.frame.size.width - MARGIN * 4;
  CGFloat maxHeight = self.frame.size.height - MARGIN * 4;
  
  ImageOrientationType orientation = [CommonUtils imageOrientationType:image];
    
  CGFloat width = 0.0f;
  CGFloat height = 0.0f;
  switch (orientation) {
    case IMG_LANDSCAPE_TY:
    {
      if (image.size.width < maxWidth) {
        width = image.size.width;
      } else {
        width = maxWidth;
      }
      height = (width * image.size.height) / image.size.width;
      break;
    }
      
    case IMG_PORTRAIT_TY:
    {
      if (image.size.height < maxHeight) {
        height = image.size.height;
      } else {
        height = maxHeight;
      }
      width = (height * image.size.width) / image.size.height;
      break;
    }
      
    case IMG_SQUARE_TY:
    {
      if (image.size.width < maxWidth) {
        width = image.size.width;
        height = image.size.height;
      } else {
        width = maxWidth;
        height = maxHeight;
      }
      break;
    }
      
    default:
      break;
  }
  
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  [self.layer addAnimation:imageFadein forKey:nil];

  _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_imageButton addTarget:self
                   action:@selector(browseBigPic:) 
         forControlEvents:UIControlEventTouchUpInside];

  _imageButton.frame = CGRectMake((self.frame.size.width - width)/2.0f,
                                  (self.frame.size.height - height)/2.0f - 3.0f, 
                                  width, height);

  _imageButton.backgroundColor = TRANSPARENT_COLOR;
  UIImage *cuttedImage = [CommonUtils cutPartImage:image
                                             width:_imageButton.frame.size.width
                                            height:_imageButton.frame.size.height];
  [_imageButton setImage:cuttedImage
                forState:UIControlStateNormal];
  [self addSubview:_imageButton];
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  CGFloat curlFactor = 10.0f;
  CGFloat shadowDepth = 8.0f;
  [shadowPath moveToPoint:CGPointMake(0, 0)];
  [shadowPath addLineToPoint:CGPointMake(_imageButton.frame.size.width, 0)];
  [shadowPath addLineToPoint:CGPointMake(_imageButton.frame.size.width, 
                                         _imageButton.frame.size.height + shadowDepth)];
  [shadowPath addCurveToPoint:CGPointMake(0.0f, _imageButton.frame.size.height + shadowDepth)
                controlPoint1:CGPointMake(_imageButton.frame.size.width - curlFactor, 
                                          _imageButton.frame.size.height + shadowDepth - curlFactor)
                controlPoint2:CGPointMake(curlFactor, 
                                          _imageButton.frame.size.height + shadowDepth - curlFactor)];
  
  _imageButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  _imageButton.layer.shadowOpacity = 0.7f;
  _imageButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  _imageButton.layer.shadowRadius = 2.0f;
  _imageButton.layer.masksToBounds = NO;
  
  _imageButton.layer.shadowPath = shadowPath.CGPath;

}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
