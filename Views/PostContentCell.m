//
//  PostContentCell.m
//  iAlumni
//
//  Created by Adam on 12-4-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PostContentCell.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "ECGradientButton.h"
#import "Post.h"
#import "NSData+Base64.h"
#import "ECMapAnnotation.h"
#import "ECEmbedMapView.h"
#import "WXWAsyncConnectorFacade.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "CoreDataUtils.h"
#import "TagListView.h"
#import "LikePeopleAlbumView.h"
#import "WXWAsyncConnectorFacade.h"

enum {
  NO_IMAGE_NO_LOCATION_TY,
  NO_IMAGE_HAS_LOCATION_TY,
  HAS_IMAGE_NO_LOCATION_TY,
  HAS_IMAGE_HAS_LOCATION_TY,
};

#define IMG_EDGE    UIEdgeInsetsMake(-12.0f, 7.0, 0.0, 0.0)
#define TITLE_EDGE  UIEdgeInsetsMake(19.0, -15.0, 0.0, 0.0)

#define IMAGE_VIEW_X            60.0f
#define CONTENT_WEB_VIEW_X      60.0f
#define CONTENT_WEB_VIEW_WIDTH  250.0f

#define DELETE_BUTTON_WIDTH     32.0f
#define DELETE_BUTTON_HEIGHT    16.0f

#define AUTHOR_BACKGROUNDBUTTON_Y 2.0f

#define DETAIL_ICON_SIDE_LENGTH 16.0f

#define TEXT_CONTENT_SIZE       15.0f

#define TAG_LIST_HEIGHT         40.0f

#define CONTENT_HEADER  @"<html><body marginwidth=\"0\" marginheight=\"0\" leftmargin=\"0\" topmargin=\"0\" bgcolor=\"#EFEFEF\" style=\"font-family:ArialMT;font-size:%f;word-wrap:break-word;\">"

@interface PostContentCell()
@property (nonatomic, copy) NSString *imageFormat;
@property (nonatomic, retain) UIImage *loadedImage;
@property (nonatomic, copy) NSString *authorPhotoUrl;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, retain) UIActivityIndicatorView *likeSpinView;
@property (nonatomic, retain) UIActivityIndicatorView *favoriteSpinView;
@property (nonatomic, retain) UIButton *imageButton;
@property (nonatomic, retain) Post *post;
@end

@implementation PostContentCell

@synthesize imageFormat = _imageFormat;
@synthesize loadedImage = _loadedImage;
@synthesize authorPhotoUrl = _authorPhotoUrl;
@synthesize imageUrl = _imageUrl;
@synthesize content = _content;
@synthesize likeSpinView = _likeSpinView;
@synthesize favoriteSpinView = _favoriteSpinView;
@synthesize imageButton = _imageButton;

#pragma mark - utils methods
- (void)connectionCancelled {
  _connectionCancelled = YES;
}

#pragma mark - user action
- (void)doSurvey:(id)sender {
  if (!_isCanGoSurvey) {
    [UIUtils showNotificationOnTopWithMsg:@"您无权回答该问卷!"
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];

    return;
  }
  
  if (_clickableElementHolderDelegate) {
    [_clickableElementHolderDelegate openUrl:self.post.surveyUrl];
  }
}

- (void)doSurveyResult:(id)sender {
  if (_clickableElementHolderDelegate) {
    [_clickableElementHolderDelegate openUrl:self.post.surveyResultUrl];
  }
}

- (void)openProfile:(id)sender {
  if (_clickableElementHolderDelegate) {
    [_clickableElementHolderDelegate openProfile:self.post.authorId userType:self.post.authorType];
  }
}

- (void)like:(id)sender {
  
  if ([self.post.liked intValue] != 1) {
    _currentType = POST_LIKE_ACTION_TY;
  }else {
    _currentType = POST_UNLIKE_ACTION_TY;
  }
  
  NSString *param = [NSString stringWithFormat:@"<post_id>%@</post_id>", self.post.postId];
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [[WXWAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:_currentType];
  [connFacade fetchGets:url];
  [connFacade release];
}

- (void)favorite:(id)sender {
  
  if ([self.post.favorited intValue] != 1) {
    _currentType = POST_FAVORITE_ACTION_TY;
  }else {
    _currentType = POST_UNFAVORITE_ACTION_TY;
  }
  
  NSString *param = [NSString stringWithFormat:@"<post_id>%@</post_id>", self.post.postId];
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:_currentType] autorelease];
  [connFacade fetchGets:url];
}

- (void)sharePost:(id)sender {
  if (_clickableElementHolderDelegate) {
    [_clickableElementHolderDelegate sharePostToWeChat:self.post];
  }
}

- (void)deleteFeed:(id)sender {
  if (_clickableElementHolderDelegate) {
    [_clickableElementHolderDelegate deletePost];
  }
}

- (void)showBigImage:(id)sender {
  if (_clickableElementHolderDelegate) {
    [_clickableElementHolderDelegate openImage:self.loadedImage];
  }
}

#pragma mark - draw tag list

- (NSArray *)parserTags {
  NSArray *ids = [self.post.tagIds componentsSeparatedByString:ITEM_TAG_ID_SEPARATOR];
  if (ids.count == 0) {
    return nil;
  }
  
  NSMutableArray *subPredicates = [NSMutableArray array];
  for (NSString *tagIdStr in ids) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagId == %lld)", tagIdStr.longLongValue];
    [subPredicates addObject:predicate];
  }
  
  NSPredicate *tagsPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicates];
  
  NSMutableArray *sortDescs = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"tagName"
                                                              ascending:YES] autorelease];
  [sortDescs addObject:descriptor];
  
  NSArray *tagList = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                             entityName:@"Tag"
                                              predicate:tagsPredicate
                                              sortDescs:sortDescs];
  return tagList;
}

