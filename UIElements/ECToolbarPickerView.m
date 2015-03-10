//
//  ECToolbarPickerView.m
//  iAlumni
//
//  Created by Adam on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECToolbarPickerView.h"

@implementation ECToolbarPickerView 

@synthesize currentSelectedItemId = _currentSelectedItemId;
@synthesize picker = _picker;

#pragma mark - user action
- (void)cancel:(id)sender {
  
  if (_pickerDelegate) {
    [_pickerDelegate pickerCancel];
  }
}

- (void)switchDone:(id)sender {
  
  if (_pickerDelegate) {
    [_pickerDelegate pickerRowSelected:_currentSelectedItemId];
  }
}

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC
           delegate:(id<ECPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>)delegate {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    _MOC = MOC;
    
    _pickerDelegate = delegate;
    
    UIToolbar *toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, TOOLBAR_HEIGHT)] autorelease];
    
    toolBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *cancelBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self 
                                                                                action:@selector(cancel:)] autorelease];
    
    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil] autorelease];
    
    UIBarButtonItem *switchDoneBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                    target:self 
                                                                                    action:@selector(switchDone:)] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:cancelBtn, space, switchDoneBtn, nil] autorelease];
    [toolBar setItems:items];
    [self addSubview:toolBar];
  
    self.picker = [[[UIPickerView alloc] initWithFrame:CGRectMake(0, toolBar.frame.origin.y + toolBar.frame.size.height, self.bounds.size.width, self.bounds.size.height - TOOLBAR_HEIGHT)] autorelease];
    self.picker.delegate = _pickerDelegate;
    self.picker.dataSource = _pickerDelegate;
    self.picker.showsSelectionIndicator = YES;
    [self addSubview:self.picker];
  }
  
  return self;
}

- (void)dealloc {
  
  self.picker = nil;
  
  [super dealloc];
}

@end
