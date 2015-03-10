//
//  NewsListCell.h
//  iAlumni
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"

@class Report;
@class Upcoming;

@interface NewsListCell : BaseUITableViewCell {
  
@private
  
  UIImageView *_datetimeImageView;
  UIImageView *_separator;
  UILabel *_titleLabel;
  UILabel *_shortDescLabel;
  
  UILabel *_weekLabel;
  UILabel *_dayLabel;
  UILabel *_monthLabel;
  
  UIImageView *_readIndicator;
  UIImageView *_likeIndicator;
  UILabel *_readCountLabel;
  UILabel *_likeCountLabel;
}

- (void)drawReport:(Report *)event;
- (void)drawUpcoming:(Upcoming *)event;

@end

