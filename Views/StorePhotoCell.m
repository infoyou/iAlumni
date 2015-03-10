//
//  StorePhotoCell.m
//  iAlumni
//
//  Created by Adam on 13-8-21.
//
//

#import "StorePhotoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AlbumPhoto.h"

#define CELL_HEIGHT   185.0f

#define BTN_WIDTH     22.0f
#define BTN_HEIGHT    21.0f

#define INNER_MARGIN      8.0f

@interface StorePhotoCell ()
@property (nonatomic, retain) NSArray *imageList;
@property (nonatomic, retain) NSMutableDictionary *imageViewDic;
@property (nonatomic, retain) NSMutableArray *currentImageViews;
@end


@implementation StorePhotoCell

#pragma mark - user action
- (void)moveToLeft:(id)sender {
  if (_currentPageIndex == 0) {
    return;
  }
  
  CGFloat currentOffset = _wallView.contentOffset.x;
  CGFloat newOffset = currentOffset - _wallView.frame.size.width;
  
  [_wallView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
  
  _currentPageIndex = [self validPageValue:_currentPageIndex - 1];
  
  [self arrangeButtons];
}

- (void)moveToRight:(id)sender {
  if (_currentPageIndex == self.imageList.count - 1) {
    return;
  }
  
  CGFloat currentOffset = _wallView.contentOffset.x;
  CGFloat newOffset = currentOffset + _wallView.frame.size.width;

  [_wallView setContentOffset:CGPointMake(newOffset, 0) animated:YES];

  _currentPageIndex = [self validPageValue:_currentPageIndex + 1];
  
  [self arrangeButtons];
}

#pragma mark - life cycle methods
- (void )initBoardView {
  if (nil == _boardView) {
    _boardView = [[[UIView alloc] initWithFrame:CGRectMake(WELFARE_CELL_MARGIN,
                                                                         0,
                                                                         self.frame.size.width - WELFARE_CELL_MARGIN * 2,
                                                                         CELL_HEIGHT)] autorelease];
    _boardView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:_boardView];
    
    _boardView.layer.shadowColor = [UIColor grayColor].CGColor;
    _boardView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(2, 10, _boardView.bounds.size.width - 4, _boardView.bounds.size.height - 10)].CGPath;
    _boardView.layer.shadowOffset = CGSizeZero;
    _boardView.layer.shadowOpacity = 1.0f;
    _boardView.layer.shadowRadius = 2.0f;
  }
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC { 
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self initBoardView];
    
    [self initWall];
  }
  return self;
}

- (void)dealloc {
  
  self.imageList = nil;
  
  self.imageViewDic = nil;
  
  self.currentImageViews = nil;
  
  [super dealloc];
}

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

- (void)updateImageList:(NSArray *)imageList {
  
  if (imageList.count == 0) {
    return;
  }
  
  self.imageList = imageList;
  
  _wallView.contentSize = CGSizeMake(_wallView.frame.size.width * self.imageList.count, _wallView.frame.size.height);
  
  [self arrangeImageViews];
  
}

- (void)arrangeImageViews {
  
  if (self.imageList.count > 0) {
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

- (void)arrangeButtons {
  if (_currentPageIndex == 0) {
    _leftButton.alpha = 0.0f;
    _rightButton.alpha = 1.0f;
  } else if (_currentPageIndex == self.imageList.count - 1) {
    _rightButton.alpha = 0.0f;
    _leftButton.alpha = 1.0;
  } else {
    _leftButton.alpha = 1.0f;
    _rightButton.alpha = 1.0f;
  }
}

- (UIImageView *)createImageView:(NSInteger)index {
  AlbumPhoto *photo = self.imageList[index];
  
  UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          _wallView.frame.size.width,
                                                                          _wallView.frame.size.height)] autorelease];
  imageView.backgroundColor = [UIColor whiteColor];
  
  if (photo.imageUrl && photo.imageUrl.length > 0) {
    [self.imageViewDic setObject:imageView forKey:photo.imageUrl];
  }
  
  [self.imageViewDic setObject:imageView
                        forKey:photo.imageUrl];
  
  [self.currentImageViews addObject:imageView];
  
  return imageView;
}

- (void)createLeftButton {
  _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _leftButton.frame = CGRectMake(INNER_MARGIN, (CELL_HEIGHT - BTN_HEIGHT)/2.0f, BTN_WIDTH, BTN_HEIGHT);
  [_leftButton setImage:[UIImage imageNamed:@"whiteLeftArrow.png"] forState:UIControlStateNormal];
  [_leftButton addTarget:self
                  action:@selector(moveToLeft:)
        forControlEvents:UIControlEventTouchUpInside];
  [_boardView addSubview:_leftButton];
}

- (void)createRightButton {
  _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _rightButton.frame = CGRectMake(_boardView.frame.size.width - INNER_MARGIN - BTN_WIDTH, (CELL_HEIGHT - BTN_HEIGHT)/2.0f, BTN_WIDTH, BTN_HEIGHT);
  [_rightButton setImage:[UIImage imageNamed:@"whiteRightArrow.png"] forState:UIControlStateNormal];
  [_rightButton addTarget:self
                  action:@selector(moveToRight:)
        forControlEvents:UIControlEventTouchUpInside];
  [_boardView addSubview:_rightButton];
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
    
    [self createLeftButton];
    _leftButton.alpha = 0.0f;
    
    [self createRightButton];
  } else {
    
    for (int i = 0; i < self.imageList.count; i++) {
      [self createImageView:i];
    }
    
    _currentPageIndex = 1;
    
    [self createLeftButton];
    [self createRightButton];
  }
  
}

- (void)initWall {
  
  _wallView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _boardView.frame.size.width, _boardView.frame.size.height)] autorelease];
  
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
  
  [_boardView addSubview:_wallView];
}


- (void)fetchImages {
  NSMutableArray *urls = [NSMutableArray array];
  for (AlbumPhoto *photo in self.imageList) {
    [urls addObject:photo.imageUrl];
  }
  
  [self fetchImage:urls forceNew:NO];
}

#pragma mark - WXWImageFetcherDelegate methods

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  UIImageView *imageView = (UIImageView *)[self.imageViewDic objectForKey:url];
  if (imageView) {
    imageView.image = [WXWCommonUtils cutMiddlePartImage:image
                                                   width:_wallView.frame.size.width
                                                  height:_wallView.frame.size.height];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  
  UIImageView *imageView = (UIImageView *)[self.imageViewDic objectForKey:url];
  if (imageView) {
    imageView.image = [WXWCommonUtils cutMiddlePartImage:image
                                                   width:_wallView.frame.size.width
                                                  height:_wallView.frame.size.height];
  }
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  
  _currentPageIndex = scrollView.contentOffset.x / _wallView.frame.size.width;
  
  [self arrangeButtons];
}
@end
