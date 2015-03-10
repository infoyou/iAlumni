//
//  TopicOptionCell.h
//  iAlumni
//
//  Created by Adam on 12-9-10.
//
//

#import "ECTextBoardCell.h"
#import "EventVoteDelegate.h"

@class OptionView;
@class Option;

@interface TopicOptionCell : ECTextBoardCell {
  
  @private
  OptionView *_leftOptionView;
  OptionView *_rightOptionView;
  
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
                MOC:(NSManagedObjectContext *)MOC
           delegate:(id<EventVoteDelegate>)delegate;

- (void)drawCellWithLeftOption:(Option *)leftOption
                   rightOption:(Option *)rightOption
                     cellIndex:(NSInteger)cellIndex
                        height:(CGFloat)height;
@end
