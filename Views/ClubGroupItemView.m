//
//  ClubGroupItemView.m
//  iAlumni
//
//  Created by Adam on 13-1-28.
//
//

#import "ClubGroupItemView.h"
#import "WXWLabel.h"
#import "WXWNumberBadge.h"
#import "Club.h"

#define GREEN_COLOR   COLOR(163, 200, 37)
#define YELLOW_COLOR  COLOR(246, 195, 55)


@interface ClubGroupItemView()
@property (nonatomic, retain) Club *group;

@end

@implementation ClubGroupItemView

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {

    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:[UIColor whiteColor]
                                       shadowColor:[UIColor darkGrayColor]] autorelease];
    _titleLabel.font = BOLD_FONT(16);
    _titleLabel.numberOfLines = 0;
    [self addSubview:_titleLabel];

  }
  return self;
}

- (void)dealloc {
  
  self.group = nil;
  
  [super dealloc];
}

#pragma mark - set properties
- (void)setEntrance:(id)entrance
         withAction:(SEL)action
      withColorType:(AlumniEntranceItemColorType)colorType {
  
  _entrance = entrance;
  
  _action = action;
  
  switch (colorType) {
    case GREENT_ITEM_TY:
      self.backgroundColor = GREEN_COLOR;
      break;
      
    case YELLOW_ITEM_TY:
      self.backgroundColor = YELLOW_COLOR;
      break;
      
    default:
      break;
  }
}

- (void)setGroupInfo:(Club *)group {
  
  self.group = group;
  
  // set title
  _titleLabel.text = group.clubName;
  
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 8, self.frame.size.height - MARGIN * 4)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _titleLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                                 (self.frame.size.height - size.height)/2.0f,
                                 size.width, size.height);

  // set badge
  if (nil == _numberBadge) {
    _numberBadge = [[[WXWNumberBadge alloc] initWithFrame:CGRectMake(0,
                                                                     MARGIN * 2,
                                                                     0, NUMBER_BADGE_HEIGHT)
                                                 topColor:NUMBER_BADGE_TOP_COLOR
                                              bottomColor:NUMBER_BADGE_BOTTOM_COLOR
                                                     font:BOLD_FONT(12)] autorelease];
    [self addSubview:_numberBadge];
  }
  
  if (group.badgeNum.intValue > 0) {
    _numberBadge.hidden = NO;
    
    [_numberBadge setNumberWithTitle:group.badgeNum];
    
    _numberBadge.frame = CGRectMake(self.frame.size.width - _numberBadge.frame.size.width - MARGIN,
                                    _numberBadge.frame.origin.y,
                                    _numberBadge.frame.size.width,
                                    _numberBadge.frame.size.height);
  } else {
    _numberBadge.hidden = YES;
  }
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_entrance && _action) {
    [_entrance performSelector:_action withObject:self.group];
  }
}

@end
