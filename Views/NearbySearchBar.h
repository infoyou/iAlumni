//
//  NearbySearchBar.h
//  ExpatCircle
//
//  Created by Adam on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"

@class WXWLabel;
@class ECSearchBar;

@interface NearbySearchBar : WXWGradientView {
  @private
  WXWLabel *_searchResultLabel;
  UIToolbar *_searchToolbar;

  id<ECFilterListDelegate> _filterListDelegate;
  
}

@property (nonatomic, retain) WXWLabel *searchResultLabel;

- (id)initWithFrame:(CGRect)frame 
           topColor:(UIColor *)topColor 
        bottomColor:(UIColor *)bottomColor 
 filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate;

- (void)needHideToolbar:(BOOL)hide;

@end
