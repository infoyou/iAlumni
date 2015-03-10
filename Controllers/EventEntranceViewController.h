//
//  EventEntranceViewController.h
//  iAlumni
//
//  Created by Adam on 13-1-14.
//
//

#import "WXWRootViewController.h"
#import "ScrollAutoPlayerDelegate.h"

@class EventWallContainerView;
@class LectureEventEntranceView;
@class EntertainmentEventEntranceView;
@class MyEventEntranceView;

@interface EventEntranceViewController : WXWRootViewController <ScrollAutoPlayerDelegate> {
  @private
  
  CGFloat _viewHeight;
  
  UIViewController *_parentVC;
  
  SEL _refreshBadgesAction;
  
  EventWallContainerView *_eventWallContainerView;

  LectureEventEntranceView *_lectureEventEntranceView;
  
  EntertainmentEventEntranceView *_entertainmentEventEntranceView;
  
  MyEventEntranceView *_myEventEntranceView;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
         parentVC:(UIViewController *)parentVC
refreshBadgesAction:(SEL)refreshBadgesAction;

#pragma mark - open shared event
- (void)openSharedEventById:(long long)eventId eventType:(int)eventType;

@end
