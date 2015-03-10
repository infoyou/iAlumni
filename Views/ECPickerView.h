//
//  ECPickerView.h
//  iAlumni
//
//  Created by Adam on 11-11-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECPickerViewDelegate.h"
#import "GlobalConstants.h"

@interface ECPickerView : UIView {
  @private
  id<ECPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> _delegate;
	UIView					*_pickerView;
	UIPickerView		*_picker;
	UIToolbar				*_toolBar;
	
	BOOL					_userHasScrolled;
  
	NSManagedObjectContext	*_MOC;
  
  long long _currentSelectedItemId;
}

@property (nonatomic, assign) long long currentSelectedItemId;
@property (nonatomic, retain) UIPickerView *picker;
@property (nonatomic, assign) BOOL userHasScrolled;

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC
           delegate:(id<ECPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>)delegate;

- (void)animatePicker:(BOOL)show;
- (void)autoScroll;

@end
