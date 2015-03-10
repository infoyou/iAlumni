//
//  ServiceItemToolbar.m
//  ExpatCircle
//
//  Created by Adam on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServiceItemToolbar.h"
#import <QuartzCore/QuartzCore.h>
#import "ServiceItem.h"
#import "WXWAsyncConnectorFacade.h"
#import "HttpUtils.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "CoreDataUtils.h"
#import "CommonUtils.h"
#import "TextConstants.h"

#define MORE_SIDE_LENGTH  20.0f

#define BUTTON_WIDTH      50.0f
#define BUTTON_HEIGHT     26.0f

#define COLLAPSED_WIDTH   50.0f


#define SPIN_VIEW_SIDE_LENGTH 26.0f

#define RADIUS    4.0f

@interface ServiceItemToolbar()
@property (nonatomic, retain) UIButton *favoriteButton;
@property (nonatomic, retain) UIButton *shareButton;
@property (nonatomic, retain) UIButton *commentButton;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) UIActivityIndicatorView *favoriteSpinView;
@end

@implementation ServiceItemToolbar

@synthesize favoriteButton = _favoriteButton;
@synthesize shareButton = _shareButton;
@synthesize commentButton = _commentButton;
@synthesize closeButton = _closeButton;
@synthesize favoriteSpinView = _favoriteSpinView;

static CGFloat pattern[2] = {2.0, 1.0};

#pragma mark - utils methods
- (void)requestConnection:(NSString *)url  
               connFacade:(WXWAsyncConnectorFacade *)connFacade 
         connectionAction:(SEL)connectionAction {
  if (_connectTriggerDelegate) {
    [_connectTriggerDelegate registerRequestUrl:url connFacade:connFacade];
  }
  
  [connFacade performSelector:connectionAction withObject:url];
}

- (void)connectionCancelled {
  _connectionCancelled = YES;
}

#pragma mark - user actions
- (void)favorite:(id)sender {
  WXWAsyncConnectorFacade *favoriteActionConnFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                                interactionContentType:ITEM_FAVORITE_TY] autorelease];
  
  NSInteger favorite = _item.favorited.boolValue ?  0 : 1;
  
  NSString *param = [NSString stringWithFormat:@"<service_id>%@</service_id><status>%d</status>", _item.itemId, favorite];
  
  NSString *url = [CommonUtils geneUrl:param itemType:ITEM_FAVORITE_TY];
  
  [self requestConnection:url 
               connFacade:favoriteActionConnFacade
         connectionAction:@selector(favoriteItem:)];
}

- (void)closeFinished {
  [self addSubview:_moreImageView];
  
  [self setNeedsDisplay];
  
  [self adjustShadow];
}

- (void)doCollapse {
  _expanded = NO;
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.2f];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(closeFinished)];
  
  [self arrangeFavoriteButton:YES];
  [self arrangeShareButton:YES];
  [self arrangeCommentButton:YES];
  [self arrangeCloseButton:YES];
  
  self.frame = CGRectMake(APP_WINDOW.frame.size.width - COLLAPSED_WIDTH,
                          self.frame.origin.y,
                          COLLAPSED_WIDTH,
                          self.frame.size.height);
  
  [UIView commitAnimations];
}

- (void)collapseIfNeeded {
  if (_expanded) {
    [self doCollapse];
  }
}

- (void)close:(id)sender {
  [self doCollapse];
}

- (void)share:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate share];
    
    [self close:nil];
  }
}

- (void)addComment:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate addComment];
    
    [self close:nil];
  }
}

#pragma mark - lifecycle methods
- (void)initSelfProperties {
  
  self.clipsToBounds = YES;
  
  self.backgroundColor = TRANSPARENT_COLOR;
  //self.alpha = 0.8f;
  
  self.layer.masksToBounds = NO;
  self.layer.cornerRadius = 0.0f;
  self.layer.borderWidth = 0.0f;
  self.layer.borderColor = TRANSPARENT_COLOR.CGColor;

  
  self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOpacity = 0.9f;

}

