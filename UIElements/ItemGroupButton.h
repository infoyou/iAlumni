//
//  ItemGroupButton.h
//  ExpatCircle
//
//  Created by Adam on 11-12-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECGradientButton.h"
#import "GlobalConstants.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWImageDisplayerDelegate.h"

@class ItemGroup;

@interface ItemGroupButton : UIButton <WXWImageFetcherDelegate> {

  ItemGroup *_itemGroup;
    
@private
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  
  ButtonColorType _colorType;
  BOOL _hideBorder;
  
  NSString *_titleText;
}

@property (nonatomic, retain) ItemGroup *itemGroup;

- (id)initWithFrame:(CGRect)frame 
             target:(id)target
             action:(SEL)action 
          colorType:(ButtonColorType)colorType
              title:(NSString *)title 
         titleColor:(UIColor *)titleColor
   titleShadowColor:(UIColor *)titleShadowColor
          titleFont:(UIFont *)titleFont 
    imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert
    titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert
          itemGroup:(ItemGroup *)itemGroup
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate;

@end
