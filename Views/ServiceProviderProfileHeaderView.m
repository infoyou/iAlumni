//
//  ServiceProviderProfileHeaderView.m
//  ExpatCircle
//
//  Created by Adam on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ServiceProviderProfileHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "ServiceProvider.h"
#import "WXWLabel.h"
#import "ECGradientButton.h"
#import "AppManager.h"
#import "TextConstants.h"
#import "UIUtils.h"
#import "CommonUtils.h"
#import "WXWAsyncConnectorFacade.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "CoreDataUtils.h"
#import "HttpUtils.h"


#define EDIT_BTN_WIDTH      70.0f
#define BUTTON_WIDTH        96.0f
#define BUTTON_HEIGHT       70.0f

#define ACTION_BTN_WIDTH    75.0f
#define ACTION_BTN_HEIGHT   30.0f

#define SPIN_VIEW_SIDE_LENGTH 26.0f

#define IMG_EDGE            UIEdgeInsetsMake(30.0, 75.0, 5.0, 5.0)  
#define TITLE_EDGE          UIEdgeInsetsMake(33.0, -7.0, 5.0, 12.0)

#define BUTTON_GAP          8.0f

enum {
  LIKE_IDX,
  //FAVORITE_IDX,
  COMMENT_IDX,
  PHOTO_IDX,
};

@interface ServiceProviderProfileHeaderView()
@property (nonatomic, retain) NSMutableDictionary *errorMsgDic;
@property (nonatomic, retain) UIActivityIndicatorView *spinView;
@property (nonatomic, copy) NSString *hashedLikedItemId;
@end


@implementation ServiceProviderProfileHeaderView

@synthesize sp = _sp;
@synthesize itemPhoto = _itemPhoto;
@synthesize errorMsgDic = _errorMsgDic;
@synthesize spinView = _spinView;
@synthesize hashedLikedItemId = _hashedLikedItemId;

#pragma mark - user actions

- (void)showBigPicture:(id)sender {
  
  if (_clickableElementDelegate && self.sp.imageUrl && self.sp.imageUrl.length > 0) {
    [_clickableElementDelegate showBigPhoto:self.sp.imageUrl];
  }
}

- (void)openLikers:(id)sender {
  
  if (_likersLoaded) {
    if (_clickableElementDelegate) {
      [_clickableElementDelegate openLikers];
    }
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLikersLoadingTitle, nil)
                                  msgType:INFO_TY 
                       belowNavigationBar:YES];
  }
}

- (void)browseComments:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate browseComments];
  }
}

- (void)browseAlbum:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate browseAlbum];
  }
  
}

- (void)browsePoints:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate browsePoints];
  }
}

- (void)requestConnection:(NSString *)url  
               connFacade:(WXWAsyncConnectorFacade *)connFacade 
         connectionAction:(SEL)connectionAction {
  if (_connectionTriggerHolderDelegate) {
    [_connectionTriggerHolderDelegate registerRequestUrl:url connFacade:connFacade];
  }
  
  [connFacade performSelector:connectionAction withObject:url];
}

- (void)likeItem {
  WXWAsyncConnectorFacade *likeActionConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                            interactionContentType:ITEM_LIKE_TY] autorelease];  
  
  NSInteger actionType = self.sp.liked.boolValue ? 0 : 1;
  
  NSString *requestUrl = [HttpUtils assembleServiceProviderLikeUrl:self.sp.spId.longLongValue
                                                        likeStatus:actionType];
  
  NSString *url = [CommonUtils assembleXmlRequestUrl:@"service_provider_like_submit" 
                                               param:requestUrl];
  
  [self requestConnection:url 
               connFacade:likeActionConnFacade 
         connectionAction:@selector(likeItem:)];
}

/*
- (void)favoriteItem {
  WXWAsyncConnectorFacade *favoriteActionConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                                interactionContentType:ITEM_FAVORITE_TY] autorelease];
  
  NSInteger favorite = self.sp.favorited.boolValue ?  0 : 1;
  
  NSString *requestUrl = [HttpUtils assembleFavoriteUrl:self.sp.itemId.longLongValue 
                                               itemType:FAVORITE_POST_TY
                                               favorite:favorite];
  
  NSString *url = [CommonUtils assembleXmlRequestUrl:@"collection_join" param:requestUrl];  
  
  [self requestConnection:url
               connFacade:favoriteActionConnFacade 
         connectionAction:@selector(favoriteItem:)];  
}
 */

