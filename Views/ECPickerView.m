//
//  ECPickerView.m
//  iAlumni
//
//  Created by Adam on 11-11-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECPickerView.h"
#import "CommonUtils.h"
#import "TextConstants.h"

#define PICKERVIEW_LANDSCAPE_Y	10.0f
#define PICKERVIEW_PORTRAIT_Y	130.0f
#define PICKERVIEW_HEIGHT		286.0f

#define PICKER_LANDSCAPE_Y		42.0f
#define PICKER_PORTRAIT_Y		70.0f
#define PICKER_HEIGHT			216.0f

#define TOOLBAR_LANDSCAPE_Y		-3.0f
#define TOOLBAR_PORTRAIT_Y		25.0f

@implementation ECPickerView

@synthesize picker = _picker;
@synthesize userHasScrolled = _userHasScrolled;
@synthesize currentSelectedItemId = _currentSelectedItemId;

#pragma mark - lifecycle methods

- (void)initToolbar:(CGRect)frame {
  
  _toolBar = [[UIToolbar alloc] initWithFrame:frame];
  
  _toolBar.barStyle = UIBarStyleBlack;
  
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
  [_toolBar setItems:items];
  [_pickerView addSubview:_toolBar];

}

- (void)initPickerView:(CGRect)frame pickerFrame:(CGRect)pickerFrame {
  _pickerView = [[UIView alloc] initWithFrame:frame];
  
  self.picker = [[[UIPickerView alloc] initWithFrame:pickerFrame] autorelease];
  self.picker.delegate = _delegate;
  self.picker.dataSource = _delegate;
  self.picker.showsSelectionIndicator = YES;
  
  [_pickerView addSubview:self.picker];
  
  [self addSubview:_pickerView];
}

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC
           delegate:(id<ECPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>)delegate
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _MOC = MOC;
    
    _delegate = delegate;
    
    CGRect pickerFrame;
		CGRect pickerViewFrame;
		CGRect toolBarFrame;
		if ([CommonUtils currentOrientationIsLandscape]) {
			pickerFrame = CGRectMake(0, PICKER_LANDSCAPE_Y, frame.size.width, PICKER_HEIGHT);
			pickerViewFrame = CGRectMake(0, PICKERVIEW_LANDSCAPE_Y, frame.size.width, PICKERVIEW_HEIGHT);
			toolBarFrame = CGRectMake(0, TOOLBAR_LANDSCAPE_Y, frame.size.width, TOOLBAR_HEIGHT);
		} else {
			pickerFrame = CGRectMake(0, PICKER_PORTRAIT_Y, frame.size.width, PICKER_HEIGHT);
			pickerViewFrame = CGRectMake(0, PICKERVIEW_PORTRAIT_Y, frame.size.width, PICKERVIEW_HEIGHT);		
			toolBarFrame = CGRectMake(0, TOOLBAR_PORTRAIT_Y, frame.size.width, TOOLBAR_HEIGHT);
		}
    
    [self initPickerView:pickerViewFrame pickerFrame:pickerFrame];
    
    [self initToolbar:toolBarFrame];
    
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_pickerView);
  RELEASE_OBJ(_toolBar);
  
  [super dealloc];
}

#pragma mark - layout sub views
- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.frame = CGRectMake(0, 0, 320, 480);
  self.picker.frame = CGRectMake(0, PICKER_PORTRAIT_Y, self.frame.size.width, PICKER_HEIGHT);
  _pickerView.frame = CGRectMake(0, PICKERVIEW_PORTRAIT_Y, self.frame.size.width, PICKERVIEW_HEIGHT);		
  _toolBar.frame = CGRectMake(0, TOOLBAR_PORTRAIT_Y, self.frame.size.width, TOOLBAR_HEIGHT);
}

#pragma mark - user action

- (void)autoScroll {
  if (_delegate) {
    [_delegate autoScroll];
  }
}

- (void)slideDownDidStop {
	[self removeFromSuperview];
}

- (void)animatePicker:(BOOL)show {
	CGRect screenRect = self.frame;
	CGSize pickerViewSize = [_pickerView sizeThatFits:CGSizeZero];
	CGRect startRect = CGRectMake(0.0, 
                                screenRect.origin.y + screenRect.size.height, 
                                pickerViewSize.width, pickerViewSize.height);
	
	CGRect pickerViewRect = CGRectMake(0.0,                                      
                                     _pickerView.frame.origin.y,
                                     pickerViewSize.width, 
                                     pickerViewSize.height);
  
	self.backgroundColor = COLOR_ALPHA(64, 64, 64, 0.7f - (int)show * 0.7f);
	
	if (show) {
		_pickerView.frame = pickerViewRect;
		[_delegate addSubViewToWindow:self];
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationDelegate:self];
	
	self.backgroundColor = COLOR_ALPHA(64, 64, 64, 0.0f + (int)show * 0.7f);
	
	if (show) {
		_pickerView.frame = pickerViewRect;
	} else {
		_pickerView.frame = startRect;
		[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	}
  
	[UIView commitAnimations];
}

- (void)cancel:(id)sender {
  
  [self animatePicker:NO];
  
  if (_delegate) {
    [_delegate pickerCancel];
  }
}

- (void)switchDone:(id)sender {
  
  [self animatePicker:NO];
  
  if (_delegate) {
    [_delegate pickerRowSelected:self.currentSelectedItemId];
  }
}

@end
