//
//  TipsEntranceView.h
//  ExpatCircle
//
//  Created by Adam on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"

@class WXWLabel;

@interface TipsEntranceView : WXWGradientView {
@private
  id<ECFilterListDelegate> _filterListDelegate;
  
  WXWLabel *_tipsTitleLabel;
  
  WXWLabel *_firstTipsTitleLabel;
  
  UIToolbar *_tipsToolbar;
}

@property (nonatomic, retain) WXWLabel *firstTipsTitleLabel;
@property (nonatomic, retain) WXWLabel *tipsTitleLabel;

- (id)initWithFrame:(CGRect)frame 
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
 filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate;

- (void)setTipsTitleLabelText:(NSString *)title;

@end