- (void)initTagList {
  
  _tagListView = [[[TagListView alloc] initWithFrame:CGRectZero] autorelease];
  [self.contentView addSubview:_tagListView];
}

#pragma mark - lifecycle methods

- (void)initAuthorProfileArea {
  _authorPhotoBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _authorPhotoBackgroundButton.frame = CGRectMake(0, AUTHOR_BACKGROUNDBUTTON_Y, self.bounds.size.width, AUTHOR_AREA_HEIGHT);
  _authorPhotoBackgroundButton.backgroundColor = CELL_COLOR;
  [_authorPhotoBackgroundButton addTarget:self
                                   action:@selector(openProfile:)
                         forControlEvents:UIControlEventTouchUpInside];
  [self.contentView addSubview:_authorPhotoBackgroundButton];
  
  UIImageView *detailArrow = [[[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - MARGIN - DETAIL_ICON_SIDE_LENGTH, (_authorPhotoBackgroundButton.frame.size.height - DETAIL_ICON_SIDE_LENGTH)/2, DETAIL_ICON_SIDE_LENGTH, DETAIL_ICON_SIDE_LENGTH)] autorelease];
  detailArrow.backgroundColor = TRANSPARENT_COLOR;
  detailArrow.image = [UIImage imageNamed:@"detailArrow.png"];
  [_authorPhotoBackgroundButton addSubview:detailArrow];
  
  _authorPhotoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, 0, POST_DETAIL_PHOTO_WIDTH, POST_DETAIL_PHOTO_HEIGHT)];
  _authorPhotoImageView.layer.cornerRadius = 6.0f;
  _authorPhotoImageView.layer.masksToBounds = YES;
  //  _authorPhotoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
  //  _authorPhotoImageView.layer.borderWidth = 2.0f;
  [_authorPhotoBackgroundButton addSubview:_authorPhotoImageView];
  
  // set editor name label
  _authorLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2 + PHOTO_SIDE_LENGTH + MARGIN * 2,
                                                           MARGIN * 2, 230, 15)
                                      textColor:DARK_TEXT_COLOR
                                    shadowColor:[UIColor whiteColor]];
  _authorLabel.font = BOLD_FONT(14);
  _authorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  //[self.contentView addSubview:_authorLabel];
  [_authorPhotoBackgroundButton addSubview:_authorLabel];
}

- (void)initUserActionButtons {
  _likeButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(MARGIN * 2, _authorPhotoBackgroundButton.frame.origin.y + /*PHOTO_SIDE_LENGTH*/ AUTHOR_AREA_HEIGHT + MARGIN * 2, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH)
                                                 target:self
                                                 action:@selector(like:)
                                              colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                  title:nil
                                                  image:[UIImage imageNamed:@"like.png"]
                                             titleColor:DARK_TEXT_COLOR
                                       titleShadowColor:[UIColor whiteColor]
                                              titleFont:FONT(12)
                                            roundedType:NO_ROUNDED
                                        imageEdgeInsert:IMG_EDGE
                                        titleEdgeInsert:TITLE_EDGE];
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  [shadowPath moveToPoint:CGPointMake(1, PHOTO_SIDE_LENGTH - 2)];
  [shadowPath addLineToPoint:CGPointMake(PHOTO_SIDE_LENGTH - 1, PHOTO_SIDE_LENGTH - 2)];
  [shadowPath addLineToPoint:CGPointMake(PHOTO_SIDE_LENGTH - 1, PHOTO_SIDE_LENGTH)];
  [shadowPath addLineToPoint:CGPointMake(1, PHOTO_SIDE_LENGTH)];
  [shadowPath addLineToPoint:CGPointMake(1, PHOTO_SIDE_LENGTH - 2)];
  
  _likeButton.layer.shadowPath = shadowPath.CGPath;
  _likeButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  _likeButton.layer.shadowOpacity = 0.9f;
  _likeButton.layer.shadowOffset = CGSizeMake(0, 0);
  _likeButton.layer.masksToBounds = NO;
  [self.contentView addSubview:_likeButton];
  
  _shareButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(MARGIN * 2, _likeButton.frame.origin.y + PHOTO_SIDE_LENGTH + MARGIN, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH)
                                                     target:self
                                                     action:@selector(sharePost:)
                                                  colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                      title:LocaleStringForKey(NSWeChatShareTitle, nil)
                                                      image:nil//[UIImage imageNamed:@"favorited.png"]
                                                 titleColor:DARK_TEXT_COLOR
                                           titleShadowColor:[UIColor whiteColor]
                                                  titleFont:FONT(10)
                                                roundedType:NO_ROUNDED
                                            imageEdgeInsert:ZERO_EDGE
                                            titleEdgeInsert:ZERO_EDGE];
  _shareButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
  _shareButton.titleLabel.textAlignment = UITextAlignmentCenter;
  _shareButton.layer.shadowPath = shadowPath.CGPath;
  _shareButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  _shareButton.layer.shadowOpacity = 0.9f;
  _shareButton.layer.shadowOffset = CGSizeMake(0, 0);
  _shareButton.layer.masksToBounds = NO;
  [self.contentView addSubview:_shareButton];
}

