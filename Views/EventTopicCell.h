//
//  EventTopicCell.h
//  iAlumni
//
//  Created by Adam on 12-9-10.
//
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"

@class WXWGradientView;
@class WXWLabel;
@class EventTopic;

@interface EventTopicCell : ECImageConsumerCell {
  
  @private
  WXWGradientView *_badgeBackgroundView;
  
  WXWLabel *_contentLabel;
  WXWLabel *_sequenceNumberLabel;
  WXWLabel *_statusLabel;
  WXWLabel *_votedLabel;
}

- (void)drawCell:(EventTopic *)topic;

@end
