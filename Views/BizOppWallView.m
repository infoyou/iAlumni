//
//  BizOppWallView.m
//  iAlumni
//
//  Created by Adam on 13-8-13.
//
//

#import "BizOppWallView.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "News.h"
#import "ThumbnailWithTitleView.h"
#import "AlumniEntranceViewController.h"
#import "CachedNews.h"

#define TITLE_BACKGROUND_HEIGHT 46.0f

#define TIMER_INTERVAL        8

#define MAX_STORED_COUNT      3

#define NEWS_PREDICATE        [NSPredicate predicateWithFormat:@"type == %d", BIZ_NEWS_TY]

#define NEWS_FILE_NAME        @"newsFile"

#define NEWS_DATA_FILE       [[CommonUtils cacheNamedDirectory] stringByAppendingFormat:@"/%@", NEWS_FILE_NAME]


@interface BizOppWallView()
@property (nonatomic, retain) NSManagedObjectContext *MOC;
@property (nonatomic, retain) NSArray *allAlumniNews;
@property (nonatomic, retain) NSMutableArray *currentAlumniNews;
@property (nonatomic, retain) NSMutableDictionary *thumbnailDic;
@property (nonatomic, retain) NSTimer *playControlTimer;
@end


@implementation BizOppWallView

#pragma mark - utils methods
- (void)connectionCancelled:(NSNotification *)notification {
  if ([[notification object] isKindOfClass:[AlumniEntranceViewController class]]) {
    _connectionCancelled = YES;
  }
  
}

#pragma mark - user action
- (void)openAlumniNews:(UITapGestureRecognizer *)gesture {
  if (_entrance && _action) {
    [_entrance performSelector:_action withObject:self.allAlumniNews[_currentPageIndex]];
  }
}

#pragma mark - load news
- (void)loadLatestAlumniNews {
  
  NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>%@</page_size><news_type>%d</news_type>", 0, ITEM_LOAD_COUNT, BIZ_NEWS_TY];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_BIZ_NEWS_TY];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:LOAD_BIZ_NEWS_TY];
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods

- (void)initWall {
  
  _wallView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
  
  _wallView.delegate = self;
  _wallView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"defaultLoadingImage.png"]];
  _wallView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _wallView.bounces = YES;
  _wallView.directionalLockEnabled = YES;
  _wallView.pagingEnabled = YES;
  _wallView.showsVerticalScrollIndicator = NO;
  _wallView.showsHorizontalScrollIndicator = NO;
  
  UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(openAlumniNews:)] autorelease];
  [_wallView addGestureRecognizer:singleTap];
  
  [self addSubview:_wallView];
  
}

- (void)addConnectionCancellNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(connectionCancelled:)
                                               name:CONN_CANCELL_NOTIFY
                                             object:nil];
  
}

- (void)addPageControl {
  _pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - MARGIN * 2 - 2.0f, self.frame.size.width, MARGIN * 2)] autorelease];
  _pageControl.userInteractionEnabled = NO;
  _pageControl.numberOfPages = self.allAlumniNews.count;
  _pageControl.hidesForSinglePage = YES;
  [_pageControl setCurrentSelectedPage:0];
  _pageControl.layer.cornerRadius = MARGIN * 2/2.0f;
  _pageControl.layer.masksToBounds = YES;
  
  CGSize size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
  
  CGFloat width = size.width + MARGIN * 2;
  _pageControl.frame = CGRectMake(self.frame.size.width - width - MARGIN * 2,
                                  self.frame.size.height - TITLE_BACKGROUND_HEIGHT + (TITLE_BACKGROUND_HEIGHT - _pageControl.frame.size.height)/2,
                                  width,
                                  _pageControl.frame.size.height);
  
  _pageControl.backgroundColor = [UIColor colorWithWhite:0.3f alpha:0.6f];
  
  [self addSubview:_pageControl];
}

- (void)arrangeLastDownloadedNews {
  [self loadNewsFromCacheNamedDirectory];
  
  [self arrangeThumbails];
}


- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
                MOC:(NSManagedObjectContext *)MOC
           entrance:(id)entrance
             action:(SEL)action {
  self = [super initWithFrame:frame
       imageDisplayerDelegate:imageDisplayerDelegate
       connectTriggerDelegate:connectTriggerDelegate];
  if (self) {
    
    self.MOC = MOC;
    
    _entrance = entrance;
    
    _action = action;
    
    [self initWall];
    
    if (![WXWCoreDataUtils objectInMOC:MOC
                            entityName:@"News"
                             predicate:NEWS_PREDICATE]) {
      
      // step 1. load local cached news
      [self arrangeLastDownloadedNews];
      
      // step 2. load from backend system
      [self loadLatestAlumniNews];
      
    } else {
      
      [self loadAlumniNewsDataWithPredicate:NEWS_PREDICATE];
      
      [self arrangeThumbails];
    }
    
    
    [self addConnectionCancellNotification];
  }
  return self;
}

