//
//  BizGroupCell.h
//  iAlumni
//
//  Created by Adam on 12-12-9.
//
//

#import "ECTextBoardCell.h"
#import "GlobalConstants.h"

@class Club;

@interface BizGroupCell : ECTextBoardCell {
@private
  WXWLabel *_groupNameLabel;
  
  WXWLabel *_authorLabel;
  WXWLabel *_contentLabel;
  WXWLabel *_dateTimeLabel;
}

- (void)drawCell:(Club *)group;

@end
