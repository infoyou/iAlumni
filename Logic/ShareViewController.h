//
//  ShareViewController.h
//  iAlumni
//
//  Created by Adam on 12-6-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "ECFilterListDelegate.h"
#import "ECItemUploaderDelegate.h"
#import "ECClickableElementDelegate.h"
#import "ECEditorDelegate.h"

@class PostToolView;
@interface ShareViewController : BaseListViewController <ECFilterListDelegate, ECItemUploaderDelegate, ECClickableElementDelegate, ECEditorDelegate> {
    
@private
    
    PostToolView *_toolTitleView;
    
    NSString *_filterCountryId;
    NSString *_currentTagIds;
    NSString *_distanceParams;
    NSString *_filterCityId;
    NSString *_currentFiltersTitle;
    
    NSTimeInterval _currentLatestTimeline;
    long long _currentLatestFeedId;
    NSTimeInterval _currentOldestTimeline;
    long long _currentOldestFeedId;
    
    SortType _sortType;
    
    CGFloat _currentContentOffset_y;
    
    BOOL _autoLoadAfterSent;
    
    BOOL _returnFromComposer;
    
    BOOL _selectedFeedBeDeleted;
    
    ItemListType _listType;
    
    ItemFavoriteCategory _favoriteItemType;
  
    BOOL _filtersChanged;
    
    BOOL _sortOptionsChanged;
  
    BOOL _tagsFetched;
    
    NSString *_targetUserId;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
         listType:(ItemListType)listType;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
     targetUserId:(NSString *)targetUserId;

- (void)openProfile:(NSString*)userId userType:(NSString*)userType;

@end
