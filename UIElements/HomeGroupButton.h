//
//  HomeGroupButton.h
//  iAlumni
//
//  Created by Adam on 12-8-4.
//
//

#import <UIKit/UIKit.h>
#import "ECGradientButton.h"
#import "GlobalConstants.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWImageDisplayerDelegate.h"

@class HomeGroup;
@interface HomeGroupButton : UIButton <WXWImageFetcherDelegate> {
    
    HomeGroup *_itemGroup;
    
@private
    id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
    
    ButtonColorType _colorType;
    BOOL _hideBorder;
    
    NSString *_titleText;
}

@property (nonatomic, retain) HomeGroup *itemGroup;

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
          itemGroup:(HomeGroup *)itemGroup
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate;

@end
