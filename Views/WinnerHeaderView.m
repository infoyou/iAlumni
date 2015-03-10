//
//  WinnerHeaderView.m
//  iAlumni
//
//  Created by Adam on 12-10-27.
//
//

#import "WinnerHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"

#define INFO_LABEL_X      40.0f
#define INFO_LABEL_WIDTH  250.0f
#define GIFT_SIDE_LENGTH  22.0f

#define ROTATE_COUNT      5

@interface WinnerHeaderView()

@end

@implementation WinnerHeaderView

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
   userListDelegate:(id<ECClickableElementDelegate>)userListDelegate {
  self = [super initWithFrame:frame];
  
  if (self) {
    
    _userListDelegate = userListDelegate;
    
    _backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.frame.size.width,
                                                                     WINNER_HEADER_HEIGHT)] autorelease];
    _backgroundView.backgroundColor = TRANSPARENT_COLOR;
    _backgroundView.image = [UIImage imageNamed:@"winnerBackground.png"];
    [self addSubview:_backgroundView];
    
    _giftView = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                               MARGIN * 2,
                                                               GIFT_SIDE_LENGTH,
                                                               GIFT_SIDE_LENGTH)] autorelease];
    _giftView.backgroundColor = TRANSPARENT_COLOR;
    _giftView.image = [UIImage imageNamed:@"gift.png"];
    [_backgroundView addSubview:_giftView];
    
    [self animationGift];
    
    _infoLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(INFO_LABEL_X,
                                                            0,
                                                            INFO_LABEL_WIDTH,
                                                            0)
                                       textColor:[UIColor whiteColor]
                                     shadowColor:[UIColor blackColor]] autorelease];
    _infoLabel.font = BOLD_FONT(13);
    _infoLabel.numberOfLines = 2;
    _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_backgroundView addSubview:_infoLabel];
  }
  
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - arrange view

- (void)animationGift {
   
  CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animation];
  
  NSMutableArray *values = [NSMutableArray array];
  for (int i = 0; i <= ROTATE_COUNT * 2; i++) {
    
    CGFloat angle = i * 3.14f;
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(angle, 0,0,1)]];
  }
  
  theAnimation.values = values;
  
	theAnimation.cumulative = YES;
	theAnimation.duration = 3.5f;
	theAnimation.removedOnCompletion = YES;
  
  theAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
   
  
  [_giftView.layer addAnimation:theAnimation forKey:@"transform"];
}

- (void)setWinnerInfo:(NSString *)info winnerType:(WinnerType)winnerType {

  CATransition *fadein = [CATransition animation];
  fadein.duration = FADE_IN_DURATION;
  fadein.type = kCATransitionFade;
  
  [_infoLabel.layer addAnimation:fadein forKey:nil];
  
  _infoLabel.text = info;
  CGSize size = [_infoLabel.text sizeWithFont:_infoLabel.font
                            constrainedToSize:CGSizeMake(INFO_LABEL_WIDTH, WINNER_HEADER_HEIGHT)
                                lineBreakMode:NSLineBreakByWordWrapping];
  _infoLabel.frame = CGRectMake(INFO_LABEL_X,
                                (WINNER_HEADER_HEIGHT - size.height)/2.0f,
                                size.width, size.height);
}

#pragma mark - touch event
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

  if (_userListDelegate) {
    [_userListDelegate showWinnersAndAwards];
  }
  
}

@end
