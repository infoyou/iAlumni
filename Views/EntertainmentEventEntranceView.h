//
//  EntertainmentEventEntranceView.h
//  iAlumni
//
//  Created by Adam on 13-1-16.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;
@class WXWNumberBadge;

@interface EntertainmentEventEntranceView : UIView {
@private
  
  id _entrance;
  
  SEL _action;
  
  UIImageView *_imageView;
  
  WXWLabel *_titleLabel;
  
  WXWNumberBadge *_numberBadge; 
}

- (id)initWithFrame:(CGRect)frame
          entrancce:(id)entrance
             action:(SEL)action;

#pragma mark - set number badge
- (void)setNumberBadgeWithCount:(NSInteger)count;

@end
