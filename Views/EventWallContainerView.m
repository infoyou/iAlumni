//
//  EventWallContainerView.m
//  iAlumni
//
//  Created by Adam on 13-1-14.
//
//

#import "EventWallContainerView.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "Event.h"
#import "ThumbnailWithTitleView.h"
#import "EventEntranceViewController.h"
#import "WXWLabel.h"
#import "AppManager.h"

#define TITLE_BACKGROUND_HEIGHT 46.0f

#define TIMER_INTERVAL        8

#define MAX_STORED_COUNT      3

@interface EventWallContainerView()
@property (nonatomic, retain) NSManagedObjectContext *MOC;
@property (nonatomic, retain) NSArray *allEvents;
@property (nonatomic, retain) NSMutableArray *currentEvents;
@property (nonatomic, retain) NSMutableDictionary *thumbnailDic;
@property (nonatomic, retain) NSTimer *playControlTimer;
@end

@implementation EventWallContainerView

#pragma mark - utils methods
- (void)connectionCancelled:(NSNotification *)notification {
  if ([[notification object] isKindOfClass:[EventEntranceViewController class]]) {
    _connectionCancelled = YES;
  }
}

#pragma mark - load videos
- (void)loadLatestEvents {
  
  // delete all events before load operation every time
  DELETE_OBJS_FROM_MOC(self.MOC, @"Event", nil);
  
  NSString *param = [NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude>", [AppManager instance].longitude, [AppManager instance].latitude];
  
  NSString *url = [CommonUtils geneUrl:param
                              itemType:LOAD_RECOMMENDED_EVENT_TY];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:LOAD_RECOMMENDED_EVENT_TY];
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods

- (void)initWall {
  _wallView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
  
  _wallView.delegate = self;
  _wallView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultEventPoster.png"]];
  _wallView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _wallView.bounces = YES;
  _wallView.directionalLockEnabled = YES;
  _wallView.pagingEnabled = YES;
  _wallView.showsVerticalScrollIndicator = NO;
  _wallView.showsHorizontalScrollIndicator = NO;
  
  UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(openEvent:)] autorelease];
  [_wallView addGestureRecognizer:singleTap];
  
  [self addSubview:_wallView];
}

- (void)addPageControl {
  _pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - MARGIN * 2 - 2.0f, self.frame.size.width, MARGIN * 2)] autorelease];
  _pageControl.userInteractionEnabled = NO;
  _pageControl.hidesForSinglePage = YES;
  _pageControl.currentPage = 0;
  _pageControl.backgroundColor = TRANSPARENT_COLOR;
  [self addSubview:_pageControl];
}

- (void)arrangePageControl {
  
  if (nil == _pageControl) {
    [self addPageControl];
  }
  
  if (self.allEvents.count > 0) {
    _pageControl.numberOfPages = self.allEvents.count;
    _pageControl.alpha = 1.0f;
  } else {
    _pageControl.alpha = 0.0f;
  }
}


- (void)addConnectionCancellNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(connectionCancelled:)
                                               name:CONN_CANCELL_NOTIFY
                                             object:nil];
  
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
                MOC:(NSManagedObjectContext *)MOC
           entrance:(id)entrance
             action:(SEL)action
 refreshBadgeAction:(SEL)refreshBadgeAction
{
  self = [super initWithFrame:frame
       imageDisplayerDelegate:imageDisplayerDelegate
       connectTriggerDelegate:connectTriggerDelegate];
  if (self) {
    
    _entrance = entrance;
    
    _refreshBadgeAction = refreshBadgeAction;
    
    _action = action;
    
    self.MOC = MOC;
    
    [self initWall];
    
    //[self loadLatestEvents];
    
    [self addConnectionCancellNotification];
  }
  return self;
}

- (void)dealloc {
  
  [self stopPlay];
  
  self.MOC = nil;
  
  self.allEvents = nil;
  
  self.currentEvents = nil;
  
  self.thumbnailDic = nil;
  
  _wallView.delegate = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:CONN_CANCELL_NOTIFY
                                                object:nil];
  
  [super dealloc];
}

#pragma mark - arrange thumbnail

- (void)autoPlay {
  
  if (_wallView.tracking ||
      _wallView.dragging ||
      _wallView.decelerating ||
      _wallView.zooming ||
      _stopScrolling) {
    return;
  }
  
  if (0 == self.allEvents.count) {
    return;
  }
  
  _currentPageIndex = [self validPageValue:_currentPageIndex + 1];
  
  [UIView animateWithDuration:0.5f
                   animations:^{
                     for (ThumbnailWithTitleView *thumbanilView in self.currentEvents) {
                       thumbanilView.frame = CGRectMake(thumbanilView.frame.origin.x - thumbanilView.frame.size.width,
                                                        thumbanilView.frame.origin.y,
                                                        thumbanilView.frame.size.width,
                                                        thumbanilView.frame.size.height);
                     }
                   }
                   completion:^(BOOL finished){
                     
                     if (!_stopScrolling) {
                       [self arrangeThumbails];
                     }
                   }];
}

