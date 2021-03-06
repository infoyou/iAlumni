//
//  BizOppWallView.h
//  iAlumni
//
//  Created by Adam on 13-8-13.
//
//

#import "WXWConnectorConsumerView.h"
#import "UIPageControl+CustomizeDot.h"

@interface BizOppWallView : WXWConnectorConsumerView <UIScrollViewDelegate> {
@private
  
  UIScrollView *_wallView;
  
  UIPageControl *_pageControl;
  
  id _entrance;
  
  SEL _action;
  
  NSInteger _currentPageIndex;
  
  BOOL _stopScrolling;

}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
                MOC:(NSManagedObjectContext *)MOC
           entrance:(id)entrance
             action:(SEL)action;
- (void)stopPlay;

- (void)play;


@end
