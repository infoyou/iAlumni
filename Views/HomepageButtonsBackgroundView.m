//
//  HomepageButtonsBackgroundView.m
//  iAlumni
//
//  Created by Adam on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HomepageButtonsBackgroundView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIUtils.h"

@implementation HomepageButtonsBackgroundView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];

  if (self) {
    self.backgroundColor = TRANSPARENT_COLOR;
  
  }
  return self;
}

- (void)drawRect:(CGRect)rect {   
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGPoint startPoint = CGPointMake(0, 0);
  CGPoint endPoint = CGPointMake(self.frame.size.width, 0);
  
  [UIUtils draw1PxStroke:context
              startPoint:startPoint 
                endPoint:endPoint
                   color:LIGHT_GRAY_BTN_BORDER_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
  
  startPoint = CGPointMake(HOME_PAGE_BTN_WIDTH, SEPARATOR_THICKNESS - 1);
  endPoint = CGPointMake(HOME_PAGE_BTN_WIDTH, SEPARATOR_THICKNESS + HOME_PAGE_BTN_HEIGHT);
  [UIUtils draw1PxStroke:context
              startPoint:startPoint 
                endPoint:endPoint
                   color:LIGHT_GRAY_BTN_BORDER_COLOR.CGColor
            shadowOffset:CGSizeMake(1.0f, 0.0f)
             shadowColor:[UIColor whiteColor]];
  
  startPoint = CGPointMake(HOME_PAGE_BTN_WIDTH * 2 + SEPARATOR_THICKNESS + 1, SEPARATOR_THICKNESS - 1);
  endPoint = CGPointMake(HOME_PAGE_BTN_WIDTH * 2 + SEPARATOR_THICKNESS + 1, SEPARATOR_THICKNESS + HOME_PAGE_BTN_HEIGHT);
  [UIUtils draw1PxStroke:context
              startPoint:startPoint 
                endPoint:endPoint
                   color:LIGHT_GRAY_BTN_BORDER_COLOR.CGColor
            shadowOffset:CGSizeMake(1.0f, 0.0f)
             shadowColor:[UIColor whiteColor]];
  
  
  startPoint = CGPointMake(0, SEPARATOR_THICKNESS + HOME_PAGE_BTN_HEIGHT);
  endPoint = CGPointMake(self.frame.size.width, SEPARATOR_THICKNESS + HOME_PAGE_BTN_HEIGHT);
  [UIUtils draw1PxStroke:context
              startPoint:startPoint 
                endPoint:endPoint
                   color:LIGHT_GRAY_BTN_BORDER_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
  
  startPoint = CGPointMake(HOME_PAGE_BTN_WIDTH, SEPARATOR_THICKNESS * 2 + HOME_PAGE_BTN_HEIGHT - 1);
  endPoint = CGPointMake(HOME_PAGE_BTN_WIDTH, SEPARATOR_THICKNESS + HOME_PAGE_BTN_HEIGHT * 2);
  [UIUtils draw1PxStroke:context
              startPoint:startPoint 
                endPoint:endPoint
                   color:LIGHT_GRAY_BTN_BORDER_COLOR.CGColor
            shadowOffset:CGSizeMake(1.0f, 0.0f)
             shadowColor:[UIColor whiteColor]];
  
  startPoint = CGPointMake(HOME_PAGE_BTN_WIDTH * 2 + SEPARATOR_THICKNESS + 1, SEPARATOR_THICKNESS * 2 + HOME_PAGE_BTN_HEIGHT - 1);
  endPoint = CGPointMake(HOME_PAGE_BTN_WIDTH * 2 + SEPARATOR_THICKNESS + 1, SEPARATOR_THICKNESS + HOME_PAGE_BTN_HEIGHT * 2);
  [UIUtils draw1PxStroke:context
              startPoint:startPoint 
                endPoint:endPoint
                   color:LIGHT_GRAY_BTN_BORDER_COLOR.CGColor
            shadowOffset:CGSizeMake(1.0f, 0.0f)
             shadowColor:[UIColor whiteColor]];
  /*
   startPoint = CGPointMake(0, SEPARATOR_THICKNESS * 2 + HOME_PAGE_BTN_HEIGHT * 2);
   endPoint = CGPointMake(self.frame.size.width, SEPARATOR_THICKNESS * 2 + HOME_PAGE_BTN_HEIGHT * 2);
   [UIUtils draw1PxStroke:context
   startPoint:startPoint 
   endPoint:endPoint
   color:LIGHT_GRAY_BTN_BORDER_COLOR.CGColor
   shadowOffset:CGSizeMake(0.0f, 0.0f)
   shadowColor:TRANSPARENT_COLOR];
   */
}


@end
