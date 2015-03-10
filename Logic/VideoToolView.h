//
//  VideoToolView.h
//  iAlumni
//
//  Created by Adam on 13-1-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;

@interface VideoToolView : WXWGradientView {
    
@private
    UIButton *_typeButton;
    WXWLabel *_typeLabel;
    
    UIButton *_sortButton;
    WXWLabel *_sortLabel;
    
    id<ECFilterListDelegate> _delegate;
}

- (id)initForVideo:(CGRect)frame
          topColor:(UIColor *)topColor
       bottomColor:(UIColor *)bottomColor
          delegate:(id<ECFilterListDelegate>)delegate
  userListDelegate:(id<ECClickableElementDelegate>)userListDelegate;

#pragma mark - biz methods

- (void)setType:(NSString *)type sort:(NSString *)sort;

@end
