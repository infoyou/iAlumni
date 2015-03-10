//
//  NearbyItemAnnotationView.m
//  ExpatCircle
//
//  Created by Adam on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NearbyItemAnnotationView.h"
#import "NearbyAnnotation.h"
#import "WXWLabel.h"

#define PIN_WIDTH   32.0f
#define PIN_HEIGHT  32.0f

@implementation NearbyItemAnnotationView

- (id)initWithAnnotation:(NearbyAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.image = [UIImage imageNamed:@"itemOrangePin.png"];
    
    _label = [[WXWLabel alloc] initWithFrame:CGRectMake(-4, 3, PIN_WIDTH, 20) 
                                  textColor:[UIColor whiteColor] 
                                shadowColor:TRANSPARENT_COLOR];
    _label.font = BOLD_FONT(11);
    _label.textAlignment = UITextAlignmentCenter;
    [self addSubview:_label];

  }
  return self;
}

- (void)setSequenceNumber:(NSInteger)number {
  _label.text = INT_TO_STRING(number);
}

- (void)setPinTextColor:(UIColor *)color {
  _label.textColor = color;
}

- (void)dealloc {
  
  RELEASE_OBJ(_label);
  
  [super dealloc];
}

@end
