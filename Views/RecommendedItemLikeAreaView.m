//
//  RecommendedItemLikeAreaView.m
//  ExpatCircle
//
//  Created by Adam on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecommendedItemLikeAreaView.h"
#import <QuartzCore/QuartzCore.h>
#import "TextConstants.h"
#import "UIUtils.h"
#import "CommonUtils.h"
#import "WXWAsyncConnectorFacade.h"
#import "CoreDataUtils.h"
#import "RecommendedItem.h"
#import "WXWLabel.h"
#import "ServiceItemLikerAlbumView.h"
#import "HttpUtils.h"
#import "XMLParser.h"

#define LIKE_BUTTON_WIDTH       40.0f
#define LIKE_BUTTON_HEIGHT      30.0f
#define LIKE_COUNT_LABEL_MARGIN 10.0f

@interface RecommendedItemLikeAreaView()
@property (nonatomic, retain) ServiceItemLikerAlbumView *likerAlbumView;
@property (nonatomic, retain) UIActivityIndicatorView *likeSpinView;
@property (nonatomic, retain) UIButton *likeButton;
@property (nonatomic, retain) WXWLabel *likeCountLabel;
@property (nonatomic, retain) NSMutableDictionary *errorMsgDic;
@property (nonatomic, copy) NSString *hashedLikedItemId;
@end

@implementation RecommendedItemLikeAreaView

@synthesize likerAlbumView = _likerAlbumView;
@synthesize likeSpinView = _likeSpinView;
@synthesize likeButton = _likeButton;
@synthesize likeCountLabel = _likeCountLabel;
@synthesize errorMsgDic = _errorMsgDic;
@synthesize hashedLikedItemId = _hashedLikedItemId;

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

#pragma mark - user action
- (void)loadLikerList {
  NSString *param = [NSString stringWithFormat:@"<service_item_id>%@</service_item_id><start_index>0</start_index><count>10000</count>", _item.itemId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_RECOMMENDED_ITEM_LIKERS_TY];
  
  WXWAsyncConnectorFacade *loadLikerListConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                               interactionContentType:LOAD_RECOMMENDED_ITEM_LIKERS_TY] autorelease];
  
  [self requestConnection:url 
               connFacade:loadLikerListConnFacade 
         connectionAction:@selector(fetchLikers:)];
}

- (void)like:(id)sender {
  
  WXWAsyncConnectorFacade *likeActionConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                            interactionContentType:RECOMMENDED_ITEM_LIKE_TY] autorelease];
  NSInteger actionType = _item.liked.boolValue ? 0 : 1;
  
  NSString *param = [NSString stringWithFormat:@"<service_recommend_item_id>%@</service_recommend_item_id><status>%d</status>", _item.itemId, actionType];
  
  NSString *url = [CommonUtils geneUrl:param itemType:RECOMMENDED_ITEM_LIKE_TY];
  
  [self requestConnection:url 
               connFacade:likeActionConnFacade 
         connectionAction:@selector(likeItem:)];
}

#pragma mark - lifecycle methods

- (void)initLikeCountLabel {
  self.likeCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(self.likeButton.frame.origin.x +
                                                                   LIKE_BUTTON_WIDTH/2.0f - 6.0f/2.0f, 
                                                                   self.likeButton.frame.origin.y + 
                                                                   LIKE_BUTTON_HEIGHT - MARGIN, 6.0f, 14.0f)
                                              textColor:BASE_INFO_COLOR
                                            shadowColor:TRANSPARENT_COLOR] autorelease];
  self.likeCountLabel.font = BOLD_FONT(10);
  self.likeCountLabel.textAlignment = UITextAlignmentCenter;
}

