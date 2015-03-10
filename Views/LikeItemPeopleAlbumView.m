//
//  LikeItemPeopleAlbumView.m
//  ExpatCircle
//
//  Created by Adam on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LikeItemPeopleAlbumView.h"
#import <QuartzCore/QuartzCore.h>
#import "ECInnerShadowImageView.h"
#import "UIUtils.h"
#import "AppManager.h"
#import "Member.h"
#import "CoreDataUtils.h"
#import "WXWLabel.h"

#define MAX_PHOTO_COUNT   5
#define ICON_WIDTH       16.0f
#define ICON_HEIGHT      16.0f
#define AVATAR_RAIDUS     PHOTO_SIDE_LENGTH/2.0f
#define AVATAR_INTERVAL  12.0f

@interface LikeItemPeopleAlbumView()
@property (nonatomic, retain) NSMutableDictionary *photoDic;
@end

@implementation LikeItemPeopleAlbumView

@synthesize photoDic = _photoDic;

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    _clickableElementDelegate = clickableElementDelegate;
    
    self.backgroundColor = CELL_COLOR;
    
    self.photoDic = [NSMutableDictionary dictionary];
    
    _displayedPeopleCount = MAX_PHOTO_COUNT;
  }
  return self;
}

- (void)dealloc {
  
  for (NSString *url in self.photoDic.allKeys) {
    [[WXWImageManager instance] clearCallerFromCache:url];
  }
  RELEASE_OBJ(_rightArrow);
  self.photoDic = nil;
  
  [super dealloc];
}

#pragma mark - draw views

- (void)removeAllAvatars {

  for (NSString *imageUrl in self.photoDic.allKeys) {
    ECInnerShadowImageView *avatar = (ECInnerShadowImageView *)(self.photoDic)[imageUrl];
    [avatar removeFromSuperview];
  }
}

- (void)drawLikesAlbum:(NSInteger)totalLikesCount 
             likedByMe:(BOOL)likedByMe
                   MOC:(NSManagedObjectContext *)MOC 
     hashedLikedItemId:(NSString *)hashedLikedItemId {
  
  _totalLikesCount = totalLikesCount;
  
  _likedByMe = likedByMe;
  
  if (nil == _rightArrow) {
    _rightArrow = [[UIImageView alloc] init];
    _rightArrow.image = [UIImage imageNamed:@"rightArrow.png"];
    _rightArrow.backgroundColor = TRANSPARENT_COLOR;
    [self addSubview:_rightArrow];
  }
  
  _rightArrow.frame = CGRectMake(self.bounds.size.width - MARGIN * 2 - ICON_WIDTH, 
                                 self.bounds.size.height/2 - ICON_HEIGHT/2 + MARGIN * 3, ICON_WIDTH, ICON_WIDTH);
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY likedItemIds.itemId == %@)", hashedLikedItemId];
  
  NSArray *likers = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Member" predicate:predicate];
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     [self removeAllAvatars];
                     
                      NSInteger index = 0;
                     
                     for (Member *liker in likers) {
                       
                       if (index >= _displayedPeopleCount) {
                         break;
                       }
                       
                       CGFloat centerX = MARGIN * 2 + (AVATAR_INTERVAL + PHOTO_SIDE_LENGTH) * index + AVATAR_RAIDUS; 
                                          
                       CGFloat centerY = _likeIcon.frame.origin.y + _likeIcon.frame.size.height +
                                         MARGIN + AVATAR_RAIDUS;
                       
                       ECInnerShadowImageView *avatar = [[[ECInnerShadowImageView alloc] initCircleWithCenterPoint:CGPointMake(centerX, centerY)
                                                                                                            radius:AVATAR_RAIDUS] autorelease];                       
                       [self addSubview:avatar];
                       (self.photoDic)[liker.photoUrl] = avatar;
                       
                       [_imageDisplayerDelegate registerImageUrl:liker.photoUrl];
                       
                       [[WXWImageManager instance] fetchImage:liker.photoUrl 
                                                               caller:self 
                                                             forceNew:NO];                       
                       index++;
                     }

                   }];

}

- (void)initCountLabel {
  _likesCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:BASE_INFO_COLOR
                                         shadowColor:[UIColor whiteColor]] autorelease];
  _likesCountLabel.font = FONT(11);
  [self addSubview:_likesCountLabel];
}

- (void)drawCountLabel {
  if (nil == _likesCountLabel) {
    [self initCountLabel];
  }

  _likesCountLabel.text = [NSString stringWithFormat:@"%d", _totalLikesCount];

  CGSize size = [_likesCountLabel.text sizeWithFont:_likesCountLabel.font
                                  constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
  _likesCountLabel.frame = CGRectMake(MARGIN * 2 + MARGIN * 4 + MARGIN, 
                                      MARGIN * 2, size.width, size.height);
}

- (void)drawLikeIcon {
  if (nil == _likeIcon) {
    _likeIcon = [[[UIImageView alloc] init] autorelease];
    _likeIcon.backgroundColor = TRANSPARENT_COLOR;
    [self addSubview:_likeIcon];
  }
  
  if (_likedByMe) {
    _likeIcon.image = [UIImage imageNamed:@"like.png"];
  } else {
    _likeIcon.image = [UIImage imageNamed:@"unlike.png"];
  }
  
  _likeIcon.frame = CGRectMake(_likesCountLabel.frame.origin.x + _likesCountLabel.frame.size.width + MARGIN, 
                               _likesCountLabel.frame.origin.y - MARGIN, ICON_WIDTH, ICON_HEIGHT);
}

- (void)drawRect:(CGRect)rect {
  
  [self drawCountLabel];
  
  [self drawLikeIcon];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat pattern[2] = {2.0, 2.0};
  
  CGFloat y = _likesCountLabel.frame.origin.y + MARGIN + 0.5f;
  
  [UIUtils draw1PxDashLine:context 
                startPoint:CGPointMake(MARGIN * 2, y)
                  endPoint:CGPointMake(MARGIN * 2 + MARGIN * 4, y)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 1.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];
  
  [UIUtils draw1PxDashLine:context 
                startPoint:CGPointMake(_likeIcon.frame.origin.x + _likeIcon.frame.size.width + MARGIN, y)
                  endPoint:CGPointMake(self.frame.size.width - MARGIN * 2, y)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 1.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  ECInnerShadowImageView *avatar = (ECInnerShadowImageView *)(self.photoDic)[url];
  avatar.imageView.image = [UIImage imageNamed:@"defaultUser.png"];
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  if (nil == url || url.length == 0) {
    return;
  }
  
  ECInnerShadowImageView *avatar = (ECInnerShadowImageView *)(self.photoDic)[url];
  
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  [avatar.imageView.layer addAnimation:imageFadein forKey:nil];
  avatar.imageView.image = image;
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