- (void)initBaseInfoArea {
  _dateLabel = [[WXWLabel alloc] initWithFrame:CGRectZero textColor:DARK_TEXT_COLOR shadowColor:[UIColor whiteColor]];
  _dateLabel.font = FONT(12);
  [self.contentView addSubview:_dateLabel];
  
  _createdAtLabel = [[WXWLabel alloc] initWithFrame:CGRectZero textColor:DARK_TEXT_COLOR shadowColor:[UIColor whiteColor]];
  _createdAtLabel.font = FONT(12);
  [self.contentView addSubview:_createdAtLabel];
  
  _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _deleteButton.backgroundColor = TRANSPARENT_COLOR;
  _deleteButton.showsTouchWhenHighlighted = YES;
  [_deleteButton setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
  [_deleteButton addTarget:self
                    action:@selector(deleteFeed:)
          forControlEvents:UIControlEventTouchUpInside];
  [self.contentView addSubview:_deleteButton];
}

- (void)initSelfProperties {
  self.accessoryType = UITableViewCellAccessoryNone;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (CGFloat)drawContentWebView {
  
  CGFloat contentHeight = [UIUtils contentHeight:self.post.content width:FEED_DETAIL_CONTENT_WIDTH];
  
  if (nil == _contentWebView) {
    _contentWebView = [[UIWebView alloc] init];
    _contentWebView.delegate = self;
    _contentWebView.userInteractionEnabled = YES;
    _contentWebView.backgroundColor = CELL_COLOR;
    _contentWebView.layer.masksToBounds = NO;
    _contentWebView.opaque = YES;
    
    // disable web view scroll
    [self disableWebViewScroll:[[_contentWebView subviews] lastObject]];
    
    [self.contentView addSubview:_contentWebView];
  }
  
  _contentWebView.hidden = NO;
  if (_textContentLoaded) {
    _contentWebView.frame = CGRectMake(_contentWebView.frame.origin.x,
                                       _contentWebView.frame.origin.y,
                                       _contentWebView.frame.size.width,
                                       _textContentHeight);
  } else {
    CGFloat y = 0.0f;
    if (self.post.imageAttached.boolValue) {
      y = _imageBackgroundView.frame.origin.y + _imageBackgroundView.frame.size.height + MARGIN * 2;
    } else {
      y = _likeButton.frame.origin.y;
    }
    
    _contentWebView.frame = CGRectMake(CONTENT_WEB_VIEW_X,
                                       y,
                                       CONTENT_WEB_VIEW_WIDTH, contentHeight);
  }
  return contentHeight;
}

- (CGFloat)triggerLoadTextContent {
  
  if (self.post.content && self.post.content.length > 0) {
    
    CGFloat height = [self drawContentWebView];
    
    if (!_textContentLoaded) {
      NSString *parseredContent = [CommonUtils parsedTextForHyperLink:self.post.content];
      NSString *htmlStr = [NSString stringWithFormat:@"%@%@<br/></body></html>", [NSString stringWithFormat:CONTENT_HEADER, TEXT_CONTENT_SIZE], parseredContent];
      
      [_contentWebView loadHTMLString:htmlStr baseURL:nil];
    }
    
    return height;
  } else {
    _contentWebView.hidden = YES;
    return 0.0f;
  }
}

- (void)addConnectionCancellNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(connectionCancelled)
                                               name:CONN_CANCELL_NOTIFY
                                             object:nil];
  
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementHolder:(id<ECClickableElementDelegate>)clickableElementHolder
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate
                MOC:(NSManagedObjectContext *)MOC
           postType:(PostType)postType {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
connectionTriggerHolderDelegate:connectionTriggerHolderDelegate
                          MOC:MOC];
  
  if (self) {
    _clickableElementHolderDelegate = clickableElementHolder;
    
    _postType = postType;
    
    [self addConnectionCancellNotification];
    
    [self initSelfProperties];
    
    [self initAuthorProfileArea];
    
    [self initUserActionButtons];
    
    switch (_postType) {
      case DISCUSS_POST_TY:
      case SHARE_POST_TY:
        [self initTagList];
        break;
        
      default:
        break;
    }
    
    [self initBaseInfoArea];
  }
  return self;
}

- (void)dealloc {
  
  [_contentWebView stopLoading];
  _contentWebView.delegate = nil;
  RELEASE_OBJ(_contentWebView);
  RELEASE_OBJ(_authorPhotoImageView);
  RELEASE_OBJ(_likeButton);
  RELEASE_OBJ(_shareButton);
  RELEASE_OBJ(_dateLabel);
  RELEASE_OBJ(_createdAtLabel);
  RELEASE_OBJ(_likedCountLabel);
  RELEASE_OBJ(_likePeopleAlbumView);
  RELEASE_OBJ(_embedMapView);
  RELEASE_OBJ(_embedMapBackgroundView);
  //RELEASE_OBJ(_loadImageView);
  
  self.imageFormat = nil;
  self.loadedImage = nil;
  self.authorPhotoUrl = nil;
  self.imageUrl = nil;
  self.thumbnailUrl = nil;
  self.content = nil;
  
  self.likeSpinView = nil;
  self.favoriteSpinView = nil;
  
  self.post = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:CONN_CANCELL_NOTIFY
                                                object:nil];
  
  [super dealloc];
}

#pragma mark - override methods
- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0.0f, 0.0f)
                endPoint:CGPointMake(self.bounds.size.width, 0.0f)
                   color:COLOR(186, 186, 186).CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0.0f, AUTHOR_BACKGROUNDBUTTON_Y + AUTHOR_AREA_HEIGHT + 1.0f)
                endPoint:CGPointMake(self.bounds.size.width, AUTHOR_BACKGROUNDBUTTON_Y + AUTHOR_AREA_HEIGHT + 1.0f)
                   color:COLOR(186, 186, 186).CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
}

#pragma mark - draw feed

- (void)disableWebViewScroll:(UIView *)scrollView {
  if ([scrollView isKindOfClass:[UIScrollView class]]) {
    ((UIScrollView *)scrollView).scrollEnabled = NO;
    ((UIScrollView *)scrollView).alwaysBounceVertical = NO;
    ((UIScrollView *)scrollView).alwaysBounceHorizontal = NO;
    ((UIScrollView *)scrollView).bouncesZoom = NO;
    ((UIScrollView *)scrollView).backgroundColor = CELL_COLOR;
  }
}

