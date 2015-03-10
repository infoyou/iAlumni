//
//  ServiceLatestCommentCell.m
//  ExpatCircle
//
//  Created by Adam on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServiceLatestCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "UIUtils.h"

#define ACCESS_DISCLOSUR_WIDTH  266.0f

@implementation ServiceLatestCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.backgroundColor = SERVICE_ITEM_CELL_COLOR;
    
    _titleLabel = [[self initLabel:CGRectZero
                         textColor:COLOR(30.0f, 30.0f, 30.0f)
                       shadowColor:[UIColor whiteColor]] autorelease];
    _titleLabel.font = BOLD_FONT(14);
    [self.contentView addSubview:_titleLabel];
    
    _subTitleLabel = [[self initLabel:CGRectZero
                            textColor:[UIColor whiteColor]
                          shadowColor:TRANSPARENT_COLOR] autorelease];
    _subTitleLabel.backgroundColor = BASE_INFO_COLOR;
    _subTitleLabel.layer.masksToBounds = YES;
    _subTitleLabel.font = BOLD_FONT(10);
    _subTitleLabel.numberOfLines = 0;
    _subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _subTitleLabel.textAlignment = UITextAlignmentCenter;
    _subTitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    [self.contentView addSubview:_subTitleLabel];
    
    _contentLabel = [[self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]] autorelease];
    _contentLabel.font = BOLD_FONT(13);
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_contentLabel];
    
    _commenterNameLabel = [[self initLabel:CGRectZero
                                 textColor:[UIColor blackColor]
                               shadowColor:[UIColor whiteColor]] autorelease];
    _commenterNameLabel.font = FONT(11);
    [self.contentView addSubview:_commenterNameLabel];
    
    _locatoinLabel = [[self initLabel:CGRectZero
                            textColor:NAVIGATION_BAR_COLOR
                          shadowColor:[UIColor whiteColor]] autorelease];
    _locatoinLabel.font = FONT(11);
    _locatoinLabel.numberOfLines = 0;
    [self.contentView addSubview:_locatoinLabel];
    
    _dateLabel = [[self initLabel:CGRectZero
                        textColor:BASE_INFO_COLOR
                      shadowColor:[UIColor whiteColor]] autorelease];
    _dateLabel.textAlignment = UITextAlignmentRight;
    _dateLabel.font = FONT(11);
    [self.contentView addSubview:_dateLabel];
    
    
  }
  return self;
}

- (void)drawOutBottomShadow:(CGFloat)height {
  
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.bounds.origin.x + MARGIN * 2 + 2,
                                                                          self.bounds.origin.y + MARGIN,
                                                                          self.bounds.size.width - MARGIN * 5 - 1,
                                                                          height - (MARGIN + 3.0f))
                                             byRoundingCorners:UIRectCornerAllCorners
                                                   cornerRadii:CGSizeMake(GROUP_STYLE_CELL_CORNER_RADIUS, GROUP_STYLE_CELL_CORNER_RADIUS)];
  
  self.layer.shadowPath = path.CGPath;
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
  self.layer.shadowOpacity = 0.9f;
  self.layer.masksToBounds = NO;
}

