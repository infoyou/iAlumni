//
//  ServiceItemPhotoWall.h
//  ExpatCircle
//
//  Created by Adam on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWConnectorDelegate.h"
#import "WXWImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWConnectorConsumerView.h"

@class ServiceItem;

@interface ServiceItemPhotoWall : WXWConnectorConsumerView {
  @private
  ServiceItem *_item;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;

  NSMutableDictionary *_errorMsgDic;
  
  UIActivityIndicatorView *_spinView;
  
  NSManagedObjectContext *_MOC;
  
  NSMutableDictionary *_photoDic;
  
  NSArray *_currentPhotos;
  
  CGRect _coloredBoxRect;
  
  BOOL _photoLoaded;
  
  NSString *_currentOldestImageUrl;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
               item:(ServiceItem *)item
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate;

- (void)appendPhoto;

- (void)addArrow;

@end
