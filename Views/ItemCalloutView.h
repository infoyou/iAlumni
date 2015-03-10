//
//  ItemCalloutView.h
//  ExpatCircle
//
//  Created by Adam on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@class WXWLabel;
@class Store;

@interface ItemCalloutView : UIView {
 
@private
  
  UIButton *_button;
  WXWLabel *_nameLabel;
   
  id _target;
  SEL _showDetailAction;
}

- (id)initWithFrame:(CGRect)frame
              store:(Store *)store
         sequenceNO:(NSInteger)sequeneNO 
             target:(id)target 
   showDetailAction:(SEL)showDetailAction;
@end
