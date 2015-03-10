//
//  ItemNamesView.m
//  ExpatCircle
//
//  Created by Adam on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ItemNamesView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "UIUtils.h"
#import "TextConstants.h"
#import "CommonUtils.h"

@implementation ItemNamesView

- (id)initWithFrame:(CGRect)frame
             enName:(NSString *)enName
             cnName:(NSString *)cnName
               font:(UIFont *)font
{
  self = [super initWithFrame:frame];
  if (self) {
    /*
    _enNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                 textColor:BASE_INFO_COLOR
                                               shadowColor:[UIColor whiteColor]] autorelease];
    _enNameLabel.font = font;
    _enNameLabel.text = enName;
    _enNameLabel.numberOfLines = 0;
    [self addSubview:_enNameLabel];
    */
    if (cnName && cnName.length > 0) {
      _cnNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                   textColor:BASE_INFO_COLOR
                                                 shadowColor:[UIColor whiteColor]] autorelease];
      _cnNameLabel.font = font;
      _cnNameLabel.text = cnName;
      _cnNameLabel.numberOfLines = 0;
      [self addSubview:_cnNameLabel];
    }

  }
  return self;
}

- (void)arrangeNames {
  /*
  CGSize size = [_enNameLabel.text sizeWithFont:_enNameLabel.font
                             constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _enNameLabel.frame = CGRectMake(MARGIN, 
                                 MARGIN, 
                                 size.width, 
                                 size.height);
   */
  
  CGSize size = [_cnNameLabel.text sizeWithFont:_cnNameLabel.font
                      constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
  _cnNameLabel.frame = CGRectMake(MARGIN, 
                                 MARGIN/*_enNameLabel.frame.origin.y + _enNameLabel.frame.size.height*/,
                                 size.width, 
                                 size.height);

}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat pattern[2] = {2.0, 2.0};
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(MARGIN, self.frame.size.height)
                  endPoint:CGPointMake(self.frame.size.width - MARGIN, self.frame.size.height)
                  colorRef:COLOR(158.0f, 161.0f, 168.0f).CGColor
              shadowOffset:CGSizeMake(0.0f, 0.0f)
               shadowColor:TRANSPARENT_COLOR
                   pattern:pattern];
}


@end
