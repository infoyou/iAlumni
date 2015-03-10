//
//  ServiceItemHeaderView.m
//  ExpatCircle
//
//  Created by Adam on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServiceItemHeaderView.h"
#import "ServiceItem.h"
#import "WXWLabel.h"
#import "ECGradientButton.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "HttpUtils.h"
#import "UIUtils.h"
#import "AppManager.h"
#import "ServiceItemLikerAlbumView.h"
#import "XMLParser.h"
#import "CoreDataUtils.h"
#import "WXWAsyncConnectorFacade.h"
#import "ServiceItemAlbumView.h"
#import "ItemTitleAvatarView.h"
#import "ServiceItemCheckinAlbumView.h"

#define GRADE_ICON_WIDTH    68.0f
#define GRADE_ICON_HEIGHT   14.0f

#define BUTTON_WIDTH        30.0f
#define BUTTON_HEIGHT       30.0f

#define NO_LIKER_SPACE      90.0f

#define IMG_EDGE            UIEdgeInsetsMake(0.0f, -105.0f, 0.0f, 0.0f)
#define TITLE_EDGE          UIEdgeInsetsMake(0.0f, -20.0f, 0.0f, 0.0f)

#define WITH_IMAGE_ALBUM_HEIGHT      117.0f//127.0f
#define WITHOUT_IMAGE_ALBUM_HEIGHT   41.0f//50.0f

#define PHOTO_COUNT_IN_WALL 3

#define TAG_ICON_SIDE_LENGTH 16.0f

#define AVATAR_WIDTH        84.0f
#define AVATAR_HEIGHT       190.0f//240.0f
#define AVATAR_MARGIN       3.0f

#define ACTION_AREA_HEIGHT        41.0f//45.0f
#define ACTION_BUTTON_WIDTH       40.0f
#define ACTION_BUTTON_HEIGHT      30.0f
#define LIKE_COUNT_LABEL_MARGIN   10.0f

@interface ServiceItemHeaderView()
@property (nonatomic, retain) ServiceItem *item;
@property (nonatomic, retain) NSMutableDictionary *errorMsgDic;
@property (nonatomic, retain) UIImage *itemPhoto;
@property (nonatomic, retain) UIActivityIndicatorView *likeSpinView;
@property (nonatomic, retain) UIActivityIndicatorView *favoriteSpinView;
@property (nonatomic, copy) NSString *hashedServiceItemId;
@end

@implementation ServiceItemHeaderView

@synthesize item = _item;
@synthesize errorMsgDic = _errorMsgDic;
@synthesize itemPhoto = _itemPhoto;
@synthesize likeSpinView = _likeSpinView;
@synthesize favoriteSpinView = _favoriteSpinView;
@synthesize itemPicBackgroundView = _itemPicBackgroundView;
@synthesize hashedServiceItemId = _hashedServiceItemId;

#pragma mark - utils methods
- (void)requestConnection:(NSString *)url
               connFacade:(WXWAsyncConnectorFacade *)connFacade
         connectionAction:(SEL)connectionAction {
  
  if (_connectTriggerDelegate) {
    [_connectTriggerDelegate registerRequestUrl:url
                                              connFacade:connFacade];
  }
  
  [connFacade performSelector:connectionAction withObject:url];
}

- (void)connectionCancelled {
  _connectionCancelled = YES;
}

#pragma mark - user actions

- (void)showBigPicture:(id)sender {
  
  if (_clickableElementDelegate && self.item.imageUrl && self.item.imageUrl.length > 0) {
    [_clickableElementDelegate showBigPhoto:self.item.imageUrl];
  }
}

- (void)initLikerAlbumView {
  if (nil == _likerAlbumView) {
    CGFloat x = _likeButton.frame.origin.x + _likeButton.frame.size.width + MARGIN + 3.0f;
    
    CGRect frame = CGRectMake(x, _likeAreaYCoordinate + MARGIN + 3,
                              self.frame.size.width - MARGIN * 2 - x, ACTION_AREA_HEIGHT - MARGIN);
    _likerAlbumView = [[[ServiceItemLikerAlbumView alloc] initWithFrame:frame
                                                 imageDisplayerDelegate:_imageDisplayerDelegate
                                               clickableElementDelegate:_clickableElementDelegate] autorelease];
    _likerAlbumView.backgroundColor = TRANSPARENT_COLOR;
    
    [self addSubview:_likerAlbumView];
  }
}

