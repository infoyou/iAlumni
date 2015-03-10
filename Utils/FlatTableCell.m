//
//  FlatTableCell.m
//  iAlumni
//
//  Created by Adam on 13-9-6.
//
//

#import "FlatTableCell.h"
#import <QuartzCore/QuartzCore.h>

@interface FlatTableCellBackgroundView : UIView
@property (nonatomic, assign) FlatTableCell *cell;
@property (nonatomic, assign) BOOL selected;
@end

@implementation FlatTableCellBackgroundView

#pragma mark - life cycle methods
- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.contentMode = UIViewContentModeRedraw;
    
    self.backgroundColor = TRANSPARENT_COLOR;
  }
  
  return self;
}

- (void)dealloc {
  
  self.cell = nil;
  
  [super dealloc];
}

#pragma mark - draw rect
- (CGPathRef)createBackgroundPathWithRect:(CGRect)rect {
  
  if (self.cell.cornerRadius == 0) {
    return [UIBezierPath bezierPathWithRect:rect].CGPath;
  } else {
    
    UIRectCorner corners;
    
    switch (self.cell.position) {
      case FLAT_CELL_TOP_POSITION:
        corners = UIRectCornerTopLeft | UIRectCornerTopRight;
        break;
        
      case FLAT_CELL_MIDDLE_POSITION:
        corners = 0;
        break;
        
      case FLAT_CELL_BOTTOM_POSITION:
        corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
        break;
        
      default:
        corners = UIRectCornerAllCorners;
        break;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:corners
                                                     cornerRadii:CGSizeMake(self.cell.cornerRadius, self.cell.cornerRadius)];
    return path.CGPath;
  }
}

- (void)drawBackgroundWithRect:(CGRect)rect context:(CGContextRef)ctx{
  
  CGContextSaveGState(ctx);
  
  CGPathRef pathRef = [self createBackgroundPathWithRect:rect];
  CGContextAddPath(ctx, pathRef);
  
  CGColorRef backgroundColorRef = [UIColor whiteColor].CGColor;
  if (self.selected) {
    backgroundColorRef = DARK_CELL_COLOR.CGColor;
  }
  
  CGContextSetFillColorWithColor(ctx, backgroundColorRef);
  CGContextFillPath(ctx);
  CGContextRestoreGState(ctx);
}

- (void)drawSeparatorInRect:(CGRect)rect context:(CGContextRef)ctx {
  
  CGContextSaveGState(ctx);
  
  CGFloat y = CGRectGetMinY(rect) + 0.5f;
  
  CGContextMoveToPoint(ctx, CGRectGetMinX(rect) + MARGIN, y);
  CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) - MARGIN, y);
  
  CGContextSetStrokeColorWithColor(ctx, SEPARATOR_LINE_COLOR.CGColor);
  CGContextSetLineWidth(ctx, 0.5f);
  CGContextStrokePath(ctx);
  
  CGContextRestoreGState(ctx);
}

- (void)drawRect:(CGRect)rect {
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  [self drawBackgroundWithRect:rect context:ctx];
  
  if (self.cell.position != FLAT_CELL_TOP_POSITION && self.cell.position != FLAT_CELL_ALONE_POSITION) {
    [self drawSeparatorInRect:rect context:ctx];
  }
}

@end


@implementation FlatTableCell

#pragma mark - life cycle methods
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
  
    self.backgroundColor = TRANSPARENT_COLOR;
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    
    FlatTableCellBackgroundView *bg = [[[FlatTableCellBackgroundView alloc] initWithFrame:self.frame] autorelease];
    bg.selected = NO;
    bg.cell = self;
    self.backgroundView = bg;
    
    bg = [[[FlatTableCellBackgroundView alloc] initWithFrame:self.frame] autorelease];
    bg.selected = YES;
    bg.cell = self;
    self.selectedBackgroundView = bg;
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void) prepareForReuse
{
  [super prepareForReuse];
  [self.backgroundView setNeedsDisplay];
}

- (void)parserCellPositionAtIndexPath:(NSIndexPath *)indexPath elementTotalCount:(NSInteger)elementTotalCount {
  
  if (elementTotalCount == 1) {
    self.position = FLAT_CELL_ALONE_POSITION;
  } else {
    
    if (indexPath.row == 0) {
      self.position = FLAT_CELL_TOP_POSITION;
    } else if (indexPath.row == elementTotalCount - 1) {
      self.position = FLAT_CELL_BOTTOM_POSITION;
    } else {
      self.position = FLAT_CELL_MIDDLE_POSITION;
    }
  }
  
}


@end
