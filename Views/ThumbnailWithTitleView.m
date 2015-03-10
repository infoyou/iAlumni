//
//  ThumbnailWithTitleView.m
//  iAlumni
//
//  Created by Adam on 13-1-10.
//
//

#import "ThumbnailWithTitleView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Event.h"

#define TITLE_BACKGROUND_HEIGHT 46.0f

enum {
  BOTTOM_POSITION,
  LEFT_POSITION,
  
};

@interface ThumbnailWithTitleView()

@end

@implementation ThumbnailWithTitleView

#pragma mark - lifecycle methods

- (void)arrangeTitleAndBackgroundViewWithFrame:(CGRect)frame {
  _titleBackgroundView = [[[UIView alloc] initWithFrame:frame] autorelease];
  
  _titleBackgroundView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
  [self addSubview:_titleBackgroundView];
  
  _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                       textColor:[UIColor whiteColor]
                                     shadowColor:TRANSPARENT_COLOR] autorelease];
  _titleLabel.font = BOLD_FONT(13);
  _titleLabel.numberOfLines = 2;
  _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [_titleBackgroundView addSubview:_titleLabel];
}

- (void)AddTitleLabes {
  
  CGRect frame = CGRectZero;
  
  switch (_titlePosition) {
    case BOTTOM_POSITION:
      frame = CGRectMake(0, self.frame.size.height - TITLE_BACKGROUND_HEIGHT, self.frame.size.width, TITLE_BACKGROUND_HEIGHT);
      break;
      
    case LEFT_POSITION:
      frame = CGRectMake(0, self.frame.size.height-TITLE_BACKGROUND_HEIGHT,
                         self.frame.size.width,
                         TITLE_BACKGROUND_HEIGHT);
      break;
      
    default:
      break;
  }
  
  [self arrangeTitleAndBackgroundViewWithFrame:frame];
}

- (id)initNeedBottomTitleWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _titlePosition = BOTTOM_POSITION;
    
    [self AddTitleLabes];
  }
  return self;
}

- (id)initNeedLeftTitleWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _titlePosition = LEFT_POSITION;
    
    [self AddTitleLabes];    
  }
  return self;
}


- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - arrange views

- (void)setTitlePositionWithLimitedWidth:(CGFloat)width {
  CGFloat titleLimitedHeight = _titleBackgroundView.frame.size.height;
  
  if (_subTitleLabel.text.length > 0) {
    _titleLabel.numberOfLines = 1;
    
    titleLimitedHeight = _titleBackgroundView.frame.size.height / 2.0f;
  }
  
  CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font
                                  constrainedToSize:CGSizeMake(width, titleLimitedHeight) lineBreakMode:_titleLabel.lineBreakMode];
  
  CGFloat textHeight = titleSize.height;
  
  CGSize subTitleSize = CGSizeZero;
  if (_subTitleLabel.text.length > 0) {
    subTitleSize = [_subTitleLabel.text sizeWithFont:_subTitleLabel.font
                                   constrainedToSize:CGSizeMake(width, 15.0f)
                                       lineBreakMode:_subTitleLabel.lineBreakMode];
    textHeight += titleSize.height;
  }
  
  CGFloat titleY = (_titleBackgroundView.frame.size.height - textHeight)/2.0f;
  _titleLabel.frame = CGRectMake(/*(_titleBackgroundView.frame.size.width - titleSize.width)/2.0f*/MARGIN,
                                 titleY,
                                 titleSize.width,
                                 titleSize.height);
  
  if (_subTitleLabel.text.length > 0) {
    _subTitleLabel.frame = CGRectMake(/*_titleBackgroundView.frame.size.width - subTitleSize.width - MARGIN*/MARGIN,
                                      _titleLabel.frame.origin.y + _titleLabel.frame.size.height,
                                      subTitleSize.width,
                                      subTitleSize.height);
  }

}

- (void)arrangeTitleForBottomPosition {
  CGFloat width = self.frame.size.width - MARGIN * 4;
  CGFloat height = TITLE_BACKGROUND_HEIGHT - MARGIN * 2;
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(width, height)
                                 lineBreakMode:_titleLabel.lineBreakMode];
  
  CGFloat pageControlY = TITLE_BACKGROUND_HEIGHT - MARGIN * 2 - 2.0f;
  _titleLabel.frame = CGRectMake(MARGIN,
                                 (pageControlY - size.height)/2.0f,
                                 size.width, size.height);
}

- (void)arrangeTitleForLeftPosition {

  //  _titleLabel.numberOfLines = 1;
  
  CGFloat titleLimitedWidth = _titleBackgroundView.frame.size.width - MARGIN * 2;
  
  [self setTitlePositionWithLimitedWidth:titleLimitedWidth];
}

- (void)arrangeTitle:(NSString *)title subTitle:(NSString *)subTitle {
  if (nil == title || title.length == 0) {
    return;
  }
  
  _titleLabel.text = title;
  
  if (subTitle.length > 0) {
    if (nil == _subTitleLabel) {
      _subTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                              textColor:[UIColor redColor]//[UIColor whiteColor]
                                            shadowColor:TRANSPARENT_COLOR] autorelease];
      _subTitleLabel.font = BOLD_FONT(11);
      _subTitleLabel.numberOfLines = 1;
      _subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
      _subTitleLabel.textAlignment = UITextAlignmentLeft;
      
      [_titleBackgroundView addSubview:_subTitleLabel];
    }
    
    _subTitleLabel.text = subTitle;
  }
}

- (void)setLeftTitle:(NSString *)title limitedWidth:(CGFloat)limitedWidth {
  [self arrangeTitle:title subTitle:nil];
  
  [self setTitlePositionWithLimitedWidth:limitedWidth];
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle {
  
  _titleLabel.text = title;
  
  switch (_titlePosition) {
    case BOTTOM_POSITION:
      [self arrangeTitleForBottomPosition];
      break;
      
    case LEFT_POSITION:
      [self arrangeTitleForLeftPosition];
      break;
      
    default:
      break;
  }
}

- (void)setThumbnail:(UIImage *)thumbnail animated:(BOOL)animated {
  
  if (animated) {
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    
    [self.layer addAnimation:imageFadein forKey:nil];
  }
  self.image = [WXWCommonUtils cutMiddlePartImage:thumbnail
                                            width:self.frame.size.width
                                           height:self.frame.size.height];
}

@end
