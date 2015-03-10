//
//  BizGroupIndicatorBar.m
//  iAlumni
//
//  Created by Adam on 13-1-26.
//
//

#import "BizGroupIndicatorBar.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "WXWUIUtils.h"

#define RADIUS  10.0f

#define HIGHTLIGHT_COLOR  COLOR(155,36,36)
#define NORMAL_COLOR      COLOR(112,112,112)

#define SELECTED_INDICATOR_X    90.0f

#define TEXT_COLOR        COLOR(130,130,130)


@implementation BizGroupIndicatorBar

#pragma mark - arrange for page switch

- (void)switchToPageWithIndex:(BizCoopPageIndex)index {
  
  switch (index) {
    case BIZ_1_PAGE_IDX:
    {
      [UIView animateWithDuration:0.2f
                       animations:^{
                         _firstPageIndicator.frame = CGRectOffset(_firstPageIndicator.bounds,
                                                                  SELECTED_INDICATOR_X,
                                                                  _firstPageIndicator.frame.origin.y);
                         _firstPageIndicator.backgroundColor = HIGHTLIGHT_COLOR;
                         _firstNameLabel.frame = CGRectOffset(_firstNameLabel.bounds,
                                                              _firstPageIndicator.frame.origin.x + _firstPageIndicator.frame.size.width + MARGIN,
                                                              _firstNameLabel.frame.origin.y);
                         _firstNameLabel.alpha = 1.0f;
                         _leftArrow.alpha = 0.0f;
                         
                         _secondPageIndicator.frame = CGRectOffset(_secondPageIndicator.bounds,
                                                                   self.frame.size.width - 44 - _secondPageIndicator.frame.size.width/2.0f,
                                                                   _secondPageIndicator.frame.origin.y);
                         _secondPageIndicator.backgroundColor = NORMAL_COLOR;
                         _secondNameLabel.frame = CGRectOffset(_secondNameLabel.bounds,
                                                               _secondPageIndicator.frame.origin.x + _secondPageIndicator.frame.size.width + MARGIN,
                                                               _secondPageIndicator.frame.origin.y);
                         _secondNameLabel.alpha = 0.0f;
                         _rightArrow.alpha = 1.0f;
                       }];
      break;
    }
      
    case BIZ_2_PAGE_IDX:
    {
      [UIView animateWithDuration:0.2f
                       animations:^{
                         _firstPageIndicator.frame = CGRectOffset(_firstPageIndicator.bounds,
                                                                  44 - _firstPageIndicator.frame.size.width/2.0f,
                                                                  _firstPageIndicator.frame.origin.y);
                         _firstPageIndicator.backgroundColor = NORMAL_COLOR;
                         _firstNameLabel.frame = CGRectOffset(_firstNameLabel.bounds,
                                                              _firstPageIndicator.frame.origin.x + _firstPageIndicator.frame.size.width + MARGIN,
                                                              _firstNameLabel.frame.origin.y);
                         _firstNameLabel.alpha = 0.0f;
                         _leftArrow.alpha = 1.0f;
                         
                         _secondPageIndicator.frame = CGRectOffset(_secondPageIndicator.bounds,
                                                                   SELECTED_INDICATOR_X,
                                                                   _secondPageIndicator.frame.origin.y);
                         _secondPageIndicator.backgroundColor = HIGHTLIGHT_COLOR;
                         _secondNameLabel.frame = CGRectOffset(_secondNameLabel.bounds,
                                                               _secondPageIndicator.frame.origin.x + _secondPageIndicator.frame.size.width + MARGIN,
                                                               _secondNameLabel.frame.origin.y);
                         _secondNameLabel.alpha = 1.0f;
                         _rightArrow.alpha = 0.0f;
                       }];
      break;
    }
      
    default:
      break;
  }
  
}


#pragma mark - lifecycle methods
- (WXWLabel *)createLabelIndicator:(NSInteger)index {
  WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:[UIColor whiteColor]
                                         shadowColor:TRANSPARENT_COLOR] autorelease];
  label.font = BOLD_FONT(12);
  label.textAlignment = UITextAlignmentCenter;
  label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
  label.layer.cornerRadius = RADIUS;
  label.layer.masksToBounds = YES;
  
  label.text = INT_TO_STRING(index + 1);
  CGFloat sideLength = RADIUS * 2;
  label.frame = CGRectMake(0, (self.frame.size.height - sideLength)/2.0f, sideLength, sideLength);
  
  return label;
}

