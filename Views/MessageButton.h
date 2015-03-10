//
//  MessageButton.h
//  iAlumni
//
//  Created by Adam on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECGradientButton.h"

@class Messages;

@interface MessageButton : ECGradientButton {

  Messages *_message;
}

@property (nonatomic, retain) Messages *message;

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
    titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert;

@end
