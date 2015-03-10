//
//  CircularAvatarBackgroundView.m
//  iAlumni
//
//  Created by Adam on 12-11-13.
//
//

#import "CircularAvatarBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

#define AVATAR_BORDER_WIDTH 5.0f


@implementation CircularAvatarBackgroundView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.layer.masksToBounds = YES;
    
    CGFloat circularDiameter = self.frame.size.width;
    
    UIView *circularView = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     circularDiameter,
                                                                     circularDiameter)] autorelease];
    circularView.backgroundColor = TRANSPARENT_COLOR;
    circularView.layer.borderWidth = AVATAR_BORDER_WIDTH;
    circularView.layer.borderColor = [UIColor whiteColor].CGColor;
    circularView.layer.cornerRadius = circularDiameter/2.0f;
    circularView.layer.masksToBounds = YES;
    [self addSubview:circularView];
    
    
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