- (WXWLabel *)createNameLabel:(NSString *)name {
  WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:TEXT_COLOR
                                         shadowColor:TRANSPARENT_COLOR] autorelease];
  label.font = BOLD_FONT(14);
  label.textAlignment = UITextAlignmentCenter;
  
  label.text = name;
  CGSize size = [label.text sizeWithFont:label.font
                       constrainedToSize:CGSizeMake(self.frame.size.width/2.0f, self.frame.size.height - MARGIN * 2)
                           lineBreakMode:NSLineBreakByWordWrapping];
  label.frame = CGRectMake(0,
                           (self.frame.size.height - size.height)/2.0f,
                           size.width, size.height);
  
  return label;
}

- (void)addArrows {
  _leftArrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_arrow.png"]] autorelease];
  _leftArrow.frame = CGRectMake(MARGIN * 2,
                                (self.frame.size.height - _leftArrow.frame.size.height)/2.0f,
                                _leftArrow.frame.size.width,
                                _leftArrow.frame.size.height);
  [self addSubview:_leftArrow];
  _leftArrow.alpha = 0.0f;
  
  _rightArrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_arrow.png"]] autorelease];
  _rightArrow.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - _rightArrow.frame.size.width, (self.frame.size.height - _rightArrow.frame.size.height)/2.0f, _rightArrow.frame.size.width, _rightArrow.frame.size.height);
  [self addSubview:_rightArrow];

}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = COLOR(219, 219, 219);
    
    _firstPageIndicator = [self createLabelIndicator:BIZ_1_PAGE_IDX];
    _firstPageIndicator.frame = CGRectMake(SELECTED_INDICATOR_X,
                                           _firstPageIndicator.frame.origin.y,
                                           _firstPageIndicator.frame.size.width,
                                           _firstPageIndicator.frame.size.height);
    _firstPageIndicator.backgroundColor = HIGHTLIGHT_COLOR;
    [self addSubview:_firstPageIndicator];
    
    _firstNameLabel = [self createNameLabel:LocaleStringForKey(NSPublicDiscussGroupTitle, nil)];
    _firstNameLabel.frame = CGRectMake(_firstPageIndicator.frame.origin.x + _firstPageIndicator.frame.size.width + MARGIN, _firstNameLabel.frame.origin.y, _firstNameLabel.frame.size.width, _firstNameLabel.frame.size.height);
    [self addSubview:_firstNameLabel];
    
    _secondPageIndicator = [self createLabelIndicator:BIZ_2_PAGE_IDX];
    _secondPageIndicator.frame = CGRectMake(self.frame.size.width - 44 - _secondPageIndicator.frame.size.width/2.0f,
                                            _secondPageIndicator.frame.origin.y,
                                            _secondPageIndicator.frame.size.width,
                                            _secondPageIndicator.frame.size.height);
    _secondPageIndicator.backgroundColor = NORMAL_COLOR;
    [self addSubview:_secondPageIndicator];
    
    _secondNameLabel = [self createNameLabel:LocaleStringForKey(NSClubAndBranchGroup, nil)];
    _secondNameLabel.frame = CGRectMake(_secondPageIndicator.frame.origin.x + _secondPageIndicator.frame.size.width + MARGIN, _secondPageIndicator.frame.origin.y, _secondNameLabel.frame.size.width, _secondNameLabel.frame.size.height);
    _secondNameLabel.alpha = 0.0f;
    [self addSubview:_secondNameLabel];
    
    [self addArrows];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - draw
- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [WXWUIUtils draw1PxStroke:context
                 startPoint:CGPointMake(0, self.frame.size.height - 0.5f)
                   endPoint:CGPointMake(self.frame.size.width, self.frame.size.height - 0.5f)
                      color:COLOR(183, 181, 181).CGColor
               shadowOffset:CGSizeMake(0, 0)
                shadowColor:TRANSPARENT_COLOR];
}

@end
