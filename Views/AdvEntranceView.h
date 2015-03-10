//
//  AdvEntranceView.h
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;

@interface AdvEntranceView : UIView {
@private
  
  NSManagedObjectContext *_MOC;
  
  id _entrance;
  
  SEL _action;
  
  UIImageView *_imageView;
  
  WXWLabel *_titleLabel;
}

- (id)initWithFrame:(CGRect)frame
          entrancce:(id)entrance
             action:(SEL)action
                MOC:(NSManagedObjectContext *)MOC;

@end