- (void)initCheckinAlbumView {
  if (nil == _checkinAlbumView) {
    CGFloat x = _checkinButton.frame.origin.x + _checkinButton.frame.size.width + MARGIN + 3.0f;
    
    CGRect frame = CGRectMake(x, _likeAreaYCoordinate + MARGIN + ACTION_AREA_HEIGHT + 3,
                              self.frame.size.width - MARGIN * 2 - x, ACTION_AREA_HEIGHT - MARGIN);
    _checkinAlbumView = [[[ServiceItemCheckinAlbumView alloc] initWithFrame:frame
                                                     imageDisplayerDelegate:_imageDisplayerDelegate
                                                   clickableElementDelegate:_clickableElementDelegate] autorelease];
    _checkinAlbumView.backgroundColor = TRANSPARENT_COLOR;
    
    [self addSubview:_checkinAlbumView];
  }
}

- (void)like:(id)sender {
  
  WXWAsyncConnectorFacade *likeActionConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                            interactionContentType:ITEM_LIKE_TY] autorelease];
  NSInteger actionType = self.item.liked.boolValue ? 0 : 1;
  
  NSString *param = [NSString stringWithFormat:@"<service_id>%@</service_id><status>%d</status>", self.item.itemId, actionType];
  
  NSString *url = [CommonUtils geneUrl:param itemType:ITEM_LIKE_TY];
  
  [self requestConnection:url
               connFacade:likeActionConnFacade
         connectionAction:@selector(likeItem:)];
}

- (void)favorite:(id)sender {
  WXWAsyncConnectorFacade *favoriteActionConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                                interactionContentType:ITEM_FAVORITE_TY] autorelease];
  
  NSInteger favorite = self.item.favorited.boolValue ?  0 : 1;
  
  NSString *requestUrl = [HttpUtils assembleFavoriteUrl:self.item.itemId.longLongValue
                                               itemType:FAVORITE_POST_TY
                                               favorite:favorite];
  
  NSString *url = [CommonUtils assembleXmlRequestUrl:@"collection_join" param:requestUrl];
  
  [self requestConnection:url
               connFacade:favoriteActionConnFacade
         connectionAction:@selector(favoriteItem:)];
}

- (void)checkin:(id)sender {
  WXWAsyncConnectorFacade *checkinActionConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                               interactionContentType:ITEM_CHECKIN_TY] autorelease];
  
  NSString *param = [NSString stringWithFormat:@"<service_id>%@</service_id><longitude>%f</longitude><latitude>%f</latitude>",
                     self.item.itemId,
                     [AppManager instance].longitude,
                     [AppManager instance].latitude];
  
  NSString *url = [CommonUtils geneUrl:param itemType:ITEM_CHECKIN_TY];
  
  [self requestConnection:url
               connFacade:checkinActionConnFacade
         connectionAction:@selector(checkin:)];
}

- (void)loadLikerList {
  
  NSString *param = [NSString stringWithFormat:@"<service_id>%@</service_id><start_index>0</start_index><count>10000</count>", self.item.itemId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_LIKERS_TY];
  
  WXWAsyncConnectorFacade *loadLikerListConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                               interactionContentType:LOAD_LIKERS_TY] autorelease];
  [self requestConnection:url
               connFacade:loadLikerListConnFacade
         connectionAction:@selector(fetchLikers:)];
}

- (void)loadCheckedinAlumnus {
  NSString *param = [NSString stringWithFormat:@"<service_id>%@</service_id><start_index>0</start_index><count>10000</count>", self.item.itemId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_CHECKEDIN_ALUMNUS_TY];
  
  WXWAsyncConnectorFacade *loadChecedinAlumnusConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                                     interactionContentType:LOAD_CHECKEDIN_ALUMNUS_TY] autorelease];
  [self requestConnection:url
               connFacade:loadChecedinAlumnusConnFacade
         connectionAction:@selector(fetchCheckedinAlumnus:)];
}

- (void)share:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate share];
  }
}

#pragma mark - lifecycle methods

- (void)initLikeCountLabel {
  _likeCountLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(_likeButton.frame.origin.x +
                                                              ACTION_BUTTON_WIDTH/2.0f - 6.0f/2.0f,
                                                              _likeButton.frame.origin.y +
                                                              ACTION_BUTTON_HEIGHT - MARGIN, 6.0f, 14.0f)
                                         textColor:BASE_INFO_COLOR
                                       shadowColor:TRANSPARENT_COLOR];
  _likeCountLabel.font = BOLD_FONT(10);
  _likeCountLabel.textAlignment = UITextAlignmentCenter;
}

