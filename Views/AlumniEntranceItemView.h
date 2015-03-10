//
//  AlumniEntranceItemView.h
//  iAlumni
//
//  Created by Adam on 13-1-17.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;
@class WXWNumberBadge;

@interface AlumniEntranceItemView : UIView {
  @private
  
  UIImageView *_imageView;
  
  WXWLabel *_titleLabel;
  
  WXWLabel *_subTitleLabel;
  
  id _entrance;
  
  SEL _action;
  
  WXWNumberBadge *_numberBadge;
}

#pragma mark - set properties
- (void)setEntrance:(id)entrance
         withAction:(SEL)action
              color:(UIColor *)color;

- (void)setImage:(UIImage *)image
       withTitle:(NSString *)title
    withSubTitle:(NSString *)subTitle;

#pragma mark - set number badge
- (void)setNumberBadgeWithCount:(NSInteger)count;

@end
