//
//  ServiceItemPhotoWall.m
//  ExpatCircle
//
//  Created by Adam on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServiceItemPhotoWall.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWAsyncConnectorFacade.h"
#import "CommonUtils.h"
#import "HttpUtils.h"
#import "ServiceItem.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "TextConstants.h"
#import "AlbumPhoto.h"
#import "CoreDataUtils.h"
#import "AppManager.h"
#import "CoreDataUtils.h"

#define IMAGE_WIDTH   84.0f
#define IMAGE_HEIGHT  56.0f
#define IMAGE_MARGIN  3.0f

#define ARROW_SIDE_LENGTH 16.0f

#define IMAGEVIEW_TAG   9

@interface ServiceItemPhotoWall()
@property (nonatomic, retain) UIActivityIndicatorView *spinView;
@property (nonatomic, retain) NSMutableDictionary *errorMsgDic;
@property (nonatomic, retain) NSMutableDictionary *photoDic;
@property (nonatomic, copy) NSString *currentOldestImageUrl;
@property (nonatomic, retain) NSArray *currentPhotos;
@end

@implementation ServiceItemPhotoWall

@synthesize spinView = _spinView;
@synthesize errorMsgDic = _errorMsgDic;
@synthesize photoDic = _photoDic;
@synthesize currentOldestImageUrl = _currentOldestImageUrl;
@synthesize currentPhotos = _currentPhotos;

#pragma mark - load photo
- (void)requestConnection:(NSString *)url  
               connFacade:(WXWAsyncConnectorFacade *)connFacade 
         connectionAction:(SEL)connectionAction {
  if (_connectTriggerDelegate) {
    [_connectTriggerDelegate registerRequestUrl:url connFacade:connFacade];
  }
  
  
  [connFacade performSelector:connectionAction withObject:url];
}

- (void)loadPhotos {
  
  NSString *param = [NSString stringWithFormat:@"<service_id>%@</service_id><start_index>0</start_index><count>3</count>", _item.itemId];
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_SERVICE_ITEM_ALBUM_PHOTO_TY];
  
  WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                  interactionContentType:LOAD_SERVICE_ITEM_ALBUM_PHOTO_TY] autorelease];
  [self requestConnection:url 
               connFacade:connFacade 
         connectionAction:@selector(fetchAlbumPhoto:)];
}

- (NSArray *)fetchImageFromMOC:(NSInteger)limitedCount {
  NSMutableArray *sortDescs = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" 
                                                              ascending:NO] autorelease];
  [sortDescs addObject:descriptor];
  NSArray *photos = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                            entityName:@"AlbumPhoto"
                                             predicate:nil
                                             sortDescs:sortDescs 
                                         limitedNumber:limitedCount];
  return photos;
}

- (void)createImageViewAndLoadImage:(AlbumPhoto *)photo index:(NSInteger)index {
  UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectMake((MARGIN + IMAGE_WIDTH + IMAGE_MARGIN * 2) * index +
                                                                     MARGIN * 2, 
                                                                     MARGIN * 2, 
                                                                     IMAGE_WIDTH + IMAGE_MARGIN * 2, 
                                                                     IMAGE_HEIGHT + IMAGE_MARGIN * 2)] autorelease];
  backgroundView.backgroundColor = [UIColor whiteColor];
  UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(IMAGE_MARGIN, 
                                                                          IMAGE_MARGIN,
                                                                          IMAGE_WIDTH, IMAGE_HEIGHT)] autorelease];
  imageView.backgroundColor = TRANSPARENT_COLOR;
  imageView.tag = IMAGEVIEW_TAG;
  
  [backgroundView addSubview:imageView];
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  [shadowPath moveToPoint:CGPointMake(4.0f, backgroundView.frame.size.height - MARGIN)];
  [shadowPath addLineToPoint:CGPointMake(backgroundView.frame.size.width - 4.0f, 
                                         backgroundView.frame.size.height - MARGIN)];
  [shadowPath addLineToPoint:CGPointMake(backgroundView.frame.size.width - 4.0f, backgroundView.frame.size.height)];
  [shadowPath addLineToPoint:CGPointMake(4.0f, backgroundView.frame.size.height )];
  [shadowPath addLineToPoint:CGPointMake(4.0f, backgroundView.frame.size.height - MARGIN)];
  backgroundView.layer.masksToBounds = NO;
  backgroundView.layer.shadowPath = shadowPath.CGPath;
  backgroundView.layer.shadowOpacity = 0.9f;
  backgroundView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
  
  [self addSubview:backgroundView];
  
  if (photo.imageUrl && photo.imageUrl.length > 0) {
    (self.photoDic)[photo.imageUrl] = backgroundView;
    
    [_imageDisplayerDelegate registerImageUrl:photo.imageUrl];
    
    [[WXWImageManager instance] fetchImage:photo.imageUrl
                                            caller:self 
                                          forceNew:NO];
  }
}

