//
//  CouponDetailViewController.h
//  ExpatCircle
//
//  Created by Adam on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class CouponItem;
@class CouponInfoHeaderView;

@interface CouponDetailViewController : BaseListViewController <ECClickableElementDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
  @private
  CouponItem *_item;
  
  CouponInfoHeaderView *_headerView;
  
  UIView *_footerView;
  
  NSInteger _actionOwnerType;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
       couponItem:(CouponItem *)couponItem;

@end