- (void)stopPlay {
  
  _stopScrolling = YES;
  
  _autoScrolling = NO;
  
  if (self.playControlTimer && [self.playControlTimer isValid]) {
    [self.playControlTimer invalidate];
  }
  self.playControlTimer = nil;
  
  _currentPageIndex = 0;
}

- (void)play {
  _stopScrolling = NO;
  
  [self triggerAutoPlay];
}

- (void)triggerAutoPlay {
  
  if (self.allEvents.count <= 2 || _autoScrolling) {
    return;
  }
  
  _autoScrolling = YES;
  
  self.playControlTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                           target:self
                                                         selector:@selector(autoPlay)
                                                         userInfo:nil
                                                          repeats:YES];
  [self.playControlTimer fire];
}

- (int)validPageValue:(NSInteger)value {
  
  if (value == -1) {
    value = self.allEvents.count - 1;
  }
  
  if (value == self.allEvents.count) {
    value = 0;
  }
  
  return value;
}

- (void)loadEventsData {
    
  NSMutableArray *sortDescs = [NSMutableArray array];
  NSSortDescriptor *desc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                        ascending:YES] autorelease];
  [sortDescs addObject:desc];
  
  self.allEvents = [WXWCoreDataUtils fetchObjectsFromMOC:self.MOC
                                              entityName:@"Event"
                                               predicate:nil
                                               sortDescs:sortDescs];
  
  NSInteger count = MAX_STORED_COUNT;
  if (self.allEvents.count < MAX_STORED_COUNT) {
    count = self.allEvents.count;
  }
  _wallView.contentSize = CGSizeMake(_wallView.frame.size.width * count, _wallView.frame.size.height);
  
  [self arrangePageControl];
  
  if (self.allEvents.count > 2) {
    [self performSelector:@selector(triggerAutoPlay)
               withObject:nil
               afterDelay:2];
  }
}

- (void)removeContainedThumbnails {
  NSArray *thumbnailViews = [_wallView subviews];
  if (thumbnailViews.count > 0) {
    [thumbnailViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  }
}

- (NSString *)generateFakeImageUrlForIndex:(NSInteger)index {
  return [NSString stringWithFormat:@"%@%d", NO_IMAGE_FLAG, index];
}

- (ThumbnailWithTitleView *)createThumbnailView:(NSInteger)index {
  Event *event = self.allEvents[index];
  
  ThumbnailWithTitleView *thumbnailView = [[[ThumbnailWithTitleView alloc] initNeedBottomTitleWithFrame:CGRectMake(0, 0,
                                                                                            _wallView.frame.size.width,
                                                                                            _wallView.frame.size.height)] autorelease];
  
  if (event.imageUrl && event.imageUrl.length > 0) {
    [self.thumbnailDic setObject:thumbnailView forKey:event.imageUrl];
  }
  /*
  if (nil == event.imageUrl || 0 == event.imageUrl.length) {
    [self.thumbnailDic setObject:thumbnailView forKey:[self generateFakeImageUrlForIndex:index]];
  } else {
    [self.thumbnailDic setObject:thumbnailView forKey:event.imageUrl];
  }
   */
  
  [thumbnailView setTitle:event.title subTitle:nil];
  
  [self setDateBookmarkIfNeeded:self.allEvents[_currentPageIndex]];
  
  [self.currentEvents addObject:thumbnailView];
  
  return thumbnailView;
}

- (void)prepareCurrentEvents {
  
  if (self.thumbnailDic == nil) {
    self.thumbnailDic = [NSMutableDictionary dictionary];
  } else {
    [self.thumbnailDic removeAllObjects];
  }
  
  if (self.currentEvents == nil) {
    self.currentEvents = [NSMutableArray array];
  } else {
    [self.currentEvents removeAllObjects];
  }
  
  if (self.allEvents.count == 1) {
    [self createThumbnailView:_currentPageIndex];
  } else if (self.allEvents.count == 2) {
    
    [self createThumbnailView:_currentPageIndex];
    
    NSInteger next = [self validPageValue:_currentPageIndex + 1];
    [self createThumbnailView:next];
  } else {
    
    NSInteger pre = [self validPageValue:_currentPageIndex - 1];
    [self createThumbnailView:pre];
    
    [self createThumbnailView:_currentPageIndex];
    
    NSInteger next = [self validPageValue:_currentPageIndex + 1];
    [self createThumbnailView:next];
  }
}

- (void)setDateBookmarkIfNeeded:(Event *)event {
  
  if (event.fake.boolValue) {
    // no need display date for fake event
    if (_bookmark) {
      [UIView animateWithDuration:0.2f
                       animations:^{
                         _bookmark.alpha = 0.0f;
                         _dateLabel.alpha = 0.0f;
                       }];
    }
    return;
  }
  
  if (nil == _bookmark) {
    _bookmark = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookmark.png"]] autorelease];
    _bookmark.frame = CGRectMake(-3, MARGIN * 2,
                                _bookmark.frame.size.width, _bookmark.frame.size.height);
    [self addSubview:_bookmark];

  }
  
  if (nil == _dateLabel) {
    _dateLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:[UIColor whiteColor]
                                      shadowColor:TRANSPARENT_COLOR] autorelease];
    _dateLabel.font = BOLD_FONT(12);
    [_bookmark addSubview:_dateLabel];
  }
    
  if (event.intervalDayCount.intValue < 0) {
    _bookmark.alpha = 0.0f;
    _dateLabel.alpha = 0.0f;
    
  } else {
    
    if (event.intervalDayCount.intValue == 0) {
      _dateLabel.text = LocaleStringForKey(NSInProcessTitle, nil);
    } else {
      _dateLabel.text = [NSString stringWithFormat:@"%@%@", event.intervalDayCount, LocaleStringForKey(NSHoldDayTitle, nil)];
    }
    
    CGSize size = [_dateLabel.text sizeWithFont:_dateLabel.font
                              constrainedToSize:_bookmark.frame.size
                                  lineBreakMode:NSLineBreakByWordWrapping];
    _dateLabel.frame = CGRectMake((_bookmark.frame.size.width - size.width)/2.0f - 3.0f,
                                  (_bookmark.frame.size.height - size.height)/2.0f - 1.0f,
                                  size.width, size.height);
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                       _bookmark.alpha = 1.0f;
                       _dateLabel.alpha = 1.0f;
                     }];    
  }  
}