- (void)addConnectionCancellNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(connectionCancelled)
                                               name:CONN_CANCELL_NOTIFY
                                             object:nil];
  
}

- (id)initWithFrame:(CGRect)frame 
               item:(ServiceItem *)item
                MOC:(NSManagedObjectContext *)MOC
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    
    _item = item;
    
    _MOC = MOC;
    
    _clickableElementDelegate = clickableElementDelegate;
    
    _connectTriggerDelegate = connectionTriggerHolderDelegate;
    
    [self addConnectionCancellNotification];
    
    [self initSelfProperties];
    
    _moreImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - MORE_SIDE_LENGTH)/2.0 + MARGIN, 
                                                                   (self.frame.size.height - MORE_SIDE_LENGTH)/2.0, 
                                                                   0, MORE_SIDE_LENGTH)];
    _moreImageView.backgroundColor = TRANSPARENT_COLOR;
    _moreImageView.image = [UIImage imageNamed:@"more.png"];
    [self addSubview:_moreImageView];
    
  }
  return self;
}

- (void)adjustShadow {
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  [shadowPath moveToPoint:CGPointMake(2.0f, self.frame.size.height - 1.0f)];
  [shadowPath addLineToPoint:CGPointMake(self.frame.size.width + 2.0f, self.frame.size.height - 1.0f)];
  [shadowPath addLineToPoint:CGPointMake(self.frame.size.width + 2.0f, self.frame.size.height + 1.0f)];
  [shadowPath addLineToPoint:CGPointMake(2.0f, self.frame.size.height + 1.0f)];
  [shadowPath addLineToPoint:CGPointMake(2.0f, self.frame.size.height - 1.0f)];
  self.layer.shadowPath = shadowPath.CGPath;

}

- (void)displayMoreImage {
  
  self.frame = CGRectMake(APP_WINDOW.frame.size.width - COLLAPSED_WIDTH, 
                          self.frame.origin.y, 
                          COLLAPSED_WIDTH, 
                          self.frame.size.height);
  
  _moreImageView.frame = CGRectMake((self.frame.size.width - MORE_SIDE_LENGTH)/2.0 + MARGIN, 
                                    (self.frame.size.height - MORE_SIDE_LENGTH)/2.0, 
                                    MORE_SIDE_LENGTH, MORE_SIDE_LENGTH);
  [self setNeedsDisplay];
  
  [self adjustShadow];
}

- (void)dealloc {
  RELEASE_OBJ(_moreImageView);
  
  self.favoriteButton = nil;
  self.shareButton = nil;
  self.closeButton = nil;
  
  self.favoriteSpinView = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                  name:CONN_CANCELL_NOTIFY 
                                                object:nil];    
  [super dealloc];
}

- (void)drawLinerGradientColor:(CGContextRef)context path:(CGPathRef)path {
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGFloat locations[] = { 0.0, 1.0 };
  
  NSArray *colors = @[(id)COLOR(165, 33, 31).CGColor, (id)COLOR(233, 89, 82).CGColor];
  
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
  
  CGPoint startPoint = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMidY(self.bounds));
  CGPoint endPoint = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds));
  
  CGContextSaveGState(context);
  
  CGContextAddPath(context, path);
  CGContextClip(context);
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGContextRestoreGState(context);
  
  CGColorSpaceRelease(colorSpace);
  CGGradientRelease(gradient);

}

- (void)drawOutlineAndFill:(CGContextRef)context {
 
  CGContextMoveToPoint(context, 0, 0);
  CGContextAddLineToPoint(context, self.frame.size.width, 0);
  CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
  CGContextAddLineToPoint(context, 0, self.frame.size.height);
  CGContextAddLineToPoint(context, self.frame.size.height/2.0f, self.frame.size.height/2.0f);
  CGContextAddLineToPoint(context, 0, 0);
  
  CGPathRef currenPath = CGContextCopyPath(context);

  CGContextDrawPath(context, kCGPathFillStroke);
  
  [self drawLinerGradientColor:context path:currenPath];
  
  CFRelease(currenPath);
}

