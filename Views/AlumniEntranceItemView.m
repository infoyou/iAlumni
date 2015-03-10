//
//  AlumniEntranceItemView.m
//  iAlumni
//
//  Created by Adam on 13-1-17.
//
//

#import "AlumniEntranceItemView.h"
#import "WXWLabel.h"
#import "WXWNumberBadge.h"

#define TITLE_HEIGHT  20.0f

@implementation AlumniEntranceItemView

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame {
  
  self = [super initWithFrame:frame];
  if (self) {
            
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:[UIColor whiteColor]
                                       shadowColor:TRANSPARENT_COLOR] autorelease];
    _titleLabel.font = BOLD_FONT(16);
    [self addSubview:_titleLabel];
    
    _subTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:[UIColor whiteColor]
                                       shadowColor:TRANSPARENT_COLOR] autorelease];
    _subTitleLabel.font = BOLD_FONT(15);
    [self addSubview:_subTitleLabel];

  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - set properties
- (void)setEntrance:(id)entrance
         withAction:(SEL)action
              color:(UIColor *)color {
  
  _entrance = entrance;
  
  _action = action;
  
  self.backgroundColor = color;
}

- (void)setImage:(UIImage *)image
       withTitle:(NSString *)title
    withSubTitle:(NSString *)subTitle {
  _titleLabel.text = title;
  
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 2, TITLE_HEIGHT)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _titleLabel.frame = CGRectMake(MARGIN, self.frame.size.height - size.height - MARGIN, size.width, size.height);
  
  if (nil != _imageView) {
    [_imageView removeFromSuperview];
    
    _imageView = nil;
  }
  
  _imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
  
  _imageView.frame = CGRectMake((self.frame.size.width - _imageView.frame.size.width)/2.0f, (_titleLabel.frame.origin.y - _imageView.frame.size.height)/2.0f, _imageView.frame.size.width, _imageView.frame.size.height);
  [self addSubview:_imageView];
  
  if (subTitle && subTitle.length > 0) {
    _subTitleLabel.hidden = NO;
    
    _subTitleLabel.text = subTitle;
    
    size = [_subTitleLabel.text sizeWithFont:_subTitleLabel.font
                           constrainedToSize:CGSizeMake(self.frame.size.width - (_imageView.frame.origin.x + _imageView.frame.size.width), TITLE_HEIGHT)
                               lineBreakMode:NSLineBreakByWordWrapping];
    _subTitleLabel.frame = CGRectMake(self.frame.size.width - MARGIN - size.width, _titleLabel.frame.origin.y - 3.0f - size.height, size.width, size.height);
    
  } else {
    _subTitleLabel.hidden = YES;
  }
}

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