- (void)addComment {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate addComment];
  }
}

- (void)addPhoto {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate addPhoto];
  }
}

- (void)userGroupActions:(id)sender {
  switch (_actionGroupButtons.selectedSegmentIndex) {
    case LIKE_IDX:
    {
      [self likeItem];
      break;
    }
      /*
    case FAVORITE_IDX:
    {
      [self favoriteItem];
      break;
    }
     */ 
    case COMMENT_IDX:
    {
      [self addComment];
      break;
    }
      
    case PHOTO_IDX:
    {
      [self addPhoto];
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - lifecycle methods

- (void)initButtons {
  _buttonsBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 
                                                                    PHOTO_SIDE_LENGTH + MARGIN * 4 + 2,
                                                                    self.bounds.size.width, 
                                                                    USER_PROF_BUTTONS_BACKGROUND_HEIGHT)];
  _buttonsBackgroundView.backgroundColor = COLOR(213, 213, 213);
  [self addSubview:_buttonsBackgroundView];
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  [shadowPath moveToPoint:CGPointMake(1, BUTTON_HEIGHT - 2)];
  [shadowPath addLineToPoint:CGPointMake(BUTTON_WIDTH - 1, BUTTON_HEIGHT - 2)];
  [shadowPath addLineToPoint:CGPointMake(BUTTON_WIDTH - 1, BUTTON_HEIGHT)];
  [shadowPath addLineToPoint:CGPointMake(1, BUTTON_HEIGHT)];
  [shadowPath addLineToPoint:CGPointMake(1, BUTTON_HEIGHT - 2)];
  
  
  _likesButtonBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(BUTTON_GAP,
                                                                        MARGIN * 2, 
                                                                        BUTTON_WIDTH, BUTTON_HEIGHT)];
  _likesButtonBackgroundView.backgroundColor = TRANSPARENT_COLOR;
  _likesButtonBackgroundView.layer.shadowPath = shadowPath.CGPath;
  _likesButtonBackgroundView.layer.shadowColor = [UIColor grayColor].CGColor;
  _likesButtonBackgroundView.layer.shadowOpacity = 0.9f;
  _likesButtonBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
  _likesButtonBackgroundView.layer.masksToBounds = NO;
  [_buttonsBackgroundView addSubview:_likesButtonBackgroundView];
  
  NSString *title;
  if (nil == self.sp.likeCount) {
    title = @"0";
  } else {
    title = [NSString stringWithFormat:@"%@", self.sp.likeCount];
  }
  _likesButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT) 
                                                  target:self 
                                                  action:@selector(openLikers:) 
                                               colorType:LIGHT_GRAY_BTN_COLOR_TY 
                                                   title:title
                                                   image:[UIImage imageNamed:@"nextArrow.png"] 
                                              titleColor:[UIColor blackColor]
                                        titleShadowColor:[UIColor whiteColor] 
                                               titleFont:BOLD_FONT(15) 
                                             roundedType:HAS_ROUNDED
                                         imageEdgeInsert:IMG_EDGE
                                         titleEdgeInsert:TITLE_EDGE];
  _likesButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  _likesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
  [_likesButtonBackgroundView addSubview:_likesButton];
  _likeCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN, MARGIN * 2, BUTTON_WIDTH - MARGIN * 2, 20) 
                                          textColor:PROFILE_TITLE_COLOR
                                        shadowColor:[UIColor whiteColor]] autorelease];
  _likeCountLabel.font = BOLD_FONT(14);
  _likeCountLabel.textAlignment = UITextAlignmentLeft;
  _likeCountLabel.text = LocaleStringForKey(NSLikerTitle, nil);
  [_likesButton addSubview:_likeCountLabel];
  
  _comentsButtonBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(BUTTON_GAP * 2 + BUTTON_WIDTH, MARGIN * 2, BUTTON_WIDTH, BUTTON_HEIGHT)];
  _comentsButtonBackgroundView.backgroundColor = TRANSPARENT_COLOR;
  _comentsButtonBackgroundView.layer.shadowPath = shadowPath.CGPath;
  _comentsButtonBackgroundView.layer.shadowColor = [UIColor grayColor].CGColor;
  _comentsButtonBackgroundView.layer.shadowOpacity = 0.9f;
  _comentsButtonBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
  _comentsButtonBackgroundView.layer.masksToBounds = NO;
  [_buttonsBackgroundView addSubview:_comentsButtonBackgroundView];
  
  if (nil == self.sp.commentCount) {
    title = @"0";
  } else {
    title = [NSString stringWithFormat:@"%@", self.sp.commentCount];
  }
  _commentsButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT) 
                                                     target:self 
                                                     action:@selector(browseComments:) 
                                                  colorType:LIGHT_GRAY_BTN_COLOR_TY 
                                                      title:title
                                                      image:[UIImage imageNamed:@"nextArrow.png"] 
                                                 titleColor:[UIColor blackColor]
                                           titleShadowColor:[UIColor whiteColor] 
                                                  titleFont:BOLD_FONT(15) 
                                                roundedType:HAS_ROUNDED
                                            imageEdgeInsert:IMG_EDGE
                                            titleEdgeInsert:TITLE_EDGE];
  _commentsButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  _commentsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
  [_comentsButtonBackgroundView addSubview:_commentsButton];
  _commentCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN, MARGIN * 2, BUTTON_WIDTH - MARGIN * 2, 20) 
                                             textColor:PROFILE_TITLE_COLOR
                                           shadowColor:[UIColor whiteColor]] autorelease];
  _commentCountLabel.font = BOLD_FONT(14);
  _commentCountLabel.textAlignment = UITextAlignmentLeft;  
  _commentCountLabel.text = LocaleStringForKey(NSReviewsTitle, nil);
  [_commentsButton addSubview:_commentCountLabel];
  
  _photoButtonBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(BUTTON_GAP * 3 + BUTTON_WIDTH * 2,
                                                                        MARGIN * 2, 
                                                                        BUTTON_WIDTH, BUTTON_HEIGHT)];
  _photoButtonBackgroundView.backgroundColor = TRANSPARENT_COLOR;
  _photoButtonBackgroundView.layer.shadowPath = shadowPath.CGPath;
  _photoButtonBackgroundView.layer.shadowColor = [UIColor grayColor].CGColor;
  _photoButtonBackgroundView.layer.shadowOpacity = 0.9f;
  _photoButtonBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
  _photoButtonBackgroundView.layer.masksToBounds = NO;
  [_buttonsBackgroundView addSubview:_photoButtonBackgroundView];
  
  if (nil == self.sp.photoCount) {
    title = @"0";
  } else {
    title = [NSString stringWithFormat:@"%@", self.sp.photoCount];
  }
  _photoButton = [[ECGradientButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT) 
                                                  target:self 
                                                  action:@selector(browseAlbum:) 
                                               colorType:LIGHT_GRAY_BTN_COLOR_TY 
                                                   title:title
                                                   image:[UIImage imageNamed:@"nextArrow.png"] 
                                              titleColor:[UIColor blackColor]
                                        titleShadowColor:[UIColor whiteColor] 
                                               titleFont:BOLD_FONT(15) 
                                             roundedType:HAS_ROUNDED
                                         imageEdgeInsert:IMG_EDGE
                                         titleEdgeInsert:TITLE_EDGE];
  _photoButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  _photoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
  [_photoButtonBackgroundView addSubview:_photoButton];
  _photoCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN, MARGIN * 2, BUTTON_WIDTH - MARGIN * 2, 20) 
                                           textColor:PROFILE_TITLE_COLOR
                                         shadowColor:[UIColor whiteColor]] autorelease];
  _photoCountLabel.font = BOLD_FONT(14);
  _photoCountLabel.textAlignment = UITextAlignmentLeft;  
  _photoCountLabel.text = LocaleStringForKey(NSPhotoTitle, nil);
  [_photoButton addSubview:_photoCountLabel];
  
}

