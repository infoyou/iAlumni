//
//  HandyUserAvatarBrowser.m
//  CEIBS
//
//  Created by Adam on 11-6-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HandyUserAvatarBrowser.h"
#import "GlobalConstants.h"
#import "CommonUtils.h"
#import "iAlumniAppDelegate.h"
#import "AppManager.h"
#import "UIUtils.h"

#define LONG_SIDE             280.0f
#define SHORT_SIDE            210.0f

#define LABEL_WIDTH           300.0f
#define AUTHOR_LABEL_HEIGHT   30.0f
#define COMMENT_LABEL_HEIGHT  60.0f

@interface HandyUserAvatarBrowser()

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) WXWImageCacheReceiver *receiver;
@property (nonatomic, retain) UIView *canvasView;
@property (nonatomic, copy) NSString *imgUrl;

@end

@implementation HandyUserAvatarBrowser

@synthesize imageView = _imageView;
@synthesize receiver = _receiver;
@synthesize imgUrl = _imgUrl;
@synthesize canvasView = _canvasView;

//- (void)adjustImageViewFrame {
//  CGRect frame;
//  
//  float imageWidth = self.imageView.image.size.width;
//  float imageHeight = self.imageView.image.size.height;
//  switch ([CommonUtils imageOrientationType:self.imageView.image]) {
//      
//    case IMG_SQUARE_TY:
//      frame = CGRectMake(0, 0, LONG_SIDE, LONG_SIDE);
//      break;
//      
//    case IMG_PORTRAIT_TY:
//      imageWidth = (imageWidth / imageHeight) * LONG_SIDE;
//      imageHeight = LONG_SIDE;
//      frame = CGRectMake(0, 0, imageWidth, imageHeight);
//      //frame = CGRectMake(0, 0, SHORT_SIDE, LONG_SIDE);
//      break;
//      
//    case IMG_LANDSCAPE_TY:
//      imageHeight = (imageHeight / imageWidth) * LONG_SIDE;
//      imageWidth = LONG_SIDE;
//      frame = CGRectMake(0, 0, imageWidth, imageHeight);
//      //frame = CGRectMake(0, 0, LONG_SIDE, SHORT_SIDE);
//      break;
//      
//    default:
//      frame = CGRectZero;
//      break;
//  }
//  
//  float x = self.bounds.size.width/2 - frame.size.width/2;
//  float y = 0.0f;
//  if (_forAblum) {
//    y = 30.0f;
//  } else {
//    y = self.bounds.size.height/2 - frame.size.height/2;
//  }
//  self.imageView.frame = CGRectMake(x, y, frame.size.width, frame.size.height);
//}


//- (void)getThumbnailImage {
//	WXWImageCache *cache = [WXWImageManager instance].imageCache;
//	
//    self.receiver.photoType = AUTHOR_PHOTO_TY;
//    self.receiver.imageConsumer = self;
//    
//    UIImage *image = [cache getImage:self.imgUrl 
//                             isLarge:NO 
//                            delegate:self.receiver
//                     defaultImageUrl:nil 
//                          isForceNew:NO];
//    if (image) {
//        self.imageView.image = image;
//    } else {
//        [UIUtils showNoBackgroundActivityView:self];
//    }
//}

- (id)initWithFrame:(CGRect)frame imgUrl:(NSString *)imgUrl imageStartFrame:(CGRect)imageStartFrame {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:imageStartFrame];
        _imageStartFrame = imageStartFrame;
        self.imgUrl = imgUrl;
        _receiver = [[WXWImageCacheReceiver alloc] init];
        self.frame = frame;
        self.backgroundColor = TRANSPARENT_COLOR;
        
        // add canvas view
        _canvasView = [[UIView alloc] initWithFrame:frame];
        self.canvasView.backgroundColor = [UIColor blackColor];
        self.canvasView.alpha = 0.75;
        [self addSubview:self.canvasView];
        [self addSubview:self.imageView];
        
//        [self getThumbnailImage];
    }
    return self;
}

- (void)dealloc {  
    /************** BEGIN OF CLEAR THE IMAGE CACHE *******************/
	WXWImageCache *cache = [[AppManager instance] imageCache];
	self.receiver.imageConsumer = nil;
	[cache removeDelegate:self.receiver forUrl:self.imgUrl];
	
	self.receiver = nil;
    /************** END OF CLEAR THE IMAGE CACHE *******************/
    
    self.imageView = nil;
    self.imgUrl = nil;
    self.canvasView = nil;
    
    if (_commentLabel) {
        RELEASE_OBJ(_commentLabel);
    }
    
    if (_authorInfoLabel) {
        RELEASE_OBJ(_authorInfoLabel);
    }
    
    [super dealloc];
}

#pragma mark - destory self
- (void)destorySelf {
    self.canvasView.alpha = 0;
    self.alpha = 0;
    if (_forAblum) {
        _commentLabel.alpha = 0;
        _authorInfoLabel.alpha = 0;
    }
    [self removeFromSuperview];
}

#pragma mark - override methods
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//  
//  _toBeRemoved = YES;
//  
//  [UIView beginAnimations:@"close" context:nil];
//  [UIView setAnimationDuration:0.5f];
//  [UIView setAnimationDelegate:self];
//  self.imageView.frame = _imageStartFrame;
//  if (_forAblum) {
//    _commentLabel.frame = CGRectMake(MARGIN, 480, LABEL_WIDTH, COMMENT_LABEL_HEIGHT);
//    _authorInfoLabel.frame = CGRectMake(MARGIN, 480, LABEL_WIDTH, AUTHOR_LABEL_HEIGHT);
//  }
//  [UIView setAnimationDidStopSelector:@selector(destorySelf)];
//  [UIView commitAnimations];
//}
//
//- (void)layoutSubviews {
//  [super layoutSubviews];
//
//  if (!_toBeRemoved) {
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5f];
//    if (_forAblum) {
//      _commentLabel.frame = CGRectMake(MARGIN, 320.0f, LABEL_WIDTH, COMMENT_LABEL_HEIGHT);
//      _authorInfoLabel.frame = CGRectMake(MARGIN, _commentLabel.frame.size.height + _commentLabel.frame.origin.y, LABEL_WIDTH, AUTHOR_LABEL_HEIGHT);
//      
//    }     
//    [self adjustImageViewFrame];
//    [UIView commitAnimations];
//  }
//}

@end
