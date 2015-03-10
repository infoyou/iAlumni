//
//  MyEventEntranceView.h
//  iAlumni
//
//  Created by Adam on 13-1-16.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;

@interface MyEventEntranceView : UIView {
@private
  
  id _entrance;
  
  SEL _action;
  
  UIImageView *_imageView;
  
  WXWLabel *_mainTitleLabel;
  WXWLabel *_sub1TitleLabel;
}

- (id)initWithFrame:(CGRect)frame
          entrancce:(id)entrance
             action:(SEL)action;


@end
