//
//  ShakeMessageIcon.m
//  iAlumni
//
//  Created by Adam on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ShakeMessageIcon.h"
#import "UIView+ShakeAnimation.h"

@implementation ShakeMessageIcon

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.image = [UIImage imageNamed:@"message.png"];
    self.backgroundColor = TRANSPARENT_COLOR;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)shake {
  [self shakeX];
}

@end