- (void)arrangeThumbails {
  
  if (self.allEvents.count > 0) {
    
    _pageControl.currentPage = _currentPageIndex;
    
    // arrange scroll content size
    [self removeContainedThumbnails];
    
    [self prepareCurrentEvents];
    
    // store loaded vidoes
    for (int i = 0; i < self.currentEvents.count; i++) {
      
      ThumbnailWithTitleView *thumbnailView = self.currentEvents[i];
      
      thumbnailView.frame = CGRectOffset(thumbnailView.frame,
                                         thumbnailView.frame.size.width * i, 0);
      
      [_wallView addSubview:thumbnailView];
    }
    
    [self fetchImage:(NSMutableArray *)self.thumbnailDic.allKeys forceNew:NO];
    
    if (self.allEvents.count > 2) {
      [_wallView setContentOffset:CGPointMake(_wallView.frame.size.width, 0)
                         animated:NO];
    }
  }
}

#pragma mark - re-prepare for load videos when user navigate back from sub layer
- (void)resetElements {
  self.allEvents = nil;
  
  [self.currentEvents removeAllObjects];
  
  if (_wallView.subviews.count > 0) {
    [_wallView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  }
  
  [self.thumbnailDic removeAllObjects];
  
  _pageControl.alpha = 0.0f;
}


#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  [self resetElements];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  if (_connectionCancelled) {
    return;
  }
  
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:self.MOC
                 connectorDelegate:self
                               url:url]) {
    
    [self loadEventsData];
    
    [self arrangeThumbails];
    
    if (_entrance && _refreshBadgeAction) {
      [_entrance performSelector:_refreshBadgeAction];
    }
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  [super connectFailed:error url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  ThumbnailWithTitleView *thumbnailView = (ThumbnailWithTitleView *)[self.thumbnailDic objectForKey:url];
  if (thumbnailView) {
    [thumbnailView setThumbnail:image
                       animated:YES];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  
  ThumbnailWithTitleView *thumbnailView = (ThumbnailWithTitleView *)[self.thumbnailDic objectForKey:url];
  if (thumbnailView) {
    [thumbnailView setThumbnail:image
                       animated:NO];
  }
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  if (self.allEvents.count > 2) {
    CGFloat x = scrollView.contentOffset.x;
    
    // scroll to right
    if (x >= (2 * _wallView.frame.size.width)) {
      _currentPageIndex = [self validPageValue:_currentPageIndex + 1];
      [self arrangeThumbails];
    }
    
    // scroll to left
    if (x <= 0) {
      _currentPageIndex = [self validPageValue:_currentPageIndex - 1];
      [self arrangeThumbails];
    }
    
    _pageControl.currentPage = _currentPageIndex;
  }
  
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if (self.allEvents.count <= 2) {
    _currentPageIndex = scrollView.contentOffset.x / _wallView.frame.size.width;
    _pageControl.currentPage = _currentPageIndex;
    
    // reset the carry out day count
    [self setDateBookmarkIfNeeded:self.allEvents[_currentPageIndex]];
  }
}

#pragma mark - touch event
- (void)openEvent:(UITapGestureRecognizer *)gesture {
  if (_entrance && _action && self.allEvents.count > 0) {
    Event *event = self.allEvents[_currentPageIndex];
    [_entrance performSelector:_action withObject:event];
  }
}
@end