- (void)updateLikeCountLabel {
  
  if (_item.likeCount.intValue > 0) {
    
    if (nil == _likeCountLabel) {
      [self initLikeCountLabel];
    }
    
    _likeCountLabel.text = [NSString stringWithFormat:@"%@", _item.likeCount];
    CGSize size = [_likeCountLabel.text sizeWithFont:_likeCountLabel.font
                                   constrainedToSize:CGSizeMake(ACTION_BUTTON_WIDTH, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    _likeCountLabel.frame = CGRectMake(_likeButton.frame.origin.x + ACTION_BUTTON_WIDTH/2.0f - size.width/2.0f,
                                       _likeButton.frame.origin.y + ACTION_BUTTON_HEIGHT - MARGIN,
                                       size.width, size.height);
    
    [self addSubview:_likeCountLabel];
    
    _likeCountLabel.alpha = 1.0f;
  } else {
    if (_likeCountLabel) {
      _likeCountLabel.alpha = 0.0f;
    }
  }
}

- (void)initLikeButton {
  
  _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  CGFloat y = 0.0f;
  
  _likeAreaYCoordinate = _titleAvatarViewHeight;
  
  if (_item.likeCount.intValue > 0) {
    y = _likeAreaYCoordinate + MARGIN;
  } else {
    y = _likeAreaYCoordinate + (ACTION_AREA_HEIGHT - ACTION_BUTTON_HEIGHT)/2.0f;
  }
  _likeButton.frame = CGRectMake(MARGIN * 2,
                                 y,
                                 ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT);
  _likeButton.backgroundColor = TRANSPARENT_COLOR;
  
  NSString *iconName = self.item.liked.boolValue ? @"like.png" : @"unlike.png";
  [_likeButton setImage:[UIImage imageNamed:iconName]
               forState:UIControlStateNormal];
  [_likeButton addTarget:self
                  action:@selector(like:)
        forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:_likeButton];
  
  [self updateLikeCountLabel];
}

- (void)initCheckinButton {
  _checkinButton = [UIButton buttonWithType:UIButtonTypeCustom];
  
  CGFloat y = _likeAreaYCoordinate + ACTION_AREA_HEIGHT + MARGIN;
  
  _checkinButton.frame = CGRectMake(MARGIN * 2, y, ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT);
  _checkinButton.backgroundColor = TRANSPARENT_COLOR;
  [_checkinButton setImage:[UIImage imageNamed:@"checkin.png"] forState:UIControlStateNormal];
  [_checkinButton setImage:[UIImage imageNamed:@"highlightCheckin.png"] forState:UIControlStateHighlighted];
  
  [_checkinButton addTarget:self
                     action:@selector(checkin:)
           forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:_checkinButton];
  
  WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:BASE_INFO_COLOR
                                       shadowColor:[UIColor whiteColor]] autorelease];
  label.font = BOLD_FONT(12);
  label.text = LocaleStringForKey(NSIamHereTitle, nil);
  CGSize size = [label.text sizeWithFont:label.font
                       constrainedToSize:CGSizeMake(320, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
  label.frame = CGRectMake(_checkinButton.frame.origin.x + ACTION_BUTTON_WIDTH/2.0f -
                           size.width/2.0f,
                           _checkinButton.frame.origin.y + ACTION_BUTTON_HEIGHT - MARGIN,
                           size.width, size.height);
  [self addSubview:label];
}

- (void)initPriceAndTagsInfo {
  
  _priceTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:PROFILE_TITLE_COLOR
                                         shadowColor:[UIColor whiteColor]] autorelease];
  _priceTitleLabel.font = FONT(12);
  _priceTitleLabel.textAlignment = UITextAlignmentLeft;
  [self addSubview:_priceTitleLabel];
  
  _priceValueLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:PROFILE_VALUE_COLOR
                                         shadowColor:[UIColor whiteColor]] autorelease];
  _priceValueLabel.font = BOLD_FONT(13);
  _priceValueLabel.numberOfLines = 0;
  _priceValueLabel.text = self.item.headerParamValue;
  
  [self addSubview:_priceValueLabel];
  
  _tagsTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:PROFILE_TITLE_COLOR
                                        shadowColor:[UIColor whiteColor]] autorelease];
  _tagsTitleLabel.font = FONT(12);
  _tagsTitleLabel.textAlignment = UITextAlignmentLeft;
  [self addSubview:_tagsTitleLabel];
  
  _tagsValueLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:PROFILE_VALUE_COLOR
                                        shadowColor:[UIColor whiteColor]] autorelease];
  _tagsValueLabel.font = BOLD_FONT(13);
  _tagsValueLabel.textAlignment = UITextAlignmentLeft;
  _tagsValueLabel.numberOfLines = 0;
  _tagsValueLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _tagsValueLabel.text = self.item.tagNames;
  [self addSubview:_tagsValueLabel];
  
  _tagsTitleLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSTagTitle, nil)];
  
  _priceTitleLabel.text = [NSString stringWithFormat:@"%@: ", self.item.headerParamName];
  _priceValueLabel.text = self.item.headerParamValue;
  
  _tagsValueLabel.text = self.item.tagNames;
  
  CGSize size = [_priceTitleLabel.text sizeWithFont:_priceTitleLabel.font
                                           forWidth:CGFLOAT_MAX
                                      lineBreakMode:NSLineBreakByWordWrapping];
  _priceTitleLabel.frame = CGRectMake(self.itemPicBackgroundView.frame.origin.x +
                                      self.itemPicBackgroundView.frame.size.width + MARGIN * 2,
                                      self.itemPicBackgroundView.frame.origin.y,
                                      size.width, size.height);
  size = [_priceValueLabel.text sizeWithFont:_priceValueLabel.font
                           constrainedToSize:CGSizeMake(self.frame.size.width - (_priceTitleLabel.frame.origin.x +
                                                                                 _priceTitleLabel.frame.size.width +
                                                                                 MARGIN * 2), CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
  _priceValueLabel.frame = CGRectMake(_priceTitleLabel.frame.origin.x + _priceTitleLabel.frame.size.width +
                                      MARGIN, _priceTitleLabel.frame.origin.y, size.width, size.height);
  
  size = [_tagsTitleLabel.text sizeWithFont:_tagsTitleLabel.font
                                   forWidth:CGFLOAT_MAX
                              lineBreakMode:NSLineBreakByWordWrapping];
  _tagsTitleLabel.frame = CGRectMake(_priceTitleLabel.frame.origin.x,
                                     self.itemPicBackgroundView.frame.origin.y +
                                     self.itemPicBackgroundView.frame.size.height - size.height,
                                     size.width, size.height);
  
  size = [_tagsValueLabel.text sizeWithFont:_tagsValueLabel.font
                          constrainedToSize:CGSizeMake(self.frame.size.width -
                                                       (_tagsTitleLabel.frame.origin.x +
                                                        _tagsTitleLabel.frame.size.width + MARGIN + MARGIN * 2),
                                                       CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
  
  _tagsValueLabel.frame = CGRectMake(_tagsTitleLabel.frame.origin.x + _tagsTitleLabel.frame.size.width + MARGIN,
                                     _tagsTitleLabel.frame.origin.y, size.width, size.height);
}

- (void)addLikerAlbum {
  
  [self initLikerAlbumView];
  
  [_likerAlbumView drawAlbum:_MOC
           hashedLikedItemId:self.hashedServiceItemId];
  
  [self loadLikerList];
}

- (void)addCheckinAlbum {
  [self initCheckinAlbumView];
  
  [_checkinAlbumView drawAlbum:_MOC
         hashedCheckedinItemId:self.hashedServiceItemId];
  
  [self loadCheckedinAlumnus];
}

- (void)initTitleAvatarView {
  
  CGFloat height = AVATAR_HEIGHT;
  
  CGSize size = [self.item.itemName sizeWithFont:BOLD_FONT(16)
                               constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4,
                                                            CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
  height += size.height + MARGIN;
  
  if (nil == self.item.tagNames || 0 == self.item.tagNames.length) {
    height += TAG_ICON_SIDE_LENGTH + MARGIN;
  } else {
    CGFloat widthLimited = self.frame.size.width - MARGIN * 4 - TAG_ICON_SIDE_LENGTH - MARGIN;
    size = [self.item.tagNames sizeWithFont:FONT(11)
                          constrainedToSize:CGSizeMake(widthLimited, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN;
  }
  
  _titleAvatarView = [[[ItemTitleAvatarView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)
                                                            item:self.item
                                          imageDisplayerDelegate:_imageDisplayerDelegate] autorelease];
  [self addSubview:_titleAvatarView];
  
  _titleAvatarViewHeight = height;
}

- (void)initProfileBaseInfo {
  /*
   _itemNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
   textColor:[UIColor blackColor]
   shadowColor:[UIColor whiteColor]] autorelease];
   _itemNameLabel.font = BOLD_FONT(16);
   _itemNameLabel.numberOfLines = 0;
   _itemNameLabel.baselineAdjustment = UIBaselineAdjustmentNone;
   _itemNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
   _itemNameLabel.text = self.item.itemName;
   
   CGSize size = [_itemNameLabel.text sizeWithFont:_itemNameLabel.font
   constrainedToSize:CGSizeMake(self.frame.size.width -
   (MARGIN * 2 + MARGIN *2 + GRADE_ICON_WIDTH + MARGIN * 2),
   CGFLOAT_MAX)
   lineBreakMode:NSLineBreakByWordWrapping];
   _itemNameLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
   [self addSubview:_itemNameLabel];
   
   _gradeImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width -
   MARGIN * 2 - GRADE_ICON_WIDTH,
   _itemNameLabel.frame.origin.y,
   GRADE_ICON_WIDTH, GRADE_ICON_HEIGHT)] autorelease];
   _gradeImageView.backgroundColor = TRANSPARENT_COLOR;
   _gradeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%dstars.png", self.item.grade.intValue]];
   [self addSubview:_gradeImageView];
   
   self.itemPicBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2,
   _itemNameLabel.frame.origin.y +
   size.height + MARGIN,
   AVATAR_WIDTH + AVATAR_MARGIN * 2,
   AVATAR_HEIGHT + AVATAR_MARGIN * 2)] autorelease];
   
   self.itemPicBackgroundView.backgroundColor = [UIColor whiteColor];
   UIBezierPath *shadowPath = [UIBezierPath bezierPath];
   [shadowPath moveToPoint:CGPointMake(3, self.itemPicBackgroundView.frame.size.height - MARGIN)];
   [shadowPath addLineToPoint:CGPointMake(self.itemPicBackgroundView.frame.size.width - 3,
   self.itemPicBackgroundView.frame.size.height - MARGIN)];
   [shadowPath addLineToPoint:CGPointMake(self.itemPicBackgroundView.frame.size.width - 3,
   self.itemPicBackgroundView.frame.size.height + 1)];
   [shadowPath addLineToPoint:CGPointMake(3, self.itemPicBackgroundView.frame.size.height + 1)];
   [shadowPath addLineToPoint:CGPointMake(3, self.itemPicBackgroundView.frame.size.height - MARGIN)];
   self.itemPicBackgroundView.layer.shadowPath = shadowPath.CGPath;
   self.itemPicBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
   self.itemPicBackgroundView.layer.shadowOpacity = 0.9f;
   self.itemPicBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
   self.itemPicBackgroundView.layer.masksToBounds = NO;
   [self addSubview:self.itemPicBackgroundView];
   
   _itemPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
   _itemPicButton.backgroundColor = [UIColor whiteColor];
   _itemPicButton.frame = CGRectMake(AVATAR_MARGIN, AVATAR_MARGIN, AVATAR_WIDTH, AVATAR_HEIGHT);
   _itemPicButton.showsTouchWhenHighlighted = YES;
   [_itemPicButton addTarget:self action:@selector(showBigPicture:) forControlEvents:UIControlEventTouchUpInside];
   [self.itemPicBackgroundView addSubview:_itemPicButton];
   
   [self initPriceAndTagsInfo];
   */
  
  ///
  [self initTitleAvatarView];
  ///
  
  [self initLikeButton];
  
  [self addLikerAlbum];
  
  [self initCheckinButton];
  
  [self addCheckinAlbum];
}

- (void)arrangeSource {
  if (self.item.source && self.item.source.length > 0) {
    if (nil == _sourceLabel) {
      _sourceLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                                0, 0, 0)
                                           textColor:BASE_INFO_COLOR
                                         shadowColor:[UIColor whiteColor]] autorelease];
      _sourceLabel.font = FONT(11);
      _sourceLabel.numberOfLines = 0;
      [self addSubview:_sourceLabel];
    }
    _sourceLabel.hidden = NO;
    _sourceLabel.text = [NSString stringWithFormat:@"%@: %@",
                         LocaleStringForKey(NSSourceTitle, nil),
                         self.item.source];
    CGSize size = [_sourceLabel.text sizeWithFont:_sourceLabel.font
                                constrainedToSize:CGSizeMake(300.0f, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    _sourceLabel.frame = CGRectMake(_sourceLabel.frame.origin.x,
                                    _itemAlbumView.frame.origin.y +
                                    _itemAlbumView.frame.size.height +
                                    MARGIN * 2,
                                    size.width, size.height);
  } else {
    if (_sourceLabel && !_sourceLabel.hidden) {
      _sourceLabel.hidden = YES;
    }
  }
}

- (void)addItemAlbum {
  
  CGFloat height = 0;
  
  if (_item.photoCount.intValue > 0) {
    height = WITH_IMAGE_ALBUM_HEIGHT;
  } else {
    height = WITHOUT_IMAGE_ALBUM_HEIGHT;
  }
  
  CGRect frame = CGRectMake(0,
                            _likeAreaYCoordinate + MARGIN + ACTION_AREA_HEIGHT * 2,
                            self.frame.size.width, height);
  
  _itemAlbumView = [[[ServiceItemAlbumView alloc] initWithFrame:frame
                                                           item:_item
                                                            MOC:_MOC
                                         imageDisplayerDelegate:_imageDisplayerDelegate
                                       clickableElementDelegate:_clickableElementDelegate
                                connectionTriggerHolderDelegate:_connectTriggerDelegate] autorelease];
  [self addSubview:_itemAlbumView];
}

- (void)addConnectionCancellNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(connectionCancelled)
                                               name:CONN_CANCELL_NOTIFY
                                             object:nil];
  
}

- (id)initWithFrame:(CGRect)frame
               item:(ServiceItem *)item
hashedServiceItemId:(NSString *)hashedServiceItemId
                MOC:(NSManagedObjectContext *)MOC
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = CELL_COLOR;
    
    self.item = item;
    
    self.hashedServiceItemId = hashedServiceItemId;
    
    _MOC = MOC;
    
    self.errorMsgDic = [NSMutableDictionary dictionary];
    
    _clickableElementDelegate = clickableElementDelegate;
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    
    _connectTriggerDelegate = connectionTriggerHolderDelegate;
    
    [self addConnectionCancellNotification];
    
    [self initProfileBaseInfo];
    
    [self addItemAlbum];
    
    //[self arrangeSource];
    
    if (_imageDisplayerDelegate) {
      [_imageDisplayerDelegate registerImageUrl:self.item.imageUrl];
    }
    
    [[WXWImageManager instance].imageCache fetchImage:self.item.imageUrl caller:self forceNew:NO];
    
  }
  return self;
}

- (void)dealloc {
  
  self.item = nil;
  self.errorMsgDic = nil;
  self.itemPhoto = nil;
  self.likeSpinView = nil;
  self.favoriteSpinView = nil;
  self.itemPicBackgroundView = nil;
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Liker", nil);
  
  RELEASE_OBJ(_likeCountLabel);
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:CONN_CANCELL_NOTIFY
                                                object:nil];
  
  self.hashedServiceItemId = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat y = 0;
  
  y = _titleAvatarViewHeight + MARGIN;
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(MARGIN, y)
                endPoint:CGPointMake(self.frame.size.width - MARGIN, y)
                   color:SEPARATOR_LINE_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
  
  y += ACTION_AREA_HEIGHT;
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(MARGIN, y)
                endPoint:CGPointMake(self.frame.size.width - MARGIN, y)
                   color:SEPARATOR_LINE_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
}

