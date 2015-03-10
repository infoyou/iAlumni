//
//  VoteDetailViewController.h
//  iAlumni
//
//  Created by Adam on 12-9-10.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "EventVoteDelegate.h"


@class EventTopic;
@class Option;

@interface VoteDetailViewController : BaseListViewController <EventVoteDelegate, UIActionSheetDelegate> {
  @private
  
  EventTopic *_eventTopic;
  
  Option *_selectedOption;
  
  UIView *_bottomToolbar;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventTopic:(EventTopic *)eventTopic;

@end
