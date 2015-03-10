//
//  WithMeConnectionView.m
//  iAlumni
//
//  Created by Adam on 12-11-20.
//
//

#import "WithMeConnectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "TextConstants.h"


#define ARROW_WIDTH       16.0f
#define ARROW_HEIGHT      16.0f

#define ICON_WIDTH        32.0f
#define ICON_HEIGHT       32.0f

@implementation WithMeConnectionView

- (void)initViews {
  self.layer.cornerRadius = 4.0f;
  self.layer.borderWidth = 0.2f;
  self.layer.borderColor = COLOR(89, 142, 22).CGColor;
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 2,
                                                                         self.frame.size.width - 2,
                                                                         self.frame.size.height - 2)];
  
  self.layer.shadowPath = shadowPath.CGPath;
  self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  self.layer.shadowOpacity = 0.9f;
  self.layer.shadowRadius = 2.0f;
  self.layer.shadowOffset = CGSizeMake(0, 0);
  self.layer.masksToBounds = NO;
  
  UIImageView *iconView = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                         (self.bounds.size.height - ICON_HEIGHT)/2.0f,
                                                                         ICON_WIDTH, ICON_HEIGHT)] autorelease];
  iconView.backgroundColor = TRANSPARENT_COLOR;
  iconView.image = [UIImage imageNamed:@"shakehand.png"];
  [self addSubview:iconView];
  
  _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                      textColor:BASE_INFO_COLOR
                                    shadowColor:TEXT_SHADOW_COLOR] autorelease];
  _titleLabel.font = BOLD_FONT(15);
  _titleLabel.text = LocaleStringForKey(NSWithMeConnectionTitle, nil);
  
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _titleLabel.frame = CGRectMake(iconView.frame.origin.x + iconView.frame.size.width + MARGIN * 2,
                                 (self.bounds.size.height - size.height)/2.0f, size.width, size.height);
  [self addSubview:_titleLabel];
  
  _badgeLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                      textColor:[UIColor whiteColor]
                                    shadowColor:TRANSPARENT_COLOR] autorelease];
  _badgeLabel.backgroundColor = BASE_INFO_COLOR;
  _badgeLabel.layer.masksToBounds = YES;
  _badgeLabel.font = BOLD_FONT(10);
  _badgeLabel.textAlignment = UITextAlignmentCenter;
  _badgeLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  _badgeLabel.alpha = 0.0f;
  [self addSubview:_badgeLabel];
  
  _rightArrow = [[UIImageView alloc] init];
  _rightArrow.image = [UIImage imageNamed:@"rightArrow.png"];
  _rightArrow.backgroundColor = TRANSPARENT_COLOR;
  
  _rightArrow.frame = CGRectMake(self.bounds.size.width - MARGIN - ARROW_WIDTH, self.bounds.size.height/2 - ARROW_HEIGHT/2, ARROW_WIDTH, ARROW_WIDTH);
  [self addSubview:_rightArrow];
}

- (id)initWithFrame:(CGRect)frame
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
{
  self = [super initWithFrame:frame
                     topColor:COLOR(250, 250, 250)
                  bottomColor:COLOR(238, 238, 238)];
  if (self) {
    
    _clickableElementDelegate = clickableElementDelegate;
    
    self.backgroundColor = TRANSPARENT_COLOR;
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
  if (count > 0) {
    _badgeLabel.text = [NSString stringWithFormat:@"%d", count];
    
    CGSize size = [_badgeLabel.text sizeWithFont:_badgeLabel.font
                           constrainedToSize:CGSizeMake(100, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat width = size.width + MARGIN * 4;
    
    _badgeLabel.frame = CGRectMake(_titleLabel.frame.origin.x + _titleLabel.frame.size.width + MARGIN * 2,
                                   (self.frame.size.height - size.height)/2.0f,
                                      width, size.height);
    _badgeLabel.layer.cornerRadius = size.height/2.0f;
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                       _badgeLabel.alpha = 1.0f;
                     }];

  }
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate openWithMeConnections];
  }
}

@end