#pragma mark - update like button and count label
- (void)arrangeLikeButtonAndCountLabel {
  [UIView animateWithDuration:0.2f
                   animations:^{
                     
                     if (_item.likeCount.intValue > 0) {
                       _likeButton.frame = CGRectMake(_likeButton.frame.origin.x,
                                                      _likeAreaYCoordinate + MARGIN,
                                                      _likeButton.frame.size.width,
                                                      _likeButton.frame.size.height);
                     } else {
                       _likeButton.frame = CGRectMake(_likeButton.frame.origin.x,
                                                      _likeAreaYCoordinate + ACTION_AREA_HEIGHT/2.0f -
                                                      ACTION_BUTTON_HEIGHT/2.0f,
                                                      ACTION_BUTTON_WIDTH,
                                                      ACTION_BUTTON_HEIGHT);
                     }
                     
                     [self updateLikeCountLabel];
                     
                   }];
}

#pragma mark - update photo wall after user add photo
- (void)updatePhotoWall {
  
  if (_connectionCancelled) {
    // if user leaves current UI before photo upload finished, then all connection
    // and all succeed action should be cancelled
    // updatePhotoWall method be called after photo upload finished
    return;
  }
  
  if (_item.photoCount.intValue <= 0) {
    // current service item has no image yet
    _originalNoPhoto = YES;
    return;
  } else {
    
    if (_originalNoPhoto) {
      // user add a new photo for this service item, then create the item album view
      _originalNoPhoto = NO;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                       _itemAlbumView.frame = CGRectMake(_itemAlbumView.frame.origin.x, _itemAlbumView.frame.origin.y,
                                                         _itemAlbumView.frame.size.width, WITH_IMAGE_ALBUM_HEIGHT);
                       
                       [_itemAlbumView addPhotoWall];
                       
                       [_itemAlbumView setNeedsDisplay];
                     }
                     completion:^(BOOL finished){
                       
                       [UIView animateWithDuration:FADE_IN_DURATION
                                        animations:^{
                                          [_itemAlbumView enlargePhotoWall];
                                          
                                          //[self arrangeSource];
                                        }
                                        completion:^(BOOL finished){
                                          
                                          [_itemAlbumView addArrow];
                                          
                                          [_itemAlbumView appendPhoto];
                                        }];
                     }];
    
    _originalNoPhoto = NO;
    
  }
}

