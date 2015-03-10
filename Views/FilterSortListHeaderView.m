//
//  FilterSortListHeaderView.m
//  ExpatCircle
//
//  Created by Adam on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FilterSortListHeaderView.h"
#import "UIUtils.h"
#import "ECColorfulButton.h"
#import "TextConstants.h"
#import "CommonUtils.h"

#define BUTTON_WIDTH    70.0f
#define BUTTON_HEIGHT   30.0f

@implementation FilterSortListHeaderView

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame 
             target:(id)target 
   filterSortAction:(SEL)filterSortAction
       cancelAction:(SEL)cancelAction {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = CELL_COLOR;
    
    ECColorfulButton *goButton = [[[ECStandardButton alloc] initWithFrame:CGRectMake(MARGIN * 2, 
                                                                                     MARGIN, 
                                                                                     BUTTON_WIDTH, 
                                                                                     BUTTON_HEIGHT)
                                                                   target:target
                                                                   action:filterSortAction  
                                                                    title:LocaleStringForKey(NSGoTitle, nil)
                                                                tintColor:NAVIGATION_BAR_COLOR
                                                                titleFont:BOLD_FONT(14)
                                                              borderColor:nil] autorelease];
    [self addSubview:goButton];
    
    ECColorfulButton *cancelButton = [[[ECStandardButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 
                                                                                         MARGIN * 2 - BUTTON_WIDTH, 
                                                                                         MARGIN, 
                                                                                         BUTTON_WIDTH, 
                                                                                         BUTTON_HEIGHT) 
                                                                       target:target
                                                                       action:cancelAction
                                                                        title:LocaleStringForKey(NSCloseTitle, nil)
                                                                    tintColor:NAVIGATION_BAR_COLOR
                                                                    titleFont:BOLD_FONT(14)
                                                                  borderColor:nil] autorelease];
    [self addSubview:cancelButton];
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, self.bounds.size.height - 1) 
                endPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - 1)
                   color:SEPARATOR_LINE_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 0.0f) 
             shadowColor:COLOR(201, 200, 206)];
}


@end
