//
//  LinkEntranceView.m
//  iAlumni
//
//  Created by Adam on 12-11-15.
//
//

#import "LinkEntranceView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "TextConstants.h"


#define ARROW_WIDTH       10.0f
#define ARROW_HEIGHT      14.0f

#define ICON_WIDTH        32.0f
#define ICON_HEIGHT       32.0f

@implementation LinkEntranceView

- (void)initViews {
  
  self.layer.borderWidth = 0.5f;
  self.layer.borderColor = COLOR(199, 200, 204).CGColor;
  
  if (CURRENT_OS_VERSION < IOS7) {
    
    self.layer.cornerRadius = 4.0f;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 2,
                                                                           self.frame.size.width - 2,
                                                                           self.frame.size.height - 2)];
    
    self.layer.shadowPath = shadowPath.CGPath;
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowOpacity = 0.9f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.masksToBounds = NO;
  }
  
  _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                       textColor:CELL_TITLE_COLOR
                                     shadowColor:TEXT_SHADOW_COLOR] autorelease];
  _titleLabel.font = BOLD_FONT(15);
  _titleLabel.text = LocaleStringForKey(NSMaybeConnectedFriendsTitle, nil);
  
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _titleLabel.frame = CGRectMake(MARGIN * 3,
                                 (self.bounds.size.height - size.height)/2.0f, size.width, size.height);
  [self addSubview:_titleLabel];
  
  _badgeLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                       textColor:[UIColor whiteColor]
                                     shadowColor:TRANSPARENT_COLOR] autorelease];
  _badgeLabel.backgroundColor = COLOR(204, 204, 204);
  _badgeLabel.layer.masksToBounds = YES;
  _badgeLabel.font = BOLD_FONT(12);
  _badgeLabel.textAlignment = UITextAlignmentCenter;
  _badgeLabel.baselineAdjustment = UIBaselineAdjustmentNone;
  _badgeLabel.alpha = 0.0f;
  [self addSubview:_badgeLabel];
  
  _rightArrow = [[UIImageView alloc] init];
  
  _rightArrow.backgroundColor = TRANSPARENT_COLOR;
  
  if (CURRENT_OS_VERSION >= IOS7) {
    _rightArrow.image = [UIImage imageNamed:@"knownFriendsDetail.png"];
    _rightArrow.frame = CGRectMake(self.bounds.size.width - MARGIN * 2 - ARROW_WIDTH - 3.5f, self.bounds.size.height/2 - ARROW_HEIGHT/2, ARROW_WIDTH, ARROW_HEIGHT);
  } else {
    _rightArrow.image = [UIImage imageNamed:@"rightArrow.png"];
    _rightArrow.frame = CGRectMake(self.bounds.size.width - MARGIN * 2 - ARROW_WIDTH, self.bounds.size.height/2 - ARROW_HEIGHT/2, 16, 16);
  }
  [self addSubview:_rightArrow];
}

- (id)initWithFrame:(CGRect)frame
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
{
  self = [super initWithFrame:frame];
  if (self) {
    
    if (CURRENT_OS_VERSION >= IOS7) {
      self.backgroundColor = [UIColor whiteColor];
    } else {
      self.backgroundColor = SERVICE_ITEM_CELL_COLOR;
    }
    
    _clickableElementDelegate = clickableElementDelegate;

    self.clipsToBounds = YES;
    
    [self initViews];
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_rightArrow);
  
  [super dealloc];
}

#pragma mark - arrange views
- (void)beginFlicker {
  [UIView animateWithDuration:0.8f
                        delay:0.f
                      options:(UIViewAnimationOptionAutoreverse| UIViewAnimationOptionRepeat)
                   animations:^{
                     _titleLabel.alpha = 0.2f;
                     _rightArrow.alpha = 0.2f;
                   } completion:^(BOOL finished){
                     _titleLabel.alpha = 1.0f;
                     _rightArrow.alpha = 1.0f;
                   }];
  
}

- (void)updateBadge:(NSInteger)count {
  _badgeLabel.text = [NSString stringWithFormat:@"%d", count];
  
  CGSize size = [_badgeLabel.text sizeWithFont:_badgeLabel.font
                             constrainedToSize:CGSizeMake(100, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat width = size.width + MARGIN * 4;
  
  CGFloat x = 0;
  CGFloat y = 0;
  if (CURRENT_OS_VERSION >= IOS7) {
    x = self.frame.size.width - MARGIN * 5 - width - MARGIN * 2;
    y = (self.frame.size.height - size.height)/2.0f - 1.0f;
  } else {
    x = self.frame.size.width - MARGIN * 3 - width - MARGIN * 2;
    y = (self.frame.size.height - size.height)/2.0f;
  }
  
  _badgeLabel.frame = CGRectMake(/*_titleLabel.frame.origin.x + _titleLabel.frame.size.width + MARGIN * 2*/x,
                                 y,
                                 width, size.height + 4);
  _badgeLabel.layer.cornerRadius = 4.0f;
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _badgeLabel.alpha = 1.0f;
                   }];
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate openKnownAlumnus];
  }
}

@end
