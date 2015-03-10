//
//  TopicOptionCell.m
//  iAlumni
//
//  Created by Adam on 12-9-10.
//
//

#import "TopicOptionCell.h"
#import "OptionView.h"
#import "Option.h"

#define EVEN_LEFT_COLOR   COLOR(160,179,35)
#define EVEN_RIGHT_COLOR  COLOR(180,46,107)
#define ODD_LEFT_COLOR    COLOR(45,117,179)
#define ODD_RIGHT_COLOR   COLOR(146,57,179)

#define OPTION_VIEW_WIDTH     145.0f

@implementation TopicOptionCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
                MOC:(NSManagedObjectContext *)MOC
           delegate:(id<EventVoteDelegate>)delegate
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    _leftOptionView = [[[OptionView alloc] initWithFrame:CGRectZero
                                                     MOC:MOC
                                                delegate:delegate] autorelease];
    [self.contentView addSubview:_leftOptionView];
    
    _rightOptionView = [[[OptionView alloc] initWithFrame:CGRectZero
                                                      MOC:MOC
                                                 delegate:delegate] autorelease];
    [self.contentView addSubview:_rightOptionView];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)drawCellWithLeftOption:(Option *)leftOption
                   rightOption:(Option *)rightOption
                     cellIndex:(NSInteger)cellIndex
                        height:(CGFloat)height {
  
  UIColor *leftColor = nil;
  UIColor *rightColor = nil;
  if (cellIndex % 2 != 0) {
    leftColor = EVEN_LEFT_COLOR;
    rightColor = EVEN_RIGHT_COLOR;
  } else {
    leftColor = ODD_LEFT_COLOR;
    rightColor = ODD_RIGHT_COLOR;
  }
  
  if (leftOption) {
    _leftOptionView.hidden = NO;
    [_leftOptionView drawViewWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2,
                                                  OPTION_VIEW_WIDTH, height - MARGIN * 4)
                                option:leftOption
                                 color:leftColor];
  } else {
    _leftOptionView.hidden = YES;
  }
  
  if (rightOption) {
    _rightOptionView.hidden = NO;

    [_rightOptionView drawViewWithFrame:CGRectMake(_leftOptionView.frame.origin.x + OPTION_VIEW_WIDTH + MARGIN * 2, MARGIN * 2, OPTION_VIEW_WIDTH, height - MARGIN * 4)
                                 option:rightOption
                                  color:rightColor];
  } else {
    _rightOptionView.hidden = YES;
  }
}

@end