- (void)initProfileBaseInfo {
  
  _itemPicBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, 
                                                                    MARGIN * 2, 
                                                                    PHOTO_SIDE_LENGTH, 
                                                                    PHOTO_SIDE_LENGTH)];
  
  _itemPicBackgroundView.backgroundColor = TRANSPARENT_COLOR;
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  [shadowPath moveToPoint:CGPointMake(2, 2)];
  [shadowPath addLineToPoint:CGPointMake(PHOTO_SIDE_LENGTH + 1, 2)];
  [shadowPath addLineToPoint:CGPointMake(PHOTO_SIDE_LENGTH + 1, PHOTO_SIDE_LENGTH + 1)];
  [shadowPath addLineToPoint:CGPointMake(2, PHOTO_SIDE_LENGTH + 1)];
  [shadowPath addLineToPoint:CGPointMake(2, 2)];
  _itemPicBackgroundView.layer.shadowPath = shadowPath.CGPath;
  _itemPicBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  _itemPicBackgroundView.layer.shadowOpacity = 0.9f;
  _itemPicBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
  _itemPicBackgroundView.layer.masksToBounds = NO;
  [self addSubview:_itemPicBackgroundView];
  
  _itemPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _itemPicButton.backgroundColor = [UIColor whiteColor];
  _itemPicButton.frame = CGRectMake(0, 0, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH);
  _itemPicButton.layer.cornerRadius = 6.0f;
  _itemPicButton.layer.masksToBounds = YES;
  _itemPicButton.showsTouchWhenHighlighted = YES;
  [_itemPicButton addTarget:self action:@selector(showBigPicture:) forControlEvents:UIControlEventTouchUpInside];
  [_itemPicBackgroundView addSubview:_itemPicButton];
  
  _itemNameLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(_itemPicBackgroundView.frame.origin.x + 
                                                             PHOTO_SIDE_LENGTH + MARGIN * 2, 
                                                             MARGIN * 2, 0, 40)
                                        textColor:[UIColor blackColor]
                                      shadowColor:[UIColor whiteColor]];
  _itemNameLabel.font = BOLD_FONT(15);
  _itemNameLabel.numberOfLines = 0;
  _itemNameLabel.baselineAdjustment = UIBaselineAdjustmentNone;
  _itemNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
  [self addSubview:_itemNameLabel];
  
  _gradeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - MARGIN - 68.0f, 
                                                                  MARGIN * 7 + 2, 68.0f, 14.0f)];
  _gradeImageView.backgroundColor = TRANSPARENT_COLOR;
  [self addSubview:_gradeImageView];
  
}

