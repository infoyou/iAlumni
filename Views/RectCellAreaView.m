//
//  RectCellAreaView.m
//  iAlumni
//
//  Created by Adam on 13-9-8.
//
//

#import "RectCellAreaView.h"
#import "UIUtils.h"
#import "WXWLabel.h"

#define ICON_WIDTH  7.0f
#define ICON_HEIGHT 11.0f

#define STAR_SIDE_LEN 19.0f

@implementation RectCellAreaView

#pragma mark - life cycle methods
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *starIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fivePointedStar.png"]] autorelease];
    starIcon.frame = CGRectMake(MARGIN * 2, (frame.size.height - STAR_SIDE_LEN)/2.0f, STAR_SIDE_LEN, STAR_SIDE_LEN);
    [self addSubview:starIcon];
    
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(starIcon.frame.origin.x + STAR_SIDE_LEN + MARGIN * 2, 0, 0, 0)
                                         textColor:BASE_INFO_COLOR
                                       shadowColor:TRANSPARENT_COLOR
                                              font:BOLD_FONT(15)] autorelease];
    [self addSubview:_titleLabel];
    
    UIImageView *arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventArrow.png"]] autorelease];
    arrow.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - ICON_WIDTH, (self.frame.size.height - ICON_HEIGHT)/2.0f, ICON_WIDTH, ICON_HEIGHT);
    [self addSubview:arrow];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)drawWithNeedBottomLine:(BOOL)needBottomLine title:(NSString *)title {
  
  _needBottomLine = needBottomLine;
  
  _titleLabel.text = title;
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font];
  _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, (self.frame.size.height - size.height)/2.0f, size.width, size.height);
  
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
 
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(ctx);
  
  CGFloat height = self.frame.size.height;
  if (!_needBottomLine) {
    height = self.frame.size.height + 1.0f;
  }
  
  UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, height)];
  
  CGContextAddPath(ctx, path.CGPath);
  
  CGContextSetStrokeColorWithColor(ctx, SEPARATOR_LINE_COLOR.CGColor);
  CGContextSetLineWidth(ctx, 0.5f);
  CGContextStrokePath(ctx);
  
  CGContextRestoreGState(ctx);
  
}


@end
