//
//  CheckinResultHeaderView.m
//  iAlumni
//
//  Created by Adam on 12-8-28.
//
//

#import "CheckinResultHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "UIUtils.h"
#import "Event.h"
#import "RegisterationFeeView.h"

#define PHOTO_WIDTH       56.0f
#define PHOTO_HEIGHT      60.0f

@interface CheckinResultHeaderView()
@property (nonatomic, copy) NSString *backendMsg;
@end

@implementation CheckinResultHeaderView

@synthesize backendMsg = _backendMsg;

- (void)drawView:(CGFloat)resultBoardHeight event:(Event *)event {
  _nameLabel.text = [AppManager instance].userName;
  CGFloat x = _authorPicBackgroundView.frame.origin.x + _authorPicBackgroundView.frame.size.width + MARGIN;
  CGFloat limitedWidth = self.frame.size.width - x - MARGIN * 2;
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                            constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
  _nameLabel.frame = CGRectMake(x, MARGIN * 2, size.width, size.height);
  
  _classLabel.text = [AppManager instance].className;
  size = [_classLabel.text sizeWithFont:_classLabel.font
                      constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
  _classLabel.frame = CGRectMake(x, _nameLabel.frame.origin.y + _nameLabel.frame.size.height + MARGIN,
                                 size.width, size.height);
  

    if (event.hasSignedUp.boolValue) {
      _signUpStatusLabel.text = LocaleStringForKey(NSHaveSignedUpTitle, nil);
    } else {
      _signUpStatusLabel.text = LocaleStringForKey(NSHaveNotSignedUpTitle, nil);
    }
    size = [_signUpStatusLabel.text sizeWithFont:_signUpStatusLabel.font
                               constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    _signUpStatusLabel.frame = CGRectMake(x,
                                          _authorPicBackgroundView.frame.origin.y + _authorPicBackgroundView.frame.size.height - size.height,
                                          size.width, size.height);
  
  
  if (nil == _resultBoardView) {
    _resultBoardView = [[[RegisterationFeeView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                                               _authorPicBackgroundView.frame.origin.y + _authorPicBackgroundView.frame.size.height + MARGIN, self.frame.size.width - MARGIN * 4,
                                                                               resultBoardHeight)
                                                         backendMsg:self.backendMsg] autorelease];
    [self addSubview:_resultBoardView];
  }
  
  [_resultBoardView arrangeViews:event];
  
  if (_imageDisplayerDelegate) {
    [_imageDisplayerDelegate registerImageUrl:[AppManager instance].userImgUrl];
  }
  
  [[WXWImageManager instance] fetchImage:[AppManager instance].userImgUrl
                             caller:self
                           forceNew:NO];
  
  
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
         backendMsg:(NSString *)backendMsg {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = CELL_COLOR;
    
    self.backendMsg = backendMsg;
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    
    _authorPicBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                                         MARGIN * 2,
                                                                         PHOTO_WIDTH + PHOTO_MARGIN * 2,
                                                                         PHOTO_HEIGHT + PHOTO_MARGIN * 2)] autorelease];
    _authorPicBackgroundView.backgroundColor = [UIColor whiteColor];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 1,
                                                                           _authorPicBackgroundView.frame.size.width - 2,
                                                                           _authorPicBackgroundView.frame.size.height - 1)];
    _authorPicBackgroundView.layer.shadowPath = shadowPath.CGPath;
    _authorPicBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _authorPicBackgroundView.layer.shadowOpacity = 0.9f;
    _authorPicBackgroundView.layer.shadowRadius = 1.0f;
    _authorPicBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    _authorPicBackgroundView.layer.masksToBounds = NO;
    [self addSubview:_authorPicBackgroundView];
    
    _authorPic = [[[UIImageView alloc] initWithFrame:CGRectMake(PHOTO_MARGIN, PHOTO_MARGIN,
                                                                PHOTO_WIDTH, PHOTO_HEIGHT)] autorelease];
    _authorPic.backgroundColor = [UIColor whiteColor];
    [_authorPicBackgroundView addSubview:_authorPic];
    
    _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                       textColor:COLOR(44, 45, 51)
                                     shadowColor:[UIColor whiteColor]] autorelease];
    _nameLabel.font = BOLD_FONT(15);
    _nameLabel.numberOfLines = 0;
    [self addSubview:_nameLabel];
    
    _classLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:BASE_INFO_COLOR
                                      shadowColor:[UIColor whiteColor]] autorelease];
    _classLabel.font = BOLD_FONT(12);
    _classLabel.numberOfLines = 0;
    [self addSubview:_classLabel];
    
    _signUpStatusLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                               textColor:DARK_TEXT_COLOR
                                             shadowColor:[UIColor whiteColor]] autorelease];
    _signUpStatusLabel.font = BOLD_FONT(12);
    [self addSubview:_signUpStatusLabel];
    
    _resultBackgroundView = [[[UIView alloc] init] autorelease];
    _resultBackgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_resultBackgroundView];
    
    _resultLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:NAVIGATION_BAR_COLOR
                                       shadowColor:[UIColor whiteColor]] autorelease];
    _resultLabel.font = BOLD_FONT(20);
    _resultLabel.textAlignment = UITextAlignmentCenter;
    _resultLabel.numberOfLines = 0;
    [_resultBackgroundView addSubview:_resultLabel];
    
  }
  return self;
}

- (void)dealloc {
  
  self.backendMsg = nil;
  
  [[WXWImageManager instance] clearCallerFromCache:[AppManager instance].userImgUrl];
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  /// draw wave line ///
  /*
   CGContextSetLineWidth(context, 1);
   CGContextSetLineJoin(context, kCGLineJoinRound);
   
   const CGFloat amplitude = 12 / 4;
   for(CGFloat x = 0; x < 320; x += 0.5)
   {
   CGFloat y = amplitude * sinf(2 * M_PI * (x / 320) * 30) + 10;
   
   if(x == 0)
   CGContextMoveToPoint(context, x, y);
   else
   CGContextAddLineToPoint(context, x, y);
   }
   
   CGContextStrokePath(context);
   */
  //////
  
  CGFloat pattern[2] = {1.0, 2.0};
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(0, self.bounds.size.height - 1.5f)
                  endPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - 1.5f)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 1.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];
  
  [[UIColor colorWithRed:0 green:192/255.0 blue:255/255.0 alpha:1] set];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  
  [_authorPic.layer addAnimation:imageFadein forKey:nil];
  
  _authorPic.image = [CommonUtils cutPartImage:image
                                         width:PHOTO_SIDE_LENGTH
                                        height:PHOTO_SIDE_LENGTH];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  _authorPic.image = [CommonUtils cutPartImage:image
                                         width:PHOTO_SIDE_LENGTH
                                        height:PHOTO_SIDE_LENGTH];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}


@end
