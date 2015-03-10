//
//  StaticIconCell.m
//  iAlumni
//
//  Created by Adam on 12-9-7.
//
//

#import "StaticIconCell.h"
#import "WXWLabel.h"
#import "UIUtils.h"

#define ICON_SIDE_LENGTH  16.0f

@implementation StaticIconCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    
    _title = [self initLabel:CGRectZero
                   textColor:BASE_INFO_COLOR
                 shadowColor:[UIColor whiteColor]];
    _title.font = BOLD_FONT(14);
    _title.numberOfLines = 0;
    [self.contentView addSubview:_title];
    
    _icon = [[[UIImageView alloc] init] autorelease];
    _icon.backgroundColor = TRANSPARENT_COLOR;
    [self.contentView addSubview:_icon];
    
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_title);
  
  [super dealloc];
}

- (void)drawCell:(NSString *)iconName
           title:(NSString *)title
   separatorType:(SeparatorType)separatorType
      cellHeight:(CGFloat)cellHeight {
  
  _title.text = title;
  CGSize size = [_title.text sizeWithFont:_title.font
                        constrainedToSize:CGSizeMake(270 - ICON_SIDE_LENGTH, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
  _title.frame = CGRectMake(MARGIN * 2 + ICON_SIDE_LENGTH + MARGIN * 2,
                            MARGIN * 2, size.width, size.height);

  _icon.image = [UIImage imageNamed:iconName];
  _icon.frame = CGRectMake(MARGIN * 2,
                           (cellHeight - ICON_SIDE_LENGTH)/2.0f,
                           ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
  
  _separatorType = separatorType;
  
  _cellHeight = cellHeight;
}

- (void)drawRect:(CGRect)rect {
  
  if (_separatorType == DASH_LINE_TY) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat pattern[2] = {1, 2};
    
    [UIUtils draw1PxDashLine:context
                  startPoint:CGPointMake(0, _cellHeight - 1.5f)
                    endPoint:CGPointMake(self.frame.size.width, _cellHeight - 1.5f)
                    colorRef:SEPARATOR_LINE_COLOR.CGColor
                shadowOffset:CGSizeMake(0.0f, 1.0f)
                 shadowColor:[UIColor whiteColor]
                     pattern:pattern];
  }
}


@end
