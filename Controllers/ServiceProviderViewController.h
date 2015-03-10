//
//  ServiceProviderViewController.h
//  ExpatCircle
//
//  Created by Adam on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "WXWImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"
#import "ECItemUploaderDelegate.h"
#import "ECPhotoPickerDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"

@class ServiceProviderProfileHeaderView;
//@class ServiceItem;
@class ECPhotoPickerOverlayViewController;
@class ServiceProvider;

@interface ServiceProviderViewController : BaseListViewController <ECClickableElementDelegate, WXWImageDisplayerDelegate, ECItemUploaderDelegate, ECPhotoPickerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, ECPhotoPickerOverlayDelegate, MFMailComposeViewControllerDelegate> {
  
  @private
  ServiceProviderProfileHeaderView *_headerView;
  
  //  ServiceItem *_item;
  
  ServiceProvider *_sp;
  
  long long _spId;
  
  ECPhotoPickerOverlayViewController *_pickerOverlayVC;
  
  NSInteger _startIndex;
  
  NSInteger _sectionCount;
  
  NSString *_hashedLikedItemId;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
             spId:(long long)spId;

@end
