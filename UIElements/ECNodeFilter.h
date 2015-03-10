//
//  ECNodeFilter.h
//  ExpatNightlife
//
//  Created by Adam on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECNodeFilterKnob.h"

@interface ECNodeFilter : UIControl {
@private
  BOOL _allowSwipe;
  
  NSInteger _initSelectedIndex;
  
  UIColor *_unselectedTitleColor;
}

@property(nonatomic, retain) UIColor *progressColor;
@property(nonatomic, readonly) int SelectedIndex;


- (id)initWithFrame:(CGRect)frame
             Titles:(NSArray *)titles
         allowSwipe:(BOOL)allowSwipe
  initSelectedIndex:(NSInteger)initSelectedIndex
unselectedTitleColor:(UIColor *)unselectedTitleColor;

- (void) setSelectedIndex:(int)index;
- (void) setTitlesColor:(UIColor *)color;
- (void) setTitlesFont:(UIFont *)font;
- (void) setHandlerColor:(UIColor *)color;

@end
