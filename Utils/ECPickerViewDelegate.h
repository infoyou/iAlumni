//
//  ECPickerViewDelegate.h
//  iAlumni
//
//  Created by Adam on 11-11-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ECPickerViewDelegate <NSObject>

@optional
- (void)addSubViewToWindow:(UIView *)addedView;
- (void)pickerRowSelected:(long long)selectedItemId;
- (void)pickerCancel;
- (void)autoScroll;

@end
