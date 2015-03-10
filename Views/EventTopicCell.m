//
//  EventTopicCell.m
//  iAlumni
//
//  Created by Adam on 12-9-10.
//
//

#import "EventTopicCell.h"
#import "WXWLabel.h"
#import "WXWGradientView.h"
#import "EventTopic.h"
#import "TextConstants.h"
#import "CommonUtils.h"

#define SIDE_LENGTH   40.0f

@implementation EventTopicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _badgeBackgroundView = [[[WXWGradientView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2,
                                                                             SIDE_LENGTH,
                                                                             SIDE_LENGTH)
                                                         topColor:COLOR(243, 243, 243)
                                                      bottomColor:COLOR(220, 220, 220)] autorelease];
    _badgeBackgroundView.layer.cornerRadius = 4.0f;
    _badgeBackgroundView.layer.borderColor = COLOR(213, 213, 213).CGColor;
    _badgeBackgroundView.layer.borderWidth = 1.0f;
    _badgeBackgroundView.layer.masksToBounds = YES;
    [self.contentView addSubview:_badgeBackgroundView];
    
    _sequenceNumberLabel = [[self initLabel:CGRectZero
                                  textColor:[UIColor whiteColor]
                                shadowColor:[UIColor blackColor]] autorelease];
    _sequenceNumberLabel.textAlignment = UITextAlignmentCenter;
    _sequenceNumberLabel.font = BOLD_HK_FONT(20);
    [_badgeBackgroundView addSubview:_sequenceNumberLabel];
    
    _statusLabel = [[self initLabel:CGRectZero
                          textColor:BASE_INFO_COLOR
                        shadowColor:[UIColor whiteColor]] autorelease];
    _statusLabel.font = BOLD_FONT(13);
    [self.contentView addSubview:_statusLabel];
    
    _votedLabel = [[self initLabel:CGRectZero
                         textColor:DARK_TEXT_COLOR
                       shadowColor:[UIColor whiteColor]] autorelease];
    _votedLabel.font = BOLD_FONT(13);
    [self.contentView addSubview:_votedLabel];
    
    _contentLabel = [[self initLabel:CGRectZero
                           textColor:DARK_TEXT_COLOR
                         shadowColor:[UIColor whiteColor]] autorelease];
    _contentLabel.font = BOLD_FONT(14);
    _contentLabel.numberOfLines = 0;
    [self.contentView addSubview:_contentLabel];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)adjustBadgeWithTopColor:(UIColor *)topColor
                    bottomColor:(UIColor *)bottomColor
                      textColor:(UIColor *)textColor {
  [_badgeBackgroundView drawWithTopColor:topColor
                             bottomColor:bottomColor];
  _badgeBackgroundView.layer.borderColor = bottomColor.CGColor;
  _statusLabel.textColor = textColor;
}

- (void)drawCell:(EventTopic *)topic {
  _sequenceNumberLabel.text = [NSString stringWithFormat:@"%@", topic.sequenceNumber];
  
  CGSize size = [_sequenceNumberLabel.text sizeWithFont:_sequenceNumberLabel.font
                                      constrainedToSize:CGSizeMake(SIDE_LENGTH, SIDE_LENGTH)
                                          lineBreakMode:NSLineBreakByWordWrapping];
  _sequenceNumberLabel.frame = CGRectMake((SIDE_LENGTH - size.width)/2.0f,
                                          (SIDE_LENGTH - size.height)/2.0f + MARGIN,
                                          size.width, size.height);
  
  switch (topic.status.intValue) {
    case VOTE_IN_PROCESS_TY:
      _statusLabel.text = LocaleStringForKey(NSInProcessTitle, nil);
      [self adjustBadgeWithTopColor:COLOR(214, 240, 146)
                        bottomColor:COLOR(167, 212, 45)
                          textColor:COLOR(167, 207, 39)];
      break;
      
    case VOTE_CLOSED_TY:
      _statusLabel.text = LocaleStringForKey(NSCloseTitle, nil);
      [self adjustBadgeWithTopColor:COLOR(230, 230, 230)
                        bottomColor:COLOR(180, 180, 180)
                          textColor:BASE_INFO_COLOR];
      break;
      
    default:
      break;
  }
  
  size = [_statusLabel.text sizeWithFont:_statusLabel.font
                       constrainedToSize:CGSizeMake(SIDE_LENGTH, SIDE_LENGTH)
                           lineBreakMode:NSLineBreakByWordWrapping];
  
  _statusLabel.frame = CGRectMake(MARGIN * 2 + (SIDE_LENGTH - size.width)/2.0f,
                                  _badgeBackgroundView.frame.origin.y + _badgeBackgroundView.frame.size.height + MARGIN,
                                  size.width, size.height);
  
  if (topic.voted.boolValue) {
    _votedLabel.text = LocaleStringForKey(NSVotedTitle, nil);
  } else {
    _votedLabel.text = LocaleStringForKey(NSNotVotedTitle, nil);
  }
  size = [_votedLabel.text sizeWithFont:_votedLabel.font
                      constrainedToSize:CGSizeMake(SIDE_LENGTH, SIDE_LENGTH)
                          lineBreakMode:NSLineBreakByWordWrapping];
  _votedLabel.frame = CGRectMake(MARGIN * 2 + (SIDE_LENGTH - size.width)/2.0f,
                                 _statusLabel.frame.origin.y + _statusLabel.frame.size.height + MARGIN,
                                 size.width, size.height);
  
  _contentLabel.text = topic.content;
  size = [_contentLabel.text sizeWithFont:_contentLabel.font
                        constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4
                                                     - MARGIN * 2 - SIDE_LENGTH, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  _contentLabel.frame = CGRectMake(_badgeBackgroundView.frame.origin.x + SIDE_LENGTH + MARGIN * 2,
                                   MARGIN * 2, size.width, size.height);
}

@end