- (void)updateLikeCountLabel {
  
  if (_item.likeCount.intValue > 0) {
    
    if (nil == self.likeCountLabel) {
      [self initLikeCountLabel];
    }
    
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", _item.likeCount];
    CGSize size = [self.likeCountLabel.text sizeWithFont:self.likeCountLabel.font
                                       constrainedToSize:CGSizeMake(LIKE_BUTTON_WIDTH, CGFLOAT_MAX)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    self.likeCountLabel.frame = CGRectMake(self.likeButton.frame.origin.x + LIKE_BUTTON_WIDTH/2.0f - size.width/2.0f, 
                                           self.likeButton.frame.origin.y + LIKE_BUTTON_HEIGHT - MARGIN, 
                                           size.width, size.height);
    
    [self addSubview:self.likeCountLabel];
    
    self.likeCountLabel.alpha = 1.0f;
  } else {
    if (self.likeCountLabel) {
      self.likeCountLabel.alpha = 0.0f;
    }
  }
}

- (void)initLikeButton {
  
  self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  CGFloat y = 0.0f;
  _likeAreaYCoordinate = 0;
  if (_item.likeCount.intValue > 0) {
    y = _likeAreaYCoordinate + MARGIN;
  } else {
    y = _likeAreaYCoordinate + (self.frame.size.height - LIKE_BUTTON_HEIGHT)/2.0f;
  }
  self.likeButton.frame = CGRectMake(MARGIN * 2, 
                                     y, 
                                     LIKE_BUTTON_WIDTH, LIKE_BUTTON_HEIGHT);
  self.likeButton.backgroundColor = TRANSPARENT_COLOR;
  
  NSString *iconName = _item.liked.boolValue ? @"like.png" : @"unlike.png";
  [self.likeButton setImage:[UIImage imageNamed:iconName] 
                   forState:UIControlStateNormal];             
  [self.likeButton addTarget:self
                      action:@selector(like:)
            forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.likeButton];
  
  [self updateLikeCountLabel];
}

- (void)initLikerAlbumView {
  
  CGFloat x = self.likeButton.frame.origin.x + self.likeButton.frame.size.width + MARGIN;
  
  self.likerAlbumView = [[[ServiceItemLikerAlbumView alloc] initWithFrame:CGRectMake(x, 
                                                                                     MARGIN,
                                                                                     self.frame.size.width - x - MARGIN, 
                                                                                     self.frame.size.height - MARGIN * 2)
                                                   imageDisplayerDelegate:_imageDisplayerDelegate 
                                                 clickableElementDelegate:_clickableElementDelegate] autorelease];
  [self addSubview:self.likerAlbumView];
  self.likerAlbumView.backgroundColor = TRANSPARENT_COLOR;
  
  [self.likerAlbumView drawAlbum:_MOC
               hashedLikedItemId:self.hashedLikedItemId];
  
  [self loadLikerList];
}

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC
               item:(RecommendedItem *)item
  hashedLikedItemId:(NSString *)hashedLikedItemId
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    _MOC = MOC;
    _item = item;
    _clickableElementDelegate = clickableElementDelegate;
    _imageDisplayerDelegate = imageDisplayerDelegate;
    _connectTriggerDelegate = connectionTriggerHolderDelegate;
    
    self.errorMsgDic = [NSMutableDictionary dictionary];
    
    self.hashedLikedItemId = hashedLikedItemId;
    
    [self initLikeButton];
    
    [self initLikerAlbumView];
  }
  return self;
}

- (void)dealloc {
  
  self.errorMsgDic = nil;
  
  self.likeCountLabel = nil;
  self.likeButton = nil;
  self.likerAlbumView = nil;
  self.likeSpinView = nil;
  
  self.hashedLikedItemId = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat pattern[] = {2.0, 2.0};
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(MARGIN, self.frame.size.height)
                  endPoint:CGPointMake(self.frame.size.width - MARGIN, self.frame.size.height)
                  colorRef:COLOR(158.0f, 161.0f, 168.0f).CGColor
              shadowOffset:CGSizeMake(0.0f, 0.0f)
               shadowColor:TRANSPARENT_COLOR
                   pattern:pattern];
}

