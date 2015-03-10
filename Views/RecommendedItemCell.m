//
//  RecommendedItemCell.m
//  ExpatCircle
//
//  Created by Adam on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecommendedItemCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonUtils.h"
#import "RecommendedItem.h"
#import "RecommendedItemThumbnailView.h"

#define ALBUM_PHOTO_SIDE_LENGTH   100.0f

@interface RecommendedItemCell()
@property (nonatomic, retain) NSMutableDictionary *itemDic;
@property (nonatomic, retain) NSMutableDictionary *itemThumbnailViewContainer;
@property (nonatomic, retain) NSArray *items;
@end


@implementation RecommendedItemCell

@synthesize itemDic = _itemDic;
@synthesize itemThumbnailViewContainer = _itemThumbnailViewContainer;
@synthesize items = _items;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
     itemListHolder:(id)itemListHolder 
   openDetailAction:(SEL)openDetailAction {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier 
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  
  if (self) {
    
    _itemListHolder = itemListHolder;
    
    _openDetailAction = openDetailAction;
    
    self.itemDic = [NSMutableDictionary dictionaryWithCapacity:ALBUM_ROW_PHOTO_COUNT];
    self.itemThumbnailViewContainer = [NSMutableDictionary dictionaryWithCapacity:ALBUM_ROW_PHOTO_COUNT];
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    
  }
  return self;
}

- (void)dealloc {
  
  self.itemDic = nil;
  self.itemThumbnailViewContainer = nil;
  self.items = nil;
  
  [super dealloc];
}

- (void)showItemDetail:(id)sender {
  RecommendedItemThumbnailView *thumbnailView = (RecommendedItemThumbnailView *)sender;
  
  // find NSNumber object(key) in _itemThumbnailViewContainer according to button instance(object)
  NSArray *keys = [self.itemThumbnailViewContainer allKeysForObject:thumbnailView];
  if (keys && keys.count > 0) {
    NSNumber *number = (NSNumber *)[keys lastObject];
    
    RecommendedItem *clickedItem = (RecommendedItem *)(self.items)[number.intValue];
   
    if (_itemListHolder && _openDetailAction) {
      [_itemListHolder performSelector:_openDetailAction withObject:clickedItem];
    } 
    
  }
}

- (void)initThumbnailView:(RecommendedItemThumbnailView **)thumbnailView
                    index:(NSInteger)index 
                     item:(RecommendedItem *)item {
  
  CGRect frame = CGRectMake(MARGIN + index * (ALBUM_PHOTO_SIDE_LENGTH + MARGIN),
                            MARGIN, 
                            ALBUM_PHOTO_SIDE_LENGTH, 
                            ALBUM_PHOTO_SIDE_LENGTH + 35.0f);
  
  *thumbnailView = [[[RecommendedItemThumbnailView alloc] initWithFrame:frame 
                                                            recommended:item] autorelease];
  [*thumbnailView addTarget:self 
                     action:@selector(showItemDetail:)
           forControlEvents:UIControlEventTouchUpInside];

  (*thumbnailView).hidden = YES;
  [self.contentView addSubview:(*thumbnailView)];

}

- (void)drawRecommendItemCell:(NSArray *)items {
  
  self.items = items;
  
  // photoDic, key is url, object is imageViewContainer index, e.g., 0, 1, 2;
  [self.itemDic removeAllObjects];
  
  // check _itemThumbnailViewContainer whether has enough button, if no, then create it firstly, then hide it;
  // because some row maybe only has two or one photo less than three, so the third button should be hidden
  for (NSInteger i = 0; i < ALBUM_ROW_PHOTO_COUNT; i++) {
    
    if (i >= items.count) {
      break;
    }
    
    NSNumber *key = @(i);
    
    RecommendedItemThumbnailView *itemThumbnailView = (RecommendedItemThumbnailView *)(self.itemThumbnailViewContainer)[key];
    if (nil == itemThumbnailView) {
      [self initThumbnailView:&itemThumbnailView
                        index:i
                         item:items[i]];      
      (self.itemThumbnailViewContainer)[key] = itemThumbnailView;
    } 
    itemThumbnailView.hidden = YES;
  }
  
  NSMutableArray *urls = [NSMutableArray array];
  for (NSInteger i = 0; i < items.count; i++) {
    
    if (i >= ALBUM_ROW_PHOTO_COUNT) {
      break;
    }
    
    NSString *thumbnailUrl = ((RecommendedItem *)items[i]).imageUrl;
    
    if (thumbnailUrl && thumbnailUrl.length > 0) {
      [urls addObject:thumbnailUrl];
      
      // update photoDic every time, update new url for dictionary
      (self.itemDic)[thumbnailUrl] = @(i);
    }
    
    RecommendedItemThumbnailView *thumbnailView = (RecommendedItemThumbnailView *)(self.itemThumbnailViewContainer)[@(i)];
    thumbnailView.hidden = NO;
  }
  
  [self fetchImage:urls forceNew:NO];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if (url && url.length > 0) {
    
    NSNumber *index = (NSNumber *)(self.itemDic)[url];
    RecommendedItemThumbnailView *thumbnailView = (RecommendedItemThumbnailView *)(self.itemThumbnailViewContainer)[index];
      
    [thumbnailView updateImage:image];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}


@end
