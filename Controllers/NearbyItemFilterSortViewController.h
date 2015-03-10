//
//  NearbyItemFilterSortViewController.h
//  ExpatCircle
//
//  Created by Adam on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"

@class FilterSortListHeaderView;
@class ItemListSectionView;

@interface NearbyItemFilterSortViewController : BaseListViewController {
@private
  ServiceItemSortType _sortType;
  NearbyDistanceFilter _filterType;
  
  NearbyItemType _itemType;
  
  NSString *_originalSortOptionValue;
  
  NSMutableDictionary *_originalFilterOptions;
  
  NSArray *_sortOptions;
  
  id<ECFilterListDelegate> _filterListDelegate;
  
  //FilterSortListHeaderView *_listHeaderView;
  UIView *_filterTitleView;
  UIView *_sortTitleView;
  
  ItemListSectionView *_filterSectionView;
  ItemListSectionView *_sortSectionView;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
       filterType:(NearbyDistanceFilter)filterType
         sortType:(ServiceItemSortType)sortType
         itemType:(NearbyItemType)itemType
filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate;

@end
