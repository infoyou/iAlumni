//
//  PeopleWithDistanceCell.m
//  iAlumni
//
//  Created by Adam on 13-2-20.
//
//

#import "PeopleWithDistanceCell.h"
#import "Alumni.h"
#import "WXWLabel.h"

#define MIN_HEIGHT  90.0f

@implementation PeopleWithDistanceCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC {

  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
       imageClickableDelegate:imageClickableDelegate
                          MOC:MOC];

  if (self) {
    _distanceLabel = [[self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:TEXT_SHADOW_COLOR] autorelease];
    _distanceLabel.font = FONT(9);
    [self.contentView addSubview:_distanceLabel];
   
    _timeLabel = [[self initLabel:CGRectZero
                        textColor:BASE_INFO_COLOR
                      shadowColor:TEXT_SHADOW_COLOR] autorelease];
    _timeLabel.font = FONT(9);
    [self.contentView addSubview:_timeLabel];
    
    _platLabel = [[self initLabel:CGRectZero
                        textColor:BASE_INFO_COLOR
                      shadowColor:TEXT_SHADOW_COLOR] autorelease];
    _platLabel.font = FONT(9);
    [self.contentView addSubview:_platLabel];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - draw cell
- (void)drawCell:(Alumni*)alumni {
  [super drawCell:alumni];
  
  _distanceLabel.text = [NSString stringWithFormat:@"%@km", self.alumni.distance];
  
  _timeLabel.text = self.alumni.time;
  
  _platLabel.text = [NSString stringWithFormat:@"%@ %@", self.alumni.plat, self.alumni.version];
  
  CGSize distanceSize = [_distanceLabel.text sizeWithFont:_distanceLabel.font];
  
  CGSize timeSize = [_timeLabel.text sizeWithFont:_timeLabel.font];
  
  CGSize platSize = [_platLabel.text sizeWithFont:_platLabel.font];
  
  CGFloat y = self.companyLabel.frame.origin.y + self.companyLabel.frame.size.height + MARGIN;
  
  CGFloat height = y + distanceSize.height + MARGIN;
  
  if (height < MIN_HEIGHT) {
    y = MIN_HEIGHT - MARGIN - distanceSize.height;
  }
  
  _distanceLabel.frame = CGRectMake(self.nameLabel.frame.origin.x,
                                    y,
                                    distanceSize.width,
                                    distanceSize.height);
  
  _platLabel.frame = CGRectMake(self.frame.size.width - MARGIN * 3 - platSize.width,
                                y,
                                platSize.width, platSize.height);
  
  _timeLabel.frame = CGRectMake((_platLabel.frame.origin.x - _distanceLabel.frame.origin.x)/2.0f + _distanceLabel.frame.origin.x - MARGIN * 4, y, timeSize.width, timeSize.height);
  
}


@end