- (void)initActionGroupButtons {
  UIImage *likeImage = self.sp.liked.boolValue ? [UIImage imageNamed:@"like.png"] : [UIImage imageNamed:@"unlike.png"];
  /*
  UIImage *favoriteImage = self.sp.favorited.boolValue ? [UIImage imageNamed:@"favorited.png"] : [UIImage imageNamed:@"unfavorited.png"];
  */
  _actionGroupButtons = [[UISegmentedControl alloc] initWithItems:@[likeImage,
                                                                   /*favoriteImage,*/ 
                                                                   [UIImage imageNamed:@"addComment16.png"],
                                                                   [UIImage imageNamed:@"camera.png"]]];
  
  _actionGroupButtons.frame = CGRectMake(10,
                                         _buttonsBackgroundView.frame.origin.y + 
                                         _buttonsBackgroundView.frame.size.height + MARGIN * 2, 300, 30);
  [_actionGroupButtons addTarget:self 
                          action:@selector(userGroupActions:)
                forControlEvents:UIControlEventValueChanged];
  _actionGroupButtons.tintColor = [UIColor colorWithHue:0.667f 
                                             saturation:0 
                                             brightness:0.731
                                                  alpha:1.0];
  _actionGroupButtons.momentary = YES;
  _actionGroupButtons.segmentedControlStyle = UISegmentedControlStyleBar;
  [self addSubview:_actionGroupButtons];
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate
                MOC:(NSManagedObjectContext *)MOC 
  hashedLikedItemId:(NSString *)hashedLikedItemId
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _MOC = MOC;
    
    self.hashedLikedItemId = hashedLikedItemId;
    
    self.backgroundColor = CELL_COLOR;
    
    _clickableElementDelegate = clickableElementDelegate;
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    
    _connectionTriggerHolderDelegate = connectionTriggerHolderDelegate;
    
    [self initProfileBaseInfo];
    
    [self initButtons]; 
    
    [self initActionGroupButtons];
    
    self.errorMsgDic = [NSMutableDictionary dictionary];
    
  }
  return self;
}