- (void)fetchImages {

  self.currentPhotos = [self fetchImageFromMOC:ALBUM_ROW_PHOTO_COUNT];
  
  for (int i = 0; i < self.currentPhotos.count; i++) {
    
    AlbumPhoto *photo = (AlbumPhoto *)(self.currentPhotos)[i];
    
    [self createImageViewAndLoadImage:photo index:i];
  }
}

- (void)appendLatestUploadedPhoto {

  self.currentPhotos = [self fetchImageFromMOC:ALBUM_ROW_PHOTO_COUNT + 1];
  
  [UIView animateWithDuration:1.0f
                   animations:^{
                     // object of index 0 is the latest one, that is user just uploaded photo;
                     // move from left to right and get rid of current oldest one (the last index)
                     
                     NSLog(@"photo count: %d", self.currentPhotos.count);
                     for (NSInteger i = self.currentPhotos.count - 1; i > 0; i--) {                       
                       
                       AlbumPhoto *photo = (AlbumPhoto *)(self.currentPhotos)[i];
                       UIView *imageBackgroundView = (UIView *)(self.photoDic)[photo.imageUrl];                                       
                       
                       if (i == self.currentPhotos.count - 1) {
                         self.currentOldestImageUrl = photo.imageUrl;
                       }
                       
                       if (i == self.currentPhotos.count - 1 && self.currentPhotos.count == ALBUM_ROW_PHOTO_COUNT + 1) {
                         imageBackgroundView.alpha = 0.0f;    
                         imageBackgroundView.transform = CGAffineTransformScale(imageBackgroundView.transform, 
                                                                                0.01f, 0.01f);
                       } else {
                         imageBackgroundView.frame = CGRectMake(imageBackgroundView.frame.origin.x + 
                                                                imageBackgroundView.frame.size.width + MARGIN, 
                                                                imageBackgroundView.frame.origin.y, 
                                                                imageBackgroundView.frame.size.width, 
                                                                imageBackgroundView.frame.size.height);
                       }
                     }
                   }
                   completion:^(BOOL finished){
                     
                     if (self.currentPhotos.count > ALBUM_ROW_PHOTO_COUNT) {
                       [self.photoDic removeObjectForKey:self.currentOldestImageUrl];
                     }                    
                     
                     [UIView animateWithDuration:FADE_IN_DURATION
                                      animations:^{
                                        
                                        if (!_connectionCancelled) {
                                          // if user does not cancel the photo upload process, then append latest uploaded photo
                                          AlbumPhoto *latestPhoto = (AlbumPhoto *)(self.currentPhotos)[0];
                                          [self createImageViewAndLoadImage:latestPhoto
                                                                      index:0];
                                        }
                                      }];                                                                         
                   }];  
}

- (void)connectionCancelled {
  _connectionCancelled = YES;
}

#pragma mark - lifecycle methods

- (void)appendPhoto {
  
  [self loadPhotos];
}

