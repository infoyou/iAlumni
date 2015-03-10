//
//  EntertainmentEventEntranceView.m
//  iAlumni
//
//  Created by Adam on 13-1-16.
//
//

#import "EntertainmentEventEntranceView.h"
#import "WXWLabel.h"
#import "WXWNumberBadge.h"

#define ICON_WIDTH  40.0f
#define ICON_HEIGHT 40.0f

@implementation EntertainmentEventEntranceView

#pragma mark - lifecycle methods
- (void)addTitleLabel {
  _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                       textColor:[UIColor whiteColor]
                                     shadowColor:[UIColor darkGrayColor]] autorelease];
  _titleLabel.font = BOLD_FONT(16);
  _titleLabel.numberOfLines = 2;
  _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  [self addSubview:_titleLabel];
  
  _titleLabel.text = LocaleStringForKey(NSStartupTitle, nil);
  
  CGFloat limitedWidth = self.frame.size.width - MARGIN * 4;
  
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(limitedWidth, self.frame.size.height - MARGIN * 2)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _titleLabel.frame = CGRectMake(self.frame.size.width - size.width - MARGIN,
                                 self.frame.size.height - size.height - MARGIN, size.width, size.height);
}

- (id)initWithFrame:(CGRect)frame
          entrancce:(id)entrance
             action:(SEL)action
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = COLOR(90, 165, 20);
    
    self.layer.masksToBounds = YES;
    
    _entrance = entrance;
    
    _action = action;
    
    _imageView = [[[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - ICON_WIDTH)/2.0f, MARGIN * 2, ICON_WIDTH, ICON_HEIGHT)] autorelease];
    _imageView.image = [UIImage imageNamed:@"sailboat.png"];
    [self addSubview:_imageView];
    
    [self addTitleLabel];
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}

#pragma mark - set number badge
- (void)setNumberBadgeWithCount:(NSInteger)count {
  
  if (nil == _numberBadge) {
    _numberBadge = [[[WXWNumberBadge alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width - MARGIN, _imageView.frame.origin.y, 0, NUMBER_BADGE_HEIGHT)
                                                 topColor:NUMBER_BADGE_TOP_COLOR
                                              bottomColor:NUMBER_BADGE_BOTTOM_COLOR
                                                     font:BOLD_FONT(12)] autorelease];
    [self addSubview:_numberBadge];
  }
  
  if (count > 0) {
    _numberBadge.hidden = NO;
    
    [_numberBadge setNumberWithTitle:[NSString stringWithFormat:@"%d", count]];
  } else {
    _numberBadge.hidden = YES;
  }
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_entrance && _action) {
    [_entrance performSelector:_action];
  }
}

@end