- (void)drawSeparatorLine:(CGContextRef)context {
  CGContextSaveGState(context);
  
  CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
  
  CGContextSetLineDash(context, 0, pattern, 2);
  
  CGContextSetLineWidth(context, 0.5f);
  
  CGFloat x = self.favoriteButton.frame.origin.x + self.favoriteButton.frame.size.width + 1.0f;
  CGContextMoveToPoint(context, x + 0.5, 0 + 0.5);  
  CGContextAddLineToPoint(context, x + 0.5, self.frame.size.height + 0.5);
  
  x = self.shareButton.frame.origin.x + self.shareButton.frame.size.width + 1.0f;
  CGContextMoveToPoint(context, x + 0.5, 0 + 0.5);
  CGContextAddLineToPoint(context, x + 0.5, self.frame.size.height + 0.5);
  
  x = self.commentButton.frame.origin.x + self.commentButton.frame.size.width + 1.0f;
  CGContextMoveToPoint(context, x + 0.5, 0 + 0.5);
  CGContextAddLineToPoint(context, x + 0.5, self.frame.size.height + 0.5);
  
  CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
    
  [self drawOutlineAndFill:context];
  
  if (_expanded) {
    [self drawSeparatorLine:context];
  }
}

- (void)arrangeFavoriteButton:(BOOL)hide {
  if (nil == self.favoriteButton) {
    self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.favoriteButton.backgroundColor = TRANSPARENT_COLOR;
    self.favoriteButton.frame = CGRectMake(MARGIN * 2, (self.frame.size.height - BUTTON_HEIGHT)/2.0f, BUTTON_WIDTH, BUTTON_HEIGHT);
    [self.favoriteButton addTarget:self 
                            action:@selector(favorite:) 
                  forControlEvents:UIControlEventTouchUpInside];
  }
  
  if (hide) {
    if (self.favoriteButton) {
      [self.favoriteButton removeFromSuperview];
    }
  } else {
    NSString *imageName = _item.favorited.boolValue ? @"favorited.png" : @"whiteUnfavorite.png";
    
    [self.favoriteButton setImage:[UIImage imageNamed:imageName]
                         forState:UIControlStateNormal];
    
    [self addSubview:self.favoriteButton];
  }
}

- (void)arrangeShareButton:(BOOL)hide {
  if (nil == self.shareButton) {
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton.backgroundColor = TRANSPARENT_COLOR;
    self.shareButton.frame = CGRectMake(self.favoriteButton.frame.origin.x + BUTTON_WIDTH + 1.0f,
                                        (self.frame.size.height - BUTTON_HEIGHT)/2.0f, BUTTON_WIDTH, BUTTON_HEIGHT);
    [self.shareButton setImage:[UIImage imageNamed:@"whiteShare.png"]
                      forState:UIControlStateNormal];
    [self.shareButton addTarget:self
                         action:@selector(share:)
               forControlEvents:UIControlEventTouchUpInside];
  }
  
  if (hide) {
    if (self.shareButton) {
      [self.shareButton removeFromSuperview];
    }
  } else {
    [self addSubview:self.shareButton];
  }
}

- (void)arrangeCommentButton:(BOOL)hide {
  if (nil == self.commentButton) {
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton.backgroundColor = TRANSPARENT_COLOR;
    self.commentButton.frame = CGRectMake(self.shareButton.frame.origin.x + BUTTON_WIDTH + 1.0f, (self.frame.size.height - BUTTON_HEIGHT)/2.0f, BUTTON_WIDTH, BUTTON_HEIGHT);
    [self.commentButton setImage:[UIImage imageNamed:@"whiteAddComment16.png"]
                        forState:UIControlStateNormal];
    [self.commentButton addTarget:self 
                           action:@selector(addComment:) 
                 forControlEvents:UIControlEventTouchUpInside];
  }
  
  if (hide) {
    if (self.commentButton) {
      [self.commentButton removeFromSuperview];
    }
  } else {
    [self addSubview:self.commentButton];
  }
}

