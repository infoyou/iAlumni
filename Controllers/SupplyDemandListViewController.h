//
//  SupplyDemandListViewController.h
//  iAlumni
//
//  Created by Adam on 13-5-22.
//
//

#import "BaseListViewController.h"
#import "ECItemUploaderDelegate.h"

@interface SupplyDemandListViewController : BaseListViewController <UISearchBarDelegate, ECItemUploaderDelegate, UITextFieldDelegate> {
  
  @private
  UISearchBar *_searchBar;
  
  UIView *_bottomToolbar;
  
  NSInteger _filterType;
  
  BOOL _autoLoadAfterSent;
  
  CGFloat _currentContentOffset_y;
  
  UITextField *_searchTextField;
  
  BOOL _clearButtonClicked;
  
  BOOL _selectedFeedBeDeleted;
  
  BOOL _returnFromComposer;
  
  BOOL _needRefresh;
  
  BOOL _forFavorited;
  
  BOOL _needAdjustForiOS7;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC needAdjustForiOS7:(BOOL)needAdjustForiOS7;

- (id)initFavoritedItemsWithMOC:(NSManagedObjectContext *)MOC needAdjustForiOS7:(BOOL)needAdjustForiOS7;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
needAdjustForiOS7:(BOOL)needAdjustForiOS7 parentVC:(UIViewController *)parentVC;

- (void)doSendSupplyDemand;

@end
