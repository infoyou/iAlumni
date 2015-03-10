//
//  GroupInfoCell.h
//  iAlumni
//
//  Created by Adam on 12-10-5.
//
//

#import "ECTextBoardCell.h"
#import "GlobalConstants.h"

@class CoreTextView;
@class WXWLabel;
@class Club;

@interface GroupInfoCell : ECTextBoardCell {
  @private
  WXWLabel *_groupNameLabel;
  CoreTextView *_postContentView;
  CoreTextView *_baseInfoView;
  
  WXWLabel *_dateTimeLabel;
  
  UIImageView *_badgeImageView;
  WXWLabel *_badgeNumLabel;
  
  Club *_club;
}

- (void)drawCell:(Club *)club;

@end
