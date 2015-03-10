//
//  ServiceItemLikerAlbumView.m
//  ExpatCircle
//
//  Created by Adam on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServiceItemLikerAlbumView.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreDataUtils.h"
#import "AppManager.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "WXWDebugLogOutput.h"
#import "Liker.h"

#define MAX_PHOTO_COUNT   5
#define ARROW_WIDTH       16.0f
#define ARROW_HEIGHT      16.0f

#define SEPARATOR_COLOR_VALUE   200.0f/255.0f

#define DIAMETER          30.0f

@interface ServiceItemLikerAlbumView()
@property (nonatomic, retain) NSMutableDictionary *photoDic;
@property (nonatomic, retain) WXWLabel *noLikerNotifyLabel;
@property (nonatomic, retain) NSMutableArray *imageViewList;
@property (nonatomic, retain) NSArray *currentLikers;
@end

@implementation ServiceItemLikerAlbumView

@synthesize spinView = _spinView;
@synthesize clickable = _clickable;
@synthesize photoDic = _photoDic;
@synthesize photoLoaded;
@synthesize noLikerNotifyLabel = _noLikerNotifyLabel;
@synthesize imageViewList = _imageViewList;
@synthesize currentLikers = _currentLikers;

static CGFloat pattern[2] = {2.0, 2.0};

- (void)updateLikeCountLabel:(NSInteger)count {
  if (count <= 0) {
    
    _likeCountLabel.alpha = 0.0f;
  } else {
    
    _likeCountLabel.text = [NSString stringWithFormat:@"%d", count];
    
    CGSize size = [_likeCountLabel.text sizeWithFont:_likeCountLabel.font
                                   constrainedToSize:CGSizeMake(100, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat width = size.width + MARGIN * 4;
    _likeCountLabel.frame = CGRectMake(_rightArrow.frame.origin.x - MARGIN - width,
                                       (self.frame.size.height - size.height)/2.0f,
                                       width, size.height);
    
    _likeCountLabel.layer.cornerRadius = size.height/2.0f;
    
    _likeCountLabel.alpha = 1.0f;
  }
}

- (void)hideOrDisplayNoLikerNotify:(NSInteger)count {
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     if (count == 0) {
                       [self addSubview:self.noLikerNotifyLabel];
                       self.noLikerNotifyLabel.alpha = 1.0f;
                       
                     } else {                       
                       self.noLikerNotifyLabel.alpha = 0.0f;                                              
                     }
                     
                     //[self updateLikeCountLabel:count];
                     
                   } completion:^(BOOL finished){
                     if (count > 0) {
                       [self.noLikerNotifyLabel removeFromSuperview];  
                     }
                   }];
}

- (void)addRightArrow {
  _rightArrow = [[UIImageView alloc] init];
  _rightArrow.image = [UIImage imageNamed:@"rightArrow.png"];
  _rightArrow.backgroundColor = TRANSPARENT_COLOR;
  [self addSubview:_rightArrow];
  
  _rightArrow.frame = CGRectMake(self.bounds.size.width - ARROW_WIDTH, 
                                 self.bounds.size.height/2 - ARROW_HEIGHT/2, 
                                 ARROW_WIDTH, ARROW_WIDTH);
}

- (void)initNoLikerNotify {
  
  self.noLikerNotifyLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                  textColor:BASE_INFO_COLOR
                                                shadowColor:[UIColor whiteColor]] autorelease];
  
  self.noLikerNotifyLabel.alpha = 0.0f;  
  self.noLikerNotifyLabel.font = TIMESNEWROM_ITALIC(13);
  self.noLikerNotifyLabel.backgroundColor = TRANSPARENT_COLOR;
  self.noLikerNotifyLabel.textAlignment = UITextAlignmentCenter;
  self.noLikerNotifyLabel.text = LocaleStringForKey(NSNoLikerNotifyMsg, nil);
  CGSize size = [self.noLikerNotifyLabel.text sizeWithFont:self.noLikerNotifyLabel.font
                                         constrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)
                                             lineBreakMode:NSLineBreakByWordWrapping];
  
  self.noLikerNotifyLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f, 
                                             (self.frame.size.height - size.height)/2.0f,
                                             size.width, size.height);  
}

