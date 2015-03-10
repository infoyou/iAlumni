//
//  WelfareItemWallView.m
//  iAlumni
//
//  Created by Adam on 13-8-18.
//
//

#import "WelfareItemWallView.h"
#import "AlbumPhoto.h"
#import "WXWLabel.h"

#define TITLE_BACKGROUND_HEIGHT 36.0f

#define TIMER_INTERVAL        5

#define MAX_STORED_COUNT      3

#define TOOL_ICON_SIDE_LEN    26.0f


@interface WelfareItemWallView ()
@property (nonatomic, retain) NSManagedObjectContext *MOC;
@property (nonatomic, retain) NSArray *imageList;
@property (nonatomic, retain) NSTimer *playControlTimer;
@property (nonatomic, retain) NSMutableDictionary *imageViewDic;
@property (nonatomic, retain) NSMutableArray *currentImageViews;
@end

@implementation WelfareItemWallView

#pragma mark - arrange images
- (int)validPageValue:(NSInteger)value {
  
  if (value == -1) {
    value = self.imageList.count - 1;
  }
  
  if (value == self.imageList.count) {
    value = 0;
  }
  
  return value;
}

- (void)removeContainedImageViews {
  NSArray *thumbnailViews = [_wallView subviews];
  if (thumbnailViews.count > 0) {
    [thumbnailViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  }
}

- (void)updatePageControl {
  _pageControl.numberOfPages = self.imageList.count;
  
  CGSize size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
  
  CGFloat width = size.width + MARGIN * 2;
  _pageControl.frame = CGRectMake((self.frame.size.width - width)/2.0f,
                                  (TITLE_BACKGROUND_HEIGHT - _pageControl.frame.size.height)/2,
                                  width,
                                  _pageControl.frame.size.height);
}

- (void)updateFavoritedStatus:(BOOL)status {
  NSString *imageName = status ? @"redFavorited.png" : @"whiteUnfavorited.png";
  [_favoriteButton setImage:[UIImage imageNamed:imageName]
                   forState:UIControlStateNormal];
  _favoriteLabel.text = status ? LocaleStringForKey(NSDeleteFavoriteTitle, nil): LocaleStringForKey(NSFavoriteTitle, nil);
  CGSize size = [_favoriteLabel.text sizeWithFont:_favoriteLabel.font];
  _favoriteLabel.frame = CGRectMake(_favoriteLabel.frame.origin.x,
                                    _favoriteLabel.frame.origin.y,
                                    size.width, size.height);
}

- (void)updateImageList:(NSArray *)imageList favoritedStatus:(BOOL)favoritedStatus {
  self.imageList = imageList;

  _wallView.contentSize = CGSizeMake(_wallView.frame.size.width * self.imageList.count, _wallView.frame.size.height);
  
  [self updateFavoritedStatus:favoritedStatus];
  
  [self updatePageControl];
  
  [self arrangeImageViews];
  
  [self triggerAutoPlay];
}

- (void)arrangeImageViews {
  
  if (self.imageList.count > 0) {
    
    [_pageControl setCurrentSelectedPage:_currentPageIndex];
    
    // arrange scroll content size
    [self removeContainedImageViews];
    
    [self prepareImageViews];
    
    // store loaded vidoes
    for (int i = 0; i < self.imageList.count; i++) {
      
      UIImageView *imageView = self.currentImageViews[i];
      
      imageView.frame = CGRectOffset(imageView.frame, imageView.frame.size.width * i, 0);
      
      [_wallView addSubview:imageView];
    }
    
    [self fetchImage:(NSMutableArray *)self.imageViewDic.allKeys forceNew:NO];
    
    if (self.imageList.count > 2) {
      [_wallView setContentOffset:CGPointMake(_wallView.frame.size.width, 0)
                         animated:NO];
    }
  }
}


#pragma mark - play control

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
                     for (UIImageView *imageView in self.currentImageViews) {
                       imageView.frame = CGRectMake(imageView .frame.origin.x - imageView.frame.size.width,
                                                        imageView.frame.origin.y,
                                                        imageView.frame.size.width,
                                                        imageView.frame.size.height);
                     }
                   }
                   completion:^(BOOL finished){
                     
                     if (!_stopScrolling) {
                       [self arrangeImageViews];
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
  
  if (self.imageList.count <= 2) {
    return;
  }
  
  self.playControlTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                           target:self
                                                         selector:@selector(autoPlay)
                                                         userInfo:nil
                                                          repeats:YES];
  [self.playControlTimer fire];
  
}

