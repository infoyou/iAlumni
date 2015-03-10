//
//  BizGroupCell.m
//  iAlumni
//
//  Created by Adam on 12-12-9.
//
//

#import "BizGroupCell.h"
#import "WXWLabel.h"
#import "Club.h"

#define LIMITED_WIDTH             300.0f

@implementation BizGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.contentView.backgroundColor = CELL_COLOR;
    
    _groupNameLabel = [[self initLabel:CGRectZero
                             textColor:DARK_TEXT_COLOR
                           shadowColor:[UIColor whiteColor]] autorelease];
    _groupNameLabel.font = BOLD_FONT(15);
    _groupNameLabel.numberOfLines = 0;
    [self.contentView addSubview:_groupNameLabel];
    
    _authorLabel = [[self initLabel:CGRectZero
                          textColor:DARK_TEXT_COLOR
                        shadowColor:[UIColor whiteColor]] autorelease];
    _authorLabel.font = BOLD_FONT(13);
    [self.contentView addSubview:_authorLabel];
    
    _contentLabel = [[self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]] autorelease];
    _contentLabel.font = BOLD_FONT(13);
    _contentLabel.numberOfLines = 1;
    [self.contentView addSubview:_contentLabel];
    
    _dateTimeLabel = [[self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]] autorelease];
    _dateTimeLabel.font = BOLD_FONT(11);
    [self.contentView addSubview:_dateTimeLabel];
    
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}

- (void)drawCell:(Club *)group {
  _groupNameLabel.text = group.clubName;
  CGSize size = [_groupNameLabel.text sizeWithFont:_groupNameLabel.font
                                 constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
  _groupNameLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);

  if (group.postAuthor && group.postAuthor.length > 0 &&
      group.postDesc && group.postDesc.length > 0 &&
      group.postTime.length && group.postTime.length > 0) {
    
    _authorLabel.text = [NSString stringWithFormat:@"%@:", group.postAuthor];
    size = [_authorLabel.text sizeWithFont:_authorLabel.font
                         constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    _authorLabel.frame = CGRectMake(MARGIN * 2,
                                    _groupNameLabel.frame.origin.x + _groupNameLabel.frame.size.height,
                                    size.width, size.height);
    
    _contentLabel.text = group.postDesc;
    size = [_contentLabel.text sizeWithFont:_contentLabel.font
                          constrainedToSize:CGSizeMake(self.frame.size.width - (_authorLabel.frame.origin.x + _authorLabel.frame.size.width + MARGIN + 20 + MARGIN), _authorLabel.frame.size.height)
                              lineBreakMode:NSLineBreakByTruncatingTail];
    _contentLabel.frame = CGRectMake(_authorLabel.frame.origin.x + _authorLabel.frame.size.width + MARGIN, _authorLabel.frame.origin.y, size.width, size.height);
    
    _dateTimeLabel.hidden = NO;
    
    _dateTimeLabel.text = group.postTime;
    size = [_dateTimeLabel.text sizeWithFont:_dateTimeLabel.font
                           constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    _dateTimeLabel.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - size.width,
                                      _contentLabel.frame.origin.y + _contentLabel.frame.size.height + MARGIN,
                                      size.width, size.height);

    _authorLabel.hidden = NO;
    _contentLabel.hidden = NO;
    _dateTimeLabel.hidden = NO;
  } else {
    _authorLabel.hidden = YES;
    _contentLabel.hidden = YES;
    _dateTimeLabel.hidden = YES;
  }
  
}

@end