- (void)arrangeSubTitle:(NSString *)subTitle {
  if (subTitle && subTitle.length > 0) {
    _subTitleLabel.hidden = NO;
    
    _subTitleLabel.text = subTitle;
    CGSize size = [_subTitleLabel.text sizeWithFont:_subTitleLabel.font
                                  constrainedToSize:CGSizeMake(self.contentView.frame.size.width -
                                                               (_titleLabel.frame.origin.x + _titleLabel.frame.size.width + MARGIN * 4),
                                                               CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    _subTitleLabel.frame = CGRectMake(_titleLabel.frame.origin.x + _titleLabel.frame.size.width + MARGIN * 2,
                                      _titleLabel.frame.origin.y + _titleLabel.frame.size.height - size.height - 2.0f,
                                      size.width + MARGIN * 4, size.height);
    _subTitleLabel.layer.cornerRadius = size.height/2.0f;
  } else {
    _subTitleLabel.hidden = YES;
  }
}

- (void)arrangeTitle:(NSString *)title {
  _titleLabel.text = title;
  CGSize size = [title sizeWithFont:_titleLabel.font
                  constrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)
                      lineBreakMode:NSLineBreakByWordWrapping];
  _titleLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
}

- (void)arrangeCommenterName:(NSString *)commenterName {
  _commenterNameLabel.text = commenterName;
  CGSize size = [commenterName sizeWithFont:_commenterNameLabel.font
                          constrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
  _commenterNameLabel.frame = CGRectMake(MARGIN * 2,
                                         _titleLabel.frame.origin.y + _titleLabel.frame.size.height + MARGIN,
                                         size.width, size.height);
}

- (void)arrangeDate:(NSString *)date {
  _dateLabel.text = date;
  CGSize size = [date sizeWithFont:_dateLabel.font
                 constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                     lineBreakMode:NSLineBreakByWordWrapping];
  _dateLabel.frame = CGRectMake(270.0f - size.width, _commenterNameLabel.frame.origin.y, size.width, size.height);
}

- (void)arrangeCommentContent:(NSString *)content {
  if (content && content.length > 0) {
    _contentLabel.hidden = NO;
    _contentLabel.text = content;
    CGSize size = [_contentLabel.text sizeWithFont:_contentLabel.font
                                 constrainedToSize:CGSizeMake(ACCESS_DISCLOSUR_WIDTH, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    
    if (_locatoinLabel.hidden) {
      _contentLabel.frame = CGRectMake(MARGIN * 2,
                                       _commenterNameLabel.frame.origin.y +
                                       _commenterNameLabel.frame.size.height + MARGIN, size.width, size.height);
    } else {
      _contentLabel.frame = CGRectMake(MARGIN * 2,
                                       _locatoinLabel.frame.origin.y +
                                       _locatoinLabel.frame.size.height + MARGIN, size.width, size.height);
    }
    
  } else {
    _contentLabel.hidden = YES;
  }
}

- (void)arrangeLocationLabel:(NSString *)location {
  if (location && location.length > 0) {
    _locatoinLabel.hidden = NO;
    
    _locatoinLabel.text = location;
    
    CGSize size = [_locatoinLabel.text sizeWithFont:_locatoinLabel.font
                                  constrainedToSize:CGSizeMake(ACCESS_DISCLOSUR_WIDTH, CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    
    _locatoinLabel.frame = CGRectMake(MARGIN * 2,
                                      _commenterNameLabel.frame.origin.y +
                                      _commenterNameLabel.frame.size.height + MARGIN, size.width, size.height);
  } else {
    _locatoinLabel.hidden = YES;
  }
}

- (void)arrangeViews:(NSString *)title
            subTitle:(NSString *)subTitle
            location:(NSString *)location
             comment:(NSString *)comment
       commenterName:(NSString *)commenterName
                date:(NSString *)date {
  
  [self arrangeTitle:title];
  
  [self arrangeSubTitle:subTitle];
  
  [self arrangeCommenterName:commenterName];
  
  [self arrangeDate:date];
  
  [self arrangeLocationLabel:location];
  
  [self arrangeCommentContent:comment];

}

- (void)drawCell:(NSString *)title
        subTitle:(NSString *)subTitle
        location:(NSString *)location
         comment:(NSString *)comment
   commenterName:(NSString *)commenterName
            date:(NSString *)date
      cellHeight:(CGFloat)cellHeight {
  
  [self arrangeViews:title
            subTitle:subTitle
            location:location
             comment:comment
       commenterName:commenterName
                date:date];
  
  [self drawOutBottomShadow:cellHeight];
}

- (void)drawNOShadowCell:(NSString *)title
                subTitle:(NSString *)subTitle
                location:(NSString *)location
                 comment:(NSString *)comment
           commenterName:(NSString *)commenterName
                    date:(NSString *)date
              cellHeight:(CGFloat)cellHeight
           separatorType:(SeparatorType)separatorType {
  
  [self arrangeViews:title
            subTitle:subTitle
            location:location
             comment:comment
       commenterName:commenterName
                date:date];
  
  _separatorType = separatorType;
  
  _cellHeight = cellHeight;
}

- (void)drawRect:(CGRect)rect {
  if (_separatorType) {
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
