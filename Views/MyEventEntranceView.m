//
//  MyEventEntranceView.m
//  iAlumni
//
//  Created by Adam on 13-1-16.
//
//

#import "MyEventEntranceView.h"
#import "WXWLabel.h"

#define ICON_WIDTH  50.0f
#define ICON_HEIGHT 50.0f

@implementation MyEventEntranceView

#pragma mark - lifecycle methods
- (void)addTitleLabel {
  _mainTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                       textColor:[UIColor whiteColor]
                                     shadowColor:[UIColor darkGrayColor]] autorelease];
  _mainTitleLabel.font = BOLD_FONT(20);
  _mainTitleLabel.numberOfLines = 2;
  _mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  [self addSubview:_mainTitleLabel];
  
  _mainTitleLabel.text = LocaleStringForKey(NSMyEventMsg, nil);
  
  CGFloat limitedWidth = self.frame.size.width - (_imageView.frame.origin.x + _imageView.frame.size.width + MARGIN) - MARGIN * 2;
  
  CGSize size = [_mainTitleLabel.text sizeWithFont:_mainTitleLabel.font
                             constrainedToSize:CGSizeMake(limitedWidth, ICON_HEIGHT/2.0f)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _mainTitleLabel.frame = CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + MARGIN, _imageView.frame.origin.y, size.width, size.height);
  
  _sub1TitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:[UIColor whiteColor]
                                         shadowColor:[UIColor darkGrayColor]] autorelease];
  _sub1TitleLabel.font = BOLD_FONT(13);
  _sub1TitleLabel.numberOfLines = 2;
  _sub1TitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  _sub1TitleLabel.text = LocaleStringForKey(NSSignedAndJoinedEventTitle, nil);
  size = [_sub1TitleLabel.text sizeWithFont:_sub1TitleLabel.font
                          constrainedToSize:CGSizeMake(limitedWidth, ICON_HEIGHT/4.0f)
                              lineBreakMode:NSLineBreakByWordWrapping];
  _sub1TitleLabel.frame = CGRectMake(_mainTitleLabel.frame.origin.x, _imageView.frame.origin.y + _imageView.frame.size.height - size.height, size.width, size.height);
  [self addSubview:_sub1TitleLabel];

}

- (id)initWithFrame:(CGRect)frame
          entrancce:(id)entrance
             action:(SEL)action
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = COLOR(241, 163, 52);
    
    self.layer.masksToBounds = YES;
    
    _entrance = entrance;
    
    _action = action;
    
    _imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, (frame.size.height - ICON_HEIGHT)/2.0f, ICON_WIDTH, ICON_HEIGHT)] autorelease];
    _imageView.image = [UIImage imageNamed:@"whiteAction.png"];
    [self addSubview:_imageView];
    
    [self addTitleLabel];
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_entrance && _action) {
    [_entrance performSelector:_action];
  }
}

@end
