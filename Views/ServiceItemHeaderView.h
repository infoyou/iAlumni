//
//  ServiceItemHeaderView.h
//  ExpatCircle
//
//  Created by Adam on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "WXWConnectorDelegate.h"
#import "ECClickableElementDelegate.h"
#import "WXWImageDisplayerDelegate.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "WXWConnectorConsumerView.h"

@class ServiceItem;
@class WXWLabel;
@class ECGradientButton;
@class ServiceItemLikerAlbumView;
@class ServiceItemAlbumView;
@class ItemTitleAvatarView;
@class ServiceItemCheckinAlbumView;

@interface ServiceItemHeaderView : WXWConnectorConsumerView {
  @private
  NSManagedObjectContext *_MOC;
  
  ServiceItem *_item;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  ItemTitleAvatarView *_titleAvatarView;
  CGFloat _titleAvatarViewHeight;
  
  UIView *_itemPicBackgroundView;
  UIButton *_itemPicButton;
    
  WXWLabel *_priceTitleLabel;
  WXWLabel *_priceValueLabel;
  
  WXWLabel *_tagsTitleLabel;
  WXWLabel *_tagsValueLabel;
  
  UIButton *_likeButton;
  WXWLabel *_likeCountLabel;
  
  UIButton *_checkinButton;
  
  CGFloat _likeAreaYCoordinate;
  
  UIActivityIndicatorView *_likeSpinView;
  UIActivityIndicatorView *_favoriteSpinView;  
  
  ServiceItemLikerAlbumView *_likerAlbumView;
  
  ServiceItemCheckinAlbumView *_checkinAlbumView;
  
  ServiceItemAlbumView *_itemAlbumView;
  
  UIImage *_itemPhoto;
  
  WXWLabel *_sourceLabel;
  
  // error message
  NSMutableDictionary *_errorMsgDic;

  BOOL _originalNoPhoto;
  
  NSString *_hashedServiceItemId;
}

@property (nonatomic, retain) UIView *itemPicBackgroundView;

- (id)initWithFrame:(CGRect)frame 
               item:(ServiceItem *)item
hashedServiceItemId:(NSString *)hashedServiceItemId
                MOC:(NSManagedObjectContext *)MOC 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate;

#pragma mark - album frame convertion
- (CGRect)convertedAddPhotoButtonRect;

#pragma mark - update photo wall after user add photo
- (void)updatePhotoWall;

#pragma mark - adjust scroll speed
- (void)adjustScrollSpeedWithOffset:(CGPoint)offset;
@end
