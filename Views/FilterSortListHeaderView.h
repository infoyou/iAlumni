//
//  FilterSortListHeaderView.h
//  ExpatCircle
//
//  Created by Adam on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECFilterListDelegate.h"

@interface FilterSortListHeaderView : UIView {

}

- (id)initWithFrame:(CGRect)frame 
             target:(id)target 
   filterSortAction:(SEL)filterSortAction
       cancelAction:(SEL)cancelAction;

@end
