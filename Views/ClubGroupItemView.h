//
//  ClubGroupItemView.h
//  iAlumni
//
//  Created by Adam on 13-1-28.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@class WXWLabel;
@class WXWNumberBadge;
@class Club;

@interface ClubGroupItemView : UIView {
@private
  
  WXWLabel *_titleLabel;
  
  id _entrance;
  
  SEL _action;
  
  WXWNumberBadge *_numberBadge;
}

- (void)setEntrance:(id)entrance
         withAction:(SEL)action
      withColorType:(AlumniEntranceItemColorType)colorType;

- (void)setGroupInfo:(Club *)group;

@end
