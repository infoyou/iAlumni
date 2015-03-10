//
//  ServiceItemListHeaderView.h
//  ExpatCircle
//
//  Created by Adam on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"

@class NearbySearchBar;
@class TipsEntranceView;

@interface ServiceItemListHeaderView : UIView {
  
  TipsEntranceView *_tipsView;
  
  NearbySearchBar *_toolbar;
}

@property (nonatomic, retain) TipsEntranceView *tipsView;
@property (nonatomic, retain) NearbySearchBar *toolbar;

- (id)initWithFrame:(CGRect)frame
 filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate;

@end
