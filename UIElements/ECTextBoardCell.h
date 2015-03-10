//
//  ECTextBoardCell.h
//  ExpatCircle
//
//  Created by Adam on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXWLabel;

@interface ECTextBoardCell : UITableViewCell {
  @private
  NSMutableArray *_labelsContainer;
}

- (WXWLabel *)initLabel:(CGRect)frame 
             textColor:(UIColor *)textColor 
           shadowColor:(UIColor *)shadowColor;

@end
