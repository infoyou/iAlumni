//
//  VideoWallContainerView.m
//  iAlumni
//
//  Created by Adam on 13-1-9.
//
//

#import "VideoWallContainerView.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "ThumbnailWithTitleView.h"
#import "HomepageEntranceViewController.h"
#import "CachedVideo.h"
#import "VideoPoster.h"

#define TITLE_BACKGROUND_HEIGHT 46.0f

#define TIMER_INTERVAL        8

#define MAX_STORED_COUNT      3

#define VIDEOS_FILE_NAME      @"videosFile"

#define VIDEO_DATA_FILE       [[CommonUtils cacheNamedDirectory] stringByAppendingFormat:@"/%@", VIDEOS_FILE_NAME]

@interface VideoWallContainerView()
@property (nonatomic, retain) NSManagedObjectContext *MOC;
@property (nonatomic, retain) NSArray *allVideos;
@property (nonatomic, retain) NSMutableArray *currentVideos;
@property (nonatomic, retain) NSMutableDictionary *thumbnailDic;
@property (nonatomic, retain) NSTimer *playControlTimer;
@end

@implementation VideoWallContainerView

#pragma mark - utils methods
- (void)connectionCancelled:(NSNotification *)notification {
    if ([[notification object] isKindOfClass:[HomepageEntranceViewController class]]) {
        _connectionCancelled = YES;
    }
    
}

#pragma mark - load videos
- (void)loadLatestVideos {
    
    NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>%@</page_size><is_home_page>1</is_home_page>", 0, ITEM_LOAD_COUNT];
    
    NSString *url = [CommonUtils geneUrl:param itemType:LOAD_LATEST_VIDEO_TY];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:LOAD_LATEST_VIDEO_TY];
    [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - current video
- (NSInteger)currentVideoId {
    return ((VideoPoster *)self.allVideos[_currentPageIndex]).videoId.intValue;
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
                                                                                 action:@selector(openVideo:)] autorelease];
    [_wallView addGestureRecognizer:singleTap];
    
    [self addSubview:_wallView];
    
}

- (void)addPageControl {
    _pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - MARGIN * 2 - 2.0f, self.frame.size.width, MARGIN * 2)] autorelease];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.hidesForSinglePage = YES;
    [_pageControl setCurrentSelectedPage:0];
    _pageControl.backgroundColor = TRANSPARENT_COLOR;
    [self addSubview:_pageControl];
}

