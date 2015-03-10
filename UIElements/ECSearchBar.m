//
//  ECSearchBar.m
//  ExpatCircle
//
//  Created by Adam on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECSearchBar.h"

@implementation ECSearchBar

- (void)clearBackgroundColor {
  for (UIView *subview in self.subviews) {
    if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
      [subview removeFromSuperview];
      break;
    } 
  }
}

- (void)setCancelButtonColor {
  for (UIView *subview in self.subviews) {
    if ([subview isKindOfClass:UIButton.class]) {
      UIButton *cancelButton = (UIButton *)subview;
      cancelButton.tintColor = NAVIGATION_BAR_COLOR;
      
      break;
    }
  }
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    // clear the background view
    [self clearBackgroundColor];
  }
  return self;
}

@end
