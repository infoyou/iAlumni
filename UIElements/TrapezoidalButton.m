//
//  TrapezoidalButton.m
//  iAlumni
//
//  Created by Adam on 12-8-29.
//
//

#import "TrapezoidalButton.h"
#import <QuartzCore/QuartzCore.h>

#define TOP_BOTTOM_RATIO  7.0f / 8.0f


// It's best to reference the visual guide to the path of the tab.
// See the Docs/tab-analysis.png file.
// The view width is divided into 4 horizontal sections.
// Each section is divided by a 20 x 16 grid.
// The control points were visually laid out atop this grid.
#define kHorizontalSectionCount           4
#define kGridWidthInSection               16
#define kGridHeight                       20
#define kTabHeightInGridUnits             17
#define kBottomControlPointDXInGridUnits  8
#define kBottomControlPointDYInGridUnits  1
#define kTopControlPointDXInGridUnits     10


@interface TrapezoidalButton()

@end

@implementation TrapezoidalButton

@synthesize color = _color;

- (id)initWithFrame:(CGRect)frame
     topBorderShort:(BOOL)topBorderShort
              title:(NSString *)title
          titleFont:(UIFont *)titleFont
         titleColor:(UIColor *)titleColor
    backgroundColor:(UIColor *)backgroundColor
             target:(id)target
             action:(SEL)action {
    
  self = [super initWithFrame:frame];
  if (self) {
    
    _topShort = topBorderShort;
    
    self.color = backgroundColor;
    
    [self setTitle:title forState:UIControlStateNormal];
    
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    self.titleLabel.font = titleFont;
    self.titleLabel.shadowColor = [UIColor whiteColor];
    self.titleEdgeInsets = UIEdgeInsetsMake(MARGIN, 0, 0, 0);
    
    [self addTarget:target
             action:action
   forControlEvents:UIControlEventTouchUpInside];

  }
  return self;
}

- (void)dealloc {
  
  self.color = nil;
  
  [super dealloc];
}

- (void)addShadow:(CGFloat)topBorderLength
        topStartX:(CGFloat)topStartX
bottomBorderLength:(CGFloat)bottomBorderLength
     bottomStartX:(CGFloat)bottomStartX {
  
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  [shadowPath moveToPoint:CGPointMake(topStartX, 0.0f)];
  [shadowPath addLineToPoint:CGPointMake(topStartX + topBorderLength, 0.0f)];
  [shadowPath addLineToPoint:CGPointMake(bottomStartX, self.frame.size.height)];
  [shadowPath addLineToPoint:CGPointMake(bottomStartX - bottomBorderLength, self.frame.size.height)];
  [shadowPath addLineToPoint:CGPointMake(topStartX, 0.0f)];
  
  self.layer.shadowPath = shadowPath.CGPath;
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOpacity = 0.5f;
  self.layer.shadowOffset = CGSizeMake(0, 0);
  self.layer.shadowRadius = 2.0f;
  self.layer.masksToBounds = NO;
}

- (CGFloat)_sectionWidth {
  return self.frame.size.width / kHorizontalSectionCount;
}

- (CGSize)_gridSize {
  return CGSizeMake([self _sectionWidth] / kGridWidthInSection,
                    self.frame.size.height / kGridHeight);
}

- (CGRect)_tabRect {
  CGFloat tabHeight = [self _gridSize].height * kTabHeightInGridUnits;
  return CGRectMake(0, self.frame.size.height - tabHeight + 0.5,
                    self.frame.size.width - 0.5, tabHeight);
}

- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
    
  CGFloat sectionWidth = [self _sectionWidth];
  CGSize  gridSize     = [self _gridSize];
  CGRect  tabRect      = [self _tabRect];

  CGFloat tabLeft   = tabRect.origin.x + 0.5;
  CGFloat tabRight  = tabRect.origin.x + tabRect.size.width - 0.5;
  CGFloat tabTop    = tabRect.origin.y + 0.5;
  CGFloat tabBottom = tabRect.origin.y + tabRect.size.height - 0.5;
  
  CGFloat bottomControlPointDX = gridSize.width  * kBottomControlPointDXInGridUnits;
  CGFloat bottomControlPointDY = gridSize.height * kBottomControlPointDYInGridUnits;
  CGFloat topControlPointDX    = gridSize.width  * kTopControlPointDXInGridUnits;
  
  CGMutablePathRef path = CGPathCreateMutable();
  
  CGPathMoveToPoint(path, NULL, tabLeft, tabBottom);
  
  CGPathAddCurveToPoint(path, NULL,
                        bottomControlPointDX, tabBottom - bottomControlPointDY,
                        sectionWidth - topControlPointDX, tabTop,
                        sectionWidth, tabTop);
  
  CGPathAddLineToPoint(path, NULL, tabRight - sectionWidth, tabTop);
  
  CGPathAddCurveToPoint(path, NULL,
                        tabRight - sectionWidth + topControlPointDX, tabTop,
                        tabRight - bottomControlPointDX, tabBottom - bottomControlPointDY,
                        tabRight, tabBottom);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGFloat locations[] = { 0.0, 0.4 };
  
  CGColorRef tabColor = self.color.CGColor;
  
  CGColorRef startColor = [UIColor whiteColor].CGColor;
  CGColorRef endColor   = tabColor;
  NSArray    *colors    = @[(id)startColor, (id)endColor];
  
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
  
  CGPoint startPoint = CGPointMake(CGRectGetMidX(tabRect), tabRect.origin.y);
  CGPoint endPoint   = CGPointMake(CGRectGetMidX(tabRect), tabRect.origin.y + tabRect.size.height);
  
  // Fill with current tab color
  
  CGContextSaveGState(context);
  CGContextAddPath(context, path);
  CGContextSetFillColorWithColor(context, tabColor);
  CGContextSetShadow(context, CGSizeMake(0, -1), MARGIN);
  CGContextFillPath(context);
  CGContextRestoreGState(context);
  
  // Render the interior of the tab path using the gradient.
  CGContextSaveGState(context);
  CGContextAddPath(context, path);
  CGContextClip(context);
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGContextRestoreGState(context);
  CGGradientRelease(gradient);
  CGColorSpaceRelease(colorSpace);

  CFRelease(path);
  
}


@end