#pragma mark - life cycle methods

- (UIImageView *)createImageView:(NSInteger)index {
  AlbumPhoto *photo = self.imageList[index];
  
  UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          _wallView.frame.size.width,
                                                                          _wallView.frame.size.height)] autorelease];
  
  if (photo.imageUrl && photo.imageUrl.length > 0) {
    [self.imageViewDic setObject:imageView forKey:photo.imageUrl];
  }
    
  [self.imageViewDic setObject:imageView
                        forKey:photo.imageUrl];
  
  [self.currentImageViews addObject:imageView];
  
  return imageView;
}

- (void)prepareImageViews {
  
  if (self.imageViewDic == nil) {
    self.imageViewDic = [NSMutableDictionary dictionary];
  } else {
    [self.imageViewDic removeAllObjects];
  }
  
  if (self.currentImageViews == nil) {
    self.currentImageViews = [NSMutableArray array];
  } else {
    [self.currentImageViews removeAllObjects];
  }
  
  if (self.imageList.count == 1) {
    [self createImageView:_currentPageIndex];
  } else if (self.imageList.count == 2) {
    
    [self createImageView:_currentPageIndex];
    
    NSInteger next = [self validPageValue:_currentPageIndex + 1];
    [self createImageView:next];
  } else {
    
    NSInteger pre = [self validPageValue:_currentPageIndex - 1];
    [self createImageView:pre];
    
    [self createImageView:_currentPageIndex];
    
    NSInteger next = [self validPageValue:_currentPageIndex + 1];
    [self createImageView:next];
  }
}

- (void)initWall {
  
  _wallView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
  
  _wallView.delegate = self;
  _wallView.backgroundColor = TRANSPARENT_COLOR;
  _wallView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _wallView.bounces = YES;
  _wallView.directionalLockEnabled = YES;
  _wallView.pagingEnabled = YES;
  _wallView.showsVerticalScrollIndicator = NO;
  _wallView.showsHorizontalScrollIndicator = NO;
  
  /*
  UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(openAlumniNews:)] autorelease];
  [_wallView addGestureRecognizer:singleTap];
  */
  
  [self addSubview:_wallView];
}

- (void)addPageControl {
  
  _bottonBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - TITLE_BACKGROUND_HEIGHT, self.frame.size.width, TITLE_BACKGROUND_HEIGHT)] autorelease];
  _bottonBackgroundView.backgroundColor = [UIColor colorWithWhite:0.3f alpha:0.6f];
  [self addSubview:_bottonBackgroundView];
  
  _pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - MARGIN * 2 - 2.0f,
                                                                  self.frame.size.width, MARGIN * 2)] autorelease];
  _pageControl.userInteractionEnabled = NO;
  _pageControl.hidesForSinglePage = YES;
  [_pageControl setCurrentSelectedPage:0];
  _pageControl.layer.cornerRadius = MARGIN * 2/2.0f;
  _pageControl.layer.masksToBounds = YES;
  
  _pageControl.backgroundColor = TRANSPARENT_COLOR;
  
  [_bottonBackgroundView addSubview:_pageControl];
}