- (void)dealloc {
  
  self.sp = nil;
  self.itemPhoto = nil;
  self.errorMsgDic = nil;
  self.spinView = nil;
  
  RELEASE_OBJ(_itemPicBackgroundView);
  RELEASE_OBJ(_itemNameLabel);
  RELEASE_OBJ(_gradeImageView);
  RELEASE_OBJ(_likesButton);
  RELEASE_OBJ(_likesButtonBackgroundView);
  RELEASE_OBJ(_commentsButton);
  RELEASE_OBJ(_comentsButtonBackgroundView);
  RELEASE_OBJ(_photoButton);
  RELEASE_OBJ(_photoButtonBackgroundView);
  RELEASE_OBJ(_buttonsBackgroundView);
  RELEASE_OBJ(_actionGroupButtons);
  
  self.hashedLikedItemId = nil;
  
  [super dealloc];
}

#pragma mark - update comment count/photo count
- (void)updateCommentCount {
  NSString *title = @"0";
  if (self.sp.commentCount) {
    title = [NSString stringWithFormat:@"%@", self.sp.commentCount];
  }
  [_commentsButton setTitle:title
                   forState:UIControlStateNormal];
}

- (void)updatePhotoCount {
  NSString *title = @"0";
  if (self.sp.photoCount) {
    title = [NSString stringWithFormat:@"%@", self.sp.photoCount];
  } 
  
  [_photoButton setTitle:title
                forState:UIControlStateNormal];
}

#pragma mark - draw
- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0.0f, 0.0f) 
                endPoint:CGPointMake(self.frame.size.width, 0) 
                   color:COLOR(186, 186, 186).CGColor 
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
  
  CGFloat y = _buttonsBackgroundView.frame.origin.y - 2;
  [UIUtils draw1PxStroke:context 
              startPoint:CGPointMake(0, y) 
                endPoint:CGPointMake(self.bounds.size.width, y)
                   color:COLOR(186, 186, 186).CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
  
  
  y = USER_PROF_BUTTONS_BACKGROUND_HEIGHT + _buttonsBackgroundView.frame.origin.y;
  [UIUtils draw1PxStroke:context 
              startPoint:CGPointMake(0, y)
                endPoint:CGPointMake(self.bounds.size.width, y) 
                   color:COLOR(186, 186, 186).CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
  
}

- (void)triggerLoadLikerList {
  
  NSString *requestUrl = [HttpUtils assembleFetchServiceProviderLikeUsersUrl:self.sp.spId.longLongValue];
  NSString *url = [CommonUtils assembleXmlRequestUrl:@"service_provider_like_list" param:requestUrl];
  
  WXWAsyncConnectorFacade *loadLikerListConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                               interactionContentType:LOAD_LIKERS_TY] autorelease];
  
  [self requestConnection:url
               connFacade:loadLikerListConnFacade
         connectionAction:@selector(fetchLikers:)];
}

