//
//  AlumniEventDetailActionView.m
//  iAlumni
//
//  Created by Adam on 13-1-26.
//
//

#import "AlumniEventDetailActionView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Event.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECPlainButton.h"
#import "ECGradientButton.h"
#import "UIImageButton.h"

#define BUTTON_WIDTH        80.0f
#define BUTTON_HEIGHT       48.f
#define BOTTOM_TOOL_H       48.f

#define FONT_SIZE           15.f

enum {
  VOTE_TAG,
  AWARD_TAG,
  DISCUSS_TAG,
  OTHER_TAG,
};

@implementation AlumniEventDetailActionView

- (void)selectionAction:(id)sender {
  
  if (nil == _delegate) {
    return;
  }
  
  ECGradientButton *button = (ECGradientButton *)sender;
  
  switch (button.tag) {
      
    case VOTE_TAG:
      [_delegate voteAction];
      break;
      
    case AWARD_TAG:
      [_delegate awardAction];
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

- (void)addShadow {
  UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
  
  self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  self.layer.shadowOffset = CGSizeZero;
  self.layer.shadowPath = path.CGPath;
  self.layer.shadowRadius = 2.0f;
  self.layer.shadowOpacity = 0.9f;
}

- (id)initWithFrame:(CGRect)frame
              event:(Event *)event
           delegate:(id<EventActionDelegate>)delegate
{
  self = [super initWithFrame:frame];
  
  if (self) {
    _delegate = delegate;
    [self initButtons];
    
    [self addShadow];
  }
  return self;
}

- (void)initButtons {
  
  // just keep share button
  self.backgroundColor = [UIColor whiteColor];
  CGRect shareFrame = CGRectMake((self.frame.size.width - BUTTON_WIDTH)/2.0f, 0,
                                 BUTTON_WIDTH,
                                 BUTTON_HEIGHT);
  ECGradientButton *shareBtn = [[[ECGradientButton alloc] initWithFrame:shareFrame
                                                                 target:self
                                                                 action:@selector(selectionAction:)
                                                              colorType:TRANSPARENT_BTN_COLOR_TY
                                                                  title:LocaleStringForKey(NSShareTitle, nil)
                                                                  image:[UIImage imageNamed:@"eventShareBottom.png"]
                                                             titleColor:COLOR(102, 102, 102)
                                                       titleShadowColor:TRANSPARENT_COLOR
                                                              titleFont:BOLD_FONT(15)
                                                            roundedType:NO_ROUNDED
                                                        imageEdgeInsert:UIEdgeInsetsMake(10.f, 13.0, 11.f, 40)
                                                        titleEdgeInsert:UIEdgeInsetsMake(-10.f, -15, -10.f, 0)
                                                             hideBorder:YES] autorelease];
  
  shareBtn.tag = OTHER_TAG;
  shareBtn.showsTouchWhenHighlighted = YES;
  [self addSubview:shareBtn];
  
  /*
   UIImageView *backgroundView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
   backgroundView.image = [UIImage imageNamed:@"eventBottom.png"];
   backgroundView.frame = CGRectMake(0, 0, self.frame.size.width, BOTTOM_TOOL_H);
   backgroundView.userInteractionEnabled = YES;
   [self addSubview:backgroundView];

    CGRect awardFrame = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
  ECGradientButton *awardBtn = [[[ECGradientButton alloc] initWithFrame:awardFrame
                                                                 target:self
                                                                 action:@selector(selectionAction:)
                                                              colorType:TRANSPARENT_BTN_COLOR_TY
                                                                  title:LocaleStringForKey(NSAwardTitle, nil)
                                                                  image:[UIImage imageNamed:@"eventAwardBottom.png"]
                                                             titleColor:COLOR(102, 102, 102)
                                                       titleShadowColor:TRANSPARENT_COLOR
                                                              titleFont:FONT(FONT_SIZE)
                                                            roundedType:NO_ROUNDED
                                                        imageEdgeInsert:UIEdgeInsetsMake(10.f, 13.0, 11.f, 40)
                                                        titleEdgeInsert:UIEdgeInsetsMake(-10.f, -15, -10.f, 0)
                                                             hideBorder:YES] autorelease];
  awardBtn.tag = AWARD_TAG;
  awardBtn.showsTouchWhenHighlighted = YES;
  [backgroundView addSubview:awardBtn];
  
    CGRect voteFrame = CGRectMake(BUTTON_WIDTH, 0,
                                  BUTTON_WIDTH, BUTTON_HEIGHT);
    ECGradientButton *voteBtn = [[[ECGradientButton alloc] initWithFrame:voteFrame
                                                                  target:self
                                                                  action:@selector(selectionAction:)
                                                               colorType:TRANSPARENT_BTN_COLOR_TY
                                                                   title:LocaleStringForKey(NSVoteTitle, nil)
                                                                   image:[UIImage imageNamed:@"eventVoteBottom.png"]
                                                              titleColor:COLOR(102, 102, 102)
                                                        titleShadowColor:TRANSPARENT_COLOR
                                                               titleFont:FONT(FONT_SIZE)
                                                             roundedType:NO_ROUNDED
                                                         imageEdgeInsert:UIEdgeInsetsMake(10.f, 13.0, 11.f, 40)
                                                         titleEdgeInsert:UIEdgeInsetsMake(-10.f, -15, -10.f, 0)
                                                              hideBorder:YES] autorelease];
    voteBtn.tag = VOTE_TAG;
    voteBtn.showsTouchWhenHighlighted = YES;
    [backgroundView addSubview:voteBtn];
      
    CGRect shareFrame = CGRectMake(BUTTON_WIDTH * 2, 0,
                                   BUTTON_WIDTH,
                                   BUTTON_HEIGHT);
  ECGradientButton *shareBtn = [[[ECGradientButton alloc] initWithFrame:shareFrame
                                                                 target:self
                                                                 action:@selector(selectionAction:)
                                                              colorType:TRANSPARENT_BTN_COLOR_TY
                                                                  title:LocaleStringForKey(NSShareTitle, nil)
                                                                  image:[UIImage imageNamed:@"eventShareBottom.png"]
                                                             titleColor:COLOR(102, 102, 102)
                                                       titleShadowColor:TRANSPARENT_COLOR
                                                              titleFont:FONT(FONT_SIZE)
                                                            roundedType:NO_ROUNDED
                                                        imageEdgeInsert:UIEdgeInsetsMake(10.f, 13.0, 11.f, 40)
                                                        titleEdgeInsert:UIEdgeInsetsMake(-10.f, -15, -10.f, 0)
                                                             hideBorder:YES] autorelease];
  
  shareBtn.tag = OTHER_TAG;
  shareBtn.showsTouchWhenHighlighted = YES;
  [backgroundView addSubview:shareBtn];
  
    CGRect discussFrame = CGRectMake(BUTTON_WIDTH * 3, 0,
                                     BUTTON_WIDTH,
                                     BUTTON_HEIGHT);
    ECGradientButton *discussBtn = [[[ECGradientButton alloc] initWithFrame:discussFrame
                                                                     target:self
                                                                     action:@selector(selectionAction:)
                                                                  colorType:TRANSPARENT_BTN_COLOR_TY
                                                                      title:LocaleStringForKey(NSDiscussTitle, nil)
                                                                      image:[UIImage imageNamed:@"eventDiscussBottom.png"]
                                                                 titleColor:COLOR(102, 102, 102)
                                                           titleShadowColor:TRANSPARENT_COLOR
                                                                  titleFont:FONT(FONT_SIZE)
                                                                roundedType:NO_ROUNDED
                                                            imageEdgeInsert:UIEdgeInsetsMake(10.f, 13.0, 11.f, 40)
                                                            titleEdgeInsert:UIEdgeInsetsMake(-10.f, -15, -10.f, 0)
                                                                 hideBorder:YES] autorelease];
    discussBtn.tag = DISCUSS_TAG;
    discussBtn.showsTouchWhenHighlighted = YES;
    [backgroundView addSubview:discussBtn];
*/
}

@end