#pragma mark - adjust scroll speed
- (void)adjustScrollSpeedWithOffset:(CGPoint)offset {
  [_titleAvatarView adjustScrollSpeedWithOffset:offset];
}

#pragma mark - album frame convertion
- (CGRect)convertedAddPhotoButtonRect {
  CGRect frame = [_itemAlbumView convertRect:_itemAlbumView.addPhotoButton.frame
                                      toView:_itemAlbumView.superview];
  return frame;
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  switch (contentType) {
    case ITEM_LIKE_TY:
      _likeButton.hidden = YES;
      self.likeSpinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
      self.likeSpinView.frame = CGRectMake(0, 0, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH);
      self.likeSpinView.center = _likeButton.center;
      [self.likeSpinView startAnimating];
      [self addSubview:self.likeSpinView];
      break;
      
    case ITEM_FAVORITE_TY:
      /*
       _favoriteButton.hidden = YES;
       self.favoriteSpinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
       self.favoriteSpinView.frame = CGRectMake(0, 0, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH);
       self.favoriteSpinView.center = _favoriteButton.center;
       [self.favoriteSpinView startAnimating];
       [self addSubview:self.favoriteSpinView];
       */
      break;
      
    case LOAD_LIKERS_TY:
    {
      _likerAlbumView.clickable = NO;
      if (self.item.likeCount.intValue <= 0 && !_likerAlbumView.photoLoaded) {
        // spin view displayed during first load process
        [_likerAlbumView startSpinView];
      }
      
      break;
    }
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
      
    case ITEM_FAVORITE_TY:
    {
      /*
       _favoriteButton.hidden = NO;
       [self.favoriteSpinView stopAnimating];
       self.favoriteSpinView = nil;
       break;
       */
    }
      
    default:
      break;
  }
}