- (void)drawProfile:(ServiceProvider *)sp {
  
  if (nil == sp) {
    return;
  }
  
  self.sp = sp;
  
  NSString *title;
  if (sp.commentCount) {
    title = [NSString stringWithFormat:@"%@", sp.commentCount];
  } else {
    title = @"0";
  }
  [_commentsButton setTitle:title
                   forState:UIControlStateNormal];
  
  if (sp.likeCount) {
    title = [NSString stringWithFormat:@"%@", sp.likeCount];
  } else {
    title = @"0";
  }
  [_likesButton setTitle:title
                forState:UIControlStateNormal];
  
  if (sp.photoCount) {
    title = [NSString stringWithFormat:@"%@", sp.photoCount];
  } else {
    title = @"0";
  }
  [_photoButton setTitle:title
                forState:UIControlStateNormal];
  
  _itemNameLabel.text = self.sp.spName;
  CGSize size = [_itemNameLabel.text sizeWithFont:_itemNameLabel.font 
                                constrainedToSize:CGSizeMake(self.frame.size.width - 
                                                             _itemNameLabel.frame.origin.x - MARGIN * 2, 
                                                             CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
  
  _itemNameLabel.frame = CGRectMake(_itemNameLabel.frame.origin.x, 
                                    _itemNameLabel.frame.origin.y, 
                                    size.width, size.height);
  
  [self setNeedsDisplay];
  
  _gradeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%dstars.png", 
                                               self.sp.grade.intValue]];
  
  if (_imageDisplayerDelegate) {
    [_imageDisplayerDelegate registerImageUrl:self.sp.imageUrl];
  }
  
  [[WXWImageManager instance].imageCache fetchImage:self.sp.imageUrl caller:self forceNew:NO];
  
  // load like user list
  [self triggerLoadLikerList];
}

#pragma mark - update like action button image 
- (void)updateSegmentButtonImage:(NSInteger)index newImage:(UIImage *)newImage {
  
  [_actionGroupButtons setImage:newImage forSegmentAtIndex:index]; 
}

- (void)updateLikeActionButtonImage {
  UIImage *likeImage = self.sp.liked.boolValue ? 
  [UIImage imageNamed:@"like.png"] :
  [UIImage imageNamed:@"unlike.png"];

  [self updateSegmentButtonImage:LIKE_IDX newImage:likeImage];
}

#pragma mark - ECConnectorDelegate methods

- (void)showSpinView:(NSInteger)index {
  
  [_actionGroupButtons setImage:nil forSegmentAtIndex:index];
  
  self.spinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
  self.spinView.frame = CGRectMake(50.0f + index * ACTION_BTN_WIDTH + 
                                   _actionGroupButtons.frame.origin.x - 
                                   SPIN_VIEW_SIDE_LENGTH/2, 
                                   _actionGroupButtons.frame.origin.y + ACTION_BTN_HEIGHT/2 - 
                                   SPIN_VIEW_SIDE_LENGTH/2, 
                                   SPIN_VIEW_SIDE_LENGTH, 
                                   SPIN_VIEW_SIDE_LENGTH);
  [self addSubview:self.spinView];
  [self.spinView startAnimating];  
  
  [self bringSubviewToFront:self.spinView];
}

- (void)hideSpinView:(NSInteger)index {
  [self.spinView stopAnimating];
  [self.spinView removeFromSuperview];
  self.spinView = nil;
  
  switch (index) {
    case LIKE_IDX:
    {
      [self updateLikeActionButtonImage];     
      break;
    }
     /* 
    case FAVORITE_IDX:
    {
      UIImage *favoriteImage = self.sp.favorited.boolValue ? 
      [UIImage imageNamed:@"favorited.png"] :
      [UIImage imageNamed:@"unfavorited.png"];
      
      [_actionGroupButtons setImage:favoriteImage forSegmentAtIndex:index];      
      break;
    }
      */
    default:
      break;
  }
  
}