- (CGFloat)drawImageButton:(ImageOrientationType)orientationType {
  CGFloat height = 0;
  CGFloat width = 0;
  
  if (self.post.originalImageWidth.floatValue < FEED_IMG_LONG_LEN_IPHONE) {
    
    width = self.post.originalImageWidth.floatValue;
    height = self.post.originalImageHeight.floatValue;
    
  } else {
    switch (orientationType) {
      case IMG_LANDSCAPE_TY:
        width = FEED_IMG_LONG_LEN_IPHONE;
        height = self.post.originalImageHeight.floatValue * FEED_IMG_LONG_LEN_IPHONE / self.post.originalImageWidth.floatValue;
        break;
        
      case IMG_PORTRAIT_TY:
        width = FEED_IMG_LONG_LEN_IPHONE;
        height = FEED_IMG_LONG_LEN_IPHONE * self.post.originalImageHeight.floatValue / self.post.originalImageWidth.floatValue;
        break;
        
      case IMG_SQUARE_TY:
        height = FEED_IMG_LONG_LEN_IPHONE;
        width = FEED_IMG_LONG_LEN_IPHONE;
        break;
        
      default:
        break;
    }
  }
  
  // add border
  CGFloat backgroundWidth = width + MARGIN * 2;
  CGFloat backgroundHeight = height + MARGIN * 2;
  
  if (nil == _imageBackgroundView) {
    _imageBackgroundView = [[[UIView alloc] init] autorelease];
    _imageBackgroundView.backgroundColor = COLOR(200, 200, 200);
  }
  
  _imageBackgroundView.hidden = NO;
  
  CGFloat leftStart_x = _likeButton.frame.origin.x + _likeButton.frame.size.width;
  _imageBackgroundView.frame = CGRectMake(leftStart_x + ((self.contentView.frame.size.width - leftStart_x) - backgroundWidth)/2.0f,
                                          _likeButton.frame.origin.y,
                                          backgroundWidth,
                                          backgroundHeight);
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  CGFloat curlFactor = 10.0f;
  CGFloat shadowDepth = 8.0f;
  [shadowPath moveToPoint:CGPointMake(0, 0)];
  [shadowPath addLineToPoint:CGPointMake(_imageBackgroundView.frame.size.width, 0)];
  [shadowPath addLineToPoint:CGPointMake(_imageBackgroundView.frame.size.width,
                                         _imageBackgroundView.frame.size.height + shadowDepth)];
  [shadowPath addCurveToPoint:CGPointMake(0.0f, _imageBackgroundView.frame.size.height + shadowDepth)
                controlPoint1:CGPointMake(_imageBackgroundView.frame.size.width - curlFactor,
                                          _imageBackgroundView.frame.size.height + shadowDepth - curlFactor)
                controlPoint2:CGPointMake(curlFactor,
                                          _imageBackgroundView.frame.size.height + shadowDepth - curlFactor)];
  
  _imageBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  _imageBackgroundView.layer.shadowOpacity = 0.7f;
  _imageBackgroundView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  _imageBackgroundView.layer.shadowRadius = 2.0f;
  _imageBackgroundView.layer.masksToBounds = NO;
  
  _imageBackgroundView.layer.shadowPath = shadowPath.CGPath;
  [self.contentView addSubview:_imageBackgroundView];
  
  if (nil == self.imageButton) {
    self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.imageButton.backgroundColor = COLOR(200, 200, 200);
    [self.imageButton addTarget:self
                         action:@selector(showBigImage:)
               forControlEvents:UIControlEventTouchUpInside];
  }
  self.imageButton.frame = CGRectMake(MARGIN, MARGIN, width, height);
  
  return _imageBackgroundView.frame.size.height;
}

- (CGFloat)drawImageButton {
  
  if (self.post.imageAttached.boolValue) {
    ImageOrientationType orientationType;
    if (self.post.originalImageWidth.floatValue > self.post.originalImageHeight.floatValue) {
      orientationType = IMG_LANDSCAPE_TY;
    } else if (self.post.originalImageWidth.floatValue < self.post.originalImageHeight.floatValue){
      orientationType = IMG_PORTRAIT_TY;
    } else {
      orientationType = IMG_SQUARE_TY;
    }
    
    return [self drawImageButton:orientationType];
  } else {
    _imageBackgroundView.hidden = YES;
    return 0.0f;
  }
}

- (void)drawEmbedMapView:(CGFloat)y {
  
  _embedMapBackgroundView.frame = CGRectMake(60, y, FEED_DETAIL_CONTENT_WIDTH, EMBED_MAP_HEIGHT);
  _embedMapBackgroundView.hidden = NO;
  
  CLLocation *location = [[[CLLocation alloc] initWithLatitude:self.post.latitude.doubleValue
                                                     longitude:self.post.longitude.doubleValue] autorelease];
  _embedMapView.centerCoordinate = location.coordinate;
  _embedMapView.userInteractionEnabled = YES;
  MKCoordinateRegion region;
  region.center.latitude = self.post.latitude.doubleValue;
  region.center.longitude = self.post.longitude.doubleValue;
  MKCoordinateSpan span;
  span.latitudeDelta = INIT_ZOOM_LEVEL;
  span.longitudeDelta = INIT_ZOOM_LEVEL;
  region.span = span;
  _embedMapView.region = region;
  
  ECMapAnnotation *annotation = [[ECMapAnnotation alloc] initWithCoordinate:location.coordinate];
  [_embedMapView addAnnotation:annotation];
  RELEASE_OBJ(annotation);
}

- (void)getLikeUsers
{
  [CommonUtils doDelete:_MOC entityName:@"Alumni"];
  _currentType = POST_LIKE_USER_LIST_TY;
  NSString *param = [NSString stringWithFormat:@"<post_id>%@</post_id><page>0</page><page_size>10</page_size>", self.post.postId];
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:_currentType] autorelease];
  [connFacade fetchGets:url];
}

