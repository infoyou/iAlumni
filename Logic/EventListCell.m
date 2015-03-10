//
//  EventListCell.m
//  iAlumni
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "EventListCell.h"
#import "Event.h"
#import "UIImage-Extensions.h"
#import "ECInnerShadowImageView.h"

#define DATE_IMG_WIDTH    59.0f
#define DATE_IMG_HEIGHT   67.0f

@interface EventListCell ()
@property (nonatomic, retain) UIImageView *dateImageView;
@property (nonatomic, retain) WXWLabel *weekLabel;
@property (nonatomic, retain) WXWLabel *dayLabel;
@property (nonatomic, retain) WXWLabel *timeLabel;
@property (nonatomic, retain) WXWLabel *nameLabel;
@property (nonatomic, retain) WXWLabel *groupLabel;
@property (nonatomic, retain) WXWLabel *signUpInfoLabel;
@property (nonatomic, retain) WXWLabel *statusLabel;
@property (nonatomic, retain) WXWLabel *comingDayLabel;

@end

@implementation EventListCell

- (void)initViews {
  self.dateImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, DATE_IMG_WIDTH, DATE_IMG_HEIGHT)] autorelease];
  [self.contentView addSubview:self.dateImageView];
  
  self.weekLabel = [[self initLabel:CGRectZero
                          textColor:[UIColor whiteColor]
                        shadowColor:TRANSPARENT_COLOR] autorelease];
  self.weekLabel.font = BOLD_FONT(9);
  [self.dateImageView addSubview:self.weekLabel];
  
  self.dayLabel = [[self initLabel:CGRectZero
                         textColor:[UIColor whiteColor]
                       shadowColor:TRANSPARENT_COLOR] autorelease];
  self.dayLabel.font = LIGHT_FONT(30);
  [self.dateImageView addSubview:self.dayLabel];
  
  self.timeLabel = [[self initLabel:CGRectZero
                          textColor:COLOR(255, 255, 255)
                        shadowColor:TRANSPARENT_COLOR] autorelease];
  self.timeLabel.font = FONT(10);
  [self.dateImageView addSubview:self.timeLabel];
  
  self.nameLabel = [[self initLabel:CGRectZero
                          textColor:DARK_TEXT_COLOR shadowColor:TRANSPARENT_COLOR] autorelease];
  self.nameLabel.font = FONT(15);
  self.nameLabel.numberOfLines = 0;
  self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [self.contentView addSubview:self.nameLabel];
  
  self.groupLabel = [[self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR shadowColor:TRANSPARENT_COLOR] autorelease];
  self.groupLabel.font = FONT(13);
  self.groupLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [self.contentView addSubview:self.groupLabel];
  
  self.signUpInfoLabel = [[self initLabel:CGRectZero
                                textColor:BASE_INFO_COLOR shadowColor:TRANSPARENT_COLOR] autorelease];
  self.signUpInfoLabel.font = FONT(13);
  [self.contentView addSubview:self.signUpInfoLabel];
  
  self.statusLabel = [[self initLabel:CGRectZero
                            textColor:NAVIGATION_BAR_COLOR shadowColor:TRANSPARENT_COLOR] autorelease];
  self.statusLabel.font = FONT(13);
  [self.contentView addSubview:self.statusLabel];
  
  self.comingDayLabel = [[self initLabel:CGRectZero
                               textColor:NAVIGATION_BAR_COLOR shadowColor:TRANSPARENT_COLOR] autorelease];
  self.comingDayLabel.font = FONT(13);
  [self.contentView addSubview:self.comingDayLabel];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.backgroundColor = COLOR(251, 251, 251);
    self.contentView.backgroundColor = COLOR(251, 251, 251);
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self initViews];

  }
  
  return self;
}

- (void)dealloc {
  
  self.dateImageView = nil;
  self.nameLabel = nil;
  self.dayLabel = nil;
  self.weekLabel = nil;
  self.timeLabel = nil;
  self.signUpInfoLabel = nil;
  self.groupLabel = nil;
  self.statusLabel = nil;
  self.comingDayLabel = nil;
  
  [super dealloc];
}

- (void)resetViews {
  self.nameLabel.text = NULL_PARAM_VALUE;
  self.dayLabel.text = NULL_PARAM_VALUE;
  self.weekLabel.text = NULL_PARAM_VALUE;
  self.timeLabel.text = NULL_PARAM_VALUE;
  self.signUpInfoLabel.text = NULL_PARAM_VALUE;
  self.groupLabel.text = NULL_PARAM_VALUE;
  self.statusLabel.text = NULL_PARAM_VALUE;
  self.comingDayLabel.text = NULL_PARAM_VALUE;
}

