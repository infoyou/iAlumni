//
//  ClubGroupCell.h
//  iAlumni
//
//  Created by Adam on 13-1-28.
//
//

#import <UIKit/UIKit.h>

@class ClubGroupItemView;
@class Club;

@interface ClubGroupCell : UITableViewCell {
@private
  ClubGroupItemView *_leftItemView;
  ClubGroupItemView *_rightItemView;

}

- (void)drawLeftItem:(NSInteger)row
               group:(Club *)group
            entrance:(id)entrance
              action:(SEL)action;

- (void)hideLeftItem;

- (void)drawRightItem:(NSInteger)row
                group:(Club *)group
             entrance:(id)entrance
               action:(SEL)action;

- (void)hideRightItem;

@end
