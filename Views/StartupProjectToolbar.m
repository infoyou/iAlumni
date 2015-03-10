//
//  StartupProjectToolbar.m
//  iAlumni
//
//  Created by Adam on 13-3-3.
//
//

#import "StartupProjectToolbar.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Event.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECPlainButton.h"
#import "ECGradientButton.h"
#import "UIImageButton.h"
#import "WXWUIUtils.h"

#define BUTTON_WIDTH        107.0f
#define BUTTON_HEIGHT       48.f
#define BOTTOM_TOOL_H       48.f

enum {
  VOTE_TAG,
  DISCUSS_TAG,
  OTHER_TAG,
};


@implementation StartupProjectToolbar

#pragma mark - user actions
- (void)selectionAction:(id)sender {
  
  if (nil == _delegate) {
    return;
  }
  
  ECGradientButton *button = (ECGradientButton *)sender;
  
  switch (button.tag) {
      
    case VOTE_TAG:
      [_delegate voteAction];
      break;
            
    case DISCUSS_TAG:
      [_delegate discussAction];
      break;
      
    case OTHER_TAG:
      [_delegate moreAction];
      break;
      
    default:
      break;
  }
}


- (id)initWithFrame:(CGRect)frame
              event:(Event *)event
           delegate:(id<EventActionDelegate>)delegate
{
  self = [super initWithFrame:frame
                     topColor:COLOR(40, 40, 40)
                  bottomColor:COLOR(3, 3, 3)];
  
  if (self) {
    _delegate = delegate;
    [self initButtons];
  }
  return self;
}

- (void)initButtons {  
  ECGradientButton *voteBtn = [[[ECGradientButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
                                                                target:self
                                                                action:@selector(selectionAction:)
                                                             colorType:TRANSPARENT_BTN_COLOR_TY
                                                                 title:LocaleStringForKey(NSVoteTitle, nil)
                                                                 image:[UIImage imageNamed:@"vote.png"]
                                                            titleColor:[UIColor whiteColor]
                                                      titleShadowColor:[UIColor clearColor]
                                                             titleFont:FONT(10)
                                                           roundedType:NO_ROUNDED
                                                       imageEdgeInsert:UIEdgeInsetsMake(11.f, 44.0, 21.f, 46.0)
                                                       titleEdgeInsert:UIEdgeInsetsMake(12.f, -21, -10.f, 10)
                                                            hideBorder:YES] autorelease];
  voteBtn.tag = VOTE_TAG;
  voteBtn.showsTouchWhenHighlighted = YES;
  [self addSubview:voteBtn];
  
  ECGradientButton *discussBtn = [[[ECGradientButton alloc] initWithFrame:CGRectMake(BUTTON_WIDTH, 0,
                                                                                     BUTTON_WIDTH,
                                                                                     BUTTON_HEIGHT)
                                                                   target:self
                                                                   action:@selector(selectionAction:)
                                                                colorType:TRANSPARENT_BTN_COLOR_TY
                                                                    title:LocaleStringForKey(NSDiscussTitle, nil)
                                                                    image:[UIImage imageNamed:@"discuss.png"]
                                                               titleColor:[UIColor whiteColor]
                                                         titleShadowColor:[UIColor clearColor]
                                                                titleFont:FONT(10)
                                                              roundedType:NO_ROUNDED
                                                          imageEdgeInsert:UIEdgeInsetsMake(13.f, 45.0, 19.f, 45.0)
                                                          titleEdgeInsert:UIEdgeInsetsMake(12.f, -22, -10.f, 10)
                                                               hideBorder:YES] autorelease];
  discussBtn.tag = DISCUSS_TAG;
  discussBtn.showsTouchWhenHighlighted = YES;
  [self addSubview:discussBtn];
  
  ECGradientButton *otherBtn = [[[ECGradientButton alloc] initWithFrame:CGRectMake(BUTTON_WIDTH * 2, 0,
                                                                                   106,
                                                                                   BUTTON_HEIGHT)
                                                                 target:self
                                                                 action:@selector(selectionAction:)
                                                              colorType:TRANSPARENT_BTN_COLOR_TY
                                                                  title:LocaleStringForKey(NSShareTitle, nil)
                                                                  image:[UIImage imageNamed:@"eventShare.png"]
                                                             titleColor:[UIColor whiteColor]
                                                       titleShadowColor:[UIColor clearColor]
                                                              titleFont:FONT(10)
                                                            roundedType:NO_ROUNDED
                                                        imageEdgeInsert:UIEdgeInsetsMake(11.f, 44.0, 21.f, 46.0)
                                                        titleEdgeInsert:UIEdgeInsetsMake(12.f, -22, -10.f, 12)
                                                             hideBorder:YES] autorelease];
  
  otherBtn.tag = OTHER_TAG;
  otherBtn.showsTouchWhenHighlighted = YES;
  [self addSubview:otherBtn];
}

#pragma mark - draw
- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [WXWUIUtils draw1PxStroke:context
                 startPoint:CGPointMake(BUTTON_WIDTH, 0)
                   endPoint:CGPointMake(BUTTON_WIDTH, self.frame.size.height)
                      color:COLOR(0, 0, 0).CGColor
               shadowOffset:CGSizeMake(0.5f, 0)
                shadowColor:COLOR(77, 77, 77)];
  
  CGFloat x = BUTTON_WIDTH * 2;
  
  [WXWUIUtils draw1PxStroke:context
                 startPoint:CGPointMake(x, 0)
                   endPoint:CGPointMake(x, self.frame.size.height)
                      color:COLOR(0, 0, 0).CGColor
               shadowOffset:CGSizeMake(0.5f, 0)
                shadowColor:COLOR(77, 77, 77)];

}
@end
