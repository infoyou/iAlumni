//
//  SortOptionCell.m
//  ExpatCircle
//
//  Created by Adam on 11-11-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SortOptionCell.h"
#import "WXWLabel.h"
#import "SortOption.h"

#define ICON_HEIGHT   24.0f
#define ICON_WIDTH    24.0f

#define LABEL_HEIGHT  24.0f

@implementation SortOptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _optionLabel = [self initLabel:CGRectZero
                         textColor:COLOR(76, 76, 76)
                       shadowColor:TRANSPARENT_COLOR];
    _optionLabel.font = BOLD_FONT(15);
    [self.contentView addSubview:_optionLabel];
    
    _selectedStatusIcon = [[UIImageView alloc] initWithFrame:CGRectMake(320 - MARGIN * 2 - ICON_WIDTH, 44/2 - ICON_HEIGHT/2, ICON_WIDTH, ICON_HEIGHT)];
    _selectedStatusIcon.backgroundColor = TRANSPARENT_COLOR;
    _selectedStatusIcon.image = UNSELECTED_IMG;
    [self.contentView addSubview:_selectedStatusIcon];
  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_optionLabel);
  RELEASE_OBJ(_selectedStatusIcon);
  
  [super dealloc];
}

- (void)drawOption:(SortOption *)option {
  _optionLabel.text = option.optionName;
  CGSize size = [_optionLabel.text sizeWithFont:_optionLabel.font 
                              constrainedToSize:CGSizeMake(_selectedStatusIcon.frame.origin.x - MARGIN * 2 - MARGIN * 2, CGFLOAT_MAX) 
                                  lineBreakMode:NSLineBreakByWordWrapping];
  _optionLabel.frame = CGRectMake(MARGIN * 2, 44/2 - LABEL_HEIGHT/2, size.width, LABEL_HEIGHT);
  
  if (option.selected.boolValue) {
    _selectedStatusIcon.image = [UIImage imageNamed:@"radioButton.png"];
  } else {
    _selectedStatusIcon.image = UNSELECTED_IMG;
  }
}

@end
