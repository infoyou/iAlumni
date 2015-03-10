//
//  BaseFilterListViewController.h
//  iAlumni
//
//  Created by Adam on 13-7-29.
//
//

#import "BaseListViewController.h"

@class ILBarButtonItem;

@interface BaseFilterListViewController : BaseListViewController {
    
  BOOL isClickSearch;
  
  ILBarButtonItem *_searchBtn;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
needRefreshHeaderView:(BOOL)needRefreshHeaderView
needRefreshFooterView:(BOOL)needRefreshFooterView
       needGoHome:(BOOL)needGoHome;

- (void)setListData:(NSMutableArray *)searchArray paramArray:(NSMutableArray *)paramsArray;

- (void)hideFilterView:(id)sender;
- (void)recoveryMainVC;
- (void)extendFilterVC;
- (void)addFilterButton;

@end