- (void)addArrow {
  UIImageView *arrow = [[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - MARGIN * 2 -
                                                                      ARROW_SIDE_LENGTH, 
                                                                      (self.frame.size.height - ARROW_SIDE_LENGTH)/2.0f, 
                                                                      ARROW_SIDE_LENGTH, 
                                                                      ARROW_SIDE_LENGTH)] autorelease];
  arrow.backgroundColor = TRANSPARENT_COLOR;
  arrow.image = [UIImage imageNamed:@"rightArrow.png"];
  [self addSubview:arrow];
}

- (void)addConnectionCancellNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(connectionCancelled)
                                               name:CONN_CANCELL_NOTIFY
                                             object:nil];
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
               item:(ServiceItem *)item
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate {
  
  self = [super initWithFrame:frame];
  if (self) {
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    _clickableElementDelegate = clickableElementDelegate;
    _connectTriggerDelegate = connectionTriggerHolderDelegate;
    
    self.errorMsgDic = [NSMutableDictionary dictionary];
    self.photoDic = [NSMutableDictionary dictionary];
    
    _MOC = MOC;
    
    _item = item;
    
    [self addConnectionCancellNotification];
    
    DELETE_OBJS_FROM_MOC(_MOC, @"AlbumPhoto", nil);
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  }
  return self;
}

- (void)dealloc {
  
  self.spinView = nil;
  self.errorMsgDic = nil;
  self.photoDic = nil;
  self.currentOldestImageUrl = nil;
  self.currentPhotos = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                  name:CONN_CANCELL_NOTIFY
                                                object:nil];

  DELETE_OBJS_FROM_MOC(_MOC, @"AlbumPhoto", nil);
  
  [super dealloc];
}

- (void)layoutSubviews {
  
  _coloredBoxRect = CGRectMake(0, 0, self.frame.size.width, MARGIN);
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

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  self.spinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
  self.spinView.backgroundColor = TRANSPARENT_COLOR;
  self.spinView.frame = CGRectMake((self.frame.size.width - 20.0f)/2.0f,
                                   (self.frame.size.height - 20.0f)/2.0f, 20.0f, 20.0f);
  [self.spinView startAnimating];
  [self addSubview:self.spinView];
}

- (void)stopSpin {
  [self.spinView stopAnimating];
  [self.spinView removeFromSuperview];
  self.spinView = nil;
}

- (void)traceParserXMLErrorMessage:(NSString *)message url:(NSString *)url {
  if (url && url.length > 0) {
    (self.errorMsgDic)[url] = message;
  }
}

- (void)connectDone:(NSData *)result 
                url:(NSString *)url 
        contentType:(NSInteger)contentType {
  
  [self stopSpin];
  
  if (_connectionCancelled) {
    // user leaved the detail UI already, then no need to continue
    return;
  }
  
  if ([XMLParser parserResponseXml:result
                              type:LOAD_SERVICE_ITEM_ALBUM_PHOTO_TY
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    
    if (!_photoLoaded) {
      [self fetchImages];
      
      _photoLoaded = YES;
    } else {
       
      [self appendLatestUploadedPhoto];
      
    }
  } else {
    
    [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                           alternativeMsg:LocaleStringForKey(NSLoadPhotoFailedMsg, nil) 
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url 
          contentType:(NSInteger)contentType {
  [self stopSpin];
  
  [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                         alternativeMsg:LocaleStringForKey(NSLoadPhotoFailedMsg, nil) 
                                msgType:ERROR_TY
                     belowNavigationBar:YES];
  
  _photoLoaded = YES;
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  [self stopSpin];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  if (nil == url || url.length == 0) {
    return;
  }
  
  UIImageView *imageView = (UIImageView *)[(UIView *)(self.photoDic)[url] viewWithTag:IMAGEVIEW_TAG];
  
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  [imageView.layer addAnimation:imageFadein forKey:nil];
  imageView.image = [CommonUtils cutPartImage:image width:IMAGE_WIDTH height:IMAGE_HEIGHT]; 
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

#pragma mark - browser all photo
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_photoLoaded && _clickableElementDelegate) {
    [_clickableElementDelegate browseAlbum];
  }
}
@end
