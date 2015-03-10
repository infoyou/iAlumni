//
//  ECTitleThumbnailView.m
//  ExpatCircle
//
//  Created by Adam on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECTitleThumbnailView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "AppManager.h"

#define PHOTO_BOUND_MARGIN  1.0f

@implementation ECTitleThumbnailView

#pragma mark - lifecycle methods

- (void)initImageView:(CGRect)frame {
  
  _photoSideLength = frame.size.width - PHOTO_BOUND_MARGIN * 2;  
  
  _defaultImageBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(PHOTO_BOUND_MARGIN, 
                                                                          PHOTO_BOUND_MARGIN, 
                                                                          _photoSideLength, 
                                                                          _photoSideLength)] autorelease];
  _defaultImageBackgroundView.userInteractionEnabled = NO;
  _defaultImageBackgroundView.backgroundColor = COLOR(200, 200, 200);
  [self addSubview:_defaultImageBackgroundView];
  
  _defaultImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallLogo.png"]] autorelease];
  _defaultImageView.userInteractionEnabled = NO;
  _defaultImageView.center = CGPointMake(_photoSideLength/2.0f, _photoSideLength/2.0f);
  [_defaultImageBackgroundView addSubview:_defaultImageView];
}

- (void)initTitle:(NSString *)title {
  _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                      textColor:BASE_INFO_COLOR 
                                    shadowColor:TRANSPARENT_COLOR] autorelease];
  _titleLabel.userInteractionEnabled = NO;
  _titleLabel.font = BOLD_FONT(13);
  _titleLabel.numberOfLines = 2;
  _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  _titleLabel.textAlignment = UITextAlignmentCenter;
  
  _titleLabel.text = title;
  
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(_photoSideLength, 
                                                          self.frame.size.height - 
                                                          (PHOTO_BOUND_MARGIN * 2 + _photoSideLength))
                                 lineBreakMode:NSLineBreakByTruncatingTail];
  _titleLabel.frame = CGRectMake((_photoSideLength - size.width)/2.0f,
                                 _thumbnailImageView.frame.origin.y + _photoSideLength + MARGIN, 
                                 size.width, size.height);
  [self addSubview:_titleLabel];
  
}

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = [UIColor whiteColor];

    [self initImageView:frame];
    
    [self initTitle:title];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc]; 
}

- (void)updateImage:(UIImage *)image {
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  
  if (_defaultImageBackgroundView) {
    if (_defaultImageView) {
      [_defaultImageView removeFromSuperview];
    }
    [_defaultImageBackgroundView removeFromSuperview];
  }
  
  [self.layer addAnimation:imageFadein forKey:nil];
  
  if (nil == _thumbnailImageView) {
    _thumbnailImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(PHOTO_BOUND_MARGIN, 
                                                                         PHOTO_BOUND_MARGIN, 
                                                                         _photoSideLength, 
                                                                         _photoSideLength)] autorelease];
    _thumbnailImageView.userInteractionEnabled = NO;
    _thumbnailImageView.backgroundColor = TRANSPARENT_COLOR;
    [self addSubview:_thumbnailImageView];
  }
    
  _thumbnailImageView.image = [CommonUtils cutPartImage:image
                                                  width:_photoSideLength 
                                                 height:_photoSideLength];
}

@end
