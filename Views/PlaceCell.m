//
//  PlaceCell.m
//  ExpatCircle
//
//  Created by Adam on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PlaceCell.h"
#import "Place.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"

@implementation PlaceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _nameLabel = [self initLabel:CGRectZero
                       textColor:COLOR(76, 76, 76)
                     shadowColor:TRANSPARENT_COLOR];
    _nameLabel.font = BOLD_FONT(14);
    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLabel.numberOfLines = 0;
    
    [self.contentView addSubview:_nameLabel];
    
    _distanceLabel = [self initLabel:CGRectZero
                           textColor:COLOR(75, 79, 85)
                         shadowColor:TRANSPARENT_COLOR];
    _distanceLabel.font = FONT(13);
    _distanceLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_distanceLabel];
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_nameLabel);
  RELEASE_OBJ(_distanceLabel);
  [super dealloc];
}

- (void)drawPlace:(Place *)place {
  
  _distanceLabel.text = [NSString stringWithFormat:@"%.01f %@", 
                         place.distance.floatValue * 1000, 
                         LocaleStringForKey(NSMeterTitle, nil)];
  
  CGSize distanceSize = [_distanceLabel.text sizeWithFont:_distanceLabel.font
                                        constrainedToSize:CGSizeMake(320, CGFLOAT_MAX)
                                            lineBreakMode:NSLineBreakByWordWrapping];
  _nameLabel.text = place.placeName;  
  CGSize nameSize = [place.placeName sizeWithFont:_nameLabel.font
                                constrainedToSize:CGSizeMake(self.frame.size.width - distanceSize.width - MARGIN - MARGIN * 4, CGFLOAT_MAX) 
                                    lineBreakMode:NSLineBreakByWordWrapping];
  
  if (place.selected.boolValue) {
    _nameLabel.textColor = NAVIGATION_BAR_COLOR;
  } else {
    _nameLabel.textColor = COLOR(76, 76, 76);
  }
  
  CGFloat height = nameSize.height + MARGIN * 4;
  if (height < 44.0f) {
    height = 44.0f;
  }
  
  _distanceLabel.frame = CGRectMake(self.frame.size.width - MARGIN - distanceSize.width, height/2 - distanceSize.height/2, distanceSize.width, distanceSize.height);

  _nameLabel.frame = CGRectMake(MARGIN * 2, height/2 - nameSize.height/2, nameSize.width, nameSize.height);
}

@end
