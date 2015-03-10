//
//  ServiceItemToolbar.h
//  ExpatCircle
//
//  Created by Adam on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "WXWConnectorDelegate.h"
#import "WXWConnectorConsumerView.h"

@class WXWLabel;
@class ServiceItem;

@interface ServiceItemToolbar : WXWConnectorConsumerView {
  @private
  
  ServiceItem *_item;
  
  NSManagedObjectContext *_MOC;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  UIButton *_favoriteButton;
  UIButton *_shareButton;
  UIButton *_commentButton;
  UIButton *_closeButton;
  
  UIActivityIndicatorView *_favoriteSpinView;
  
  UIImageView *_moreImageView;
  
  BOOL _expanded;

}

- (id)initWithFrame:(CGRect)frame 
               item:(ServiceItem *)item
                MOC:(NSManagedObjectContext *)MOC
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate;

- (void)displayMoreImage;

- (void)collapseIfNeeded;
@end
