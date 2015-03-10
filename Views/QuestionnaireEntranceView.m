//
//  QuestionnaireEntranceView.m
//  iAlumni
//
//  Created by Adam on 13-2-3.
//
//

#import "QuestionnaireEntranceView.h"
#import "WXWLabel.h"
#import "AppManager.h"

#define ICON_WIDTH  44.0f
#define ICON_HEIGHT 50.0f


@implementation QuestionnaireEntranceView

- (void)addTitleLabel {
  _mainTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:[UIColor whiteColor]
                                         shadowColor:TRANSPARENT_COLOR] autorelease];
  _mainTitleLabel.font = BOLD_FONT(20);
  _mainTitleLabel.numberOfLines = 2;
  _mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  [self addSubview:_mainTitleLabel];
  
  _mainTitleLabel.text = LocaleStringForKey(NSQuestionnaireTitle, nil);
  
  CGFloat limitedWidth = self.frame.size.width - (_imageView.frame.origin.x + _imageView.frame.size.width + MARGIN) - MARGIN * 2;
  
  CGSize size = [_mainTitleLabel.text sizeWithFont:_mainTitleLabel.font
                                 constrainedToSize:CGSizeMake(limitedWidth, ICON_HEIGHT/2.0f)
                                     lineBreakMode:NSLineBreakByWordWrapping];
  _mainTitleLabel.frame = CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + MARGIN, _imageView.frame.origin.y, size.width, size.height);
  
  _subTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:[UIColor whiteColor]
                                         shadowColor:TRANSPARENT_COLOR] autorelease];
  _subTitleLabel.font = BOLD_FONT(13);
  _subTitleLabel.numberOfLines = 2;
  _subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  _subTitleLabel.text = [AppManager instance].questionSubTitle;
  size = [_subTitleLabel.text sizeWithFont:_subTitleLabel.font
                          constrainedToSize:CGSizeMake(limitedWidth, ICON_HEIGHT/4.0f)
                              lineBreakMode:NSLineBreakByWordWrapping];
  _subTitleLabel.frame = CGRectMake(_mainTitleLabel.frame.origin.x, _imageView.frame.origin.y + _imageView.frame.size.height - size.height, size.width, size.height);
  [self addSubview:_subTitleLabel];
}

- (id)initWithFrame:(CGRect)frame entrancce:(id)entrance action:(SEL)action
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = COLOR(195, 193, 191);//COLOR(28, 47, 78);
    
    _entrance = entrance;
    
    _action = action;
    
    _imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, (frame.size.height - ICON_HEIGHT)/2.0f, ICON_WIDTH, ICON_HEIGHT)] autorelease];
    _imageView.image = [UIImage imageNamed:@"survey.png"];
    [self addSubview:_imageView];
    
    [self addTitleLabel];
    
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_entrance && _action) {
    [_entrance performSelector:_action];
  }
}

@end
