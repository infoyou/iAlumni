//
//  ItemLikersListViewController.h
//  iAlumni
//
//  Created by Adam on 12-8-10.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class Alumni;

@interface ItemLikersListViewController : BaseListViewController <ECClickableElementDelegate, UIActionSheetDelegate> {
  @private
  
  NSString *_hashedLikedItemId;

  long long _itemId;
  
  Alumni *_alumni;

  WebItemType _loadContentType;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
needRefreshHeaderView:(BOOL)needRefreshHeaderView
needRefreshFooterView:(BOOL)needRefreshFooterView
hashedLikedItemId:(NSString *)hashedLikedItemId;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           itemId:(long long)itemId
  loadContentType:(WebItemType)loadContentType;

@end
