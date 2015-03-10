//
//  ECToolbarPickerView.h
//  iAlumni
//
//  Created by Adam on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECPickerViewDelegate.h"

@interface ECToolbarPickerView : UIView {
  
  long long _currentSelectedItemId;
  
  UIPickerView *_picker;
  
  @private
  NSManagedObjectContext	*_MOC;
  
  id<ECPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> _pickerDelegate;
}

@property (nonatomic, assign) long long currentSelectedItemId;
@property (nonatomic, retain) UIPickerView *picker;

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC
           delegate:(id<ECPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>)delegate;

@end
