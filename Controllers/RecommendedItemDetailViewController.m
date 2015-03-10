//
//  RecommendedItemDetailViewController.m
//  ExpatCircle
//
//  Created by Adam on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecommendedItemDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ServiceItemLikerAlbumView.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "HttpUtils.h"
#import "XMLParser.h"
#import "RecommendedItem.h"
#import "AppManager.h"
#import "WXWLabel.h"
#import "ItemNamesView.h"
#import "ECAsyncConnectorFacade.h"
#import "RecommendedItemLikeAreaView.h"
#import "CoreDataUtils.h"
#import "UIUtils.h"
#import "ItemLikersListViewController.h"

#define ITEM_PHOTO_SIDE_LENGTH  300.0f

#define LIKE_ACTION_AREA_HEIGHT 45.0f



@interface RecommendedItemDetailViewController ()
@property (nonatomic, retain) UIActivityIndicatorView *likeSpinView;
@property (nonatomic, copy) NSString *hashedLikedItemId;
@end

@implementation RecommendedItemDetailViewController

@synthesize likeSpinView = _likeSpinView;
@synthesize hashedLikedItemId = _hashedLikedItemId;

#pragma mark - fetch image if necessary

- (void)fetchImage:(NSString *)imageUrl {
  
  [self registerImageUrl:imageUrl];
  
  [[WXWImageManager instance] fetchImage:imageUrl
                             caller:self 
                           forceNew:NO];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC 
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction
             item:(RecommendedItem *)item {
  
  self = [super initWithMOC:MOC 
                     holder:holder 
           backToHomeAction:backToHomeAction
                 needGoHome:NO];
  
  if (self) {
    _item = item;
    
    self.hashedLikedItemId = [CommonUtils hashStringAsMD5:[NSString stringWithFormat:@"%@_%@_recommendedItem", 
                                                           _item.itemId, _item.serviceItemId]];
  }
  return self;
}

- (void)dealloc {
  
  self.hashedLikedItemId = nil;
  
  [super dealloc];
}

- (void)initPhotoView {
  
  if (_item.imageUrl && _item.imageUrl.length > 0) {
    CGFloat backgroundViewWidth = ITEM_PHOTO_SIDE_LENGTH + MARGIN * 2;
    _imageBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN, 
                                                                     MARGIN, 
                                                                     backgroundViewWidth, 
                                                                     backgroundViewWidth)] autorelease];
    _imageBackgroundView.backgroundColor = [UIColor whiteColor];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    CGFloat curlFactor = 10.0f;
    CGFloat shadowDepth = 4.0f;
    [shadowPath moveToPoint:CGPointMake(0, 0)];
    [shadowPath addLineToPoint:CGPointMake(backgroundViewWidth, 0)];
    [shadowPath addLineToPoint:CGPointMake(backgroundViewWidth, 
                                           backgroundViewWidth + shadowDepth)];
    [shadowPath addCurveToPoint:CGPointMake(0.0f, backgroundViewWidth + shadowDepth)
                  controlPoint1:CGPointMake(backgroundViewWidth - curlFactor, 
                                            backgroundViewWidth + shadowDepth - curlFactor)
                  controlPoint2:CGPointMake(curlFactor, 
                                            backgroundViewWidth + shadowDepth - curlFactor)];
    
    _imageBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _imageBackgroundView.layer.shadowOpacity = 0.7f;
    _imageBackgroundView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _imageBackgroundView.layer.shadowRadius = 2.0f;
    _imageBackgroundView.layer.masksToBounds = NO;
    
    _imageBackgroundView.layer.shadowPath = shadowPath.CGPath;
    [_contentView addSubview:_imageBackgroundView];
    
    
    _defaultImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallLogo.png"]] autorelease];
    _defaultImageView.center = _imageBackgroundView.center;
    [_imageBackgroundView addSubview:_defaultImageView];
    
    if (_item.imageUrl && _item.imageUrl.length > 0) {
      [self fetchImage:_item.imageUrl];
    }
  }
}

- (void)initSelfProperties {
  self.view.backgroundColor = CELL_COLOR;
  
  CGRect frame = _contentView.frame;
  frame.size.height = _introContentView.frame.origin.y + _introContentView.frame.size.height;
  _contentView.contentSize = CGSizeMake(frame.size.width, frame.size.height + 44.0f);
}

