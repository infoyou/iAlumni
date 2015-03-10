//
//  ItemNamesView.h
//  ExpatCircle
//
//  Created by Adam on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@class WXWLabel;

@interface ItemNamesView : UIView {
  @private
  WXWLabel *_cnNameLabel;
}

- (id)initWithFrame:(CGRect)frame 
             enName:(NSString *)enName
             cnName:(NSString *)cnName
               font:(UIFont *)font;

- (void)arrangeNames;

@end
