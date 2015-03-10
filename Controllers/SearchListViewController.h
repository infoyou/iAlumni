//
//  SearchListViewController.h
//  ExpatCircle
//
//  Created by Adam on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "ECFilterListDelegate.h"

@interface SearchListViewController : BaseListViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
  @private
  UISearchDisplayController *_itemSearchDisplayController;
  
  id<ECFilterListDelegate> _filterListDelegate;
  
  NSString *_keywords;
  
  BOOL _beginSearch;

  NSMutableArray *_recentSearchKeywords;
  
  UISearchBar *_searchBar;
}

- (id)initNoSwipeBackWithMOC:(NSManagedObjectContext *)MOC 
                      holder:(id)holder 
            backToHomeAction:(SEL)backToHomeAction

          filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate;

@end