- (void)arrangePageControl {
    
    if (nil == _pageControl) {
        [self addPageControl];
    }
    
    if (self.allVideos.count > 0) {
        _pageControl.numberOfPages = self.allVideos.count;
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

- (void)arrangeLastDownloadedVideos {
    [self loadVideosFromCacheNamedDirectory];
    
    [self arrangeThumbails];
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
                MOC:(NSManagedObjectContext *)MOC
           entrance:(id)entrance
             action:(SEL)action
{
    self = [super initWithFrame:frame
         imageDisplayerDelegate:imageDisplayerDelegate
         connectTriggerDelegate:connectTriggerDelegate];
    if (self) {
        
        _entrance = entrance;
        
        _action = action;
        
        self.MOC = MOC;
        
        [self initWall];
        
        if (![WXWCoreDataUtils objectInMOC:MOC
                                entityName:@"VideoPoster"
                                 predicate:nil]) {
            
            // step 1.
            [self arrangeLastDownloadedVideos];
            
            // step 2
            [self loadLatestVideos];
            
        } else {
            
            [self loadVideosData];
            
            [self arrangeThumbails];
        }
        
        [self addConnectionCancellNotification];
    }
    return self;
}

- (void)dealloc {
    
    [self stopPlay];
    
    self.allVideos = nil;
    
    self.currentVideos = nil;
    
    self.thumbnailDic = nil;
    
    _wallView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CONN_CANCELL_NOTIFY
                                                  object:nil];
    
    self.MOC = nil;
    
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
    
    if (0 == self.allVideos.count) {
        return;
    }
    
    _currentPageIndex = [self validPageValue:_currentPageIndex + 1];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (ThumbnailWithTitleView *thumbanilView in self.currentVideos) {
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
    
    if (self.allVideos.count <= 2 || _autoScrolling) {
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
        value = self.allVideos.count - 1;
    }
    
    if (value == self.allVideos.count) {
        value = 0;
    }
    
    return value;
}

- (void)saveVideosIntoLocalArchive {
    
    if (self.allVideos.count == 0) {
        return;
    }
    
    [CommonUtils deleteCacheNamedDirectoryWithFileName:VIDEOS_FILE_NAME];
    
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    
    NSMutableArray *cachedVideos = [NSMutableArray array];
    for (VideoPoster *video in self.allVideos) {
        CachedVideo *cachedVideo = [[[CachedVideo alloc] init] autorelease];
        cachedVideo.imageUrl = video.imageUrl;
        cachedVideo.order = video.order;
        cachedVideo.videoId = video.videoId;
        cachedVideo.videoName = video.videoName;
        
        [cachedVideos addObject:cachedVideo];
    }
    
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [arch encodeObject:cachedVideos forKey:VIDEOS_FILE_NAME];
    [arch finishEncoding];
    [arch release];
    
    [CommonUtils saveLocalFile:data fileName:VIDEOS_FILE_NAME];
}

- (void)loadVideosFromCacheNamedDirectory {
    
    if([[NSFileManager defaultManager] fileExistsAtPath:VIDEO_DATA_FILE]) {
        NSData *objData = [CommonUtils readLocalFile:VIDEOS_FILE_NAME];
        
        NSKeyedUnarchiver *darch = [[NSKeyedUnarchiver alloc] initForReadingWithData:objData];
        id object = [darch decodeObjectForKey:VIDEOS_FILE_NAME];
        [darch finishDecoding];
        [darch release];
        
        NSMutableArray *cachedVideos = object;
        
        NSMutableArray *videos = [NSMutableArray array];
        for (CachedVideo *cachedVideo in cachedVideos) {
            VideoPoster *video = (VideoPoster *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoPoster"
                                                                              inManagedObjectContext:_MOC];
            video.imageUrl = cachedVideo.imageUrl;
            video.order = cachedVideo.order;
            video.videoId = cachedVideo.videoId;
            video.videoName = cachedVideo.videoName;
            [videos addObject:video];
        }
        self.allVideos = videos;
        
        _usingLocalCachedVideos = YES;
        
    } else {
        self.allVideos = nil;
    }
}

- (void)loadVideosData {
    
    NSMutableArray *sortDescs = [NSMutableArray array];
    NSSortDescriptor *desc = [[[NSSortDescriptor alloc] initWithKey:@"videoId"
                                                          ascending:NO] autorelease];
    [sortDescs addObject:desc];
    
    self.allVideos = [WXWCoreDataUtils fetchObjectsFromMOC:self.MOC
                                                entityName:@"VideoPoster"
                                                 predicate:nil
                                                 sortDescs:sortDescs
                                             limitedNumber:5];
    
    if (self.allVideos.count > 0) {
        [self saveVideosIntoLocalArchive];
    }
    
    NSInteger count = MAX_STORED_COUNT;
    if (self.allVideos.count < MAX_STORED_COUNT) {
        count = self.allVideos.count;
    }
    _wallView.contentSize = CGSizeMake(_wallView.frame.size.width * count, _wallView.frame.size.height);
    
    [self arrangePageControl];
    
    if (self.allVideos.count > 2) {
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
    VideoPoster *video = self.allVideos[index];
    
    ThumbnailWithTitleView *thumbnailView = [[[ThumbnailWithTitleView alloc] initNeedBottomTitleWithFrame:CGRectMake(0, 0,
                                                                                                                     _wallView.frame.size.width,
                                                                                                                     _wallView.frame.size.height)] autorelease];
    
    if (video.imageUrl && video.imageUrl.length > 0) {
        [self.thumbnailDic setObject:thumbnailView forKey:video.imageUrl];
    }
    
    [thumbnailView setTitle:[NSString stringWithFormat:@"%@%@", LocaleStringForKey(NSBracketsVideoTitle, nil), video.videoName]
                   subTitle:nil];
    
    [self.currentVideos addObject:thumbnailView];
    
    return thumbnailView;
}

- (void)prepareCurrentVideos {
    
    if (self.thumbnailDic == nil) {
        self.thumbnailDic = [NSMutableDictionary dictionary];
    } else {
        [self.thumbnailDic removeAllObjects];
    }
    
    if (self.currentVideos == nil) {
        self.currentVideos = [NSMutableArray array];
    } else {
        [self.currentVideos removeAllObjects];
    }
    
    if (self.allVideos.count == 1) {
        [self createThumbnailView:_currentPageIndex];
    } else if (self.allVideos.count == 2) {
        
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
    
    if (self.allVideos.count > 0) {
        
        [_pageControl setCurrentSelectedPage:_currentPageIndex];
        
        // arrange scroll content size
        [self removeContainedThumbnails];
        
        //    if (self.thumbnailDic.count == 0) {
        [self prepareCurrentVideos];
        //    }
        
        
        // store loaded vidoes
        for (int i = 0; i < self.currentVideos.count; i++) {
            
            ThumbnailWithTitleView *thumbnailView = self.currentVideos[i];
            
            thumbnailView.frame = CGRectOffset(thumbnailView.frame,
                                               thumbnailView.frame.size.width * i, 0);
            
            [_wallView addSubview:thumbnailView];
        }
        
        [self fetchImage:(NSMutableArray *)self.thumbnailDic.allKeys forceNew:NO];
        
        if (self.allVideos.count > 2) {
            [_wallView setContentOffset:CGPointMake(_wallView.frame.size.width, 0)
                               animated:NO];
        }
    }
}

#pragma mark - re-prepare for load videos when user navigate back from sub layer
- (void)resetElements {
    self.allVideos = nil;
    
    [self.currentVideos removeAllObjects];
    
    if (_wallView.subviews.count > 0) {
        [_wallView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self.thumbnailDic removeAllObjects];
    
    _pageControl.alpha = 0.0f;
    
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
    
    if (!_usingLocalCachedVideos) {
        [self resetElements];
    }
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
    
    if (_connectionCancelled) {
        return;
    }
    
    // delete all videos before load operation every time
    DELETE_OBJS_FROM_MOC(self.MOC, @"VideoPoster", nil);
    
    if ([XMLParser parserResponseXml:result
                                type:contentType
                                 MOC:self.MOC
                   connectorDelegate:self
                                 url:url]) {
        
        [self loadVideosData];
        
        _usingLocalCachedVideos = NO;
        
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
    
    if (self.allVideos.count > 2) {
        CGFloat x = scrollView.contentOffset.x;
        
        // scroll to right
        if (x >= (_wallView.frame.size.width * 2)) {
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
    
    if (self.allVideos.count <= 2) {
        _currentPageIndex = scrollView.contentOffset.x / _wallView.frame.size.width;
        [_pageControl setCurrentSelectedPage:_currentPageIndex];
    }
}

#pragma mark - touch event
- (void)openVideo:(UITapGestureRecognizer *)gesture {
    if (_entrance && _action) {
        [_entrance performSelector:_action];
    }
}

@end
