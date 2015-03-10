//
//  EventWallContainerView.h
//  iAlumni
//
//  Created by Adam on 13-1-14.
//
//

#import "WXWConnectorConsumerView.h"

@interface EventWallContainerView : WXWConnectorConsumerView <UIScrollViewDelegate> {
@private
  
  UIScrollView *_wallView;
  
  UIPageControl *_pageControl;
  
  id _entrance;
  
  SEL _action;
  
  SEL _refreshBadgeAction;
  
  NSInteger _currentPageIndex;
  
  BOOL _stopScrolling;
  
  BOOL _autoScrolling;
  
  UIImageView *_bookmark;
  
  WXWLabel *_dateLabel;
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
                MOC:(NSManagedObjectContext *)MOC
           entrance:(id)entrance
             action:(SEL)action
 refreshBadgeAction:(SEL)refreshBadgeAction;

- (void)loadLatestEvents;

#pragma mark - timer controller
- (void)play;

- (void)stopPlay;

- (void)triggerAutoPlay;

@end
