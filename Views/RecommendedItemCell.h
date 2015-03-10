//
//  RecommendedItemCell.h
//  ExpatCircle
//
//  Created by Adam on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@interface RecommendedItemCell : ECImageConsumerCell {
  
@private
  
  NSMutableDictionary *_itemDic;
  
  NSMutableDictionary *_itemThumbnailViewContainer;
  
  NSArray *_items;
  
  id _itemListHolder;
  SEL _openDetailAction;

}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
     itemListHolder:(id)itemListHolder 
   openDetailAction:(SEL)openDetailAction;

- (void)drawRecommendItemCell:(NSArray *)items;

@end
