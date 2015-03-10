//
//  ClubGroupCell.m
//  iAlumni
//
//  Created by Adam on 13-1-28.
//
//

#import "ClubGroupCell.h"
#import "ClubGroupItemView.h"
#import "Club.h"

#define ITEM_WIDTH 145.0f
#define ITEM_HEIGHT 100.0f

@interface ClubGroupCell()

@end

@implementation ClubGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.accessoryType = UITableViewCellAccessoryNone;

    _leftItemView = [[[ClubGroupItemView alloc] initWithFrame:CGRectMake(MARGIN * 2, 0, ITEM_WIDTH, ITEM_HEIGHT)] autorelease];
    [self.contentView addSubview:_leftItemView];
    
    _rightItemView = [[[ClubGroupItemView alloc] initWithFrame:CGRectMake(_leftItemView.frame.origin.x + _leftItemView.frame.size.width + MARGIN * 2, 0, ITEM_WIDTH, ITEM_HEIGHT)] autorelease];
    [self.contentView addSubview:_rightItemView];
  }
  return self;
}

- (void)dealloc {
    
  [super dealloc];
}

#pragma mark - draw cell
- (void)drawLeftItem:(NSInteger)row
               group:(Club *)group
            entrance:(id)entrance
              action:(SEL)action {
  
  _leftItemView.hidden = NO;
  
  AlumniEntranceItemColorType colorType = 0;
  if (row % 2 == 0) {
    colorType = YELLOW_ITEM_TY;
  } else {
    colorType = GREENT_ITEM_TY;
  }
  
  [_leftItemView setEntrance:entrance
                  withAction:action
               withColorType:colorType];
  
  [_leftItemView setGroupInfo:group];
}

- (void)hideLeftItem {
  _leftItemView.hidden = YES;
  _leftItemView.userInteractionEnabled = NO;
}

- (void)drawRightItem:(NSInteger)row
                group:(Club *)group
             entrance:(id)entrance
               action:(SEL)action {
  
  _rightItemView.hidden = NO;
  
  AlumniEntranceItemColorType colorType = 0;
  if (row % 2 == 0) {
    colorType = GREENT_ITEM_TY;
  } else {
    colorType = YELLOW_ITEM_TY;
  }
  
  [_rightItemView setEntrance:entrance
                   withAction:action
                withColorType:colorType];
  
  [_rightItemView setGroupInfo:group];
}

- (void)hideRightItem {
  _rightItemView.hidden = YES;
  _rightItemView.userInteractionEnabled = NO;
}

@end