- (void)dealloc {
  
  [self stopPlay];
  
  self.MOC = nil;
  
  self.allAlumniNews = nil;
  
  self.currentAlumniNews = nil;
  
  self.thumbnailDic = nil;
  
  _wallView.delegate = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:CONN_CANCELL_NOTIFY
                                                object:nil];
  
  [super dealloc];
}

#pragma mark - handle local cached news
- (void)saveNewsIntoLocalArchive {
  
  if (self.allAlumniNews.count == 0) {
    return;
  }
  
  [CommonUtils deleteCacheNamedDirectoryWithFileName:NEWS_FILE_NAME];
  
  NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
  NSMutableArray *cachedNewsList = [NSMutableArray array];
  for (News *news in self.allAlumniNews) {
    CachedNews *cachedNews = [[[CachedNews alloc] init] autorelease];
    cachedNews.date = news.date;
    cachedNews.dateSeparator = news.dateSeparator;
    cachedNews.drawnFrom = news.drawnFrom;
    cachedNews.elapsedDayCount = news.elapsedDayCount;
    cachedNews.elapsedTime = news.elapsedTime;
    cachedNews.imageAttached = news.imageAttached;
    cachedNews.imageUrl = news.imageUrl;
    cachedNews.newsId = news.newsId;
    cachedNews.originalImageHeight = news.originalImageHeight;
    cachedNews.originalImageWidth = news.originalImageWidth;
    cachedNews.subTitle = news.subTitle;
    cachedNews.thumbnailUrl = news.thumbnailUrl;
    cachedNews.timestamp = news.timestamp;
    cachedNews.title = news.title;
    cachedNews.url = news.url;
    cachedNews.type = news.type;

    
    [cachedNewsList addObject:cachedNews];
  }
  
  NSKeyedArchiver *arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [arch encodeObject:cachedNewsList forKey:NEWS_FILE_NAME];
  [arch finishEncoding];
  [arch release];
  
  [CommonUtils saveLocalFile:data fileName:NEWS_FILE_NAME];
}

