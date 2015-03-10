//
//  StartupProjectCell.h
//  iAlumni
//
//  Created by Adam on 13-3-7.
//
//

#import "BaseUITableViewCell.h"

@class Event;

@interface StartupProjectCell : BaseUITableViewCell {
  
@private
  
  UIImageView *_postImageView;
  UIImageView *_eventDateImageView;
  WXWLabel *_titleLabel;
  UILabel *_descLabel;
  
  WXWLabel *_dateLabel;
  WXWLabel *_intervalDayLabel;
  WXWLabel *_signUpCountLabel;
    
  NSString *_url;
  
}

@property (nonatomic, retain) NSString *url;

- (void)drawEvent:(Event *)event;

@end