- (void)initLikeCountLabel {
  _likeCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(_rightArrow.frame.origin.x - MARGIN * 2, self.frame.size.height/2.0f, 0, 0)
                                          textColor:[UIColor whiteColor]
                                        shadowColor:TRANSPARENT_COLOR] autorelease];
  _likeCountLabel.font = BOLD_FONT(10);
  _likeCountLabel.textAlignment = UITextAlignmentCenter;
  _likeCountLabel.backgroundColor = BASE_INFO_COLOR;
  _likeCountLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
  _likeCountLabel.alpha = 0.0f;
  
  [self addSubview:_likeCountLabel];
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    _displayedPeopleCount = MAX_PHOTO_COUNT;
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    _clickableElementDelegate = clickableElementDelegate;
    
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = 0.0f;
    self.layer.borderWidth = 0.0f;
    self.layer.borderColor = TRANSPARENT_COLOR.CGColor;
    
    self.photoDic = [NSMutableDictionary dictionary];
    
    self.imageViewList = [NSMutableArray array];
    
    _displayedPeopleCount = MAX_PHOTO_COUNT;
    
    self.clickable = YES;
    
    [self addRightArrow];
    
    [self initNoLikerNotify];
    
    [self initLikeCountLabel];
  
  }
  return self;
}


- (void)dealloc {
  
  for (NSString *url in self.photoDic.allKeys) {
    [[WXWImageManager instance] clearCallerFromCache:url];
  }
  RELEASE_OBJ(_rightArrow);
  self.photoDic = nil;
  
  self.noLikerNotifyLabel = nil;
  
  self.imageViewList = nil;
  
  self.currentLikers = nil;
  
  [super dealloc];
}

- (void)drawAlbum:(NSManagedObjectContext *)MOC 
hashedLikedItemId:(NSString *)hashedLikedItemId {
  
  if (self.imageViewList.count > 0) {
    [self.imageViewList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewList removeAllObjects];
  }
  
  [self addSubview:_rightArrow];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY likedItemIds.itemId == %@)", hashedLikedItemId];
  
  self.currentLikers = [WXWCoreDataUtils fetchObjectsFromMOC:MOC 
                                               entityName:@"Liker"
                                                predicate:predicate];
  
  [self hideOrDisplayNoLikerNotify:self.currentLikers.count];
  
  NSInteger index = 0;
  
  for (Liker *liker in self.currentLikers) {
    
    if (index >= _displayedPeopleCount) {
      break;
    }
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake((DIAMETER + MARGIN) * index + MARGIN + 2, 
                                                                            (self.frame.size.height - DIAMETER)/2.0,
                                                                            DIAMETER, DIAMETER)] autorelease];
    imageView.layer.cornerRadius = DIAMETER/2.0f;
    imageView.layer.masksToBounds = YES;
    imageView.backgroundColor = TRANSPARENT_COLOR;
    [self.imageViewList addObject:imageView];
    
    [self addSubview:imageView];
    (self.photoDic)[liker.photoUrl] = imageView;
    
    [_imageDisplayerDelegate registerImageUrl:liker.photoUrl];
    
    [[WXWImageManager instance] fetchImage:liker.photoUrl
                                            caller:self 
                                          forceNew:NO]; 
    index++;
    
    photoLoaded = YES;
     
  }  
}

- (void)hideRightArrow {
  _rightArrow.frame = CGRectMake(0, _rightArrow.frame.origin.y, 0, _rightArrow.frame.size.height);
}

- (void)startSpinView {
  self.spinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
  self.spinView.frame = CGRectMake(0, 0, 16.0f, 16.0f);
  self.spinView.center = self.center;
  [self.spinView startAnimating];
}

- (void)stopSpinView {
  if (self.spinView) {
    [self.spinView stopAnimating];
    
    [self.spinView removeFromSuperview];
    
    self.spinView = nil;
  }
}

- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(0, 0)
                  endPoint:CGPointMake(0, self.frame.size.height)
                  colorRef:COLOR(158.0f, 161.0f, 168.0f).CGColor
              shadowOffset:CGSizeMake(1.0f, 1.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  if (nil == url || url.length == 0) {
    return;
  }
  UIImageView *imageView = (UIImageView *)(self.photoDic)[url];
  
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  [imageView.layer addAnimation:imageFadein forKey:nil];
  imageView.image = [CommonUtils cutPartImage:image width:DIAMETER height:DIAMETER];
  
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate openLikers];
  }
}

@end
