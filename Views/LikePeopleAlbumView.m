//
//  LikePeopleAlbumView.m
//  iAlumni
//
//  Created by Adam on 11-12-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LikePeopleAlbumView.h"
#import <QuartzCore/QuartzCore.h>
#import "Alumni.h"
#import "CoreDataUtils.h"
#import "AppManager.h"

#define MAX_PHOTO_COUNT   5
#define ARROW_WIDTH       16.0f
#define ARROW_HEIGHT      16.0f

@interface LikePeopleAlbumView()
@property (nonatomic, retain) NSMutableDictionary *photoDic;
@end

@implementation LikePeopleAlbumView

@synthesize photoDic = _photoDic;
@synthesize photoLoaded;

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    _clickableElementDelegate = clickableElementDelegate;
    
    self.backgroundColor = TRANSPARENT_COLOR;//COLOR(225, 225, 225);
    self.clipsToBounds = YES;
    //self.layer.masksToBounds = YES;
    //self.layer.cornerRadius = 5.0f;
    //self.layer.borderWidth = 1.0f;
    //self.layer.borderColor = COLOR(235, 235, 235).CGColor;
    
    self.photoDic = [NSMutableDictionary dictionary];
    
    _displayedPeopleCount = MAX_PHOTO_COUNT;
  }
  return self;
}

- (void)dealloc {
  
  for (NSString *url in self.photoDic.allKeys) {
    [[WXWImageManager instance] clearCallerFromCache:url];
  }
  RELEASE_OBJ(_topShadow);
  RELEASE_OBJ(_rightArrow);
  self.photoDic = nil;
  
  [super dealloc];
}

- (void)drawAlbum:(NSManagedObjectContext *)MOC {
  
  if (nil == _topShadow) {
    _topShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
    _topShadow.backgroundColor = COLOR(225, 225, 225);    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, _topShadow.bounds.size.height - 0.5)];
    [path addLineToPoint:CGPointMake(_topShadow.bounds.size.width, _topShadow.bounds.size.height - 0.5)];
    [path addLineToPoint:CGPointMake(_topShadow.bounds.size.width, _topShadow.bounds.size.height)];
    [path addLineToPoint:CGPointMake(0, _topShadow.bounds.size.height)];
    [path addLineToPoint:CGPointMake(0, _topShadow.bounds.size.height - 0.5)];
    _topShadow.layer.shadowColor = [[UIColor blackColor] CGColor];
    _topShadow.layer.shadowOpacity = 0.9f;
    _topShadow.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);    
    _topShadow.layer.masksToBounds = NO;
    _topShadow.layer.shadowPath = path.CGPath;
  }
  
  if (nil == _rightArrow) {
    _rightArrow = [[UIImageView alloc] init];
    _rightArrow.image = [UIImage imageNamed:@"rightArrow.png"];
    _rightArrow.backgroundColor = TRANSPARENT_COLOR;
  }
  
  _rightArrow.frame = CGRectMake(self.bounds.size.width - MARGIN - ARROW_WIDTH, self.bounds.size.height/2 - ARROW_HEIGHT/2, ARROW_WIDTH, ARROW_WIDTH);
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId != '')"];
  NSArray *likers = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Alumni" predicate:predicate];
  
  NSInteger index = 0;
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.2f];
  [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  //[self addSubview:_topShadow];
  [self addSubview:_rightArrow];
  
  for (Alumni *liker in likers) {
    
    if (index >= _displayedPeopleCount) {
      break;
    }
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake((POST_LIKE_PHOTO_WIDTH + MARGIN) * index + MARGIN + 2, (self.frame.size.height - POST_LIKE_PHOTO_HEIGHT)/2.0, POST_LIKE_PHOTO_WIDTH, POST_LIKE_PHOTO_HEIGHT)] autorelease];
    imageView.layer.cornerRadius = 6.0f;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 2.0f;
    imageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:imageView];
    (self.photoDic)[liker.imageUrl] = imageView;
    
    [_imageDisplayerDelegate registerImageUrl:liker.imageUrl];
    
    [[WXWImageManager instance] fetchImage:liker.imageUrl caller:self forceNew:NO];
    
    index++;
    
    photoLoaded = YES;
  }
  
  [UIView commitAnimations];
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat radius = 6.0f;
  
  //UIBezierPath *visiblePath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
  
  // Create the "visible" path, which will be the shape that gets the inner shadow
  // In this case it's just a rounded rect, but could be as complex as your want
  CGMutablePathRef visiblePath = CGPathCreateMutable();
  CGPathMoveToPoint(visiblePath, NULL, self.bounds.origin.x, self.bounds.origin.y);
  CGPathAddArcToPoint(visiblePath, NULL, self.bounds.size.width, self.bounds.origin.y, self.bounds.size.width, self.bounds.origin.y + radius, radius);
  CGPathAddArcToPoint(visiblePath, NULL, self.bounds.size.width, self.bounds.size.height, self.bounds.size.width - radius, self.bounds.size.height, radius);
  CGPathAddArcToPoint(visiblePath, NULL, self.bounds.origin.x, self.bounds.size.height, self.bounds.origin.x, self.bounds.size.height - radius, radius);
  CGPathAddArcToPoint(visiblePath, NULL, self.bounds.origin.x, self.bounds.origin.y, self.bounds.origin.x + radius, self.bounds.origin.y, radius);
  CGPathCloseSubpath(visiblePath);
  
  // Fill this path
  [COLOR(225, 225, 225) setFill];
  CGContextAddPath(context, visiblePath);
  CGContextFillPath(context);
  
  // Now create a larger rectangle, which we're going to subtract the visible path from
  // and apply a shadow
  CGMutablePathRef shadowPath = CGPathCreateMutable();
  //(when drawing the shadow for a path whichs bounding box is not known pass 
  //"CGPathGetPathBoundingBox(visiblePath)" instead of "bounds" in the following line:)
  //-42 cuould just be any offset > 0
  CGPathAddRect(shadowPath,
                NULL, 
                CGRectInset(self.bounds, -42, -42));
  
  // Add the visible path (so that it gets subtracted for the shadow)
  CGPathAddPath(shadowPath, NULL, visiblePath);
  CGPathCloseSubpath(shadowPath);
  
  // Add the visible paths as the clipping path to the context
  CGContextAddPath(context, visiblePath);
  CGContextClip(context);
  
  // Now setup the shadow properties on the context
  UIColor *color = [UIColor colorWithRed:0
                                   green:0 
                                    blue:0 
                                   alpha:0.5f];
  CGContextSaveGState(context);
  CGContextSetShadowWithColor(context, CGSizeMake(0, 1.0f), 3.0f, color.CGColor);
  
  // Now fill the rectangle, so the shadow gets drawn
  [color setFill];
  CGContextSaveGState(context);
  CGContextAddPath(context, shadowPath);
  CGContextEOFillPath(context);
  
  // Release the paths
  CGPathRelease(shadowPath);
  CGPathRelease(visiblePath);
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
  imageView.image = image;
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
