//
//  TabBarItem.m
//  iAlumni
//
//  Created by Adam on 13-1-10.
//
//

#import "TabBarItem.h"
#import "WXWLabel.h"
#import "WXWNumberBadge.h"

#define ICON_SIDE_LENGTH 20.0f

#define HIGHLIGHT_COLOR NAVIGATION_BAR_COLOR

#define NORMAL_COLOR    COLOR(26,26,26)

#define BADGE_HEIGHT    16.0f

#define DOT_RADIUS          5.0f

@implementation TabBarItem

- (void)setTitle:(NSString *)title image:(UIImage *)image {
  
  _titleLabel.text = title;
  
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                            constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height)
                                lineBreakMode:NSLineBreakByWordWrapping];
  _titleLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                                (self.frame.size.height - size.height),
                                size.width, size.height);
  [self setImage:image];
}

- (void)setTitleColorForHighlight:(BOOL)highlight {
  if (highlight) {
    _titleLabel.textColor = HIGHLIGHT_COLOR;
  } else {
    _titleLabel.textColor = NORMAL_COLOR;
  }
}

- (void)setImage:(UIImage *)image {
  _imageView.image = image;
  _imageView.frame = CGRectMake(_imageView.frame.origin.x,
                                _titleLabel.frame.origin.y - ICON_SIDE_LENGTH - 1.0f,
                                ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
}

- (id)initWithFrame:(CGRect)frame
           delegate:(id)delegate
    selectionAction:(SEL)selectionAction
                tag:(NSInteger)tag {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    
    self.tag = tag;
    
    self.backgroundColor = [UIColor whiteColor];
    
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:NORMAL_COLOR
                                       shadowColor:TRANSPARENT_COLOR] autorelease];
    _titleLabel.font = FONT(10);
    [self addSubview:_titleLabel];
    
    _imageView = [[[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - ICON_SIDE_LENGTH)/2.0f, 0, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH)] autorelease];
    [self addSubview:_imageView];
    
    _delegate = delegate;
    _selectionAction = selectionAction;
  }
  
  
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - set number badge
- (void)setNumberBadgeWithCount:(NSInteger)count showNewFlag:(BOOL)showNewFlag {
  
  if (!showNewFlag) {
    if (_dot != nil) {
      _dot.hidden = YES;
    }
  }
  
  
  if (nil == _numberBadge) {
    _numberBadge = [[[WXWNumberBadge alloc] initWithFrame:CGRectMake(0,
                                                                     _imageView.frame.origin.y,
                                                                     0,
                                                                     BADGE_HEIGHT)
                                                 topColor:NUMBER_BADGE_TOP_COLOR
                                              bottomColor:NUMBER_BADGE_BOTTOM_COLOR
                                                     font:BOLD_FONT(12)] autorelease];
    [self addSubview:_numberBadge];
  }
  
  if (count > 0) {
    _numberBadge.hidden = NO;
    
    [_numberBadge setNumberWithTitle:[NSString stringWithFormat:@"%d", count]];
    
    _numberBadge.frame = CGRectMake(self.frame.size.width - _numberBadge.frame.size.width - MARGIN,
                                    _imageView.frame.origin.y,
                                    _numberBadge.frame.size.width,
                                    _numberBadge.frame.size.height);
    
    if (_dot != nil) {
      _dot.hidden = YES;
    }
  } else {
    _numberBadge.hidden = YES;
    
    if (showNewFlag) {
      if (nil == _dot) {
        _dot = [[[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - DOT_RADIUS * 2 - MARGIN * 2, _imageView.frame.origin.y, DOT_RADIUS * 2, DOT_RADIUS * 2)] autorelease];
        _dot.backgroundColor = NAVIGATION_BAR_COLOR;
        _dot.layer.cornerRadius = DOT_RADIUS;
        [self addSubview:_dot];
      }
      _dot.hidden = NO;
    }
  }
  
}

#pragma mark - override touch event 
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_delegate && _selectionAction) {
    [_delegate performSelector:_selectionAction
                    withObject:@(self.tag)];
  }
}


@end
