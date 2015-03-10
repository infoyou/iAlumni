//
//  PlaceCell.h
//  ExpatCircle
//
//  Created by Adam on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECTextBoardCell.h"

@class Place;
@class WXWLabel;

@interface PlaceCell : ECTextBoardCell {
  @private
  
  //UIImageView *_iconView;
  WXWLabel *_nameLabel;
  WXWLabel *_distanceLabel;
  
}

- (void)drawPlace:(Place *)place;

@end
