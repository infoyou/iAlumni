//
//  GroupDiscussionViewController.h
//  iAlumni
//
//  Created by Adam on 12-10-23.
//
//

#import "BaseListViewController.h"
#import "ECFilterListDelegate.h"
#import "ECItemUploaderDelegate.h"
#import "ECClickableElementDelegate.h"
#import "UITabView.h"
#import "ClubHeadView.h"
#import "ClubManagementDelegate.h"
#import "ECEditorDelegate.h"
#import "UPOMP.h"

@class PostToolView;
@class AllScopeGroupHeaderView;
@class Club;

@interface GroupDiscussionViewController : BaseListViewController <ECFilterListDelegate, ECItemUploaderDelegate, ECClickableElementDelegate, TabTapDelegate, ClubManagementDelegate, ECEditorDelegate, UPOMPDelegate> {
  BOOL isFirst;
  
@private
  
  id _parent;
  SEL _refreshParentAction;
  
  ClubViewType _showType;
  NSString *postListType;

  UITabView *_tabView;
  
  AllScopeGroupHeaderView *_allScopeGroupHeaderView;
  ClubHeadView *_clubHeaderView;
  
  NSString *_filterCountryId;
  NSString *_currentTagIds;
  NSString *_distanceParams;
  NSString *_filterCityId;
  NSString *_currentFiltersTitle;
  
  SortType _sortType;
  
  CGFloat _currentContentOffset_y;
  
  BOOL _autoLoadAfterSent;
  
  BOOL _tagsFetched;
  
  BOOL _returnFromComposer;
  
  BOOL _selectedFeedBeDeleted;
  
  ItemListType _listType;
  
  BOOL _filtersChanged;
  
  NSString *_targetUserId;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
            group:(Club *)group
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
           parent:(id)parent
refreshParentAction:(SEL)refreshParentAction
         listType:(ItemListType)listType
         showType:(ClubViewType)showType;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
     targetUserId:(NSString *)targetUserId;

@property (nonatomic, copy) NSString *postListType;

- (void)openProfile:(NSString*)authorId userType:(NSString*)userType;

@end
