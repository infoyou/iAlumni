//
//  AlbumCell.m
//  ExpatCircle
//
//  Created by Adam on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AlbumCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonUtils.h"
#import "AlbumPhoto.h"

#define ALBUM_PHOTO_SIDE_LENGTH   100.0f

@interface AlbumCell()
@property (nonatomic, retain) NSMutableDictionary *photoDic;
@property (nonatomic, retain) NSMutableDictionary *buttonContainer;
@property (nonatomic, retain) NSArray *photos;
@end

@implementation AlbumCell

@synthesize photoDic = _photoDic;
@synthesize buttonContainer = _buttonContainer;
@synthesize photos = _photos;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate 
                MOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier 
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  
  if (self) {
    _clickableElementDelegate = imageClickableDelegate;
    
    self.photoDic = [NSMutableDictionary dictionaryWithCapacity:ALBUM_ROW_PHOTO_COUNT];
    self.buttonContainer = [NSMutableDictionary dictionaryWithCapacity:ALBUM_ROW_PHOTO_COUNT];
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    
  }
  return self;
}

- (void)dealloc {
  
  self.photoDic = nil;
  self.buttonContainer = nil;
  self.photos = nil;
  
  [super dealloc];
}

- (void)showBigPhoto:(id)sender {
  UIButton *button = (UIButton *)sender;
  if (_clickableElementDelegate) {
    // find NSNumber object(key) in buttonContainer according to button instance(object)
    NSArray *keys = [self.buttonContainer allKeysForObject:button];
    if (keys && keys.count > 0) {
      NSNumber *number = (NSNumber *)[keys lastObject];
      
      // find thumbnail url(key) in photoDic according to NSNumber object(object)
      NSArray *thumbnailUrls = [self.photoDic allKeysForObject:number]; 
      if (thumbnailUrls && thumbnailUrls.count > 0) {
        NSString *thumbnailUrl = (NSString *)[thumbnailUrls lastObject];
            
        if (thumbnailUrl && thumbnailUrl.length > 0) {
          
          // find photo instance according to image url
          AlbumPhoto *clickedPhoto = nil;
          for (AlbumPhoto *photo in self.photos) {
            if ([thumbnailUrl isEqualToString:photo.imageUrl]) {
              clickedPhoto = photo;
              break;
            }
          }
          
          [_clickableElementDelegate openImageUrl:clickedPhoto.imageUrl 
                                     imageCaption:clickedPhoto.caption];
        }
      }
    }
  }
}

- (void)initButton:(UIButton **)button index:(NSInteger)index {
  *button = [UIButton buttonWithType:UIButtonTypeCustom];
  [*button addTarget:self 
              action:@selector(showBigPhoto:)
    forControlEvents:UIControlEventTouchUpInside];
  
  (*button).frame = CGRectMake(MARGIN + index * (ALBUM_PHOTO_SIDE_LENGTH + MARGIN), MARGIN, ALBUM_PHOTO_SIDE_LENGTH, ALBUM_PHOTO_SIDE_LENGTH);
  (*button).backgroundColor = [UIColor lightGrayColor];
  (*button).layer.borderColor = [UIColor whiteColor].CGColor;
  (*button).layer.borderWidth = 1.0f;
  (*button).hidden = YES;
  [self.contentView addSubview:(*button)];
}

- (void)drawAlbumCell:(NSArray *)photos {
  
  self.photos = photos;

  // photoDic, key is url, object is imageViewContainer index, e.g., 0, 1, 2;
  [self.photoDic removeAllObjects];
  
  // check buttonContainer whether has enough button, if no, then create it firstly, then hide it;
  // because some row maybe only has two or one photo less than three, so the third button should be hidden
  for (NSInteger i = 0; i < ALBUM_ROW_PHOTO_COUNT; i++) {
    NSNumber *key = @(i);
    
    UIButton *button = (UIButton *)(self.buttonContainer)[key];
    if (nil == button) {
      [self initButton:&button index:i];      
      (self.buttonContainer)[key] = button;
    } 
    [button setImage:nil forState:UIControlStateNormal];
    button.hidden = YES;
  }
  
  NSMutableArray *urls = [NSMutableArray array];
  for (NSInteger i = 0; i < photos.count; i++) {
  
    if (i >= ALBUM_ROW_PHOTO_COUNT) {
      break;
    }
    
    NSString *thumbnailUrl = ((AlbumPhoto *)photos[i]).imageUrl;
    
    [urls addObject:thumbnailUrl];
    
    // update photoDic every time, update new url for dictionary
    (self.photoDic)[thumbnailUrl] = @(i);
    
    UIButton *button = (UIButton *)(self.buttonContainer)[@(i)];
    button.hidden = NO;
  }
  
  [self fetchImage:urls forceNew:NO];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {

}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if (url && url.length > 0) {
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    
    NSNumber *index = (NSNumber *)(self.photoDic)[url];
    UIButton *button = (UIButton *)(self.buttonContainer)[index];
    [button.layer addAnimation:imageFadein forKey:nil];
    
    [button setImage:[CommonUtils cutPartImage:image
                                         width:ALBUM_PHOTO_SIDE_LENGTH 
                                        height:ALBUM_PHOTO_SIDE_LENGTH] 
            forState:UIControlStateNormal];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  NSNumber *index = (NSNumber *)(self.photoDic)[url];
  UIButton *button = (UIButton *)(self.buttonContainer)[index];
  
  [button setImage:[CommonUtils cutPartImage:image
                                       width:ALBUM_PHOTO_SIDE_LENGTH 
                                      height:ALBUM_PHOTO_SIDE_LENGTH] 
          forState:UIControlStateNormal];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}


@end
