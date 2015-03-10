//
//  EventListViewController.h
//  iAlumni
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "EventListCell.h"
#import "ECClickableElementDelegate.h"
#import "ECFilterListDelegate.h"
#import "PanMoveProtocol.h"
#import "PlainTabView.h"

@class ILBarButtonItem;


@interface EventListViewController : BaseListViewController <TapSwitchDelegate, ECFilterListDelegate, ECClickableElementDelegate> {
    
@private
  BOOL _isPop;
  
  PlainTabView *_tabSwitchView;
  
  EventGroupTabIndex _tabType;
  
  CGRect _originalTableViewFrame;
  
  BOOL _keepEventsInMOC;
    
  ILBarButtonItem *_searchBtn;
  
  BOOL _showingFilter;
  
  UIButton *_btn;
  
  BOOL _scrolling;
  
  BOOL _onlyMine;
  
  BOOL _needRefresh;
}

@property (nonatomic, assign) id<PanMoveProtocol> delegate;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(WXWRootViewController *)parentVC
         tabIndex:(EventGroupTabIndex)tabIndex;

#pragma mark - handle vc
- (void)setViewMoveWayType:(ScrollMoveWayType)tag;
- (void)setShowingFilter:(BOOL)flag;
- (void)extendFilterVC;
- (void)recoveryMainVC;
- (void)disableTableScroll;
- (void)enableTableScroll;
- (BOOL)tableScrolling;

#pragma mark - open shared event
- (void)openSharedEventById:(long long)eventId;

@end
