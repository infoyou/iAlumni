//
//  AlumniEntranceItemCell.m
//  iAlumni
//
//  Created by Adam on 13-1-17.
//
//

#import "AlumniEntranceItemCell.h"
#import "AlumniEntranceItemView.h"

#define ITEM_WIDTH 145.0f
#define ITEM_HEIGHT 100.0f

@implementation AlumniEntranceItemCell

#pragma mark - lifecycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _leftItemView = [[[AlumniEntranceItemView alloc] initWithFrame:CGRectMake(MARGIN * 2, 0, ITEM_WIDTH, ITEM_HEIGHT)] autorelease];
    [self.contentView addSubview:_leftItemView];
    
    _rightItemView = [[[AlumniEntranceItemView alloc] initWithFrame:CGRectMake(_leftItemView.frame.origin.x + _leftItemView.frame.size.width + MARGIN * 2, 0, ITEM_WIDTH, ITEM_HEIGHT)] autorelease];
    [self.contentView addSubview:_rightItemView];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - draw cell
- (void)drawLeftItem:(NSInteger)row
               image:(UIImage *)image
               title:(NSString *)title
            subTitle:(NSString *)subTitle
         numberBadge:(NSInteger)numberBadge
            entrance:(id)entrance
              action:(SEL)action
               color:(UIColor *)color {
    
  [_leftItemView setEntrance:entrance
                  withAction:action
                       color:color];
  [_leftItemView setImage:image withTitle:title withSubTitle:subTitle];
  
  [_leftItemView setNumberBadgeWithCount:numberBadge];
}

- (void)drawRightItem:(NSInteger)row
                image:(UIImage *)image
                title:(NSString *)title
             subTitle:(NSString *)subTitle
          numberBadge:(NSInteger)numberBadge
             entrance:(id)entrance
               action:(SEL)action
               color:(UIColor *)color {

  [_rightItemView setEntrance:entrance
                   withAction:action
                        color:color];
  [_rightItemView setImage:image withTitle:title withSubTitle:subTitle];
  
  [_rightItemView setNumberBadgeWithCount:numberBadge];
}

@end