- (void)arrangeCloseButton:(BOOL)hide {
  if (nil == self.closeButton) {
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.backgroundColor = TRANSPARENT_COLOR;
    self.closeButton.frame = CGRectMake(self.commentButton.frame.origin.x + BUTTON_WIDTH + 1.0f, 
                                        (self.frame.size.height - BUTTON_HEIGHT)/2.0f, 
                                        BUTTON_WIDTH, BUTTON_HEIGHT);
    [self.closeButton setImage:[UIImage imageNamed:@"white20Close.png"]
                      forState:UIControlStateNormal];
    
    [self.closeButton addTarget:self
                         action:@selector(close:) 
               forControlEvents:UIControlEventTouchUpInside];
  }
  
  if (hide) {
    if (self.closeButton) {
      [self.closeButton removeFromSuperview];
    }
  } else {
    [self addSubview:self.closeButton];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if (!_expanded) {
    
    [_moreImageView removeFromSuperview];
         
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];

    self.frame = CGRectMake(self.frame.origin.x - (BUTTON_WIDTH * 3 + 2 * 1.0f),
                            self.frame.origin.y, 
                            (self.frame.size.width + (BUTTON_WIDTH * 3 + 2 * 1.0f)), 
                            self.frame.size.height);  
         
    [self arrangeFavoriteButton:NO];
    
    [self arrangeShareButton:NO];
    
    [self arrangeCommentButton:NO];
    
    [self arrangeCloseButton:NO];
    
    _expanded = YES;
    
    [self setNeedsDisplay];
    
    [self adjustShadow];
    
    [UIView commitAnimations];
  }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url 
           contentType:(NSInteger)contentType {
  
  _favoriteButton.hidden = YES;
  self.favoriteSpinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
  self.favoriteSpinView.frame = CGRectMake(0, 0, SPIN_VIEW_SIDE_LENGTH, SPIN_VIEW_SIDE_LENGTH);
  self.favoriteSpinView.center = _favoriteButton.center;
  [self.favoriteSpinView startAnimating];
  [self addSubview:self.favoriteSpinView];
}

- (void)setStatusForConnectionStop {
  _favoriteButton.hidden = NO;
  [self.favoriteSpinView stopAnimating];
  self.favoriteSpinView = nil;
}

- (void)connectDone:(NSData *)result 
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  if (_connectionCancelled) {
    return;
  }
  
  if ([XMLParser parserResponseXml:result 
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    
    
    [self setStatusForConnectionStop];
    
    _item.favorited = [NSNumber numberWithBool:!_item.favorited.boolValue];
    SAVE_MOC(_MOC);
    
    NSString *imageName = _item.favorited.boolValue ? @"favorited.png" : @"whiteUnfavorite.png";
    
    [self.favoriteButton setImage:[UIImage imageNamed:imageName]
                         forState:UIControlStateNormal];
    
  } else {
    NSString *msg = _item.favorited.boolValue ? LocaleStringForKey(NSUnfavoriteFailedMsg, nil) : LocaleStringForKey(NSFavoriteFailedMsg, nil);
    
    [UIUtils showNotificationOnTopWithMsg:msg msgType:ERROR_TY belowNavigationBar:YES];
  }
  
}

- (void)connectCancelled:(NSString *)url 
             contentType:(NSInteger)contentType {
  
}

- (void)connectFailed:(NSError *)error 
                  url:(NSString *)url 
          contentType:(NSInteger)contentType {
  
  [self setStatusForConnectionStop];
  
  NSString *msg = nil;
  if (error) {
    msg = [error localizedDescription];
  } else {
    msg = _item.favorited.boolValue ? LocaleStringForKey(NSUnfavoriteFailedMsg, nil) : LocaleStringForKey(NSFavoriteFailedMsg, nil);
  }
  
  [UIUtils showNotificationOnTopWithMsg:msg msgType:ERROR_TY belowNavigationBar:YES];
}

@end
