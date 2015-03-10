//
//  AlumniLinkView.m
//  iAlumni
//
//  Created by Adam on 12-11-29.
//
//

#import "AlumniLinkView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "UIUtils.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "RelationshipLink.h"
#import "UIImageButton.h"
#import "WXWGradientView.h"
#import "ECColorfulButton.h"
#import "RelationshipLink.h"
#import "XMLParser.h"
#import "CoreDataUtils.h"

#define PHOTO_WIDTH     56.0f
#define PHOTO_HEIGHT    58.0f

#define BUTTON_WIDTH    60.0f
#define BUTTON_HEIGHT   30.0f
#define BUTTON_BACKGROUND_HEIGHT   44.0f

#define CONTENT_BUTTON_SEPARATOR_WIDTH  1.0f

#define ACTIVITY_VIEW_SIDE_LENGTH       24.0f

@interface AlumniLinkView()
@property (nonatomic, retain) RelationshipLink *link;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@end

@implementation AlumniLinkView

#pragma mark - user actions
- (void)favorite:(id)sender {
  
  if (self.link) {
    
    NSInteger favoriteStatus = (self.link.favorited.boolValue ? 0 : 1);
    
    NSString *param = [NSString stringWithFormat:@"<favorite>%d</favorite>", favoriteStatus];
    
    NSString *url = [CommonUtils geneUrl:param itemType:FAVORITE_ALUMNI_LINK_TY];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                             contentType:FAVORITE_ALUMNI_LINK_TY];
    [connFacade asyncGet:url showAlertMsg:YES];
  }

}

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
     linkListHolder:(id<ECClickableElementDelegate>)linkListHolder
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate {
  
  self = [super initWithFrame:frame
       imageDisplayerDelegate:imageDisplayerDelegate
       connectTriggerDelegate:connectTriggerDelegate];
  
  if (self) {
    
    _linkListHolder = linkListHolder;
    
    _MOC = MOC;
    
    self.backgroundColor = LIGHT_CELL_COLOR;
        
    _avatarBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      PHOTO_WIDTH + PHOTO_MARGIN * 2,
                                                                      PHOTO_HEIGHT + PHOTO_MARGIN * 2)] autorelease];
    
    _avatarBackgroundView.backgroundColor = [UIColor whiteColor];
    
    _avatarBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _avatarBackgroundView.layer.shadowOpacity = 0.9f;
    _avatarBackgroundView.layer.shadowRadius = 1.0f;
    _avatarBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    _avatarBackgroundView.layer.masksToBounds = NO;
    [self addSubview:_avatarBackgroundView];
    
    _referenceAvatar = [[[UIImageView alloc] initWithFrame:CGRectMake(PHOTO_MARGIN,
                                                                      PHOTO_MARGIN,
                                                                      PHOTO_WIDTH,
                                                                      PHOTO_HEIGHT)] autorelease];    
    _referenceAvatar.backgroundColor = [UIColor whiteColor];
    [_avatarBackgroundView addSubview:_referenceAvatar];
    
    _referenceNameLabel = [[self initLabel:CGRectZero
                                 textColor:DARK_TEXT_COLOR
                               shadowColor:TRANSPARENT_COLOR
                                      font:BOLD_FONT(14)] autorelease];
    _referenceNameLabel.numberOfLines = 0;
    _referenceNameLabel.textAlignment = UITextAlignmentCenter;
    [_avatarBackgroundView addSubview:_referenceNameLabel];
    
    _withMeEventLabel = [[self initLabel:CGRectZero
                               textColor:BASE_INFO_COLOR
                             shadowColor:TRANSPARENT_COLOR
                                    font:BOLD_FONT(13)] autorelease];
    _withMeEventLabel.numberOfLines = 0;
    [self addSubview:_withMeEventLabel];
    
    _withTargetEventLabel = [[self initLabel:CGRectZero
                                   textColor:BASE_INFO_COLOR
                                 shadowColor:TRANSPARENT_COLOR
                                        font:BOLD_FONT(13)] autorelease];
    _withTargetEventLabel.numberOfLines = 0;
    [self addSubview:_withTargetEventLabel];
    
    /*
    _buttonBackgroundView = [[[WXWGradientView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              self.frame.size.width,
                                                                              BUTTON_BACKGROUND_HEIGHT)
                                                          topColor:COLOR(240, 240, 240)
                                                       bottomColor:COLOR(225, 225, 225)] autorelease];
    
    _favoriteButton = [[[ECStandardButton alloc] initWithFrame:CGRectMake(-1, 0, self.frame.size.width + 2.0f, BUTTON_BACKGROUND_HEIGHT + 1)
                                                                       target:self
                                                                       action:@selector(favorite:)
                                                                        title:nil
                                                                    tintColor:COLOR(235, 235, 235)
                                                                    titleFont:BOLD_FONT(13)
                                                                  borderColor:TRANSPARENT_COLOR] autorelease];
    [self addSubview:_favoriteButton];
     */
  }
  return self;
}

- (void)dealloc {
  
  self.link = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  
  CGFloat pattern[2] = {1, 2};
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(_avatarBackgroundView.frame.origin.x + _avatarBackgroundView.frame.size.width + MARGIN * 2, _separatorY + 0.5f)
                  endPoint:CGPointMake(self.frame.size.width - MARGIN * 2, _separatorY + 0.5f)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 0.0f)
               shadowColor:TRANSPARENT_COLOR
                   pattern:pattern];

  /*
  CGContextRestoreGState(context);  
  CGFloat y = _favoriteButton.frame.origin.y - CONTENT_BUTTON_SEPARATOR_WIDTH;
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, y)
                endPoint:CGPointMake(self.frame.size.width, y)
                   color:CELL_BORDER_COLOR.CGColor
            shadowOffset:CGSizeMake(0, 0)
             shadowColor:TRANSPARENT_COLOR];
   */
  
}