- (void)drawEvent:(Event *)event {
  
  [self resetViews];
  
  self.weekLabel.text = event.monthWeekInfo;
  CGSize size = [CommonUtils sizeForText:self.weekLabel.text
                                    font:self.weekLabel.font];
  self.weekLabel.frame = CGRectMake((DATE_IMG_WIDTH - size.width)/2.0f,
                                    9, size.width, size.height);
  
  self.dayLabel.text = event.monthDayInfo;
  size = [CommonUtils sizeForText:self.dayLabel.text
                             font:self.dayLabel.font];
  self.dayLabel.frame = CGRectMake((DATE_IMG_WIDTH - size.width)/2.0f, self.weekLabel.frame.origin.x + self.weekLabel.frame.size.height + MARGIN, size.width, size.height);
  
  if (event.timeStr.length > 1) {
    self.timeLabel.text = event.timeStr;
    size = [CommonUtils sizeForText:self.timeLabel.text
                               font:self.timeLabel.font
                  constrainedToSize:CGSizeMake(DATE_IMG_WIDTH - 4, 15)
                      lineBreakMode:BREAK_BY_WORD_WRAPPING];
    self.timeLabel.frame = CGRectMake((DATE_IMG_WIDTH - size.width)/2.0f, self.dayLabel.frame.origin.x + self.dayLabel.frame.size.height + 6, size.width, size.height);
  }
  
  self.nameLabel.text = event.title;
  CGSize textFrameSize = [CommonUtils sizeForText:self.nameLabel.text
                                             font:self.nameLabel.font
                                constrainedToSize:CGSizeMake(220, 40)
                                    lineBreakMode:BREAK_BY_TRUNCATING_TAIL];
  
  self.nameLabel.frame = CGRectMake(self.dateImageView.frame.origin.x + self.dateImageView.frame.size.width + MARGIN * 2, self.dateImageView.frame.origin.y, textFrameSize.width, textFrameSize.height);
  
  self.groupLabel.text = event.hostName;
  textFrameSize = [CommonUtils sizeForText:self.groupLabel.text
                                  font:self.groupLabel.font
                     constrainedToSize:CGSizeMake(220, 20)
                         lineBreakMode:BREAK_BY_TRUNCATING_TAIL];
  self.groupLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + 7.0f, textFrameSize.width, textFrameSize.height);
  
  self.signUpInfoLabel.text = STR_FORMAT(LocaleStringForKey(NSPlacedSignUpCountMsg, nil), event.signupCount);
  size = [CommonUtils sizeForText:self.signUpInfoLabel.text
                             font:self.signUpInfoLabel.font];
  self.signUpInfoLabel.frame = CGRectMake(self.nameLabel.frame.origin.x,
                                          self.dateImageView.frame.origin.y + self.dateImageView.frame.size.height,
                                          size.width, size.height);
  
  if (event.actionType.intValue == EXPIRED_BTN_TY) {
    self.dateImageView.image = IMAGE_WITH_NAME(@"eventGrayIcon.png");
  } else {
    self.dateImageView.image = IMAGE_WITH_NAME(@"eventRedIcon.png");
  }
  
  switch (event.actionType.intValue) {
    case PAYMENT_BTN_TY:
    case EXIT_EVENT_BTN_TY:
    {
      self.statusLabel.text = event.actionStr;
      
      size = [CommonUtils sizeForText:self.statusLabel.text
                                 font:self.statusLabel.font];
      self.statusLabel.frame = CGRectMake(205, self.signUpInfoLabel.frame.origin.y, size.width, size.height);
      
      break;
    }
      
    default:
      break;
  }
  
  // interval day
  int interValDay = [event.intervalDayCount intValue];
  [self drawInterValDay:interValDay];

}

#pragma mark - interval day
- (void)drawInterValDay:(int)interValDay{
  
  if (0 == interValDay) {
    self.comingDayLabel.text = LocaleStringForKey(NSInProcessTitle, nil);
  } else if (interValDay > 0){
    self.comingDayLabel.text = [NSString stringWithFormat:@"%d %@", interValDay, LocaleStringForKey(NSHoldDayTitle, nil)];
    
    CGSize size = [CommonUtils sizeForText:self.comingDayLabel.text
                                      font:self.comingDayLabel.font];
    self.comingDayLabel.frame = CGRectMake(self.frame.size.width - 8 - size.width, self.signUpInfoLabel.frame.origin.y, size.width, size.height);
  }
  
}
@end
