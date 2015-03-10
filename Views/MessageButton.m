//
//  MessageButton.m
//  iAlumni
//
//  Created by Adam on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageButton.h"
#import "Messages.h"

@implementation MessageButton

@synthesize message = _message;

- (id)initWithFrame:(CGRect)frame
             target:(id)target 
             action:(SEL)action 
          colorType:(ButtonColorType)colorType 
              title:(NSString *)title
              image:(UIImage *)image 
         titleColor:(UIColor *)titleColor
   titleShadowColor:(UIColor *)titleShadowColor 
          titleFont:(UIFont *)titleFont
        roundedType:(ButtonRoundedType)roundedType 
    imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert
    titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert {
  
  self = [super initWithFrame:frame
                       target:target
                       action:action 
                    colorType:colorType 
                        title:title 
                        image:image 
                   titleColor:titleColor 
             titleShadowColor:titleShadowColor
                    titleFont:titleFont 
                  roundedType:roundedType
              imageEdgeInsert:imageEdgeInsert
              titleEdgeInsert:titleEdgeInsert];
  
  if (self) {

  }
  return self;
}

- (void)dealloc {
  self.message = nil;
  
  [super dealloc];
  
}

@end
