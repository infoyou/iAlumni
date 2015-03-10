//
//  AlumniEntranceItemCell.h
//  iAlumni
//
//  Created by Adam on 13-1-17.
//
//

#import <UIKit/UIKit.h>

@class AlumniEntranceItemView;

@interface AlumniEntranceItemCell : UITableViewCell {
  @private
  AlumniEntranceItemView *_leftItemView;
  AlumniEntranceItemView *_rightItemView;
}

- (void)drawLeftItem:(NSInteger)row
               image:(UIImage *)image
               title:(NSString *)title
            subTitle:(NSString *)subTitle
         numberBadge:(NSInteger)numberBadge
            entrance:(id)entrance
              action:(SEL)action
               color:(UIColor *)color;

- (void)drawRightItem:(NSInteger)row
                image:(UIImage *)image
                title:(NSString *)title
             subTitle:(NSString *)subTitle
          numberBadge:(NSInteger)numberBadge
             entrance:(id)entrance
               action:(SEL)action
                color:(UIColor *)color;

@end
