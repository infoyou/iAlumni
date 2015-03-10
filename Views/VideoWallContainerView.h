//
//  VideoWallContainerView.h
//  iAlumni
//
//  Created by Adam on 13-1-9.
//
//

#import "WXWConnectorConsumerView.h"
#import "UIPageControl+CustomizeDot.h"

@interface VideoWallContainerView : WXWConnectorConsumerView <UIScrollViewDelegate> {
    
@private
    
    UIScrollView *_wallView;
    
    UIPageControl *_pageControl;
    
    id _entrance;
    
    SEL _action;
    
    NSInteger _currentPageIndex;
    
    BOOL _stopScrolling;
    
    BOOL _autoScrolling;
    
    BOOL _usingLocalCachedVideos;
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
                MOC:(NSManagedObjectContext *)MOC
           entrance:(id)entrance
             action:(SEL)action;

- (void)stopPlay;

- (void)play;

- (void)loadLatestVideos;

#pragma mark - current video
- (NSInteger)currentVideoId;

@end
