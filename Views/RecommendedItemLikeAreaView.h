//
//  RecommendedItemLikeAreaView.h
//  ExpatCircle
//
//  Created by Adam on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "WXWImageDisplayerDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "WXWConnectorDelegate.h"
#import "WXWConnectorConsumerView.h"

@class ServiceItemLikerAlbumView;
@class WXWLabel;
@class RecommendedItem;

@interface RecommendedItemLikeAreaView : WXWConnectorConsumerView {
  
  ServiceItemLikerAlbumView *_likerAlbumView;
  UIActivityIndicatorView *_likeSpinView;
  UIButton *_likeButton;
  WXWLabel *_likeCountLabel;
  
  @private
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  CGFloat _likeAreaYCoordinate;
  RecommendedItem *_item;
  
  NSManagedObjectContext *_MOC;
  
  NSString *_hashedLikedItemId;
}

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC
               item:(RecommendedItem *)item
  hashedLikedItemId:(NSString *)hashedLikedItemId
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate;

@end
