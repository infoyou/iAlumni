//
//  BuzzEntranceCell.h
//  iAlumni
//
//  Created by Adam on 12-10-17.
//
//

#import "ECTextBoardCell.h"
#import "GlobalConstants.h"

@class WXWLabel;
@class ECPlainButton;

@interface BuzzEntranceCell : ECTextBoardCell {
@private
  WXWLabel *_titleLabel;
  WXWLabel *_subTitleLabel;
  WXWLabel *_contentLabel;
  
  WXWLabel *_commenterNameLabel;
  WXWLabel *_locatoinLabel;
  WXWLabel *_dateLabel;
  
  SeparatorType _separatorType;
  
  CGFloat _cellHeight;
  
  ECPlainButton *_enterButton;
  
  id _eventHolder;
  SEL _enterDiscussAction;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
        eventHolder:(id)eventHolder
 enterDiscussAction:(SEL)enterDiscussAction;

- (void)drawCell:(NSString *)title
        subTitle:(NSString *)subTitle
        location:(NSString *)location
         comment:(NSString *)comment
   commenterName:(NSString *)commenterName
            date:(NSString *)date
      cellHeight:(CGFloat)cellHeight;

- (void)drawNOShadowCell:(NSString *)title
                subTitle:(NSString *)subTitle
                location:(NSString *)location
                 comment:(NSString *)comment
           commenterName:(NSString *)commenterName
                    date:(NSString *)date
              cellHeight:(CGFloat)cellHeight
           separatorType:(SeparatorType)separatorType;

@end