- (void)drawWithLink:(RelationshipLink *)link height:(CGFloat)height {
  
  self.link = link;
  
  //CGFloat infoContentHeight = height - BUTTON_BACKGROUND_HEIGHT - CONTENT_BUTTON_SEPARATOR_WIDTH;
  CGFloat infoContentHeight = height;

  _separatorY = infoContentHeight/2.0f;
  
  if (link.referenceAvatarUrl && link.referenceAvatarUrl.length > 0) {
    [self fetchImage:[NSMutableArray arrayWithObject:link.referenceAvatarUrl]
            forceNew:NO];
  }
  
  _referenceNameLabel.text = link.referenceName;
  CGSize size = [_referenceNameLabel.text sizeWithFont:_referenceNameLabel.font
                                     constrainedToSize:CGSizeMake(PHOTO_WIDTH, CGFLOAT_MAX)
                                         lineBreakMode:NSLineBreakByWordWrapping];
  _referenceNameLabel.frame = CGRectMake((PHOTO_WIDTH + PHOTO_MARGIN * 2 - size.width)/2.0f,
                                         _referenceAvatar.frame.origin.y + _referenceAvatar.frame.size.height + MARGIN,
                                         size.width, size.height);
  
  CGFloat avatarBackgroundViewHeight = PHOTO_MARGIN + PHOTO_HEIGHT + MARGIN + size.height + PHOTO_MARGIN;
  _avatarBackgroundView.frame = CGRectMake(MARGIN * 2,
                                           (infoContentHeight - avatarBackgroundViewHeight)/2.0f,
                                           _avatarBackgroundView.frame.size.width,
                                           avatarBackgroundViewHeight);
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 1,
                                                                         _avatarBackgroundView.frame.size.width - 2,
                                                                         _avatarBackgroundView.frame.size.height - 1)];
  _avatarBackgroundView.layer.shadowPath = shadowPath.CGPath;
  
  CGFloat textWidth = self.frame.size.width - (MARGIN * 4 + _avatarBackgroundView.frame.size.width) - MARGIN * 2;
  CGFloat x = _avatarBackgroundView.frame.origin.x + _avatarBackgroundView.frame.size.width + MARGIN * 2;
  _withMeEventLabel.text = link.withMeEvent;
  size = [_withMeEventLabel.text sizeWithFont:_withMeEventLabel.font
                            constrainedToSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
  _withMeEventLabel.frame = CGRectMake(x,
                                       infoContentHeight/2.0f - MARGIN - size.height,
                                       size.width, size.height);
  
  _withTargetEventLabel.text = link.withTargetEvent;
  size = [_withTargetEventLabel.text sizeWithFont:_withTargetEventLabel.font
                                constrainedToSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
  _withTargetEventLabel.frame = CGRectMake(x,
                                           infoContentHeight/2.0f + MARGIN,
                                           size.width, size.height);
  
  /*
  _buttonBackgroundView.frame = CGRectMake(_buttonBackgroundView.frame.origin.x,
                                           height - _buttonBackgroundView.frame.size.height,
                                           _buttonBackgroundView.frame.size.width,
                                           _buttonBackgroundView.frame.size.height);
  
  // set favorite button status
  _favoriteButton.frame = CGRectMake(_favoriteButton.frame.origin.x,
                                     height - BUTTON_BACKGROUND_HEIGHT,
                                     _favoriteButton.frame.size.width,
                                     _favoriteButton.frame.size.height);
  NSString *buttonImageName = (link.favorited.boolValue ? @"linkFavorited.png" : @"linkUnfavorited.png");
  [_favoriteButton setImage:[UIImage imageNamed:buttonImageName]
                   forState:UIControlStateNormal];
   */
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchView:url]) {
    _referenceAvatar.image = nil;
  }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchView:url]) {
    
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    [_referenceAvatar.layer addAnimation:imageFadein forKey:nil];
    
    _referenceAvatar.image = [CommonUtils cutPartImage:image width:PHOTO_WIDTH height:PHOTO_HEIGHT];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  _referenceAvatar.image = [CommonUtils cutPartImage:image width:PHOTO_WIDTH height:PHOTO_HEIGHT];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

/*
#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  if (nil == self.activityView) {
    self.activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.activityView.frame = CGRectMake((_favoriteButton.frame.size.width - ACTIVITY_VIEW_SIDE_LENGTH)/2.0f, (_favoriteButton.frame.size.height - ACTIVITY_VIEW_SIDE_LENGTH)/2.0f, ACTIVITY_VIEW_SIDE_LENGTH, ACTIVITY_VIEW_SIDE_LENGTH);
    [_favoriteButton addSubview:self.activityView];
  }
  
  self.activityView.hidden = NO;
  [self.activityView startAnimating];
  
  [_favoriteButton setImage:nil forState:UIControlStateNormal];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case FAVORITE_ALUMNI_LINK_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        
        if (self.link) {
          NSString *imageName = (self.link.favorited.boolValue ? @"linkUnfavorited.png" : @"linkFavorited.png");
          
          [_favoriteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
          
          self.link.favorited = @(!self.link.favorited.boolValue);
          SAVE_MOC(_MOC);
        }
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
      
      break;
    }
            
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {

  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  [UIUtils closeActivityView];
  
  [super connectFailed:error url:url contentType:contentType];
}
*/

@end