- (void)drawProfileArea {
  _authorLabel.text = self.post.authorName;
  
  [[WXWImageManager instance] fetchImage:self.post.authorPicUrl
                                          caller:self
                                        forceNew:NO];
  
}

- (void)drawUserActionButtons {
  [_likeButton setTitle:[NSString stringWithFormat:@"%@", self.post.likeCount]
               forState:UIControlStateNormal];
  
  /*
  NSString *favoriteImageName = self.post.favorited.boolValue ? @"favorited.png" : @"unfavorited.png";
  [_shareButton setImage:[UIImage imageNamed:favoriteImageName] forState:UIControlStateNormal];
  */
  NSString *imageName = self.post.liked.boolValue ? @"like.png" : @"unlike.png";
  [_likeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)drawImageIfNecessary {
  
  if (self.post.imageAttached.boolValue) {
    if (_imageDisplayerDelegate) {
      [_imageDisplayerDelegate registerImageUrl:self.post.imageUrl];
    }
    [[WXWImageManager instance] fetchImage:self.post.imageUrl
                               caller:self
                             forceNew:NO];
  }
}

- (CGFloat)drawEmbedMapView {
  
  if (self.post.locationAttached.boolValue) {
    if (nil == _embedMapBackgroundView) {
      _embedMapBackgroundView = [[UIView alloc] init];
      _embedMapBackgroundView.backgroundColor = [UIColor whiteColor];
      _embedMapBackgroundView.layer.borderWidth = 1.0f;
      _embedMapBackgroundView.layer.borderColor = LIGHT_GRAY_BTN_BORDER_COLOR.CGColor;
      [self.contentView addSubview:_embedMapBackgroundView];
    }
    
    CGFloat y = _likeButton.frame.origin.y;
    if (self.post.imageAttached.boolValue) {
      y += _imageBackgroundView.frame.size.height + MARGIN * 2;
    }
    
    if (self.post.content && self.post.content.length > 0) {
      y += _contentWebView.frame.size.height + MARGIN * 2;
    }
    
    _embedMapBackgroundView.frame = CGRectMake(60, y, FEED_DETAIL_CONTENT_WIDTH, EMBED_MAP_HEIGHT);
    
    if (nil == _embedMapView) {
      _embedMapView = [[ECEmbedMapView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                       MARGIN,
                                                                       _embedMapBackgroundView.frame.size.width - MARGIN * 2,
                                                                       _embedMapBackgroundView.frame.size.height - MARGIN * 2)
                                   clickableElementDelegate:_clickableElementHolderDelegate];
      _embedMapView.scrollEnabled = NO;
      _embedMapView.zoomEnabled = NO;
      [_embedMapBackgroundView addSubview:_embedMapView];
    }
    
    if (nil == _placeLabel) {
      _placeLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:BASE_INFO_COLOR
                                        shadowColor:[UIColor whiteColor]] autorelease];
      _placeLabel.font = FONT(11);
      _placeLabel.numberOfLines = 0;
      [self.contentView addSubview:_placeLabel];
    }
    
    CGSize size = CGSizeMake(0, 0);
    if (self.post.place.length > 0) {
      _placeLabel.hidden = NO;
      _placeLabel.text = [NSString stringWithFormat:@"%@%@", LocaleStringForKey(NSAtTitleMsg, nil), self.post.place];
      size = [_placeLabel.text sizeWithFont:_placeLabel.font
                          constrainedToSize:CGSizeMake(FEED_DETAIL_CONTENT_WIDTH, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
      _placeLabel.frame = CGRectMake(_embedMapBackgroundView.frame.origin.x,
                                     _embedMapBackgroundView.frame.origin.y + EMBED_MAP_HEIGHT + MARGIN,
                                     size.width, size.height);
    }
    
    _embedMapBackgroundView.hidden = NO;
    
    CLLocation *location = [[[CLLocation alloc] initWithLatitude:self.post.latitude.doubleValue
                                                       longitude:self.post.longitude.doubleValue] autorelease];
    _embedMapView.centerCoordinate = location.coordinate;
    _embedMapView.userInteractionEnabled = YES;
    MKCoordinateRegion region;
    region.center.latitude = self.post.latitude.doubleValue;
    region.center.longitude = self.post.longitude.doubleValue;
    MKCoordinateSpan span;
    span.latitudeDelta = INIT_EMBED_ZOOM_LEVEL;
    span.longitudeDelta = INIT_EMBED_ZOOM_LEVEL;
    region.span = span;
    _embedMapView.region = region;
    
    ECMapAnnotation *annotation = [[ECMapAnnotation alloc] initWithCoordinate:location.coordinate];
    [_embedMapView addAnnotation:annotation];
    RELEASE_OBJ(annotation);
    
    return EMBED_MAP_HEIGHT + MARGIN + size.height;
  } else {
    _embedMapBackgroundView.hidden = YES;
    _embedMapView.userInteractionEnabled = NO;
    _embedMapBackgroundView.frame = CGRectZero;
    _placeLabel.hidden = YES;
    return 0.0f;
  }
}

- (void)drawSurvey:(CGFloat)y {
  if (!_surveyBut) {
    _isCanGoSurvey = YES;
    NSString *surveryStr = NULL_PARAM_VALUE;
    switch ([self.post.userIsAnswered intValue]) {
      case 0:
        surveryStr = LocaleStringForKey(NSPostSurveyTitle, nil);
        break;
      case 1:
        surveryStr = LocaleStringForKey(NSPostReSurveyTitle, nil);
        break;
      case 2:
      {
        _isCanGoSurvey = NO;
        surveryStr = LocaleStringForKey(NSPostSurveyTitle, nil);
      }
        break;
      default:
        break;
    }
    
    _surveyBut = [[[ECGradientButton alloc] initWithFrame:CGRectMake(_contentWebView.frame.origin.x, y, SCREEN_WIDTH/3, 25.0f)
                                                   target:self
                                                   action:@selector(doSurvey)
                                                colorType:RED_BTN_COLOR_TY
                                                    title:surveryStr
                                                    image:nil
                                               titleColor:BLUE_BTN_TITLE_COLOR
                                         titleShadowColor:BLUE_BTN_TITLE_SHADOW_COLOR
                                                titleFont:BOLD_FONT(14)
                                              roundedType:HAS_ROUNDED
                                          imageEdgeInsert:ZERO_EDGE
                                          titleEdgeInsert:ZERO_EDGE] autorelease];
    
    UIGestureRecognizer *surveyTap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(doSurvey:)];
    surveyTap.delegate = self;
    [_surveyBut addGestureRecognizer:surveyTap];
    [self.contentView addSubview:_surveyBut];
    
    _surveyResultBut = [[[ECGradientButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+27, y, SCREEN_WIDTH/3, 25.0f)
                                                         target:self
                                                         action:@selector(doSurveyResult)
                                                      colorType:RED_BTN_COLOR_TY
                                                          title:LocaleStringForKey(NSPostSurveyResultTitle, nil)
                                                          image:nil
                                                     titleColor:BLUE_BTN_TITLE_COLOR
                                               titleShadowColor:BLUE_BTN_TITLE_SHADOW_COLOR
                                                      titleFont:BOLD_FONT(14)
                                                    roundedType:HAS_ROUNDED
                                                imageEdgeInsert:ZERO_EDGE
                                                titleEdgeInsert:ZERO_EDGE] autorelease];
    
    UIGestureRecognizer *surveyResultTap = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(doSurveyResult:)];
    surveyResultTap.delegate = self;
    [_surveyResultBut addGestureRecognizer:surveyResultTap];
    [self.contentView addSubview:_surveyResultBut];
  }
}

