//
//  ServiceItemAlbumView.h
//  ExpatCircle
//
//  Created by Adam on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"

@class ServiceItem;
@class ServiceItemPhotoWall;
@class ECGradientButton;

@interface ServiceItemAlbumView : UIView {
  @private
  ServiceItem *_item;
  
  NSManagedObjectContext *_MOC;
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  id<WXWConnectionTriggerHolderDelegate> _connectionTriggerHolderDelegate;

  ServiceItemPhotoWall *_photoWall;
  
  ECGradientButton *_addPhotoButton;
  
  CGFloat _wall_y;
}

@property (nonatomic, retain) ECGradientButton *addPhotoButton;

- (id)initWithFrame:(CGRect)frame 
               item:(ServiceItem *)item
                MOC:(NSManagedObjectContext *)MOC
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate;

#pragma mark - append photo
- (void)appendPhoto;

- (void)addPhotoWall;

- (void)enlargePhotoWall;

#pragma mark - add arrow
- (void)addArrow;
@end
