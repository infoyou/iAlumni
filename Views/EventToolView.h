//
//  EventToolView.h
//  iAlumni
//
//  Created by Adam on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"
#import "ECClickableElementDelegate.h"

@class ECGradientButton;
@class WXWLabel;

@interface EventToolView : WXWGradientView {
    
@private
    ECGradientButton *_distanceButton;
    ECGradientButton *_timeButton;
    WXWLabel *_distanceLabel;
    WXWLabel *_timeLabel;
    ECGradientButton *_sortButton;
    WXWLabel *_sortLabel;
    
    id<ECFilterListDelegate> _delegate;
}

- (id)initWithFrame:(CGRect)frame
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
           delegate:(id<ECFilterListDelegate>)delegate
            tabSize:(int)tabSize;

#pragma mark - biz methods
- (void)setBackValue:(NSString *)distance time:(NSString *)time sort:(NSString *)sort;

@end