- (void)initToolsOnBotton {
  _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _favoriteButton.showsTouchWhenHighlighted = YES;
  _favoriteButton.frame = CGRectMake(MARGIN, MARGIN, TOOL_ICON_SIDE_LEN, TOOL_ICON_SIDE_LEN);
  [_favoriteButton setImage:[UIImage imageNamed:@"redFavorited.png"] forState:UIControlStateNormal];
  [_favoriteButton addTarget:_welfareDetailVC
                      action:_favoriteAction
            forControlEvents:UIControlEventTouchUpInside];
  [_bottonBackgroundView addSubview:_favoriteButton];
  
  _favoriteLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:[UIColor whiteColor]
                                        shadowColor:TRANSPARENT_COLOR
                                               font:BOLD_FONT(18)] autorelease];
  _favoriteLabel.text = LocaleStringForKey(NSFavoriteStatusTitle, nil);
  CGSize size = [_favoriteLabel.text sizeWithFont:_favoriteLabel.font];
  _favoriteLabel.frame = CGRectMake(_favoriteButton.frame.origin.x + TOOL_ICON_SIDE_LEN + MARGIN,
                                    (TITLE_BACKGROUND_HEIGHT - size.height)/2.0f, size.width, size.height);
  [_bottonBackgroundView addSubview:_favoriteLabel];
  
  _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];//[HintEnlargedButton buttonWithType:UIButtonTypeCustom];
  _shareButton.layer.masksToBounds = YES;
  _shareButton.frame = CGRectMake(_bottonBackgroundView.frame.size.width - 80, 0, 80, TITLE_BACKGROUND_HEIGHT);
  _shareButton.showsTouchWhenHighlighted = YES;
  [_shareButton setTitle:LocaleStringForKey(NSShareTitle, nil) forState:UIControlStateNormal];
  [_shareButton setImage:[UIImage imageNamed:@"whiteShare.png"] forState:UIControlStateNormal];
  [_shareButton addTarget:_welfareDetailVC
                   action:_shareAction
         forControlEvents:UIControlEventTouchUpInside];

  [_bottonBackgroundView addSubview:_shareButton];
}

- (void)fetchImages {
  NSMutableArray *urls = [NSMutableArray array];
  for (AlbumPhoto *photo in self.imageList) {
    [urls addObject:photo.imageUrl];
  }
  
  [self fetchImage:urls forceNew:NO];
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
    welfareDetailVC:(id)welfareDetailVC
     favoriteAction:(SEL)favoriteAction
        shareAction:(SEL)shareAction
    saveImageAction:(SEL)saveImageAction
{
  
  self = [super initWithFrame:frame
       imageDisplayerDelegate:imageDisplayerDelegate
       connectTriggerDelegate:nil];
  if (self) {
    
    self.MOC = MOC;
    
    _welfareDetailVC = welfareDetailVC;
    _favoriteAction = favoriteAction;
    _shareAction = shareAction;
    _saveImageAction = saveImageAction;
    
    [self initWall];

    [self addPageControl];
    
    [self initToolsOnBotton];
  }
  return self;
}

- (void)dealloc {
  self.imageList = nil;
  
  self.imageViewDic = nil;
  
  self.currentImageViews = nil;
  
  [self stopPlay];
  
  self.MOC = nil;
  
  [super dealloc];
}

#pragma mark - WXWImageFetcherDelegate methods

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  UIImageView *imageView = (UIImageView *)[self.imageViewDic objectForKey:url];
  if (imageView) {
    imageView.image = [WXWCommonUtils cutMiddlePartImage:image
                                                   width:_wallView.frame.size.width
                                                  height:_wallView.frame.size.height];
    
    if (_welfareDetailVC && _saveImageAction) {
      [_welfareDetailVC performSelector:_saveImageAction
                             withObject:imageView.image];
    }
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  
  [self imageFetchDone:image url:url];
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  if (self.imageList.count > 2) {
    CGFloat x = scrollView.contentOffset.x;
    
    // scroll to right
    if (x >= (2 * _wallView.frame.size.width)) {
      _currentPageIndex = [self validPageValue:_currentPageIndex + 1];
      [self arrangeImageViews];
    }
    
    // scroll to left
    if (x <= 0) {
      _currentPageIndex = [self validPageValue:_currentPageIndex - 1];
      [self arrangeImageViews];
    }
    
    [_pageControl setCurrentSelectedPage:_currentPageIndex];
  }
  
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  
  if (self.imageList.count <= 2) {
    _currentPageIndex = scrollView.contentOffset.x / _wallView.frame.size.width;
    
    [_pageControl setCurrentSelectedPage:_currentPageIndex];
  }
}

@end
