//
//  SupplyDemandItemViewController.h
//  iAlumni
//
//  Created by Adam on 13-6-4.
//
//

#import "BaseListViewController.h"
#import "JSCoreTextView.h"
#import "ECClickableElementDelegate.h"
#import "WXApi.h"
#import "TagListView.h"

@class Post;
@class SupplyDemandItemToolbar;

@interface SupplyDemandItemViewController : BaseListViewController <TagSelectionDelegate,JSCoreTextViewDelegate, ECClickableElementDelegate, WXApiDelegate, UIActionSheetDelegate> {
  
  @private
  SupplyDemandItemToolbar *_toolbar;
  
  id _target;
  SEL _triggerRefreshAction;
}

- (id)initMOC:(NSManagedObjectContext *)MOC
         item:(Post *)item
       target:(id)target
triggerRrefreshAction:(SEL)triggerRrefreshAction;

@end
