//
//  AdvEntranceView.m
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import "AdvEntranceView.h"
#import "WXWLabel.h"
#import "Messages.h"
#import "CommonUtils.h"

#define ICON_WIDTH  57.5f
#define ICON_HEIGHT 57.5f

@implementation AdvEntranceView

#pragma mark - lifecycle method
- (id)initWithFrame:(CGRect)frame
          entrancce:(id)entrance
             action:(SEL)action
                MOC:(NSManagedObjectContext *)MOC
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _MOC = MOC;
    
    self.backgroundColor = COLOR(243, 104, 97);
    
    _entrance = entrance;
    
    _action = action;
    
    _imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(85, (frame.size.height - ICON_HEIGHT)/2.0f, ICON_WIDTH, ICON_HEIGHT)] autorelease];
    _imageView.image = [UIImage imageNamed:@"donate.png"];
    [self addSubview:_imageView];
    
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:[UIColor whiteColor]
                                       shadowColor:TRANSPARENT_COLOR] autorelease];
    _titleLabel.font = BOLD_FONT(18);
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.text = LocaleStringForKey(NSDonateTitle, nil);
    
    CGSize size = [CommonUtils sizeForText:_titleLabel.text
                                      font:_titleLabel.font];
    _titleLabel.frame = CGRectMake(MARGIN * 2, self.frame.size.height - 7 - size.height, size.width, size.height);
    
    [self addSubview:_titleLabel];
    
    //[self arrangeMessages];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - arrange titles
- (void)arrangeMessages {
  
    _titleLabel.text = LocaleStringForKey(NSFollowWechatForHelpMsg, nil);
    
    CGFloat width = _imageView.frame.origin.x - MARGIN *2 - MARGIN * 2;
    
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                               constrainedToSize:CGSizeMake(width, self.frame.size.height)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    _titleLabel.frame = CGRectMake(MARGIN * 2,
                                   (self.frame.size.height - size.height)/2.0f,
                                   size.width, size.height);
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_entrance && _action) {
    [_entrance performSelector:_action];
  }
}

@end
