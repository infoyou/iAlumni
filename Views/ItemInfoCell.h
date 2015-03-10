//
//  ItemInfoCell.h
//  ExpatCircle
//
//  Created by Adam on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECTextBoardCell.h"

@class ServiceProvider;
@class WXWLabel;

@interface ItemInfoCell : ECTextBoardCell {
  @private
  WXWLabel *_label;
}

- (void)drawInfoCell:(ServiceProvider *)sp 
            infoType:(ServiceProviderInfoType)infoType
    needBottomShadow:(BOOL)needBottomShadow;

@end