- (void)loadNewsFromCacheNamedDirectory {
  
  if([[NSFileManager defaultManager] fileExistsAtPath:NEWS_DATA_FILE]) {
    NSData *objData = [CommonUtils readLocalFile:NEWS_FILE_NAME];
    
    NSKeyedUnarchiver *darch = [[NSKeyedUnarchiver alloc] initForReadingWithData:objData];
    id object = [darch decodeObjectForKey:NEWS_FILE_NAME];
    [darch finishDecoding];
    [darch release];
    
    NSMutableArray *cachedNewsList = object;
    
    NSMutableArray *newsList = [NSMutableArray array];
    for (CachedNews *cachedNews in cachedNewsList) {
      News *news = (News *)[NSEntityDescription insertNewObjectForEntityForName:@"News"
                                                         inManagedObjectContext:_MOC];
      news.date = cachedNews.date;
      news.dateSeparator = cachedNews.dateSeparator;
      news.drawnFrom = cachedNews.drawnFrom;
      news.elapsedDayCount = cachedNews.elapsedDayCount;
      news.elapsedTime = cachedNews.elapsedTime;
      news.imageAttached = cachedNews.imageAttached;
      news.imageUrl = cachedNews.imageUrl;
      news.newsId = cachedNews.newsId;
      news.originalImageHeight = cachedNews.originalImageHeight;
      news.originalImageWidth = cachedNews.originalImageWidth;
      news.subTitle = cachedNews.subTitle;
      news.thumbnailUrl = cachedNews.thumbnailUrl;
      news.timestamp = cachedNews.timestamp;
      news.title = cachedNews.title;
      news.url = cachedNews.url;
      news.type = cachedNews.type;

      
      [newsList addObject:news];
    }
    self.allAlumniNews = newsList;
    
  } else {
    self.allAlumniNews = nil;
  }
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
  
  _currentPageIndex = [self validPageValue:_currentPageIndex + 1];
  
  [UIView animateWithDuration:0.5f
                   animations:^{
                     for (ThumbnailWithTitleView *thumbanilView in self.currentAlumniNews) {
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
  
  if (self.playControlTimer && [self.playControlTimer isValid]) {
    [self.playControlTimer invalidate];
  }
  self.playControlTimer = nil;
}

- (void)play {
  _stopScrolling = NO;
  
  [self triggerAutoPlay];
}

- (void)triggerAutoPlay {
  
  if (self.allAlumniNews.count <= 2) {
    return;
  }
  
  self.playControlTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                           target:self
                                                         selector:@selector(autoPlay)
                                                         userInfo:nil
                                                          repeats:YES];
  [self.playControlTimer fire];
  
}

- (int)validPageValue:(NSInteger)value {
  
  if (value == -1) {
    value = self.allAlumniNews.count - 1;
  }
  
  if (value == self.allAlumniNews.count) {
    value = 0;
  }
  
  return value;
}

- (void)triggerRearrangeForNoAlumniNews {
  [[NSNotificationCenter defaultCenter] postNotificationName:NO_ALUMNI_NEWS_NOTIFY
                                                      object:nil
                                                    userInfo:nil];
}

- (void)loadAlumniNewsDataWithPredicate:(NSPredicate *)predicate {
  
  NSMutableArray *sortDescs = [NSMutableArray array];
  NSSortDescriptor *desc = [[[NSSortDescriptor alloc] initWithKey:@"newsId"
                                                        ascending:NO] autorelease];
  [sortDescs addObject:desc];
  
  self.allAlumniNews = [WXWCoreDataUtils fetchObjectsFromMOC:self.MOC
                                                  entityName:@"News"
                                                   predicate:predicate
                                                   sortDescs:sortDescs];
  
  if (0 == self.allAlumniNews.count) {
    
    [self triggerRearrangeForNoAlumniNews];
    
  } else {
    
    // save into local file
    [self saveNewsIntoLocalArchive];
    
    NSInteger count = MAX_STORED_COUNT;
    if (self.allAlumniNews.count < MAX_STORED_COUNT) {
      count = self.allAlumniNews.count;
    }
    _wallView.contentSize = CGSizeMake(_wallView.frame.size.width * count, _wallView.frame.size.height);
    
    if (nil == _pageControl) {
      [self addPageControl];
    }
    
    if (self.allAlumniNews.count > 2) {
      [self performSelector:@selector(triggerAutoPlay)
                 withObject:nil
                 afterDelay:2];
    }
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
  News *alumniNews = self.allAlumniNews[index];
  
  ThumbnailWithTitleView *thumbnailView = [[[ThumbnailWithTitleView alloc] initNeedLeftTitleWithFrame:CGRectMake(0, 0,
                                                                                                                 _wallView.frame.size.width,
                                                                                                                 _wallView.frame.size.height)] autorelease];
  
  if (alumniNews.imageUrl && alumniNews.imageUrl.length > 0) {
    [self.thumbnailDic setObject:thumbnailView forKey:alumniNews.imageUrl];
  }
  
  [thumbnailView setThumbnail:[CommonUtils cutMiddlePartImage:[UIImage imageNamed:alumniNews.imageUrl]
                                                        width:self.bounds.size.width
                                                       height:self.bounds.size.height]
                     animated:YES];
  
  if (nil == alumniNews.imageUrl || 0 == alumniNews.imageUrl.length) {
    [self.thumbnailDic setObject:thumbnailView
                          forKey:[self generateFakeImageUrlForIndex:index]];
  } else {
    [self.thumbnailDic setObject:thumbnailView forKey:alumniNews.imageUrl];
  }
  
  
  CGFloat limitedWidth = _pageControl.frame.origin.x - MARGIN * 2;
  [thumbnailView setLeftTitle:alumniNews.title limitedWidth:limitedWidth];
  
  [self.currentAlumniNews addObject:thumbnailView];
  
  return thumbnailView;
}

- (void)prepareCurrentAlumniNews {
  
  if (self.thumbnailDic == nil) {
    self.thumbnailDic = [NSMutableDictionary dictionary];
  } else {
    [self.thumbnailDic removeAllObjects];
  }
  
  if (self.currentAlumniNews == nil) {
    self.currentAlumniNews = [NSMutableArray array];
  } else {
    [self.currentAlumniNews removeAllObjects];
  }
  
  if (self.allAlumniNews.count == 1) {
    [self createThumbnailView:_currentPageIndex];
  } else if (self.allAlumniNews.count == 2) {
    
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

- (void)arrangeThumbails {
  
  if (self.allAlumniNews.count > 0) {
    
    [_pageControl setCurrentSelectedPage:_currentPageIndex];
    
    // arrange scroll content size
    [self removeContainedThumbnails];
    
    [self prepareCurrentAlumniNews];
    
    // store loaded vidoes
    for (int i = 0; i < self.currentAlumniNews.count; i++) {
      
      ThumbnailWithTitleView *thumbnailView = self.currentAlumniNews[i];
      
      thumbnailView.frame = CGRectOffset(thumbnailView.frame,
                                         thumbnailView.frame.size.width * i, 0);
      
      [_wallView addSubview:thumbnailView];
      
    }
    
    [self fetchImage:(NSMutableArray *)self.thumbnailDic.allKeys forceNew:NO];
    
    
    if (self.allAlumniNews.count > 2) {
      [_wallView setContentOffset:CGPointMake(_wallView.frame.size.width, 0)
                         animated:NO];
    }
  }
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  if (_connectionCancelled) {
    return;
  }
  
  DELETE_OBJS_FROM_MOC(self.MOC, @"News", NEWS_PREDICATE);
  
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:self.MOC
                 connectorDelegate:self
                               url:url]) {
    
    [self loadAlumniNewsDataWithPredicate:NEWS_PREDICATE];
    
    [self arrangeThumbails];
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
  
  if (self.allAlumniNews.count > 2) {
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
    
    [_pageControl setCurrentSelectedPage:_currentPageIndex];
  }
  
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  
  if (self.allAlumniNews.count <= 2) {
    _currentPageIndex = scrollView.contentOffset.x / _wallView.frame.size.width;
    
    [_pageControl setCurrentSelectedPage:_currentPageIndex];
  }
}
@end