- (void)arrangeButtonsAfterLikeAction {
  
  // update like count and status
  self.item.likeCount = self.item.liked.boolValue ?
  @([self.item.likeCount intValue] - 1) :
  @(self.item.likeCount.intValue + 1);
  
  self.item.liked = [NSNumber numberWithBool:!self.item.liked.boolValue];
  
  SAVE_MOC(_MOC);
  
  // update elements layout
  NSString *imageName = self.item.liked.boolValue ?
  @"like.png" : @"unlike.png";
  
  [_likeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
  
  [_likerAlbumView drawAlbum:_MOC
           hashedLikedItemId:self.hashedServiceItemId];
  
  [_likerAlbumView setNeedsDisplay];
}

- (void)arrangeCheckinAlbum {
  
  [_checkinAlbumView drawAlbum:_MOC hashedCheckedinItemId:self.hashedServiceItemId];
  
  [_checkinAlbumView setNeedsDisplay];
}

- (void)traceParserXMLErrorMessage:(NSString *)message url:(NSString *)url {
  if (url && url.length > 0) {
    (self.errorMsgDic)[url] = message;
  }
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  if (_connectionCancelled) {
    return;
  }
  
  switch (contentType) {
    case LOAD_LIKERS_TY:
    {
      if ([XMLParser parserLikers:result
                             type:contentType
                hashedLikedItemId:self.hashedServiceItemId
                              MOC:_MOC
                connectorDelegate:self
                              url:url]) {
        
        _likerAlbumView.clickable = YES;
        
        [_likerAlbumView stopSpinView];
        
        [_likerAlbumView drawAlbum:_MOC
                 hashedLikedItemId:self.hashedServiceItemId];
        
      }
      break;
    }
      
    case LOAD_CHECKEDIN_ALUMNUS_TY:
    {
      if ([XMLParser parserCheckedinAlumnus:result
                               hashedItemId:self.hashedServiceItemId
                                        MOC:_MOC
                          connectorDelegate:self
                                        url:url]) {
        _checkinAlbumView.clickable = YES;
        
        [_checkinAlbumView stopSpinView];
        
        [_checkinAlbumView drawAlbum:_MOC
               hashedCheckedinItemId:self.hashedServiceItemId];
      }
      break;
    }
    case ITEM_FAVORITE_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        [self setStatusForConnectionStop:url actionType:contentType];
        
        self.item.favorited = [NSNumber numberWithBool:!self.item.favorited.boolValue];
        [WXWCoreDataUtils saveMOCChange:_MOC];
        
      }
      break;
    }
      
    case ITEM_LIKE_TY:
    {
      if ([XMLParser parserLikeItem:result
                  hashedLikedItemId:self.hashedServiceItemId
                 originalLikeStatus:_item.liked.boolValue
                           memberId:[AppManager instance].personId.longLongValue
                                MOC:_MOC
                  connectorDelegate:self
                                url:url
                               type:contentType]) {
        
        [self setStatusForConnectionStop:url actionType:contentType];
        
        [self arrangeButtonsAfterLikeAction];
                
        // load latest liker list
        [self loadLikerList];
        
        [self arrangeLikeButtonAndCountLabel];
        
      }
      break;
    }
      
    case ITEM_CHECKIN_TY:
    {
      CheckinResultType ret = [XMLParser parserCheckin:result
                                     connectorDelegate:self
                                                   url:url];
      switch (ret) {
        case CHECKIN_OK_TY:
        {
          [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCheckinDoneMsg, nil)
                                        msgType:SUCCESS_TY
                             belowNavigationBar:YES];
          
          [self setStatusForConnectionStop:url actionType:contentType];
          
          [self arrangeCheckinAlbum];
          
          [self loadCheckedinAlumnus];
          
          break;
        }
          
        case CHECKIN_FAILED_TY:
        {
          [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                 alternativeMsg:LocaleStringForKey(NSCheckinFailedMsg, nil)
                                        msgType:ERROR_TY
                             belowNavigationBar:YES];
          break;
        }
          
        case CHECKIN_FARAWAY_TY:
        {
          [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                 alternativeMsg:LocaleStringForKey(NSCheckinFarAwayMsg, nil)
                                        msgType:ERROR_TY
                             belowNavigationBar:YES];
          break;
        }
          
        default:
          break;
      }
      break;
    }
      
    default:
      break;
  }
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  if (contentType != LOAD_LIKERS_TY) {
    [self setStatusForConnectionStop:url actionType:contentType];
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
        case ITEM_LIKE_TY:
        {
          msg = self.item.liked.boolValue ? LocaleStringForKey(NSUnlikeActionFailedMsg, nil) : LocaleStringForKey(NSLikeActionFailedMsg, nil);
          break;
        }
          
        case ITEM_FAVORITE_TY:
        {
          msg = self.item.favorited.boolValue ? LocaleStringForKey(NSUnfavoriteFailedMsg, nil) : LocaleStringForKey(NSFavoriteFailedMsg, nil);
          break;
        }
          
        case ITEM_CHECKIN_TY:
        {
          msg = LocaleStringForKey(NSCheckinFailedMsg, nil);
          break;
        }
          
        default:
          break;
      }
    }
    
    [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                           alternativeMsg:msg
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  } else {
    _likerAlbumView.clickable = YES;
  }
}


#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  self.itemPhoto = [CommonUtils cutPartImage:image width:AVATAR_WIDTH height:AVATAR_HEIGHT];
  CATransition *imageFade = [CATransition animation];
  imageFade.duration = FADE_IN_DURATION;
  imageFade.type = kCATransitionFade;
  [_itemPicButton.layer addAnimation:imageFade forKey:nil];
  [_itemPicButton setImage:self.itemPhoto forState:UIControlStateNormal];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  self.itemPhoto = [CommonUtils cutPartImage:image width:AVATAR_WIDTH height:AVATAR_HEIGHT];
  
  [_itemPicButton setImage:self.itemPhoto forState:UIControlStateNormal];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
