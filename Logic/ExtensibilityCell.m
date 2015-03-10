
#import "ExtensibilityCell.h"

@implementation ExtensibilityCell
@synthesize titleLabel,arrowImageView;

- (void)dealloc
{
  self.titleLabel = nil;
  self.arrowImageView = nil;
  [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)changeArrowWithUp:(BOOL)up
{
  NSInteger degree = 0;
  if (_rotated && !up) {
    degree = 0;
    _rotated = NO;
  } else if (!_rotated && up) {
    degree = 90;
    _rotated = YES;
  }
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     self.arrowImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(degree));
                   }];
}

- (void)drawCell {
  
  CGRect line1Frame = CGRectMake(0, self.contentView.frame.size.height - 0.5, SCREEN_WIDTH, 0.5);
  CGRect line2Frame = CGRectMake(0, self.contentView.frame.size.height - 1, SCREEN_WIDTH, 0.5);
  [self drawSplitLine:line1Frame color:COLOR(27, 28, 30)];
  [self drawSplitLine:line2Frame color:COLOR(77, 77, 77)];
}

- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color
{
  
  UIView *splitLine = [[[UIView alloc] initWithFrame:lineFrame] autorelease];
  splitLine.backgroundColor = color;
  
  [self.contentView addSubview:splitLine];
}

@end
