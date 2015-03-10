//
//  ServiceItemListHeaderView.m
//  ExpatCircle
//
//  Created by Adam on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServiceItemListHeaderView.h"
#import "TipsEntranceView.h"
#import "NearbySearchBar.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"

#define SEARCH_BAR_HEIGHT             40.0f
#define TIPS_VIEW_HEIGHT              40.0f

@implementation ServiceItemListHeaderView

@synthesize tipsView = _tipsView;
@synthesize toolbar = _toolbar;

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
 filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    
    self.backgroundColor = CELL_COLOR;
    /*
    self.tipsView = [[[TipsEntranceView alloc] initWithFrame:CGRectMake(0, 0, 
                                                                        self.frame.size.width, 
                                                                        self.frame.size.height/2.0f)
                                                    topColor:COLOR(162, 162, 169)
                                                 bottomColor:COLOR(202, 202, 207) 
                                          filterListDelegate:filterListDelegate] autorelease];
    [self addSubview:self.tipsView];
     */
    
    self.toolbar = [[[NearbySearchBar alloc] initWithFrame:CGRectMake(0, 
                                                                  /*_tipsView.frame.size.height*/0,
                                                                  self.frame.size.width, 
                                                                  /*self.frame.size.height/2.0f*/self.frame.size.height)
                                                  topColor:COLOR(162, 162, 169)//COLOR(185, 52, 52)
                                               bottomColor:COLOR(202, 202, 207)//COLOR(155, 0, 0)
                                        filterListDelegate:filterListDelegate] autorelease];    
    [self addSubview:self.toolbar];
  }
  return self;
}

- (void)dealloc {
  
  self.tipsView = nil;
  self.toolbar = nil;
  
  [super dealloc];
}

@end
