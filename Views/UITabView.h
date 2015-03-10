//
//  UITabView.h
//  iAlumni
//
//  Created by Adam on 12-8-14.
//
//

#import <UIKit/UIKit.h>

@protocol TabTapDelegate <NSObject>
- (void)tabTap:(int)selIndex;
@end

@interface UITabView : UIView {
    
    id<TabTapDelegate> _delegate;
    
    UIImage *selTabImg;
    UIImage *unSelTabImg;
    
    int    selTapIndex;
    
    UIImageView *tab0View;
    UIImageView *tab1View;
    
    UIButton *tab0But;
    UIButton *tab1But;
    
}

- (id)initWithFrame:(CGRect)frame tab0Str:(NSString*)tab0Str tab1Str:(NSString*)tab1Str delegate:(id<TabTapDelegate>)delegate;

@end
