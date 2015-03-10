//
//  SearchAlumniEntranceView.m
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import "SearchAlumniEntranceView.h"
#import "WXWLabel.h"
#import "CommonUtils.h"

#define ICON_WIDTH    57.5f
#define ICON_HEIGHT   57.5f

@implementation SearchAlumniEntranceView

- (id)initWithFrame:(CGRect)frame entrancce:(id)entrance action:(SEL)action
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = COLOR(33, 185, 178);
    
    _entrance = entrance;
    
    _action = action;
    
    CGFloat y = 0;
    if ([CommonUtils screenHeightIs4Inch]) {
      y = MARGIN * 4;
    } else {
      y = MARGIN * 2;
    }
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(58.4f, y, ICON_WIDTH, ICON_HEIGHT)] autorelease];
    imageView.image = [UIImage imageNamed:@"whiteSearch.png"];
    [self addSubview:imageView];
    
    WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                             textColor:[UIColor whiteColor]
                                           shadowColor:TRANSPARENT_COLOR] autorelease];
    label.font = BOLD_FONT(18);
    label.textAlignment = UITextAlignmentCenter;
    label.text = LocaleStringForKey(NSAlumniSearchTitle, nil);
    
    CGSize size = [CommonUtils sizeForText:label.text
                                      font:label.font
                         constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 6, self.frame.size.height)
                             lineBreakMode:BREAK_BY_TRUNCATING_TAIL];
    label.frame = CGRectMake(MARGIN * 2, self.frame.size.height - MARGIN * 3 - size.height, size.width, size.height);
    
    [self addSubview:label];
    
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
