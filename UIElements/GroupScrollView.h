//
//  GroupScrollView.h
//  ExpatCircle
//
//  Created by Adam on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WXWImageDisplayerDelegate.h"
//#import "ECFilterListDelegate.h"
#import "GlobalConstants.h"

@class HomeGroupButton;

@interface GroupScrollView : UIView {
  @private
  UIScrollView *_groupContiner;
  
  NSManagedObjectContext *_MOC;
  
  id _switchHandler;
  SEL _switchAction;
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  
  NSMutableArray *_btns;
  
  HomeGroupButton *_lastSelectedButton;
}

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC 
      switchHandler:(id)switchHandler 
       switchAction:(SEL)switchAction 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate;

- (void)drawItemButtons;

- (void)defaultSelectDummyAll;

@end
