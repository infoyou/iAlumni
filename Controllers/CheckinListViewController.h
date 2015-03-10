//
//  CheckinListViewController.h
//  iAlumni
//
//  Created by Adam on 12-8-18.
//
//

#import "BaseListViewController.h"
#import "ECClickableElementDelegate.h"

@class ServiceItem;
@class Alumni;

@interface CheckinListViewController : BaseListViewController <ECClickableElementDelegate, UIActionSheetDelegate> {
  
  @private
  ServiceItem *_item;
  
  NSString *_hashedServiceItemId;
  
  Alumni *_alumni;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
             item:(ServiceItem *)item
hashedServiceItemId:(NSString *)hashedServiceItemId;

@end
