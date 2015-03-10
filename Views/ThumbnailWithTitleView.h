//
//  ThumbnailWithTitleView.h
//  iAlumni
//
//  Created by Adam on 13-1-10.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;
@class Event;

@interface ThumbnailWithTitleView : UIImageView {
  @private
  UIView *_titleBackgroundView;
  
  WXWLabel *_titleLabel;
  
  WXWLabel *_subTitleLabel;
  
  NSInteger _titlePosition;
}

- (id)initNeedBottomTitleWithFrame:(CGRect)frame;

- (id)initNeedLeftTitleWithFrame:(CGRect)frame;

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle;

- (void)setThumbnail:(UIImage *)thumbnail animated:(BOOL)animated;

- (void)setLeftTitle:(NSString *)title limitedWidth:(CGFloat)limitedWidth;

@end