- (void)drawLikerAlbum:(CGFloat)y {
  if (self.post.likeCount.intValue > 0) {
    if (nil == _likedCountLabel) {
      _likedCountLabel = [[WXWLabel alloc] initWithFrame:CGRectZero textColor:DARK_TEXT_COLOR shadowColor:[UIColor whiteColor]];
      _likedCountLabel.font = FONT(12);
      [self.contentView addSubview:_likedCountLabel];
    }
    
    if (nil == _likePeopleAlbumView) {
      _likePeopleAlbumView = [[LikePeopleAlbumView alloc] initWithFrame:CGRectMake(MARGIN * 2, 0, 300, LIKE_PEOPLE_ALBUM_HEIGHT)
                                                 imageDisplayerDelegate:_imageDisplayerDelegate
                                               clickableElementDelegate:_clickableElementHolderDelegate];
      [self.contentView addSubview:_likePeopleAlbumView];
    }
    
    y += MARGIN * 2;
    
    _likedCountLabel.hidden = NO;
    _likedCountLabel.text = [NSString stringWithFormat:@"%@ %@",
                             self.post.likeCount, LocaleStringForKey(NSLikeThisTitle, nil)];
    _likedCountLabel.frame = CGRectMake(MARGIN * 2, y, 230, CELL_BASE_INFO_HEIGHT);
    
    _likePeopleAlbumView.hidden = NO;
    _likePeopleAlbumView.userInteractionEnabled = YES;
    _likePeopleAlbumView.frame = CGRectMake(MARGIN * 2,
                                            _likedCountLabel.frame.origin.y + _likedCountLabel.frame.size.height,
                                            _likePeopleAlbumView.frame.size.width,
                                            LIKE_PEOPLE_ALBUM_HEIGHT);
    
    [self getLikeUsers];
    
  } else {
    _likedCountLabel.hidden = YES;
    _likePeopleAlbumView.hidden = YES;
    _likePeopleAlbumView.userInteractionEnabled = NO;
  }
}

- (void)drawBaseInfos:(CGFloat)y {
  _dateLabel.text = self.post.elapsedTime;
  CGSize size = [_dateLabel.text sizeWithFont:_dateLabel.font
                            constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
  
  _dateLabel.frame = CGRectMake(MARGIN * 2, y, size.width, CELL_BASE_INFO_HEIGHT);
  
  _createdAtLabel.text = [NSString stringWithFormat:@"%@ %@",
                          LocaleStringForKey(NSFromTitle, nil), self.post.createdAt];
  _createdAtLabel.frame = CGRectMake(_dateLabel.frame.origin.x + size.width + MARGIN * 2,
                                     _dateLabel.frame.origin.y, 200, CELL_BASE_INFO_HEIGHT);
  if (self.post.couldBeDeleted.boolValue) {
    _deleteButton.hidden = NO;
    _deleteButton.enabled = YES;
    _deleteButton.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - DELETE_BUTTON_WIDTH, _dateLabel.frame.origin.y - 3, DELETE_BUTTON_WIDTH, DELETE_BUTTON_HEIGHT);
  } else {
    _deleteButton.hidden = YES;
    _deleteButton.enabled = NO;
  }
}

- (void)drawTagsView:(CGFloat)y {
  _tagListView.frame = CGRectMake(0, y, self.frame.size.width, TAG_LIST_HEIGHT);
  [_tagListView drawViews:[self parserTags]];
}