- (void)initNameLabels {
  
  UIFont *font = BOLD_FONT(14);
  _namesView = [[[ItemNamesView alloc] initWithFrame:CGRectZero
                                              enName:_item.enName
                                              cnName:_item.cnName
                                                font:font] autorelease];
  _namesView.userInteractionEnabled = NO;
  _namesView.backgroundColor = TRANSPARENT_COLOR;
  
  [_contentView addSubview:_namesView];
  
  /*
  CGSize size = [_item.enName sizeWithFont:font
                         constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 2, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = size.height;
   */
  
  CGSize size = [_item.cnName sizeWithFont:font
                  constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 2, CGFLOAT_MAX)
                      lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = size.height + MARGIN * 2;
  
  
  CGFloat y = 0.0f;
  if (_item.imageUrl && _item.imageUrl.length > 0) {
    y = _imageBackgroundView.frame.origin.y + _imageBackgroundView.frame.size.height + MARGIN;
  } else {
    
    // if no image, then arrange the name labes on the first
    y = MARGIN;
  }
  _namesView.frame = CGRectMake(0, 
                                y,
                                self.view.frame.size.width, 
                                height);
  
  [_namesView arrangeNames];
}

- (void)initLikerAlbumArea {
  _likerAlbumArea = [[[RecommendedItemLikeAreaView alloc] initWithFrame:CGRectMake(0.0f, 
                                                                                   _namesView.frame.origin.y + 
                                                                                   _namesView.frame.size.height, 
                                                                                   self.view.frame.size.width, 
                                                                                   LIKE_ACTION_AREA_HEIGHT)
                                                                    MOC:_MOC
                                                                   item:_item
                                                      hashedLikedItemId:self.hashedLikedItemId
                                                 imageDisplayerDelegate:self
                                               clickableElementDelegate:self
                                        connectionTriggerHolderDelegate:self] autorelease];
  _likerAlbumArea.backgroundColor = TRANSPARENT_COLOR;
  [_contentView addSubview:_likerAlbumArea];  
}

- (void)initIntroView {
  _introContentView = [[[UITextView alloc] initWithFrame:CGRectMake(MARGIN, 
                                                                    _likerAlbumArea.frame.origin.y + 
                                                                    _likerAlbumArea.frame.size.height, 
                                                                    self.view.frame.size.width - MARGIN * 2, 
                                                                    0.0f)] autorelease];
  
  _introContentView.backgroundColor = TRANSPARENT_COLOR;
  _introContentView.font = BOLD_FONT(13);
  _introContentView.text = _item.intro;
  _introContentView.textColor = BASE_INFO_COLOR;
  _introContentView.layer.shadowColor = [UIColor whiteColor].CGColor;
  _introContentView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
  _introContentView.layer.shadowOpacity = 1.0f;
  _introContentView.layer.shadowRadius = 1.0f;
  [_contentView addSubview:_introContentView];
  
  CGRect frame = _introContentView.frame;
  frame.size.height = _introContentView.contentSize.height;
  _introContentView.frame = frame;
}

- (void)initContentView {
  _contentView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 
                                                                 self.view.frame.size.width, 
                                                                 self.view.frame.size.height)] autorelease];
  _contentView.backgroundColor = CELL_COLOR;
  [self.view addSubview:_contentView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self initContentView];
  
  [self initPhotoView];
  
  [self initNameLabels];
  
  [self initLikerAlbumArea];
  
  [self initIntroView];
  
  // the order should be the last one, because the view height need be re-calculate
  [self initSelfProperties];

}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECClickableElementDelegate methods
- (void)openLikers {
  /*
  LikersListViewController *likersListVC = [[[LikersListViewController alloc] initWithMOC:_MOC
                                                                                   holder:_holder 
                                                                         backToHomeAction:_backToHomeAction 
                                                                    needRefreshHeaderView:NO 
                                                                    needRefreshFooterView:NO
                                                                        hashedLikedItemId:self.hashedLikedItemId] autorelease];
  likersListVC.title = LocaleStringForKey(NSLikerTitle, nil);
  [self.navigationController pushViewController:likersListVC animated:YES];
   */
  
  ItemLikersListViewController *likersListVC = [[[ItemLikersListViewController alloc] initWithMOC:_MOC
                                                                                           holder:_holder
                                                                                 backToHomeAction:_backToHomeAction
                                                                            needRefreshHeaderView:NO
                                                                            needRefreshFooterView:NO
                                                                                hashedLikedItemId:self.hashedLikedItemId] autorelease];
  likersListVC.title = LocaleStringForKey(NSLikerTitle, nil);
  [self.navigationController pushViewController:likersListVC animated:YES];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  if (nil == url || url.length == 0) {
    return;
  }
  
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  
  if (_defaultImageView) {
    [_defaultImageView removeFromSuperview];
  }
  
  if (nil == _photoView) {
    _photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, 
                                                                MARGIN, 
                                                                ITEM_PHOTO_SIDE_LENGTH, 
                                                                ITEM_PHOTO_SIDE_LENGTH)] autorelease];
    _photoView.backgroundColor = COLOR(200, 200, 200);
    [_imageBackgroundView addSubview:_photoView];
  }
  
  [_imageBackgroundView.layer addAnimation:imageFadein forKey:nil];
  
  _photoView.image = [CommonUtils cutPartImage:image 
                                         width:ITEM_PHOTO_SIDE_LENGTH 
                                        height:ITEM_PHOTO_SIDE_LENGTH
                                        square:YES];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