#pragma mark - update like button and count label
- (void)arrangeLikeButtonAndCountLabel {
  [UIView animateWithDuration:0.2f
                   animations:^{
                     
                     if (_item.likeCount.intValue > 0) {
                       self.likeButton.frame = CGRectMake(self.likeButton.frame.origin.x,
                                                          _likeAreaYCoordinate + MARGIN,
                                                          self.likeButton.frame.size.width,
                                                          self.likeButton.frame.size.height);
                     } else {
                       self.likeButton.frame = CGRectMake(self.likeButton.frame.origin.x, 
                                                          _likeAreaYCoordinate + 
                                                          self.frame.size.height/2.0f - LIKE_BUTTON_HEIGHT/2.0f, 
                                                          LIKE_BUTTON_WIDTH, 
                                                          LIKE_BUTTON_HEIGHT);
                     }
                     
                     [self updateLikeCountLabel];
                     
                   }];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case RECOMMENDED_ITEM_LIKE_TY:
      self.likeButton.hidden = YES;
      self.likeSpinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
      self.likeSpinView.frame = CGRectMake(0, 0, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH);
      self.likeSpinView.center = self.likeButton.center;
      [self.likeSpinView startAnimating];
      [self addSubview:self.likeSpinView];
      break;
      
    case LOAD_RECOMMENDED_ITEM_LIKERS_TY:
    {
      self.likerAlbumView.clickable = NO;
      if (_item.likeCount.intValue <= 0 && !self.likerAlbumView.photoLoaded) {
        // spin view displayed during first load process
        [self.likerAlbumView startSpinView];
      }
      
      break;
    } 
    default:
      break;
  }
  
}

- (void)setStatusForConnectionStop:(NSString *)url 
                        actionType:(WebItemType)actionType {
  
  switch (actionType) {
    case RECOMMENDED_ITEM_LIKE_TY:
    {
      self.likeButton.hidden = NO;
      [self.likeSpinView stopAnimating];
      self.likeSpinView = nil;
      break;
    }
      
    default:
      break;
  }     
}

- (void)arrangeButtonsAfterLikeAction {
  
  // update like count and status
  _item.likeCount = _item.liked.boolValue ? 
  @([_item.likeCount intValue] - 1) : 
  @(_item.likeCount.intValue + 1);
  
  _item.liked = [NSNumber numberWithBool:!_item.liked.boolValue];        
  
  [WXWCoreDataUtils saveMOCChange:_MOC];
  
  // update elements layout
  NSString *imageName = _item.liked.boolValue ? 
  @"like.png" : @"unlike.png";
  
  [self.likeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
  
  [self.likerAlbumView drawAlbum:_MOC 
               hashedLikedItemId:self.hashedLikedItemId];
  
  [self.likerAlbumView setNeedsDisplay];
  
}

- (void)connectDone:(NSData *)result 
                url:(NSString *)url 
        contentType:(NSInteger)contentType {
  
  if (_connectionCancelled) {
    return;
  }
  
  switch (contentType) {
    case LOAD_RECOMMENDED_ITEM_LIKERS_TY:
    {
      if ([XMLParser parserLikers:result
                             type:contentType
                hashedLikedItemId:self.hashedLikedItemId
                              MOC:_MOC
                connectorDelegate:self
                              url:url]) {
        
        self.likerAlbumView.clickable = YES;
        [self.likerAlbumView stopSpinView];
        [self.likerAlbumView drawAlbum:_MOC
                     hashedLikedItemId:self.hashedLikedItemId];        
      }     
      break;
    }
      
    case RECOMMENDED_ITEM_LIKE_TY:
    {
      if ([XMLParser parserLikeItem:result
                  hashedLikedItemId:self.hashedLikedItemId
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
      
    default:
      break;
  }
}

- (void)connectCancelled:(NSString *)url 
             contentType:(NSInteger)contentType {
  
  if (contentType != LOAD_RECOMMENDED_ITEM_LIKERS_TY) {
    [self setStatusForConnectionStop:url actionType:contentType];
  } 
}

- (void)connectFailed:(NSError *)error 
                  url:(NSString *)url 
          contentType:(NSInteger)contentType {
  
  if (contentType != LOAD_RECOMMENDED_ITEM_LIKERS_TY) {
    [self setStatusForConnectionStop:url actionType:contentType];
    
    NSString *msg = nil;
    if (error) {
      msg = [error localizedDescription];
    } else {
      switch (contentType) {
        case RECOMMENDED_ITEM_LIKE_TY:
        {
          msg = _item.liked.boolValue ? 
          LocaleStringForKey(NSUnlikeActionFailedMsg, nil) : 
          LocaleStringForKey(NSLikeActionFailedMsg, nil);
          break;
        }
          
        default:
          break;
      }
    }
    [UIUtils showNotificationOnTopWithMsg:msg msgType:ERROR_TY belowNavigationBar:YES];
  } else {
    self.likerAlbumView.clickable = YES;
  }
}

@end