- (void)drawPost:(Post *)feed {
  self.post = feed;
  
  [self drawProfileArea];
  
  [self drawUserActionButtons];
  
  [self drawImageButton];
  
  [self triggerLoadTextContent];
  
  CGFloat mapAreaHeight = [self drawEmbedMapView];
  
  CGFloat contentHeight = _contentWebView.frame.size.height + MARGIN * 2;
  if (self.post.imageAttached.boolValue) {
    contentHeight += _imageBackgroundView.frame.size.height;
    contentHeight += MARGIN * 2;
  }
  
  if (self.post.locationAttached.boolValue) {
    contentHeight += mapAreaHeight;//EMBED_MAP_HEIGHT;
  }
  
  CGFloat y = _likeButton.frame.origin.y;
  if (LEFT_TOOLBAR_HEIGHT < contentHeight) {
    y += contentHeight;
  } else {
    y += LEFT_TOOLBAR_HEIGHT;
  }
  
  if (self.post.isHaveSurvey.boolValue) {
    y += MARGIN;
    [self drawSurvey:y];
    y += 25;
  }
  
  [self drawLikerAlbum:y];
  y += MARGIN * 2;
  
  if (self.post.likeCount.intValue > 0) {
    //y += CELL_BASE_INFO_HEIGHT;
    y += LIKE_PEOPLE_ALBUM_HEIGHT;
    y += MARGIN * 4;
  }
  
  if (self.post.tagNames && self.post.tagNames.length > 0) {
    [self drawTagsView:y];
    
    y += _tagListView.frame.size.height + MARGIN * 2;
  }
  
  [self drawBaseInfos:y];
  self.imageUrl = nil;
  self.authorPhotoUrl = nil;
  NSMutableArray *urls = [NSMutableArray array];
  if (!_authorImageLoaded) {
    [urls addObject:self.post.authorPicUrl];
  }
  
  self.authorPhotoUrl = self.post.authorPicUrl;
  self.imageUrl = self.post.imageUrl;
  self.thumbnailUrl = self.post.thumbnailUrl;
  if (self.post.imageAttached.boolValue && !_attachedImageLoaded) {
    [urls addObject:self.post.imageUrl];
    [urls addObject:self.post.thumbnailUrl];
  }

  [self fetchImage:urls forceNew:NO];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation {
  MKAnnotationView* annotationView = nil;
	
	ECMapAnnotation* csAnnotation = (ECMapAnnotation*)annotation;
	
	NSString* identifier = @"Pin";
	MKPinAnnotationView* pin = (MKPinAnnotationView*)[_embedMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if (nil == pin) {
		pin = [[[MKPinAnnotationView alloc] initWithAnnotation:csAnnotation
                                           reuseIdentifier:identifier] autorelease];
	}
	
  pin.pinColor = MKPinAnnotationColorRed;
	
	annotationView = pin;
	
	return annotationView;
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  switch (contentType) {
    case ITEM_LIKE_TY:
      _likeButton.hidden = YES;
      self.likeSpinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
      self.likeSpinView.frame = CGRectMake(0, 0, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH);
      self.likeSpinView.center = _likeButton.center;
      [self.likeSpinView startAnimating];
      [self.contentView addSubview:self.likeSpinView];
      break;
      
    case ITEM_FAVORITE_TY:
      _shareButton.hidden = YES;
      self.favoriteSpinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
      self.favoriteSpinView.frame = CGRectMake(0, 0, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH);
      self.favoriteSpinView.center = _shareButton.center;
      [self.favoriteSpinView startAnimating];
      [self.contentView addSubview:self.favoriteSpinView];
      break;
      
    case LOAD_LIKERS_TY:
      //_likePeopleLoading = YES;
      break;
      
    default:
      break;
  }
  
}

- (void)setStatusForConnectionStop:(NSString *)url actionType:(WebItemType)actionType {
  switch (actionType) {
    case ITEM_LIKE_TY:
    {
      _likeButton.hidden = NO;
      [self.likeSpinView stopAnimating];
      self.likeSpinView = nil;
      break;
    }
      /*
    case ITEM_FAVORITE_TY:
    {
      _shareButton.hidden = NO;
      [self.favoriteSpinView stopAnimating];
      self.favoriteSpinView = nil;
      break;
    }
       */
      
    default:
      break;
  }
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  if (_connectionCancelled) {
    return;
  }
  
  switch (contentType) {
      
    case POST_LIKE_ACTION_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        // update like count and status
        self.post.likeCount = self.post.liked.boolValue ? @([self.post.likeCount intValue] - 1) : @([self.post.likeCount intValue] + 1);
        
        self.post.liked = [NSNumber numberWithBool:!(self.post.liked.boolValue)];
        
        [CommonUtils saveMOCChange:_MOC];
        
        // update elements layout
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        
        [_likeButton setTitle:[NSString stringWithFormat:@"%@", self.post.likeCount]
                     forState:UIControlStateNormal];
        
        NSString *imageName = self.post.liked.boolValue ? @"like.png" : @"unlike.png";
        [_likeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        _likedCountLabel.text = [NSString stringWithFormat:@"%@ %@",
                                 self.post.likeCount, @"Like this Title"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DISPLAY_LIKE_ALBUM_NOTIFY
                                                            object:nil
                                                          userInfo:nil];
        [UIView commitAnimations];
        [self getLikeUsers];
      } else {
        NSString *msg = nil;
        msg = @"LikeFailedMsg";

        [UIUtils showNotificationOnTopWithMsg:msg
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];

      }
      break;
    }
      
    case POST_UNLIKE_ACTION_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        // update like count and status
        self.post.likeCount = self.post.liked.boolValue ? @([self.post.likeCount intValue] - 1) : @([self.post.likeCount intValue] + 1);
        
        self.post.liked = [NSNumber numberWithBool:!(self.post.liked.boolValue)];
        
        [CommonUtils saveMOCChange:_MOC];
        
        // update elements layout
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        
        [_likeButton setTitle:[NSString stringWithFormat:@"%@", self.post.likeCount]
                     forState:UIControlStateNormal];
        
        NSString *imageName = self.post.liked.boolValue ? @"like.png" : @"unlike.png";
        [_likeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        _likedCountLabel.text = [NSString stringWithFormat:@"%@ %@",
                                 self.post.likeCount, @"Like this Title"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DISPLAY_LIKE_ALBUM_NOTIFY
                                                            object:nil
                                                          userInfo:nil];
        [UIView commitAnimations];
      } else {
        NSString *msg = nil;
        msg = @"UnLikeFailedMsg";

        [UIUtils showNotificationOnTopWithMsg:msg
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
    }
      
    case POST_LIKE_USER_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        [_likePeopleAlbumView drawAlbum:_MOC];
      } else {
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];

      }
      break;
    }
      
    default:
      break;
  }
  
  [self setStatusForConnectionStop:url actionType:contentType];
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  if (contentType != LOAD_LIKERS_TY) {
    [self setStatusForConnectionStop:url actionType:contentType];
  } else {
    //_likePeopleLoading = NO;
  }
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  if (contentType != LOAD_LIKERS_TY) {
    [self setStatusForConnectionStop:url actionType:contentType];
    
    NSString *msg = nil;
    if (error) {
      msg = [error localizedDescription];
    } else {
      switch (contentType) {
          /*
        case POST_FAVORITE_ACTION_TY:
        case POST_UNFAVORITE_ACTION_TY:
        {
          //                    NSString *msg = nil;
          //                    if (self.post.favorited.boolValue) {
          //                        msg = LocaleStringForKey(NSUnfavoriteFailedMsg, nil);
          //                    } else {
          //                        msg = LocaleStringForKey(NSFavoriteFailedMsg, nil);
          //                    }
          break;
        }
           */
          
        case ITEM_LIKE_TY:
        {
          msg = self.post.liked.boolValue ? LocaleStringForKey(NSUnlikeActionFailedMsg, nil) : LocaleStringForKey(NSLikeActionFailedMsg, nil);
          break;
        }
          
        case ITEM_FAVORITE_TY:
        {
          msg = self.post.favorited.boolValue ? LocaleStringForKey(NSUnfavoriteFailedMsg, nil) : LocaleStringForKey(NSFavoriteFailedMsg, nil);
          break;
        }
          
        default:
          break;
      }
    }
    [UIUtils showNotificationOnTopWithMsg:msg msgType:ERROR_TY belowNavigationBar:YES];
  } else {
    //_likePeopleLoading = NO;
  }
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([url isEqualToString:self.authorPhotoUrl]) {
    _authorPhotoImageView.image = [UIImage imageNamed:@"defaultUser.png"];
  } else if ([url isEqualToString:self.post.imageUrl]) {
    /*
     _loadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallLogo.png"]];
     _loadImageView.backgroundColor = COLOR(200, 200, 200);
     _loadImageView.center = CGPointMake(_imageBackgroundView.frame.size.width/2, _imageBackgroundView.frame.size.height/2);
     
     [_imageBackgroundView addSubview:_loadImageView];
     */
  }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  if (nil == url || [url length] == 0) {
    return;
  }
  
  if (image) {
        
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    
    if ([url isEqualToString:self.authorPhotoUrl]) {
      
      [_authorPhotoImageView.layer addAnimation:imageFadein forKey:nil];
      _authorPhotoImageView.image = image;
      
      _authorImageLoaded = YES;
      
    } else if ([url isEqualToString:self.imageUrl]) {
      /*
       if (_loadImageView) {
       [_loadImageView removeFromSuperview];
       }
       */
      
      if (_imageDisplayerDelegate && [_imageDisplayerDelegate respondsToSelector:@selector(saveDisplayedImage:)]) {
        [_imageDisplayerDelegate saveDisplayedImage:image];
      }
      
      self.loadedImage = image;
      
      [self.imageButton.layer addAnimation:imageFadein forKey:nil];
      [self.imageButton setImage:image
                        forState:UIControlStateNormal];
      
      [_imageBackgroundView.layer addAnimation:imageFadein forKey:nil];
      _imageBackgroundView.backgroundColor = [UIColor whiteColor];
      
      [_imageBackgroundView addSubview:self.imageButton];
      
      _attachedImageLoaded = YES;
      
    } else if ([url isEqualToString:self.thumbnailUrl]) {
      if (_imageDisplayerDelegate && [_imageDisplayerDelegate respondsToSelector:@selector(saveDisplayedImage:)]) {
        [_imageDisplayerDelegate saveDisplayedImage:image];
      }
    }
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  if ([url isEqualToString:self.authorPhotoUrl]) {
    _authorImageLoaded = YES;
  } else if ([url isEqualToString:self.imageUrl]) {
    _attachedImageLoaded = YES;
  }
  
}