- (void)connectStarted:(NSString *)url 
           contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case ITEM_LIKE_TY:
      [self showSpinView:0];
      break;
      
    case ITEM_FAVORITE_TY:
      [self showSpinView:1];      
      break;             
      
    default:
      break;
  }
  
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url 
        contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case LOAD_LIKERS_TY:
    {
      if ([XMLParser parserLikers:result
                             type:contentType
                hashedLikedItemId:self.hashedLikedItemId
                              MOC:_MOC
                connectorDelegate:self
                              url:url]) {
        
        _likersLoaded = YES;
      } else {
        
        _likesButton.enabled = NO;
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLikersLoadFailedTitle, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    } 
      
    case ITEM_LIKE_TY:
    {
      if ([XMLParser parserLikeItem:result
                  hashedLikedItemId:self.hashedLikedItemId
                 originalLikeStatus:self.sp.liked.boolValue
                           memberId:[AppManager instance].userId.longLongValue
                                MOC:_MOC
                  connectorDelegate:self
                                url:url
                               type:contentType]) {
        // update like count and status            
        self.sp.likeCount = self.sp.liked.boolValue ? 
        @([self.sp.likeCount intValue] - 1) : 
        @([self.sp.likeCount intValue] + 1);
        
        self.sp.liked = [NSNumber numberWithBool:!self.sp.liked.boolValue];        
        
        [WXWCoreDataUtils saveMOCChange:_MOC];
        
        NSString *title = @"0";
        if (self.sp.likeCount) {
          title = [NSString stringWithFormat:@"%@", self.sp.likeCount];
        }
        [_likesButton setTitle:title
                      forState:UIControlStateNormal];
        
        [self hideSpinView:LIKE_IDX];
        
      } else {
        [self hideSpinView:LIKE_IDX];
        NSString *msg = self.sp.liked.boolValue ? 
        LocaleStringForKey(NSUnlikeActionFailedMsg, nil) : 
        LocaleStringForKey(NSLikeActionFailedMsg, nil);
        
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:msg
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];        
      }
      break;
    }
      /*
    case ITEM_FAVORITE_TY:
    {
      if ([XMLParser parserResponseXml:result 
                                  type:contentType 
                                   MOC:_MOC 
                     connectorDelegate:self 
                                   url:url]) {
        self.sp.favorited = [NSNumber numberWithBool:!self.sp.favorited.boolValue];
        [WXWCoreDataUtils saveMOCChange:_MOC];
        
        [self hideSpinView:FAVORITE_IDX];    
      } else {
        [self hideSpinView:FAVORITE_IDX];
        NSString *msg = self.sp.favorited.boolValue ? 
        LocaleStringForKey(NSUnfavoriteFailedMsg, nil) : 
        LocaleStringForKey(NSFavoriteFailedMsg, nil);
       
        [UIUtils showNotificationOnTopWithMsg:[self.errorMsgDic objectForKey:url]
                               alternativeMsg:msg
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
    }
     */ 
    default:
      break;
  }  
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
}

- (void)connectFailed:(NSError *)error 
                  url:(NSString *)url 
          contentType:(NSInteger)contentType {
  NSString *msg = nil;
  switch (contentType) {
    case ITEM_LIKE_TY:
    {
      [self hideSpinView:LIKE_IDX];
      msg = self.sp.liked.boolValue ?
      LocaleStringForKey(NSUnlikeActionFailedMsg, nil) : 
      LocaleStringForKey(NSLikeActionFailedMsg, nil);
      
      [UIUtils showNotificationOnTopWithMsg:msg
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      break;
    }
      /*
    case ITEM_FAVORITE_TY:
    {
      [self hideSpinView:FAVORITE_IDX];
      msg = self.sp.favorited.boolValue ? 
       LocaleStringForKey(NSUnfavoriteFailedMsg, nil) :
       LocaleStringForKey(NSFavoriteFailedMsg, nil);
       
      [UIUtils showNotificationOnTopWithMsg:msg
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      break;             
    }
      */
    case LOAD_LIKERS_TY:
    {
      _likesButton.enabled = NO;
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLikersLoadFailedTitle, nil) 
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      break;
    }
    default:
      break;
  }
}

- (void)traceParserXMLErrorMessage:(NSString *)message 
                               url:(NSString *)url {
  if (url && url.length > 0) {
    (self.errorMsgDic)[url] = message;
  }
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  self.itemPhoto = [CommonUtils cutPartImage:image
                                       width:PHOTO_SIDE_LENGTH 
                                      height:PHOTO_SIDE_LENGTH];
  
  CATransition *imageFade = [CATransition animation];
  imageFade.duration = FADE_IN_DURATION;
  imageFade.type = kCATransitionFade;
  
  [_itemPicButton.layer addAnimation:imageFade 
                              forKey:nil];
  
  [_itemPicButton setImage:self.itemPhoto 
                  forState:UIControlStateNormal];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  self.itemPhoto = [CommonUtils cutPartImage:image
                                       width:PHOTO_SIDE_LENGTH 
                                      height:PHOTO_SIDE_LENGTH];
  
  [_itemPicButton setImage:self.itemPhoto
                  forState:UIControlStateNormal];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
