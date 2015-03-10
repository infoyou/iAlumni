//
//  EventIntroCell.m
//  iAlumni
//
//  Created by Adam on 12-9-7.
//
//

#import "EventIntroCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "UIUtils.h"

@implementation EventIntroCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      
      _titleLabel = [self initLabel:CGRectZero
                          textColor:CELL_TITLE_COLOR
                        shadowColor:[UIColor whiteColor]];
      _titleLabel.font = BOLD_FONT(14);
      [self.contentView addSubview:_titleLabel];
      
      _contentLabel = [self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]];
      _contentLabel.font = BOLD_FONT(13);
      _contentLabel.numberOfLines = 0;
      [self.contentView addSubview:_contentLabel];
      
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
      self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_titleLabel);
  RELEASE_OBJ(_contentLabel);
  
  [super dealloc];
}

- (void)drawCell:(NSString *)title
         content:(NSString *)content
       maxHeight:(CGFloat)maxHeight
   separatorType:(SeparatorType)separatorType {
  
  _titleLabel.text = title;
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 6, maxHeight - MARGIN * 4)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _titleLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
  
  _contentLabel.text = content;
  size = [_contentLabel.text sizeWithFont:_contentLabel.font
                               constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 6,
                                                            maxHeight - _titleLabel.frame.size.height - MARGIN * 6)
                                   lineBreakMode:NSLineBreakByTruncatingTail];
  _contentLabel.frame = CGRectMake(MARGIN * 2,
                                   _titleLabel.frame.origin.y + _titleLabel.frame.size.height + MARGIN * 2,
                                   size.width, size.height);
  
  _cellHeight = _titleLabel.frame.size.height + _contentLabel.frame.size.height + MARGIN * 6;
  
  _separatorType = separatorType;
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
