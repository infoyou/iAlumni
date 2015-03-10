//
//  SelectablePeopleCell.h
//  iAlumni
//
//  Created by Adam on 12-12-4.
//
//

#import "PeopleCell.h"
#import "GlobalConstants.h"

@class NameCard;

@interface SelectablePeopleCell : PeopleCell {
  @private
  
  UIImageView *_selectIcon;
}
- (void)drawCell:(NameCard *)nameCard;

@end