#pragma mark - adjust height
- (void)adjustWebViewHeight:(UIWebView *)webView {
  
  if (!_textContentLoaded) {
    
    _textContentLoaded = YES;
    
    NSString *height = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"];
    
    CGFloat offsetHeight = height.floatValue - _contentWebView.frame.size.height;
    
    CGRect newFrame = _contentWebView.frame;
    if (offsetHeight > 0) {
      newFrame = CGRectMake(newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height + offsetHeight + MARGIN * 4);
    }
    
    _textContentHeight = newFrame.size.height;
    
    NSMutableDictionary *heightDic = [NSMutableDictionary dictionary];
    heightDic[TEXT_CONTENT_HEIGHT_KEY] = @(newFrame.size.height);
    [[NSNotificationCenter defaultCenter] postNotificationName:TEXT_CONTENT_LOADED_NOTIFY
                                                        object:self
                                                      userInfo:heightDic];
  }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView
shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
  
  if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    
    NSURL *url = [request URL];
    
    NSString *urlStr = [url absoluteString];
    NSString *scheme = [url scheme];
    
    if ([scheme caseInsensitiveCompare:HTTP_PRIFIX] == 0
        || [scheme caseInsensitiveCompare:HTTPS_PRIFIX] == 0) {
      if (_clickableElementHolderDelegate) {
        [_clickableElementHolderDelegate openUrl:urlStr];
        return NO;
      }
    }
  }
  return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [self adjustWebViewHeight:webView];
}


@end
