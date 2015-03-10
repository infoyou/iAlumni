//
//  PeopleWithChatCell.h
//  iAlumni
//
//  Created by Adam on 12-12-4.
//
//

#import "PeopleCell.h"
#import "GlobalConstants.h"

@class Alumni;

@interface PeopleWithChatCell : PeopleCell {

  UIImageView *_chatImgView;
  
@private

  UIButton *_chatImgBut;

}

#pragma mark - draw cell
- (void)drawCell:(Alumni*)alumni;

@end
